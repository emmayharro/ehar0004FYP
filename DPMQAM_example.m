%16QAM example
clear all;
close all;
clc;

addpath DSP_stack_modules

M=4;       %'M'-ary QAM
baud=12.5;    %symbol rate [Gbaud]
DACrate=80; %transmitter DAC sampling rate [GSa/s]
Npilots=1024;   %number of pilot symbols for equalizer initialization



%% Generate signals
Gen_PM_MQAM_RRCshaped_multiband(M,baud,DACrate,0.1); %generate signals

for i=[1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 1e7, 1e8]
%% Read in data files

%read in I & Q in both pols
[XI,XQ,YI,YQ]=import_data_files();

%load various parameters to do with signal
cd data_files
load('tmp_transmit_data.mat');
cd ..

% %% Read in waveforms from scope
% scope_obj = instr_initializeScope('follower','TCPIP','ni');
% fprintf(scope_obj,'ACQ:SRAT?');ADCrate=str2num(fscanf(scope_obj)); %scope sampling rate
% 
% [k,XI,XQ,YI,YQ] = instr_getData(scope_obj);


%% Rebuild fields

%orthoganlization
[XI, XQ] = func_hybridIQcomp(XI, XQ);
[YI, YQ] = func_hybridIQcomp(YI, YQ);

%build fields
Ex=XI+1i*XQ; %construct x-pol field
Ey=YI+1i*YQ; %construct y-pol field

% Plot x-pol optical power spectrum
% figure
% plot(20*log10(abs(fftshift(fft(Ex)))))
% title('initial x-pol signal spectrum')
% figure
% plot(Ex,'.')
% xlim([-10 10])
% ylim([-10 10])

%% add impariments
f_samp=DACrate; %define the sampling rate used for the fields Ex & Ey [GHz]

%DC offset
dc_off=0.02; %residual carrier leakage due to limited extinction ratio. 
Ex=Ex./sqrt(mean(abs(Ex).^2))+dc_off; %add DC offset to x-pol
Ey=Ey./sqrt(mean(abs(Ey).^2))+dc_off; %add DC offset to y-pol

% figure(1000)
% plot(real(Ex))

%frequency offset
f_off = 0.01; % offset frequency [GHz]
[Ex,Ey] = impair_freqOffset(Ex,Ey,f_samp,f_off); %add a frequency offset

%phase noise
linewidth = i; %combined linewidth (2x laser linewidth spec.) [Hz]
disp(['Laser linewidth: ' num2str(linewidth) 'Hz'])
[Ex,Ey] = impair_phaseNoise(Ex,Ey,f_samp.*1e9,linewidth);

%OSNR
OSNR = 20; %OSNR [dB]
[Ex,Ey] = impair_OSNR(Ex,Ey,f_samp,OSNR); %load in optical noise

%Reciever resample
ADCrate=80; %receiver sampling emulation [GSa/s] 
Ex=resample(Ex,ADCrate*1000,DACrate*1000);
Ey=resample(Ey,ADCrate*1000,DACrate*1000);

% figure(1)
% plot(20*log10(abs(fftshift(fft(Ex)))))
% figure(11)
% plot(Ex,'.')
%% receiver-side DSP

%resample to 2 Sa/symb
Ex=resample(Ex,2*baud*1e3,ADCrate*1e3);
Ey=resample(Ey,2*baud*1e3,ADCrate*1e3);
% figure(2)
% plot(Ex,'.')

%chromatic dispersion compensation
f_samp=2*baud*1e9; %sampling frequnecy [Hz]
Ex=func_DispComp_OverlapAdd(f_samp,0,Ex); %assumes D=16 ps/(nm.km). In lab ~17.6 ps/(nm.km)
Ey=func_DispComp_OverlapAdd(f_samp,0,Ey);
% figure(3)
% plot(Ex,'.')

%peak-search frequency offset compensation
[Ex,Ey] = func_FreqOffsetComp4th(f_samp/1e9,Ex,Ey);  %sampling freq in GHz ...
% figure(4)
% plot(Ex,'.')

%'matched' filter
rrc = fdesign.pulseshaping(2,'Square Root Raised Cosine','Ast,Beta',Att_stop,Beta);
rrc_filter = design(rrc);
Ex = filter(rrc_filter,Ex);
Ey = filter(rrc_filter,Ey);

%synchronize to packet preamble, and truncate to single packet
samples = 8000;
sample_length = length(dataX)*2-500;
[start] = func_synch_2pol(synch, 2, samples,  0, Ex, Ey);
Ex = Ex(start:start-1+sample_length);
Ey = Ey(start:start-1+sample_length);

%Dynamic equalizer
FFE_length = 41;    %# of taps in FIR filter [int]
mu = 5e-5;          %\mu - error step size (<<1)
%pre-convergence with CMA or LMS
[Hxx,Hyy,Hxy,Hyx,Ex_0,Ey_0] = MIMO_FIR_CMA(Ex, Ey, mu, FFE_length); % CMA
[Hxx,Hyx,Hxy,Hyy,Ex,Ey] = MIMO_MR_CMA_MQAM(Ex, Ey, M, mu, FFE_length, Hxx, Hyx, Hxy, Hyy); % MR-CMA

% figure(6);
% plot(20*log10(abs(fftshift(fft(Hxx)))),'b');
% hold on
% plot(20*log10(abs(fftshift(fft(Hyy)))),'k');
% plot(20*log10(abs(fftshift(fft(Hxy)))),'r');
% plot(20*log10(abs(fftshift(fft(Hyx)))),'g');
% hold off;

% figure(60)
% plot(Ex,'.')

%synch to data pattern
[Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e4);

%Training-based max. liklihood phase recovery
[Ex,Ey] = func_phaseComp_ML(Ex,Ey,pix,piy,16,0);

%% Signal performance metrics

%synch to data pattern
[Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e4);

%calculate perfromance metrics
[BERx,Qx]=BERQ_MQAM(Ex,pix,M);
[BERy,Qy]=BERQ_MQAM(Ey,piy,M);

%let's print them out on screen
disp(['BER, x-pol: ' num2str(BERx)])
%disp(['BER, y-pol: ' num2str(BERy)])
disp(['Q^2, x-pol: ' num2str(Qx) ' dB'])
%disp(['Q^2, y-pol: ' num2str(Qy) ' dB'])

% and here is the final processed constellation.
% figure(7)
% plot(real(Ex),imag(Ex),'.')
% title('signal constellation after reciever-side DSP')
% axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])
% 
% figure(8)
% plot(20*log10(abs(fftshift(fft(Ex)))))
% title('final x-pol signal spectrum')

end