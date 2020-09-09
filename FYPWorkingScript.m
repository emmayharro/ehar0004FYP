%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Final Year Project                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Written by: Emily Harrison (ID: 28761537)
% Supervised by: Dr Bill Corcoran

% This script shall generate M-QAM signals for digital processing, where M
% is between 4 and 256.

close all; clear all; clc;

% add the DSP Stack of Modules for use
addpath DSP_stack_modules

% Define Parameters
%signal
M = 16;           %'M'-ary QAM
baud = 12.5;      %symbol rate [Gbaud]
Nsc = 2;          %number of sub-bands to be generated.
sep_fact = 1.05;  %separation factor (sub-bands are separated by baud*sep_fact)
DC_fact = 0.01;   %small DC addition to each sub-band (useful for freq. offset)

%equipment
DACRate = 64;     %transmitter DAC sampling rate [GSa/s]

%shaping
Beta = 0.025;     %roll-off factor of RRC shaping filter used
Att_stop = 25;    %stop band attenuation of RRC shaping filter [dB]

%carrier
tone_fact = 0.1;  %tone field amplitude as a fraction of the RMS signal field strength.
gap = 1;          %clear gap between bands [GHz]

%% Generate Signals
Gen_PM_MQAM_RRCshaped_multiband(M,baud,DACRate,0.1); %generate signals


%% Read in data files
%read in I & Q in both polarizations
[XI,XQ,YI,YQ]=import_data_files();

%load various parameters to do with signal
cd data_files
load('tmp_transmit_data.mat');
cd ..

%% Rebuild fields & perform front-end compensation
%orthoganlization
[XI, XQ] = func_hybridIQcomp(XI, XQ);
[YI, YQ] = func_hybridIQcomp(YI, YQ);

%build fields
Ex=XI+1i*XQ; %construct x-pol field
Ey=YI+1i*YQ; %construct y-pol field

% Plot x-pol optical power spectrum
figure(1)
plot(linspace(-DACRate/2,DACRate/2,length(XI)),20*log10(abs(fftshift(fft(Ex)))))
title('initial x-pol signal spectrum')
figure(2)
plot(Ex,'.')
title('initial x constellation')
xlim([-10 10])
ylim([-10 10])

%% Add Impairments
% These are variable and are required to imitate accurately a real optical
% communications system.
% Any filter or technique developed/used should be effective over ranges of
% these impairments.
fs = DACRate; %(GHz)

dc_off = 0.01;      % DC Offset 
freq_off = 0.01;    % Frequency Offset
linewidth = 1e3;    % Laser Linewidth that contributes to Phase Noise (Hz)
OSNR = 20;           % Optical Signal to Noise Ratio (dB)
ADCRate = 40;       % Receiver Resample Rate (GSa/s)

% apply the impairments:
Ex=Ex./sqrt(mean(abs(Ex).^2))+dc_off;               %add DC offset to x-pol
Ey=Ey./sqrt(mean(abs(Ey).^2))+dc_off;               %add DC offset to y-pol
[Ex,Ey] = impair_freqOffset(Ex,Ey,fs,freq_off);     %add frequency offset
[Ex,Ey] = impair_phaseNoise(Ex,Ey,fs.*1e9,linewidth); %add phase noise
[Ex,Ey] = impair_OSNR(Ex,Ey,fs,OSNR);               %load in optical noise
Ex=resample(Ex,ADCRate*1000,DACRate*1000);          % emulate receiver side sampling
Ey=resample(Ey,ADCRate*1000,DACRate*1000);          % emulate reciever side sampling

figure(3)
plot(20*log10(abs(fftshift(fft(Ex)))))
title ('impaired x-pol signal spectrum')
figure(4)
plot(Ex,'.')
xlim([-10 10])
ylim([-10 10])
title('imparied x-pol signal constellation')

%% Receiver Side DSP
% Trying to recover our signal using existing methods

% Resample at 2 samples/symbol
Ex=resample(Ex,2*baud*1e3,ADCRate*1e3);
Ey=resample(Ey,2*baud*1e3,ADCRate*1e3);
figure(5)
plot(Ex,'.')
xlim([-10 10])
ylim([-10 10])

% Chromatic Dispersion Compensation
f_samp=2*baud*1e9;                          %sampling frequnecy [Hz] - why 1e9??
Ex=func_DispComp_OverlapAdd(f_samp,5,Ex);   %assumes D=16 ps/(nm.km). 0 indicates 0km
Ey=func_DispComp_OverlapAdd(f_samp,5,Ey);
figure(6)
plot(Ex,'.')
xlim([-10 10])
ylim([-10 10])

%peak-search frequency offset compensation
[Ex,Ey] = func_FreqOffsetComp4th(f_samp/1e9,Ex,Ey);  %sampling freq in GHz ...
figure(7)
plot(Ex,'.')
xlim([-10 10])
ylim([-10 10])

%'matched' filter
rrc = fdesign.pulseshaping(2,'Square Root Raised Cosine','Ast,Beta',Att_stop,Beta);
rrc_filter = design(rrc);
Ex = filter(rrc_filter,Ex);
Ey = filter(rrc_filter,Ey);
figure(7)
plot(Ex,'.')
xlim([-10 10])
ylim([-10 10])

%synchronize to packet preamble, and truncate to single packet
samples = round(8000*baud);
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

figure(8);
plot(20*log10(abs(fftshift(fft(Hxx)))),'b');
hold on
plot(20*log10(abs(fftshift(fft(Hyy)))),'k');
plot(20*log10(abs(fftshift(fft(Hxy)))),'r');
plot(20*log10(abs(fftshift(fft(Hyx)))),'g');
hold off;

figure(80)
plot(Ex,'.')

%synch to data pattern
[Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e4);

%Training-based max. liklihood phase recovery
[Ex,Ey] = func_phaseComp_ML(Ex,Ey,pix,piy,16,0);

%% Signal performance metrics

%synch to data pattern
[Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e3);

%calculate perfromance metrics
[BERx,Qx]=BERQ_MQAM(Ex,pix,M);
[BERy,Qy]=BERQ_MQAM(Ey,piy,M);

%let's print them out on screen
disp(['BER, x-pol: ' num2str(BERx)])
disp(['BER, y-pol: ' num2str(BERy)])
disp(['Q^2, x-pol: ' num2str(Qx) ' dB'])
disp(['Q^2, y-pol: ' num2str(Qy) ' dB'])

% and here is the final processed constellation.
figure(9)
plot(real(Ex),imag(Ex),'.')
title('signal constellation after reciever-side DSP')
axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])


figure(10)
plot(20*log10(abs(fftshift(fft(Ex)))))
title('final x-pol signal spectrum')