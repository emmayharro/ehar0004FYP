%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dual-polarization QPSK example
% Bill Corcoran, 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Hi!
%
% So this script generates two polarization tributaries of quadrature
% phase shift keying. This is the type of signal used as a 100 Gb/s channel
% in modern coherent optical communication links.
% The idea here is to give you an introduction into using digital signal
% processing to enable signal generation and demodulation at the reciever
% end.
%
% This script is broken up into sections by the '%%' comments. This allows
% you to run the script in sections, to help you understand what's
% happening piece by piece. You can evaluate each section by pressing
% ctrl-enter.

%% housekeeping
% this first bit wipes the workspace, and adds the folder 'modules' to the
% execution path. 'modules' holds a bunch of DSP functions that you'll be
% using.

clear all;
close all;
clc;

addpath DSP_stack_modules

%% Signal parameters
% These are the key signal parameters that you need to enter in. 
%
% The DAC rate is a parameter we use to match the sampling rate of the 
% arbitrary waveform generator (AWG) we use in the lab, and by default 
% should be 64 giga-samples-per-second (GSa/s).
%
% The symbol rate defines how many pulses you send per second, with each
% encoded in four differnt phase states (QPSK - 2 bits/(symbol.pol)) and
% on two polarization modes 'X' and 'Y', giving 4 bits/symbol. Times by the 
% symbol rate and you get the total bit rate

M=4;        %'M'-ary QAM
baud=12.5;    %symbol rate [Gbaud]
DACrate=64; %transmitter DAC sampling rate [GSa/s]

%% Generate signals
% This function takes the parameters you set above and generates a set of
% data files, which we would upload to the AWG (not in this example). There
% are a bunch of optional settings in this function. You can inspect this
% by right clicking on the function and opening it.

Gen_PM_MQAM(M,baud,DACrate); %generate signals


%% Read in data files
% Here, we read in the files we just created, perform front-end
% compensation (orthoganlization) and reconstruct the complex fields.
% 
% In experiment, instead of inporting data files, you would read waveforms 
% in off an oscilloscope. The reciever resample step emulates the change in
% sampling rate between the reciever side scope in the lab and the
% transmitter side AWG.

%read in I & Q in both pols
[XI,XQ,YI,YQ]=import_data_files();

%load various parameters to do with signal
cd data_files
load('tmp_transmit_data.mat','dataX','dataY');
cd ..

%orthoganlization
[XI, XQ] = func_hybridIQcomp(XI, XQ);
[YI, YQ] = func_hybridIQcomp(YI, YQ);

%build fields
Ex=XI+1i*XQ; %construct x-pol field
Ey=YI+1i*YQ; %construct y-pol field

% At any stage you can have a look at what's going on with the signal. Here
% we plot the x-pol constellation ...
figure(1)
plot(Ex,'.')
title('initial x-pol signal constellation')
axis([-3 3 -3 3])

% ... which looks a bit messy. This is becasue we're not sampling at 1
% Sa/symb. and so we also see the transitions between data symbols.
% What we can also plot is the original data x-pol constellation ...
figure(2)
plot(dataX,'o')
title('x-pol data constellation')
axis([-5 5 -5 5])

%... which looks a bit more like a QPSK constellation, right?
% We can also plot the signal x-pol optical power spectrum.
figure(3)
plot(20*log10(abs(fftshift(fft(Ex)))))
title('initial x-pol signal spectrum')

%% add impariments
% Ok, so at this point we have an almost perfect signal. However, in
% reality, there are a bunch of differnt things that impair signals in and
% optical communications system. Note that this is only really useful in
% simulation - in experiment, these effects come for free :).
%
% Here, we emulate limited extinction ratio in the modulator (dc_off),
% laser linewidth (phase noise) and additive noise (OSNR). This allows you
% to model a more 'real' system, to get a good idea as to what you might
% expect in experiment. Additionally, we resample the signal to emulate the
% mismatch between transmitter DAC adn reciever ADC sampling rates.

f_samp=DACrate; %define the sampling rate used for the fields Ex & Ey [GHz]

%DC offset
dc_off=0.00; %residual carrier leakage due to limited extinction ratio. 
Ex=Ex./sqrt(mean(abs(Ex).^2))+dc_off; %add DC offset to x-pol
Ey=Ey./sqrt(mean(abs(Ey).^2))+dc_off; %add DC offset to y-pol

%frequency offset
f_off = 0.21; % offset frequency [GHz]
[Ex,Ey] = impair_freqOffset(Ex,Ey,f_samp,f_off); %add a frequency offset

%phase noise
linewidth = 100e3; %combined linewidth (2x laser linewidth spec.) [Hz]
[Ex,Ey] = impair_phaseNoise(Ex,Ey,f_samp.*1e9,linewidth);

%OSNR
OSNR = 20; %OSNR [dB]
[Ex,Ey] = impair_OSNR(Ex/2,Ey/2,f_samp,OSNR); %load in optical noise

%Reciever resample
ADCrate=40; %receiver sampling emulation [GSa/s] 
Ex=resample(Ex,ADCrate*1000,DACrate*1000);
Ey=resample(Ey,ADCrate*1000,DACrate*1000);

%... and we can plot constellations and spectra at this point.
figure(4)
plot(Ex,'.')
title('imparied x-pol signal constellation')
axis([-2 2 -2 2])

figure(40)
plot(real(Ex),'b')
hold on
plot(imag(Ex),'r')
hold off

figure(5)
plot(20*log10(abs(fftshift(fft(Ex)))))
title('impaired x-pol signal spectrum')

%% receiver-side DSP
% Now we can start to fix up our impaired signal. This includes chromatic
% dispersion compensation, carrier recovery, and equalization.
%
% First, we resample to 2 samples-per-symbol. This is a generally used 
% sampling rate in recievers to ensure efficient data processing.

%resample to 2 Sa/symb
Ex=resample(Ex,2*baud*1e3,ADCrate*1e3);
Ey=resample(Ey,2*baud*1e3,ADCrate*1e3);

% Next, we compensate for a defined amount of chromatic dispersion. This is
% achieved using an overlap-add method to help with computation. Here,
% there is no dispersion, so we set the length for compensation to 0.

%chromatic dispersion compensation
f_samp=2*baud*1e9; %sampling frequnecy [Hz]
Ex=func_DispComp_OverlapAdd(f_samp,0,Ex); %for fibre with D=16 ps/(nm.km)
Ey=func_DispComp_OverlapAdd(f_samp,0,Ey);

% At this point we can use a spectral peak search for frequnecy offset
% compensation. Essentially, this takes an FFT of the field, and looks for
% a peak that corresponds to a residual carrier.

%peak-search frequency offset compensation
[Ex,Ey] = func_FreqOffsetComp4th(f_samp/1e9,Ex,Ey);  %sampling freq in GHz ...

% Here, we use a constant-modulus algorithm to converge the finite-impulse
% response equalizer filter. We also plot the frequnecy domain version of 
% the equalizer filtersm to give you an idea of what's going on with that
% filter function.

%Dynamic equalizer
FFE_length = 21;    %# of taps in FIR filter
mu = 2e-3;          %\mu - error step size
[Hxx,Hyy,Hxy,Hyx,Ex,Ey] = MIMO_FIR_CMA(Ex, Ey, mu, FFE_length); % CMA

figure(6);
plot(20*log10(abs(fftshift(fft(Hxx)))),'b');
hold on
plot(20*log10(abs(fftshift(fft(Hyy)))),'k');
plot(20*log10(abs(fftshift(fft(Hxy)))),'r');
plot(20*log10(abs(fftshift(fft(Hyx)))),'g');
hold off;

figure(60)
plot(Ex,'.')
title('x-pol signal constellation after equalization')

% Next, we perform carrier phase compensation. This phase noise 
% compensation removes random mutual phase drifts between the carrier of 
% the signal and the local oscillator. After this, the signal is ready for 
% bit-error counting to extract BER. I've put in two alternate methods, the
% Viterbi-Viterbi method and a blind phase search algorithm. You notice a
% significant difference in running time ...

% Viterbi-Viterbi (4th-order) phase estimation
Nwin=20;
[Ex,Ey]=func_phaseComp_ViterbiViterbi(Ex,Ey,Nwin);
 
% % blind phase search
% Nwin = 20;
% [Ex,Ey] = func_phaseComp_BlindPhaseSearch(Ex,Ey,2^8,Nwin,4);

% % maximum liklihood, training based
% [Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e4);
% Nwin=20;
% [Ex,Ey] = func_phaseComp_ML(Ex,Ey,pix,piy,Nwin,2);

%% Signal performance metrics
% Finally, we'd like to see how our signal is doing in terms of perfromance
% at the reciever. Can we get back our data? Who knows! Let's find out ...

% Here, we first use cross-correlation of the signal and data to
% synchronize their patterns for error counting

%synch to data pattern
[Ex,Ey,pix,piy] = pattern_sync(Ex,Ey,dataX,dataY,M,1e4);

% BER gives the number of errors over the number of bits, Q is gathered
% from error-vector magnitude.

%calculate perfromance metrics
[BERx,Qx]=BERQ_MQAM(Ex,pix,M);
[BERy,Qy]=BERQ_MQAM(Ey,piy,M);

%let's print them out on screen
disp(['BER, x-pol: ' num2str(BERx)])
disp(['BER, y-pol: ' num2str(BERy)])
disp(['Q^2, x-pol: ' num2str(Qx) ' dB'])
disp(['Q^2, y-pol: ' num2str(Qy) ' dB'])

% and here is the final processed constellation.
figure(7)
plot(real(Ex),imag(Ex),'.')
title('signal constellation after reciever-side DSP')
axis([-4 4 -4 4])

figure(8)
plot(20*log10(abs(fftshift(fft(Ex)))))
title('final x-pol signal spectrum')

% Ok! So that's the full signal generation to reception flow. 
%
% You should be able to change the impariments and effect the quality of 
% the signal, and you can set up sweeps in MATLAB to check things like BER 
% against OSNR and the effect of laser linewidth on system performance.
%
% You can then use this to simulate the performance of the link you plan to
% demonstrate in experiment, and prepare efficient sweeps to make the most
% of your time on the kit.


