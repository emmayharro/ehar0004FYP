%QAM example
clear all;
close all;
clc;
delete(instrfind)

addpath DSP_stack_modules

Npilots=1e3;   %number of pilot symbols for equalizer initialization
%equipment
DACrate=200;
ADCrate=200; %transmitter DAC sampling rate [GSa/s]

%signal
M=4;       %'M'-ary QAM
baud=40;    %symbol rate [Gbaud]
Nsc=2;      %number of sub-bands to be generated.
sep_fact=1.05; %separation factor (sub-bands are separated by baud*sep_fact)
DC_fact=0.01; %small DC addition to each sub-band (useful for freq. offset)

%shaping
Beta=0.025; %roll-off factor of RRC shaping filter used
Att_stop=25; %stop band attenuation of RRC shaping filter [dB]

%carrier
tone_fact=0.1; %tone field amplitude as a fraction of the RMS signal field strength.
gap=1; %clear gap between bands [GHz] can increase to 2GHz if want

OSNR = 40; %OSNR [dB]

% for j=1:100
linewidth = 1e3; %Phase noise - combined linewidth (2x laser linewidth spec.) [Hz] 10MHz then look at FFT lorentzian
% Laser = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8];


% for baud = [40, 80]
%     for M = [4,16,64]
%% Generate signals
Gen_PM_MQAM_RRCshaped_2band_centre(M,baud,DACrate,Beta,Att_stop,gap,sep_fact,DC_fact,tone_fact); %generate signals


    %% Read in data files
    
    %read in I & Q in both pols
    [XI,XQ,YI,YQ]=import_data_files();
    XI=resample(XI,ADCrate*1e3,DACrate*1e3);
    XQ=resample(XQ,ADCrate*1e3,DACrate*1e3);
    YI=resample(YI,ADCrate*1e3,DACrate*1e3);
    YQ=resample(YQ,ADCrate*1e3,DACrate*1e3);
    
    %load various parameters to do with signal
    cd data_files
    load('tmp_transmit_data.mat');
    cd ..
    DataX=dataX;
    DataY=dataY;
    baud=Baud/Nsc;    %symbol rate [Gbaud]
    
    f_shifts=dfs;
    sc_sels=1:Nsc;
    
    for ii=1:length(sc_sels)
        sc_sel=sc_sels(ii);
        f_shift=f_shifts(ii); %shift frequency [GHz]
        %         fprintf("pass %d\n",ii)
        %% Rebuild fields
        %orthoganlization
        [XI, XQ] = func_hybridIQcomp(XI, XQ);
        [YI, YQ] = func_hybridIQcomp(YI, YQ);
        
        % build fields ...
        % ... from files or hybrid
        Ex=XI+1i*XQ; %construct x-pol field
        Ey=YI+1i*YQ; %construct y-pol field
        
        % Plot x-pol optical power spectrum
        % figure(11)
        % plot(linspace(-DACrate/2,DACrate/2,length(XI)),20*log10(abs(fftshift(fft(Ex)))))
        % title('initial x-pol signal spectrum received')
        % figure(10)
        % plot(Ex,'.','DisplayName','Initial')
        % title('x constellation')
        % xlim([-4 4])
        % ylim([-4 4])
        % legend
        
        % get sent data
        dataX=DataX(sc_sel,:);
        dataY=DataY(sc_sel,:);
        
        %% Add Impariments
        f_samp=ADCrate; %sampling rate in Ga/st=(1:length(Ex))./ADCrate; %time [ns]
        t=(1:length(Ex))./f_samp; %time [ns]
        f=linspace(-f_samp/2,f_samp/2,length(t));
        
        dc_off = 0.1; %DC Offset - residual carrier leakage due to limited extinction ratio.
        f_off = 0.045; % offset frequency [GHz]
        %OSNR = 20; %OSNR [dB]
        
        Ex=Ex./sqrt(mean(abs(Ex).^2))+dc_off; %add DC offset to x-pol
        Ey=Ey./sqrt(mean(abs(Ey).^2))+dc_off; %add DC offset to y-pol
        [Ex,Ey] = impair_phaseNoise(Ex,Ey,f_samp.*1e9,linewidth);
        [Ex,Ey] = impair_freqOffset(Ex,Ey,f_samp,f_off); %add a frequency offset
        [Ex,Ey] = impair_OSNR(Ex,Ey,f_samp,OSNR); %load in optical noise
        
        % figure(2)
        % plot(linspace(-ADCrate/2,ADCrate/2,length(Ex)),20*log10(abs(fftshift(fft(Ex)))))
        % title('Impaired x-pol signal spectrum')
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','Impaired')
        % hold off
        
        %% receiver-side DSP
        t=(1:length(Ex))./ADCrate; %time [ns]
        f=linspace(-ADCrate/2,ADCrate/2,length(t));
        
        % peak-search frequency offset compensation to centre on central tone -
        % does this mean FreqOS is where I need to centre my filter?
        [Ex,Ey] = func_FreqOffsetComp(f_samp/1e9,Ex,Ey);  %sampling freq in GHz ...
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','FreqOffComp')
        % hold off
        % figure(12)
        % plot(f,20*log10(abs(fftshift(fft(Ex)))))
        %% remove phase noise
        %employ filter to remove central optical tone centred at 0 before shifting
        % sub-band
        HPF = dsp.HighpassFilter('SampleRate', f_samp, 'StopbandFrequency', 0.75,'PassbandFrequency', 1,'StopbandAttenuation', 80);
        LPF = dsp.LowpassFilter('SampleRate', f_samp, 'StopbandFrequency', 1, 'PassbandFrequency', 0.75, 'StopbandAttenuation', 80);
        % fvtool(LPF)
        ExLP = LPF(Ex); %stored as complex a+ib
        EyLP = LPF(Ey);
        %ExLP = Eideal * exp(1i*phase(t)) % phase in radians
        [phase, ideal] = cart2pol(real(ExLP), imag(ExLP));
        [phaseY, idealY] = cart2pol(real(EyLP), imag(EyLP));
        
        ExHP = HPF(Ex);
        [phaseHP, idealHP] = cart2pol(real(ExHP), imag(ExHP));
        EyHP = HPF(Ey);
        [phaseyHP, idealyHP] = cart2pol(real(EyHP), imag(EyHP));
        
        phaseEx = phaseHP-phase;
        [A,B] = pol2cart(phaseEx, idealHP);
        ExHPA = complex(A,B);
        phaseEy = phaseyHP-phaseY;
        [C,D] = pol2cart(phaseEy, idealyHP);
        EyHPA = complex(C,D);
 
        Ex = ExHP.*exp(-1i*angle(ExLP));
        %Ey = EyHP.*exp(-1i*phaseY);
        
        same = (Ex - ExHPA);
        same(same < 1e-10 + 1i*1e-10) = 0;
        samelog = (same ~= 0);
        samelog(samelog == 0) = [];
        
    end