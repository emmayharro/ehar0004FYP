%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Final Year Project                              %
%                               2020                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by: Emily Harrison (ID: 28761537)
% Supervised by: Dr Bill Corcoran

% PROJECT AIM: simulate an optical communications system that uses Optical
% Injection Locking to improve the reliability of the system

% THE PROJECT focuses on M-QAM signals, where M is between 4 and 64. It
% uses linewidths ranging from 1kHz to 100MHz.

% THIS SCRIPT is the main working file for the project. It implements an
% optical communications network from generation to recovery and
% quantification of quality with the metrics of Bit Error rate and Quality
% Factor. Optical injection locking is implemented using deterministic
% carrier recovery. This script allows the user to choose between 5
% different filters to implement this. The user can also chosoe whether
% plots are displayed as the code runs.
% The script operates with a series of nested loops to print results for
% all QAM levels and linewidths. BER and Q are only printed, they need to
% be manually transferred to other scripts for plotting.

%% Housekeeping
% Clear workspace and command window and close all figures. Add the folder
% containing the required functions to the execution path. Start timer.

clear all; close all; clc;
addpath DSP_stack_modules

tic                         % Start timer

%% User choices
choose_Plot = 0;            % Set to 1 to display figures, set to 2 to also display every constellation

choose_Phase_Rec = 0;       % Choose desired recovery technique according to below switch statement

fprintf("Selected Additional Phase Recovery Technique:\n")
switch choose_Phase_Rec
    case 0
        fprintf("None; using only only Training-based max. liklihood phase recovery\n")
    case 1
        fprintf("Deterministc carrier recovery using Fragkos Filter\n")
    case 2
        fprintf("Deterministc carrier recovery using Modified Fragkos Filter\n")
    case 3
        fprintf("Deterministc carrier recovery using Jignesh Filter\n")
    case 4
        fprintf("Deterministc carrier recovery using Modified Jignesh Filter\n")
    case 5
        fprintf("Deterministc carrier recovery using filter with full Lorentzian shape\n")
end

%% Signal Parameters
% Define the parameters that will be constant for every execution.
% Equipment
DAC_rate = 200;      % Transmitter DAC sampling rate [GSa/s]. Must match AWG in lab
ADC_rate = 200;      % Receiver ADC sampling rate [GSa/s].

% Signal Generation
Baud = 40;          % Symbol rate [Gbaud]
Beta = 0.025;       % Roll-off factor of RRC shaping filter used
Att_stop = 25;      % Stop band attenuation of RRC shaping filter [dB]
gap = 1;            % clear gap between bands [GHz] - can increase to 2GHz
sep_fact = 1.05;    % Separation factor (sub-bands are separated by baud*sep_fact)
DC_fact = 0.02;     % Small DC addition to each sub-band (useful for freq. offset)
tone_fact = 0.2;    % Tone field amplitude as a fraction of the RMS signal field strength.
Nsc = 2;            % Number of sub-bands to be generated.

% Impairments
dc_off = 0.1;       % DC Offset - residual carrier leakage due to limited extinction ratio.
f_off = 0.045;      % Offset frequency [GHz]
OSNR = 27;          % Optical Signal-to-Noise Ratio [dB]
distance = 0;       % Distance over which system is transmitted [km]

% Dynamic Equaliser
FFE_length = 41;    % # of taps in FIR filter [int]
mu = 1e-4;          % error step size (<<1)

%% Preliminary filter design values
% Fragkos Filter
if choose_Phase_Rec == 1
    wc = gap/35; % aiming for attenuation of -15db at gap frequency
end

% Modified Fragkos Filter
if choose_Phase_Rec == 2
    HPF = dsp.HighpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.5,...
        'PassbandFrequency', 0.75,'StopbandAttenuation', 80);
    LPF = dsp.LowpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.75, ...
        'PassbandFrequency', 0.5, 'StopbandAttenuation', 80);
    HPF_1 = dsp.HighpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.5,...
        'PassbandFrequency', 1,'StopbandAttenuation', 80);
    LPF_1 = dsp.LowpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 1, ...
        'PassbandFrequency', 0.5, 'StopbandAttenuation', 80);   
    if choose_Plot == 1
        h = fvtool(LPF, LPF_1);
        legend(h, 'Low Pass Filter for low linewidth', 'Low Pass Filter for high linewidth')
        h.CurrentAxes.XLim = [0 5];
    end
end

% Lorentzian-based filters
if choose_Phase_Rec >= 3
    y = 0.5;            % HWHM
    x0 = 0;             % Centre
    I = 1;              % Gain
end

%% Initialise Signals
for M = 64%[4,16,64] % M-QAM Level
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
    for linewidth = [1e3, 1e4, 1e5, 2e5, 5e5, 1e6, 2e6, 5e6, 1e7, 2e7, 5e7, 1e8]
        fprintf("Laser linewidth: %d Hz\n", linewidth)
        
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
                figure(1)
                hold on
                plot(linspace(-DAC_rate/2,DAC_rate/2,length(XI)),20*log10(abs(fftshift(fft(Ex)))))
                title('Initial signal spectrum')
                xlabel('Frequency (GHz)')
                ylabel('Power (dB)')
                hold off
                if (choose_Plot == 2)
                    % Plot x-pol constellation
                    figure(10)
                    plot(Ex,'.','DisplayName','Initial')
                    title('x constellation')
                    xlim([-4 4])
                    ylim([-4 4])
                    legend
                end
            end
            
            % Retrieve sent data
            dataX = DataX(sc_sel,:);
            dataY = DataY(sc_sel,:);
            
            %% Add Impariments
            % Signals generated in software should be perfect, so
            % impairments need to be added to simulate effects that occur
            % in real optical communication systems. 
            % The remainder of the code assumes that these impairments 
            % exist and may produce inaccurate results if these functions 
            % are not included.
            
            f_samp = ADC_rate;                                  %sampling rate
            Ex = Ex./sqrt(mean(abs(Ex).^2))+dc_off;             %add DC offset to x-pol
            Ey = Ey./sqrt(mean(abs(Ey).^2))+dc_off;             %add DC offset to y-pol
            [Ex,Ey] = impair_phaseNoise(Ex,Ey,f_samp.*1e9,linewidth);
            [Ex,Ey] = impair_freqOffset(Ex,Ey,f_samp,f_off);    %add a frequency offset
            [Ex,Ey] = impair_OSNR(Ex,Ey,f_samp,OSNR);           %load in optical noise
            
            if (choose_Plot > 0)
                figure(2)
                plot(linspace(-ADC_rate/2,ADC_rate/2,length(Ex)),20*log10(abs(fftshift(fft(Ex)))))
                title('Impaired signal spectrum')
                xlabel('Frequency (GHz)')
                ylabel('Power (dB)')
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
            
            %% Deterministic Recovery imitating Optical Injection Locking
            if choose_Phase_Rec > 0
                if choose_Phase_Rec == 1
                    F = linspace(-ADC_rate/2, ADC_rate/2, length(Ex));
                    LP = 1./(1+1i*F./(wc*2*pi));
                    HP = 1-LP;
                    % Apply filter to data in frequency domain
                    LPFx = fftshift(fft(Ex)).*LP';
                    LPFy = fftshift(fft(Ey)).*LP';
                    Ex_LP = ifft(ifftshift(LPFx));
                    Ey_LP = ifft(ifftshift(LPFy));
                    
                    HPFx = fftshift(fft(Ex)).*HP';
                    HPFy = fftshift(fft(Ey)).*HP';
                    Ex_HP = ifft(ifftshift(HPFx));
                    Ey_HP = ifft(ifftshift(HPFy));
                end
                if choose_Phase_Rec == 2
                    if (linewidth < 2e6)
                        Ex_LP = LPF(Ex);
                        Ey_LP = LPF(Ey);
                        Ex_HP = HPF(Ex);
                        Ey_HP = HPF(Ey);
                    else
                        Ex_LP = LPF_1(Ex);
                        Ey_LP = LPF_1(Ey);
                        Ex_HP = HPF_1(Ex);
                        Ey_HP = HPF_1(Ey);
                    end
                end
                
                if choose_Phase_Rec >= 3
                    % Create Lorentzian shape
                    F = linspace(-ADC_rate/2, ADC_rate/2, length(Ex));
                    A = I * (y^2 ./ ((F - x0).^2 + y^2));
                    if choose_Phase_Rec == 3
                        A(A < 10^(-9/10)) = 0; %-9dB
                    elseif choose_Phase_Rec == 4
                        A(F > gap | F < -gap) = 0;
                    end
                    
                    HP = I-A;
                    
                    % Apply filter to data in frequency domain
                    LPFx = fftshift(fft(Ex)).*A';
                    LPFy = fftshift(fft(Ey)).*A';
                    Ex_LP = ifft(ifftshift(LPFx));
                    Ey_LP = ifft(ifftshift(LPFy));
                    
                    HPFx = fftshift(fft(Ex)).*HP';
                    HPFy = fftshift(fft(Ey)).*HP';
                    Ex_HP = ifft(ifftshift(HPFx));
                    Ey_HP = ifft(ifftshift(HPFy));
                end
                
                % Visualise filtered parts of signal
                if (ii == 1 && choose_Plot == 1)
                    figure(50)
                    hold on
                    plot(f,20*log10(abs(fftshift(fft(Ex_HP)))))
                    plot(f,20*log10(abs(fftshift(fft(Ex_LP)))))
                    legend('High-pass', 'Low-pass')
                    title('Signal FFT')
                    xlabel("Frequency (GHz)")
                    ylabel("Power (dB)")
                    hold off
                end
                
                % Combining high and low pass components
                Ex = Ex_HP.*exp(-1i*angle(Ex_LP));
                Ey = Ey_HP.*exp(-1i*angle(Ey_LP));
                
                if (ii == 1 && choose_Plot == 1)
                    figure(60)
                    hold on
                    plot(f,20*log10(abs(fftshift(fft(Ex)))))
                    xlabel("Frequency (GHz)")
                    ylabel("Power (dB)")
                    hold off
                end
            end
            %% Resume reciever-side DSP
            % Frequency shift to get working sub-band close to baseband
            t = (1:length(Ex))./ADC_rate; %time [ns]
            Ex = Ex.*exp(1i*2*pi*f_shift*t.');
            Ey = Ey.*exp(1i*2*pi*f_shift*t.');
            if (choose_Plot > 0)
                figure(14)
                plot(f,20*log10(abs(fftshift(fft(Ex)))))
                xlabel("Frequency (GHz)")
                ylabel("Power (dB)")
            end
            
            % Resample to 2 Sa/symb
            Ex = resample(Ex,2*baud*1e3,ADC_rate*1e3);
            Ey = resample(Ey,2*baud*1e3,ADC_rate*1e3);
            
            if (choose_Plot > 0)
                t = (1:length(Ex))./2*baud; %time [ns]
                f = linspace(-2*baud/2,2*baud/2,length(t));
                figure(4)
                plot(f,20*log10(abs(fftshift(fft(Ex)))))
                if (choose_Plot == 2)
                    figure(10)
                    hold on
                    plot(Ex,'.','DisplayName','Resample 2Sa/sym')
                    hold off
                end
            end
            
            % Chromatic Dispersion Compensation - Compensate for a defined
            % amount of chromatic dispersion. This is achieved using an
            % overlap-add method to help with computation.
            f_samp = 2*baud*1e9;                                %sampling frequnecy [Hz]
            Ex = func_DispComp_OverlapAdd(f_samp,distance,Ex);  %assumes D=16 ps/(nm.km). In lab ~17.6 ps/(nm.km)
            Ey = func_DispComp_OverlapAdd(f_samp,distance,Ey);
            if (choose_Plot == 2)
                figure(10)
                hold on
                plot(Ex,'.','DisplayName','CDC')
                hold off
            end
            
            % Peak-search frequency offset compensation - At this point we
            % can use a spectral peak search for frequnecy offset
            % compensation. Essentially, this takes an FFT of the field,
            % and looks for a peak that corresponds to a residual carrier.
            [Ex,Ey] = func_FreqOffsetComp(f_samp/1e9,Ex,Ey);  % sampling freq in GHz
            if (choose_Plot == 2)
                figure(10)
                hold on
                plot(Ex,'.','DisplayName','FreqOffComp2')
                hold off
            end
            
            % 'Matched' filter
            rrc = fdesign.pulseshaping(2,'Square Root Raised Cosine','Ast,Beta',Att_stop,Beta);
            rrc_filter = design(rrc);
            Ex = filter(rrc_filter,Ex);
            Ey = filter(rrc_filter,Ey);
            if (choose_Plot == 2)
                figure(10)
                hold on
                plot(Ex,'.','DisplayName','Matched Filter')
                hold off
            end
            
            % Synchronize to packet preamble, and truncate to single packet
            samples = 5000;
            sample_length = length(dataX)*2-5000;
            [start] = func_synch_2pol(synch, 2, samples,  0, Ex, Ey);
            Ex = Ex(start:start-1+sample_length);
            Ey = Ey(start:start-1+sample_length);
            if (choose_Plot > 0)
                t = (1:length(Ex))./2*baud; %time [ns]
                f = linspace(-2*baud/2,2*baud/2,length(t));
                figure(3)
                plot(f,20*log10(abs(fftshift(fft(Ex)))))
                if (choose_Plot == 2)
                    figure(10)
                    hold on
                    plot(Ex,'.','DisplayName','synch_2pol')
                    hold off
                end
            end
            
            % Remove residual DC signal value 
            Ex = Ex-mean(Ex);
            Ey = Ey-mean(Ey);
            Ex = Ex./sqrt(mean(abs(Ex).^2)).*sqrt(2/3*(M-1));
            Ey = Ey./sqrt(mean(abs(Ey).^2)).*sqrt(2/3*(M-1));
            
            %Dynamic equalizer
            % Pre-convergence with CMA
            [Hxx,Hyy,Hxy,Hyx,Ex_0,Ey_0] = MIMO_FIR_CMA(Ex, Ey, mu, FFE_length); % CMA
            if (choose_Plot > 0)
                figure(60);
                plot(20*log10(abs(fftshift(fft(Hxx)))),'b');
                hold on
                plot(20*log10(abs(fftshift(fft(Hyy)))),'k');
                plot(20*log10(abs(fftshift(fft(Hxy)))),'r');
                plot(20*log10(abs(fftshift(fft(Hyx)))),'g');
                hold off;
            end
            [Hxx,Hyx,Hxy,Hyy,Ex,Ey] = MIMO_MR_CMA_MQAM(Ex, Ey, M, mu, FFE_length, Hxx, Hyx, Hxy, Hyy); % MR-CMA
            if (choose_Plot > 0)
                figure(6);
                plot(20*log10(abs(fftshift(fft(Hxx)))),'b');
                hold on
                plot(20*log10(abs(fftshift(fft(Hyy)))),'k');
                plot(20*log10(abs(fftshift(fft(Hxy)))),'r');
                plot(20*log10(abs(fftshift(fft(Hyx)))),'g');
                hold off;
                figure(4)
                plot(20*log10(abs(fftshift(fft(Ex)))))
            end
            
            % Synch to data pattern
            [Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e4);
            if (choose_Plot == 2)
                figure(10)
                hold on
                plot(Ex,'.','DisplayName','Dynamic Equalizer & pattern_synch')
                hold off
            end
            
            % Training-based max. liklihood phase recovery
            [Ex,Ey] = func_phaseComp_ML(Ex,Ey,pix,piy,32,0);
            if (choose_Plot == 2)
                figure(10)
                hold on
                plot(Ex,'.','DisplayName','PhaseComp')
                hold off
            end
            
            trim = 1; %500;%2e4;
            Ex = Ex(trim:end-trim);
            Ey = Ey(trim:end-trim);
            pix = pix(trim:end-trim);
            piy = piy(trim:end-trim);
            if (choose_Plot == 2)
                figure(10)
                hold on
                plot(Ex,'.','DisplayName','Final')
                hold off
            end
            
            %% Signal performance metrics
            % Synch to data pattern again
            [Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,pix,piy,M,1e4);
            
            % Calculate perfromance metrics
            [BER_x,Q_x] = BERQ_MQAM(Ex,pix,M);
            [BER_y,Q_y] = BERQ_MQAM(Ey,piy,M);

            if M == 64
                GMIx=calcGMI_withNormalization(pix(1:length(Ex)),Ex,'gray');
                GMIy=calcGMI_withNormalization(piy(1:length(Ey)),Ey,'gray');
            end
            
            if (ii == 1)
                disp(['BER, mean: ' num2str((BER_x+BER_y)/2)])
                disp(['Q, mean: ' num2str(1/((1/Q_x+1/Q_y)/2))])
                
                if M == 64
                    disp(['GMIx:' num2str(GMIx) ' GMIy:'  num2str(GMIy)])
                end
                
                % and here is the final processed constellation.
                if (choose_Plot > 0)
                    figure(70+ii)
                    clf;
                    scatplot(real(Ex),imag(Ex));
                    title('X-pol signal constellation after reciever-side DSP','FontSize', 16)
                    axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])
                    grid on
                    
                    figure(80+ii)
                    clf;
                    scatplot(real(Ey),imag(Ey));
                    title('Y-pol signal constellation after reciever-side DSP')
                    axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])
                    grid on
                end
                
            end         % if (ii == 1)
        end             % for ii = 1:length(sc_sels)
        clear pix piy;      % need to clear these to run the loops without error
    end                 % for linewidth = [...]
end                     % for M = [4,16,64]

toc                     % end timer
