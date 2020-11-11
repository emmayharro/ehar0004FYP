%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Final Year Project                              %
%                               2020                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by: Emily Harrison (ID: 28761537)
% Supervised by: Dr Bill Corcoran

% PROJECT AIM: produce an optical communications system that uses Optical
% Injection Locking to improve the reliability of the system

% THE PROJECT focuses on M-QAM signals, where M is between 4 and 256. It
% uses linewidths ranging from 1kHz to 10MHz. Transmission speeds are
% between 100Gbps and 1Tbps over distances up to 5000km.

% THIS SCRIPT is the main working file for the first part of the project,
% in which a digital brick-wall filter is used in place of injection
% locking to help define parameter spaces and expected output ranges.

%% Housekeeping
% Clear workspace and command window and close all figures. Add the folder
% containing the required functions to the execution path. Start timer.

clear all; close all; clc;
choose_Plot = 0;            % Set to 1 to display figures, set to 2 to also display every constellation
tic
addpath DSP_stack_modules

%% Signal Parameters
% Define the parameters that will be constant for every execution.
% Equipment
DAC_rate = 200;      % Transmitter DAC sampling rate [GSa/s]. Must match AWG in lab
ADC_rate = 200;      % Receiver ADC sampling rate [GSa/s].

% Signal Generation
Baud = 40;          % Symbol rate [Gbaud]
Beta = 0.025;       % Roll-off factor of RRC shaping filter used
Att_stop = 25;      % Stop band attenuation of RRC shaping filter [dB]
gap = 1;            % clear gap between bands [GHz] can increase to 2GHz if want
sep_fact = 1.05;    % Separation factor (sub-bands are separated by baud*sep_fact)
DC_fact = 0.01;     % Small DC addition to each sub-band (useful for freq. offset)
tone_fact = 0.1;    % Tone field amplitude as a fraction of the RMS signal field strength.
Nsc = 2;            % Number of sub-bands to be generated.

% Impairments
dc_off = 0.1;       % DC Offset - residual carrier leakage due to limited extinction ratio.
f_off = 0.045;      % Offset frequency [GHz]
OSNR = 40;          % Optical Signal-to-Noise Ratio [dB]
%distance = 0;       % Distance over which system is transmitted [km]

% Brick-Wall Filters
HPF = dsp.HighpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.5,'PassbandFrequency', 0.75,'StopbandAttenuation', 80);
LPF = dsp.LowpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.75, 'PassbandFrequency', 0.5, 'StopbandAttenuation', 80);
HPF_1 = dsp.HighpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.5,'PassbandFrequency', 1,'StopbandAttenuation', 80);
LPF_1 = dsp.LowpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 1, 'PassbandFrequency', 0.5, 'StopbandAttenuation', 80);

% Dynamic Equaliser
FFE_length = 41;    % # of taps in FIR filter [int]
mu = 1e-4;          % \mu - error step size (<<1)

%% Initialise Signals
for M = 4%[4,16,64] % M-QAM Level
    fprintf("\nM = %d\n",M)
    
    % Generate signals
    % Generates a set of data files, which could uploaded to the AWG
    Gen_PM_MQAM_RRCshaped_2band_centre(M, Baud, DAC_rate, Beta, Att_stop, gap, sep_fact, DC_fact, tone_fact);
    
    % Read in data files
    % Read in I & Q in both polarisations
    [XI,XQ,YI,YQ] = import_data_files();
    % Resample to correct rates
    XI = resample(XI,ADC_rate*1e3,DAC_rate*1e3);
    XQ = resample(XQ,ADC_rate*1e3,DAC_rate*1e3);
    YI = resample(YI,ADC_rate*1e3,DAC_rate*1e3);
    YQ = resample(YQ,ADC_rate*1e3,DAC_rate*1e3);
    
    % Load additional parameters related to signal
    cd data_files
    load('tmp_transmit_data.mat');
    cd ..
    
    DataX = dataX;      % Duplicate data to avoid overwriting
    DataY = dataY;
    baud = Baud/Nsc;    % Adjust symbol rate [Gbaud]
    
    % **********
    f_shifts = dfs;
    sc_sels = 1:Nsc;
    
    % Simulations are repeated over a range of linewidths to observe effect. Linewidth is a signal impairment.
    %for linewidth = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8] %[Hz]
    linewidth = 1e3%[1e3, 1e4, 1e5, 1e6, 1e7, 1e8]
    fprintf("Laser linewidth: %d Hz\n", linewidth)
    distance = 1%[1, 5, 10, 50, 70, 90, 95, 100, 500, 1000, 5000]
    fprintf("%d km\n",distance)
    %% Working with individual sub-bands
    for ii = 1:length(sc_sels)
        sc_sel = sc_sels(ii);
        f_shift = f_shifts(ii); % Shift frequency [GHz]
        
        %% Rebuild fields
        % Almost every function from now on has to performed twice - once for each polarisation
        % Orthoganlization
        [XI, XQ] = func_hybridIQcomp(XI, XQ);
        [YI, YQ] = func_hybridIQcomp(YI, YQ);
        % Build fields
        Ex = XI+1i*XQ;      %construct x-pol field
        Ey = YI+1i*YQ;      %construct y-pol field
        
        if (choose_Plot > 0)
            % Plot x-pol optical power spectrum
            figure(11)
            plot(linspace(-DAC_rate/2,DAC_rate/2,length(XI)),20*log10(abs(fftshift(fft(Ex)))))
            title('Initial x-pol signal spectrum received')
            % add axis labels
            if (choose_Plot == 2)
                % Plot x-pol constellation
                figure(10)
                plot(Ex,'.','DisplayName','Initial')
                title('x constellation')
                xlim([-4 4])
                ylim([-4 4])
                % add axis labels
                legend
            end
        end
        
        % Retrieve sent data
        dataX = DataX(sc_sel,:);
        dataY = DataY(sc_sel,:);
        
        %% Add Impariments
        % Signals generated in software should be perfect, so
        % impairments need to be added to simulate effects that occur
        % in real optical communication systems
        
        f_samp = ADC_rate;   %sampling rate in Ga/st=(1:length(Ex))./ADCrate;
        Ex = Ex./sqrt(mean(abs(Ex).^2))+dc_off;             %add DC offset to x-pol
        Ey = Ey./sqrt(mean(abs(Ey).^2))+dc_off;             %add DC offset to y-pol
        [Ex,Ey] = impair_phaseNoise(Ex,Ey,f_samp.*1e9,linewidth);
        [Ex,Ey] = impair_freqOffset(Ex,Ey,f_samp,f_off);    %add a frequency offset
        [Ex,Ey] = impair_OSNR(Ex,Ey,f_samp,OSNR);           %load in optical noise
        
        if (choose_Plot > 0)
            figure(2)
            plot(linspace(-ADC_rate/2,ADC_rate/2,length(Ex)),20*log10(abs(fftshift(fft(Ex)))))
            title('Impaired x-pol signal spectrum')
            if (choose_Plot == 2)
                figure(10)
                hold on
                plot(Ex,'.','DisplayName','Impaired')
                hold off
            end
        end
        
        %% Receiver-side DSP
        % Peak-search frequency offset compensation to centre on central tone
        [Ex,Ey] = func_FreqOffsetComp(f_samp/1e9,Ex,Ey);  %sampling freq in GHz
        
        %% Lorentzian
         y = 0.1; %HWHM
         x0 = 0; %centre
         F = linspace(-100, 100, length(Ex));
         I = 1; %height - does this matter??
         A = I*(y^2./((F-x0).^2+y^2));

        filte = fft(Ex).*A';
        
%           t=(1:length(Ex))./ADC_rate; %time [ns]
%           f=linspace(-ADC_rate/2,ADC_rate/2,length(t));
%           figure(50+ii)
%          plot(f,filter)
        
        Ex_LP = ifft(filte);
        
        
        HP = I-A;
HPF = fft(Ex).*HP';
           
%           t=(1:length(Ex))./ADC_rate; %time [ns]
%           f=linspace(-ADC_rate/2,ADC_rate/2,length(t));
%           figure(52+ii)
%          plot(f,HPF)   
        Ex_HP = ifft(HPF);
        
        LP = designfilt('arbmagfir', 'FilterOrder', 800, 'Frequencies', F, ...
            'Amplitudes', exp(A-I), 'SampleRate', 200, ...
           'DesignMethod', 'ls');
        %fvtool(LP)
        A = I-I*(y^2./((F-x0).^2+y^2));
        HP = designfilt('arbmagfir', 'FilterOrder', 800, 'Frequencies', F, ...
            'Amplitudes', exp(I-A-I), 'SampleRate', 200, ...
            'DesignMethod', 'ls');
%         %fvtool(HP)
%         %
        Ex_HP1 = filter(HP,Ex);
        Ex_LP1 = filter(LP,Ex);
        %                 if ii ==1
        %                 t=(1:length(Ex))./ADC_rate; %time [ns]
        %                 f=linspace(-ADC_rate/2,ADC_rate/2,length(t));
        %                 figure(50)
        %                 plot(f,20*log10(abs(fftshift(fft(Ex)))))
        %                 hold on
        %                 plot(f,20*log10(abs(fftshift(fft(E_x)))))
        %                 end
        
        Ex1 = Ex_HP.*exp(-1i*angle(Ex_LP));
        Ex2 = Ex_HP1.*exp(-1i*angle(Ex_LP1));
        

    end
end
        same = (Ex1 - Ex2);
        same((same < 1e-5 + 1i*1e-5)&(same > -1e-5 - 1i*1e-5)) = 0;
        samelog = (same ~= 0);
        samelog(samelog == 0) = [];


