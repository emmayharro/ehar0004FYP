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

% THIS SCRIPT 

%% Housekeeping
close all; clear all; clc;

linewidth = [1e3, 1e4, 1e5, 2e5, 5e5, 1e6, 2e6, 5e6, 1e7, 2e7, 5e7, 1e8];

%% From experiment_compare
% 16-QAM
BER16_PC = [0, 0, 0, 1.1741e-05, 1.7611e-05, 0.00012328, 0.00089231, ...
    0.0058529, 0.021462, 0.04859, 0.11288, 0.17105];
BER16_BWs = [0.0016613, 0.0016848, 0.001679, 0.0017494, 0.0020018, 0.0027767, ...
    0.0038041, 0.0074672, 0.015522, 0.031542, 0.072436, 0.11943];
BER16_L9 = [0.00041093, 0.00052247, 0.00046964, 0.00043442, 0.00046377, ...
    0.00055182, 0.00069859, 0.0013091, 0.0022249, 0.0056826, 0.019073, 0.039661];

Q16_PC = [18.5685, 18.5435, 18.4371, 18.5619, 18.0029, 17.5951, 16.8302, ...
    14.9551, 12.902, 10.4971, 7.2805, 4.4792];
Q16_BWs = [16.7636, 16.7139, 16.667, 16.6062, 16.5354, 16.3822, 15.9693, ...
    15.0967, 14.0015, 12.3059, 9.181, 6.904];
Q16_L9 = [17.9237, 17.9074, 17.8933, 17.883, 17.8374, 17.7612, 17.5491, ...
    17.1448, 16.6088, 15.6603, 13.555, 11.5727];

figure(1)
h= semilogx(linewidth, Q16_PC, '-o', linewidth, Q16_BWs,'-d', linewidth, Q16_L9,'-^');
set(h(1), 'linewidth', 1.5)
set(h(2), 'linewidth', 1.5)
set(h(3), 'linewidth', 1.5)
xlabel('Linewidth (Hz)')
ylabel('Q (dB)')
xlim([1e3 1e8])
ylim([0 20])
title('Quality Factor of 16-QAM System', 'FontSize', 16)
legend({'Without Deterministic Phase Recovery', 'Single-pole Filter', ...
    'Lorentzian, attenuation=0 below -9dB'},'FontSize', 12, 'Location', 'southwest')
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

figure(10)
h= loglog(linewidth, BER16_PC, '-o', linewidth, BER16_BWs,'-d', linewidth, BER16_L9,'-^');
set(h(1), 'linewidth', 1.5)
set(h(2), 'linewidth', 1.5)
set(h(3), 'linewidth', 1.5)
xlabel('Linewidth (Hz)')
ylabel('BER')
xlim([1e3 1e8])
title('Bit Error Rate of 16-QAM System', 'FontSize', 16)
legend({'Without Deterministic Phase Recovery', 'Single-pole Filter', ...
    'Lorentzian, attenuation=0 below -9dB'},'FontSize', 12, 'Location', 'northwest')
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

%% Filter Design
gap = 1;
wc = 2*pi*gap/35;
ADC_rate = 200;
F = linspace(-ADC_rate/2, ADC_rate/2, 262144);
BWs = 1./(1+1i*F./wc);

y = 0.5;
x0 = 0;
I = 1;
A = I * (y^2 ./ ((F - x0).^2 + y^2));
B = A;
%A(A < 10^(-9/10)) = 0; %-9dB

figure
h = semilogx(F, mag2db(BWs), F, mag2db(A));
set(h(1), 'linewidth', 1.5)
set(h(2), 'linewidth', 1.5)
title('Filter Design', 'FontSize', 16)
xlabel('log(Frequency) (GHz)')
ylabel('Magnitude (dB)')
legend({'Fragkos Filter','Lorentzian Filter'},'FontSize', 12, 'Location', 'southwest')
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

figure
hold on
plot(F, BWs, 'linewidth', 1.5)
%A(A < 10^(-9/10)) = 0; %-9dB
plot(F, A, 'linewidth', 1.5)
%B(F > gap | F < -gap) = 0;
%plot(F, B, 'linewidth', 1.5)
hold off
title('Filter Design', 'FontSize', 16)
xlabel('Frequency (GHz)')
ylabel('Amplitude')
xlim([-5 5])
legend({'Fragkos Filter', 'Jignesh Filter'},'FontSize', 12)
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;