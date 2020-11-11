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

% THIS SCRIPT shows the sweep of tone_fact used to determine the best value
% to be used. It is all in-line plotting functions. 

%% Housekeeping
close all; clear all; clc;

tone = [0.01, 0.1, 0.2, 1/sqrt(10), 0.4, 0.5, 0.7, 1, 2, sqrt(10)];

%%
figure
hold on
plot(tone, [13.9936, Q4_01(1), 20.9876, Q4_1S10(1), 20.249, Q4_05(1), 14.8252, 11.3703, 6.5907, Q4_S10(1)])
plot(tone, [-2.7518, 27.7619, 27.4489, 23.7394, 21.5469, 18.7816, 14.9153, 11.3617, 6.5544, 4.8611])
plot(tone, [-2.9795, 13.3019, 18.6219, 20.4366, 19.7516, 18.3386, 14.8703, 11.4357, 6.6517, 4.8514])
plot(tone, [18.6688, 22.1802, 23.9689, 22.7345, 20.9595, 18.748, 15.0495, 11.3677, 6.6001, 4.8516])
plot(tone, [27.7943, 27.5057, 26.533, 23.4796, 21.2742, 18.6468, 14.8377, 11.3432, 6.5995, 4.8197])
plot(tone, [26.5532, 27.0013, 26.08, 23.7641, 21.2429, 18.7805, 14.836, 11.3124, 6.5468, 4.7816])
hold off
xlabel('tone factor')
ylabel('Q^2')
title('4-QAM, 1e3 Linewidth')
legend('Lorentzian & Impaired', 'Only Phasecomp & 0 Impair', 'Lorentzian & 0 Impair', 'Lorentzian & Impaired - 2GHZ Gap', 'Phasecomp', 'Brickwall')

figure
hold on
plot(tone, [24.4821, 24.9882, 24.4095, 22.3388, 20.5966, 18.3487, 14.7234, 11.2265, 6.5343, 4.8124])
plot(tone, [23.0236, 22.5816, 22.6268, 21.1523, 19.6053, 17.8149, 14.5354, 11.097, 6.4945, 4.8016])
plot(tone, [23.2589, 23.031, 22.2206, 21.1802, 19.4324, 17.7826, 14.4217, 11.174, 6.4876, 4.8061])
plot(tone, [23.0458, 22.7742, 22.4382, 21.2533, 19.4246, 17.6865, 14.3954, 11.1579, 6.5185, 4.8108])
hold off
xlabel('tone factor')
ylabel('Q^2')
title('4-QAM, 1e6 Linewidth')
legend('Brickwall', 'Phasecomp', 'Lorentzian', 'Lorentzian - 2GHz')


subTone = tone(1:end-2);
figure
hold on
plot(subTone, [21.4866, 24.1467, 24.82, 22.9578, 21.1902, 18.7205, 14.9199, 11.2481])
plot(subTone, [21.4409, 24.0392, 24.7337, 22.8993, 21.168, 18.7, 14.9082, 11.2446])
plot(subTone, [21.0562, 23.4478, 24.0974, 22.4965, 20.873, 18.5363, 14.8353, 11.2065])
plot(subTone, [18.1993, 19.9886, 20.4377, 19.6626, 18.7069, 17.1073, 14.1132, 10.8695])
plot(subTone, [10.3653, 11.6748, 12.2395, 12.0611, 11.923, 11.5436, 10.4361, 8.6135])
hold off
xlabel('tone factor')
ylabel('Q^2')
title('4-QAM Lorentzian 1GHz gap HWHM=0.5')
legend('1e3 Hz', '1e5 Hz', '1e6 Hz', '1e7 Hz', '1e8 Hz')

figure
hold on
plot(subTone, [26.5921, 26.9205, 26.3966, 23.5779, 20.959, 18.8358, 15.0248, 11.3395])
plot(subTone, [26.3731, 26.6918, 26.1874, 23.4825, 20.9071, 18.7777, 15.0021, 11.33])
plot(subTone, [24.8119, 25.0682, 24.7097, 22.6331, 20.4075, 18.4783, 14.8619, 11.261])
plot(subTone, [9.7328, 10.1364, 10.2642, 9.9687, 9.5973, 9.6334, 8.7643, 7.4288])
hold off
xlabel('tone factor')
ylabel('Q^2')
title('4-QAM Lorentzian 1GHz gap HWHM=0.25')
legend('1e3 Hz', '1e5 Hz', '1e6 Hz', '1e8 Hz')


figure
hold on
plot(subTone, [17.2666, 21.342, 22.787, 22.2336, 20.596, 18.3975, 14.7769, 11.3003])
plot(subTone, [17.2425, 21.3095, 22.768, 22.2096, 20.5794, 18.381, 14.7649, 11.2954])
plot(subTone, [17.0444, 21.016, 22.4072, 21.9229, 20.384, 18.2583, 14.7033, 11.2677])
plot(subTone, [9.2408, 12.0925, 13.0047, 13.0865, 12.839, 12.2611, 10.9694, 9.0628])
hold off
xlabel('tone factor')
ylabel('Q^2')
title('4-QAM Lorentzian 1GHz gap HWHM=0.75')
legend('1e3 Hz', '1e5 Hz', '1e6 Hz', '1e8 Hz')

figure
hold on
plot(subTone, [14.8631, 19.2412, 21.1576, 21.3897, 20.2239, 18.1815, 14.7286, 11.209])
plot(subTone, [14.8334, 19.2048, 21.1539, 21.3934, 20.2078, 18.1711, 14.72, 11.2007])
plot(subTone, [14.756, 19.0309, 20.8956, 21.1567, 20.0484, 18.0698, 14.6708, 11.1762])
plot(subTone, [8.3066, 11.7534, 12.7973, 13.2289, 13.0484, 12.5429, 11.1527, 9.2217])
hold off
xlabel('tone factor')
ylabel('Q^2')
title('4-QAM Lorentzian 1GHz gap HWHM=1')
legend('1e3 Hz', '1e5 Hz', '1e6 Hz', '1e8 Hz')

figure
hold on
title('4-QAM Lorentzian, linewidth 1e3Hz, 1GHz gap')
plot(subTone, [26.5921, 26.9205, 26.3966, 23.5779, 20.959, 18.8358, 15.0248, 11.3395])
plot(subTone, [21.4866, 24.1467, 24.82, 22.9578, 21.1902, 18.7205, 14.9199, 11.2481])
plot(subTone, [17.2666, 21.342, 22.787, 22.2336, 20.596, 18.3975, 14.7769, 11.3003])
plot(subTone, [14.8631, 19.2412, 21.1576, 21.3897, 20.2239, 18.1815, 14.7286, 11.209])
hold off
xlabel('tone factor')
ylabel('Q^2')
legend('HWHM=0.25', 'HWHM=0.5', 'HWHM=0.75', 'HWHM=1')