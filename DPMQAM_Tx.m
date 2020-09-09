%16QAM example
clear all;
close all;
clc;

addpath DSP_stack_modules

%equipment
DACrate=92; %transmitter DAC sampling rate [GSa/s]

%signal
M=16;       %'M'-ary QAM
baud=40;    %symbol rate [Gbaud]
Nsc=2;      %number of sub-bands to be generated.
sep_fact=1.05; %separation factor (sub-bands are separated by baud*sep_fact)
DC_fact=0.01; %small DC addition to each sub-band (useful for freq. offset)

%shaping
Beta=0.025; %roll-off factor of RRC shaping filter used
Att_stop=25; %stop band attenuation of RRC shaping filter [dB]

%carrier
tone_fact=0.1; %tone field amplitude as a fraction of the RMS signal field strength.
gap=1; %clear gap between bands [GHz]

%% Generate signals
Gen_PM_MQAM_RRCshaped_2band_centre(M,baud,DACrate,Beta,Att_stop,gap,sep_fact,DC_fact,tone_fact); %generate signals

%read in I & Q in both pols
[XI,XQ,YI,YQ]=import_data_files();

%display generated signal spectrum
figure(1)
plot(linspace(-DACrate/2,DACrate/2,length(XI)),20*log10(abs(fftshift(fft(XI+1i*XQ)))))
title('x-pol signal spectrum sent')