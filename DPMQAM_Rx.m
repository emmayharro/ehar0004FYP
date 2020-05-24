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
M=64;       %'M'-ary QAM
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
% linewidth = 1e6; %Phase noise - combined linewidth (2x laser linewidth spec.) [Hz] 10MHz then look at FFT lorentzian
% Laser = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8];


% for baud = [40, 80]
%     for M = [4,16,64]
%% Generate signals
Gen_PM_MQAM_RRCshaped_2band_centre(M,baud,DACrate,Beta,Att_stop,gap,sep_fact,DC_fact,tone_fact); %generate signals

%         for OSNR = [20, 40, 100, 200]
%             BER = [1, 2];
%             Q = [1, 2];
for linewidth = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8]
    %linewidth = i;
    fprintf("\nLaser linewidth: %d Hz\n", linewidth)
    %     disp(['\nLaser linewidth: ' num2str(linewidth) 'Hz'])
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
        HPF = dsp.HighpassFilter('SampleRate', f_samp, 'StopbandFrequency', 0.25,'PassbandFrequency', 1.25,'StopbandAttenuation', 80);
        LPF = dsp.LowpassFilter('SampleRate', f_samp, 'StopbandFrequency', 1.25, 'PassbandFrequency', 0.25, 'StopbandAttenuation', 80);
        % fvtool(LPF)
        ExLP = LPF(Ex); %stored as complex a+ib
        EyLP = LPF(Ey);
        %ExLP = Eideal * exp(1i*phase(t))
        [phase, ideal] = cart2pol(real(ExLP), imag(ExLP));
        [phaseY, idealY] = cart2pol(real(EyLP), imag(EyLP));
        
        Ex = HPF(Ex);
        [phaseHP, idealHP] = cart2pol(real(Ex), imag(Ex));
        Ey = HPF(Ey);
        [phaseyHP, idealyHP] = cart2pol(real(Ey), imag(Ey));
        
%         if (ii == 1)
%         figure(50)
%         hold on
%         plot(f,20*log10(abs(fftshift(fft(Ex)))))
%         plot(f,20*log10(abs(fftshift(fft(ExLP)))))
%         hold off
%         end 
        % process ExLP/EyLP
        phaseEx = phaseHP-phase;
        [A,B] = pol2cart(phaseEx, idealHP);
        Ex = complex(A,B);
        phaseEy = phaseyHP-phaseY;
        [C,D] = pol2cart(phaseEy, idealyHP);
        Ey = complex(C,D);
        
        %% reciever side DSP
        %frequency shift to get wanted sub-band close to baseband
        t=(1:length(Ex))./ADCrate; %time [ns]
        Ex=Ex.*exp(1i*2*pi*f_shift*t.');
        Ey=Ey.*exp(1i*2*pi*f_shift*t.');
        
        % figure(14)
        % plot(f,20*log10(abs(fftshift(fft(Ex)))))
        
        %resample to 2 Sa/symb - why?
        Ex=resample(Ex,2*baud*1e3,ADCrate*1e3);
        Ey=resample(Ey,2*baud*1e3,ADCrate*1e3);
        
        % t=(1:length(Ex))./2*baud; %time [ns]
        % f=linspace(-2*baud/2,2*baud/2,length(t));
        % figure(4)
        % plot(f,20*log10(abs(fftshift(fft(Ex)))))
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','Resample 2Sa/sym')
        % hold off
        
        %chromatic dispersion compensation
        f_samp=2*baud*1e9; %sampling frequnecy [Hz]
        Ex=func_DispComp_OverlapAdd(f_samp,0,Ex); %assumes D=16 ps/(nm.km). In lab ~17.6 ps/(nm.km)
        Ey=func_DispComp_OverlapAdd(f_samp,0,Ey);   %'0' is distance
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','CDC')
        % hold off
        
        % peak-search frequency offset compensation
        [Ex,Ey] = func_FreqOffsetComp(f_samp/1e9,Ex,Ey);  %sampling freq in GHz ...
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','FreqOffComp2')
        % hold off
        
        %'matched' filter
        rrc = fdesign.pulseshaping(2,'Square Root Raised Cosine','Ast,Beta',Att_stop,Beta);
        rrc_filter = design(rrc);
        Ex = filter(rrc_filter,Ex);
        Ey = filter(rrc_filter,Ey);
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','Matched Filter')
        % hold off
        
        %synchronize to packet preamble, and truncate to single packet
        samples = 5000;
        sample_length = length(dataX)*2-5000;
        [start] = func_synch_2pol(synch, 2, samples,  0, Ex, Ey);
        Ex = Ex(start:start-1+sample_length);
        Ey = Ey(start:start-1+sample_length);
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','synch_2pol')
        % hold off
        
        t=(1:length(Ex))./2*baud; %time [ns]
        f=linspace(-2*baud/2,2*baud/2,length(t));
        % figure(3)
        % plot(f,20*log10(abs(fftshift(fft(Ex)))))
        
        Ex=Ex-mean(Ex);
        Ey=Ey-mean(Ey);
        Ex=Ex./sqrt(mean(abs(Ex).^2)).*sqrt(2/3*(M-1));
        Ey=Ey./sqrt(mean(abs(Ey).^2)).*sqrt(2/3*(M-1));
        
        %Dynamic equalizer
        FFE_length = 41;    %# of taps in FIR filter [int]
        mu = 1e-4;          %\mu - error step size (<<1)
        sps=2;
        stt=round((FFE_length-1)/(2*sps))+1;
        pix=dataX(stt:stt-1+Npilots);
        piy=dataY(stt:stt-1+Npilots);
        
        %pre-convergence with CMA or LMS
        [Hxx,Hyy,Hxy,Hyx,Ex_0,Ey_0] = MIMO_FIR_CMA(Ex, Ey, mu, FFE_length); % CMA
        % [Hxx,Hyx,Hxy,Hyy,Ex_0,Ey_0] = MIMO_FIR_training_LMS(Ex, Ey, mu, FFE_length,pix,piy,2);
        
        % figure(60);
        % plot(20*log10(abs(fftshift(fft(Hxx)))),'b');
        % hold on
        % plot(20*log10(abs(fftshift(fft(Hyy)))),'k');
        % plot(20*log10(abs(fftshift(fft(Hxy)))),'r');
        % plot(20*log10(abs(fftshift(fft(Hyx)))),'g');
        % hold off;
        
        [Hxx,Hyx,Hxy,Hyy,Ex,Ey] = MIMO_MR_CMA_MQAM(Ex, Ey, M, mu, FFE_length, Hxx, Hyx, Hxy, Hyy); % MR-CMA
        
        % figure(6);
        % plot(20*log10(abs(fftshift(fft(Hxx)))),'b');
        % hold on
        % plot(20*log10(abs(fftshift(fft(Hyy)))),'k');
        % plot(20*log10(abs(fftshift(fft(Hxy)))),'r');
        % plot(20*log10(abs(fftshift(fft(Hyx)))),'g');
        % hold off;
        
        % figure(4)
        % plot(20*log10(abs(fftshift(fft(Ex)))))
        
        %synch to data pattern
        [Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e4);
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','Dynamic Equalizer & pattern_synch')
        % hold off
        
        %Training-based max. liklihood phase recovery
        [Ex,Ey] = func_phaseComp_ML(Ex,Ey,pix,piy,32,0);
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','PhaseComp')
        % hold off
        
        trim=1;%500;%2e4;
        Ex=Ex(trim:end-trim);
        Ey=Ey(trim:end-trim);
        pix=pix(trim:end-trim);
        piy=piy(trim:end-trim);
        % figure(10)
        % hold on
        % plot(Ex,'.','DisplayName','Final')
        % hold off
        
        %% Signal performance metrics
        
        %synch to data pattern
        [Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,pix,piy,M,1e4);
        
        %calculate perfromance metrics
        [BERx,Qx]=BERQ_MQAM(Ex,pix,M);
        [BERy,Qy]=BERQ_MQAM(Ey,piy,M);
        
        %let's print them out on screen
        % disp(['BER, x-pol: ' num2str(BERx)])
        % disp(['BER, y-pol: ' num2str(BERy)])
        % disp(['Q^2, x-pol: ' num2str(Qx) ' dB'])
        % disp(['Q^2, y-pol: ' num2str(Qy) ' dB'])
        
        if (ii ==1)
            disp(['BER, mean: ' num2str((BERx+BERy)/2)])
            disp(['Q^2, mean: ' num2str(1/((1/Qx+1/Qy)/2))])
            %BER = [BER (BERx+BERy)/2];
            %Q = [Q 1/((1/Qx+1/Qy)/2)];
            % and here is the final processed constellation.
            
%             figure(70+ii)
%             clf;
%             % plot(real(Ex),imag(Ex),'.');
%             scatplot(real(Ex),imag(Ex));
%             title('X-pol signal constellation after reciever-side DSP')
%             axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])
%             grid on
%             
%             
%             figure(80+ii)
%             clf;
%             scatplot(real(Ey),imag(Ey));
%             title('Y-pol signal constellation after reciever-side DSP')
%             axis([-sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1 -sqrt(2/3*(M-1))-1 sqrt(2/3*(M-1))+1])
%             grid on
        end
    end
    
end
%             figure(1)
%             axes('XScale', 'log', 'YScale', 'log')
%             hold on
%             name = sprintf('%d-QAM, %d baud, %d OSNR', M, baud, OSNR);
%             plot(Laser, BER(3:end), 'DisplayName', name)
%             hold off
%         end
%     end
% end