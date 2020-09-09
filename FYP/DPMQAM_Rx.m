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
gap = 1;            %clear gap between bands [GHz] can increase to 2GHz if want
sep_fact = 1.05;    % Separation factor (sub-bands are separated by baud*sep_fact)
DC_fact = 0.01;     % Small DC addition to each sub-band (useful for freq. offset)
tone_fact = 0.1;    % Tone field amplitude as a fraction of the RMS signal field strength.
Nsc = 2;            % Number of sub-bands to be generated.

% Impairments
dc_off = 0.1;       % DC Offset - residual carrier leakage due to limited extinction ratio.
f_off = 0.045;      % Offset frequency [GHz]
OSNR = 40;          % Optical Signal-to-Noise Ratio [dB]
distance = 0;       % Distance over which system is transmitted [km]

% Brick-Wall Filters
HPF = dsp.HighpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.5,'PassbandFrequency', 0.75,'StopbandAttenuation', 80);
LPF = dsp.LowpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.75, 'PassbandFrequency', 0.5, 'StopbandAttenuation', 80);
HPF_1 = dsp.HighpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 0.5,'PassbandFrequency', 1,'StopbandAttenuation', 80);
LPF_1 = dsp.LowpassFilter('SampleRate', ADC_rate, 'StopbandFrequency', 1, 'PassbandFrequency', 0.5, 'StopbandAttenuation', 80);

% Dynamic Equaliser
FFE_length = 41;    % # of taps in FIR filter [int]
mu = 1e-4;          % \mu - error step size (<<1)

%% Initialise Signals
for M = [4,16,64] % M-QAM Level
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
    for linewidth = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8] %[Hz]
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
            
            if (choose_Plot > 0)
                t=(1:length(Ex))./ADC_rate; %time [ns]
                f=linspace(-ADC_rate/2,ADC_rate/2,length(t));
                figure(12)
                plot(f,20*log10(abs(fftshift(fft(Ex)))))
                if (choose_Plot == 2)
                    figure(10)
                    hold on
                    plot(Ex,'.','DisplayName','FreqOffComp')
                    hold off
                end
            end
            %% Removing phase noise with brick-wall filters
            % Employ filter to remove the central optical tone centred at 0
            % before shifting the sub-band. There is a more efficient way
            % to implement this, this was my method from first principles.
            % After viewing graphs, it can be seen that the signal quality
            % deteriorates at 2e6Hz, so trying to add extra
            % compensation/recovery only where needed
            if (linewidth < 2e6)
                Ex_LP = LPF(Ex); %stored as complex a+ib
                Ey_LP = LPF(Ey);
            else
                Ex_LP = LPF_1(Ex); %stored as complex a+ib
                Ey_LP = LPF_1(Ey);
            end
            %In theory: ExLP = Eideal * exp(1i*phase(t))
            [phase_X, ~] = cart2pol(real(Ex_LP), imag(Ex_LP));
            [phase_Y, ~] = cart2pol(real(Ey_LP), imag(Ey_LP));
            
            if (linewidth < 2e6)
                Ex = HPF(Ex);
                Ey = HPF(Ey);
            else
                Ex = HPF_1(Ex);
                Ey = HPF_1(Ey);
            end
            [phase_xHP, ideal_xHP] = cart2pol(real(Ex), imag(Ex));
            [phase_yHP, ideal_yHP] = cart2pol(real(Ey), imag(Ey));
            
            if (ii == 1 && choose_Plot == 1)
                figure(50)
                hold on
                plot(f,20*log10(abs(fftshift(fft(Ex)))))
                plot(f,20*log10(abs(fftshift(fft(Ex_LP)))))
                xlabel("Frequency (GHz)")
                ylabel("Power (dB)")
                legend("High-Pass", "Low-Pass")
                hold off
            end
            
            % process ExLP/EyLP
            phase_Ex = phase_xHP-phase_X;
            [A,B] = pol2cart(phase_Ex, ideal_xHP);
            Ex = complex(A,B);
            phase_Ey = phase_yHP-phase_Y;
            [C,D] = pol2cart(phase_Ey, ideal_yHP);
            Ey = complex(C,D);
            
            %% Resume reciever-side DSP
            % Frequency shift to get working sub-band close to baseband
            t = (1:length(Ex))./ADC_rate; %time [ns]
            Ex = Ex.*exp(1i*2*pi*f_shift*t.');
            Ey = Ey.*exp(1i*2*pi*f_shift*t.');
            if (choose_Plot > 0)
                figure(14)
                plot(f,20*log10(abs(fftshift(fft(Ex)))))
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
            
            %****************
            Ex = Ex-mean(Ex);
            Ey = Ey-mean(Ey);
            Ex = Ex./sqrt(mean(abs(Ex).^2)).*sqrt(2/3*(M-1));
            Ey = Ey./sqrt(mean(abs(Ey).^2)).*sqrt(2/3*(M-1));
            
            %Dynamic equalizer
            % Pre-convergence with CMA or LMS
            [Hxx,Hyy,Hxy,Hyx,Ex_0,Ey_0] = MIMO_FIR_CMA(Ex, Ey, mu, FFE_length); % CMA
            %[Hxx,Hyx,Hxy,Hyy,Ex_0,Ey_0] = MIMO_FIR_training_LMS(Ex, Ey, mu, FFE_length,pix,piy,2);
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
            
            trim = 1;%500;%2e4;
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
            % Let's print them out on screen
            % disp(['BER, x-pol: ' num2str(BERx)])
            % disp(['BER, y-pol: ' num2str(BERy)])
            % disp(['Q^2, x-pol: ' num2str(Qx) ' dB'])
            % disp(['Q^2, y-pol: ' num2str(Qy) ' dB'])
            
            if (ii == 1)
                disp(['BER, mean: ' num2str((BER_x+BER_y)/2)])
                disp(['Q^2, mean: ' num2str(1/((1/Q_x+1/Q_y)/2))])
                
                % and here is the final processed constellation.
                if (choose_Plot > 0)
                    figure(70+ii)
                    clf;
                    scatplot(real(Ex),imag(Ex));
                    title('X-pol signal constellation after reciever-side DSP')
                    axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])
                    grid on
                    
                    figure(80+ii)
                    clf;
                    scatplot(real(Ey),imag(Ey));
                    title('Y-pol signal constellation after reciever-side DSP')
                    axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])
                    grid on
                end
            end % if (ii == 1)
        end %for ii = 1:length(sc_sels)
        clear pix piy; % need to clear these to run the loops without error
    end % for linewidth
end % for M = [4,16,64]
toc