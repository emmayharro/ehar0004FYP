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

% THIS SCRIPT intends to show a comparison between the performance of Q^2
% and BER across multiple transmission distances, at each QAM level for a
% smaller number of laser linewidths each.
%% Housekeeping
close all; clear all; clc;

Laser = [1e3, 1e4, 1e5, 1e6, 1e7, 1e8];

%% 4-QAM
% Results for 0km
BER4_0 = [0, 0, 0, 0, 0, 0.039285];
Q4_0 = [26.9054, 26.8481, 26.6247, 24.7875, 16.3745, 7.1616];

%Results for 50km
BER4_50 = [0, 0, 0, 0, 0, 0.037923];
Q4_50 = [26.5389, 26.5262, 26.2803, 24.5482, 16.5979, 7.248];

% Results for 500km
BER4_500 = [0.46204, 0.46157, 0.46123, 0.46126, 0.46009, 0.46994];
Q4_500 = [-2.4855, -2.4804, -2.4822, -2.474, -2.451, -2.6195];

BER4_5000 = [0.49678, 0.49714, 0.49605, 0.49694, 0.49674, 0.49712];
Q4_5000 = [-2.9788, -2.9858, -2.977, -2.9828, -2.9772, -2.9817];

figure(1)
loglog(Laser, BER4_0, Laser, BER4_50, Laser, BER4_500, Laser, BER4_5000)
title('BER - 4-QAM, 40dB OSNR')
legend('0 km', '50 km', '500 km', '5000 km')
legend('Location', 'best')

figure(2)
semilogx(Laser, Q4_0, Laser, Q4_50, Laser, Q4_500, Laser, Q4_5000)
ylim([-5 30])
title('Q^2 - 4-QAM, 40dB OSNR')
legend('0 km', '50 km', '500 km', '5000 km')
legend('Location', 'best')

%% Change of View
% After observing this first set of results, I thought it would be
% beneficial to change the way the graphs are shown. I changed to having
% distance on the x-axis to better observe at what distance the signal
% metrics deteriorate
distance = [1, 5, 10, 50, 70, 90, 95, 100, 500, 1000, 5000];

BER4_1e3 = [0, 0, 0, 0, 0, 0.0049547, 0.1031, 0.15705, 0.4957, 0.49833, 0.49746];
Q4_1e3 = [27.2304, 27.2572, 27.2458, 26.9107, 26.3169, 12.6933, 2.9738, 2.4557, -2.9895, -2.987, -2.995];

BER4_1e4 = [0, 0, 0, 0, 0, 0.015404, 0.28892, 0.12118, 0.49829, 0.49901, 0.49583];
Q4_1e4 = [27.0884, 27.1216, 27.1522, 26.7658, 26.1449, 9.5879, 0.20893, 3.1961, -2.9973, -3.026, -2.9673];

BER4_1e5 = [0, 0, 0, 0, 0, 1.1741e-05, 0.066008, 0.26173, 0.42534, 0.49665, 0.49834];
Q4_1e5 = [27.1842, 27.1476, 27.1286, 26.783, 26.2429, 15.6694, 5.1897, -2.3128, -2.1192, -2.989, -3.0065];

BER4_1e6 = [0, 0, 0, 0, 0, 0.01841, 0.17103, 0.047739, 0.43479, 0.49725, 0.49644];
Q4_1e6 = [24.9799, 25.0989, 24.9657, 24.8045, 24.4563, 9.0848, 0.3874, 6.1139, -2.2514, -2.9718, -2.9959];

BER4_1e7 = [0, 0, 0, 0, 0, 0.026722, 0.16103, 0.070692, 0.45243, 0.47621, 0.49836];
Q4_1e7 = [16.5056, 16.6779, 16.6869, 16.3022, 16.4251, 7.6009, 2.3761, 4.9476, -2.3009, -2.7517, -3.0008];

BER4_1e8 = [0.036702, 0.035798, 0.045297, 0.040929, 0.03844, 0.079921, 0.19327, 0.12235, 0.47313, 0.48833, 0.49587];
Q4_1e8 = [7.3138, 7.2677, 6.8118, 7.1285, 7.2326, 4.7735, 1.4542, 3.0265, -2.688, -2.8723, -2.9977];

figure (3)
semilogx(distance, Q4_1e3, distance, Q4_1e4, distance, Q4_1e5, distance, Q4_1e6, distance, Q4_1e7, distance, Q4_1e8)
xlabel('Distance (km)')
title('Q^2 - 4-QAM')
legend('1e3 Hz', '1e4 Hz', '1e5 Hz', '1e6 Hz', '1e7 Hz', '1e8 Hz')
legend('Location', 'best')

% 16-QAM
BER16_1e3 = [0, 0, 0, 0, 0.0083772, 0.34783, 0.31282, 0.34108, 0.47826, 0.4919, 0.49595];
Q16_1e3 = [23.6834, 23.7058, 23.6279, 21.8618, 15.2038, 0.53424, 1.4556, -1.1301, -2.4641, -2.8235, -2.9844];

BER16_1e4 = [0, 0, 0, 0, 0.0014735, 0.36479, 0.36451, 0.34144, 0.48381, 0.49734, 0.49652];
Q16_1e4 = [23.8362, 23.7697, 23.7497, 22.2468, 17.4747, -0.33806, -1.0145, 0.70277, -2.6055, -3.0276, -3.0155];

BER16_1e5 = [0, 0, 0, 0, 0.0025008, 0.31473, 0.33598, 0.35134, 0.48134, 0.4913, 0.49845];
Q16_1e5 = [23.5741, 23.5677, 23.5523, 21.9095, 16.9327, 1.0904, 1.0912, 0.074633, -2.5196, -2.8051, -2.9885];

BER16_1e6 = [0, 0, 0, 5.8705e-06, 0.0029, 0.31492, 0.33777, 0.35107, 0.48573, 0.49121, 0.49706];
Q16_1e6 = [22.6205, 22.5567, 22.5274, 21.1761, 16.6774, 1.0173, 1.0507, 0.13536, -2.633, -2.7856, -2.9877];

BER16_1e7 = [0.0069095, 0.0060759, 0.0063108, 0.0074261, 0.01133, 0.26913, 0.35504, 0.36978, 0.47674, 0.49866, 0.49855];
Q16_1e7 = [16.0129, 16.1272, 16.1911, 15.7543, 14.6365, 2.4292, -0.0081742, 0.33207, -2.3412, -3.0019, -2.989];

BER16_1e8 = [0.11555, 0.12012, 0.11464, 0.11632, 0.12016, 0.30529, 0.33989, 0.32755, 0.49702, 0.49086, 0.4988];
Q16_1e8 = [7.0095, 6.7587, 7.004, 6.9077, 6.7908, 1.584, 0.49418, 1.0383, -3.005, -2.7972, -3.0107];

figure (4)
semilogx(distance, Q16_1e3, distance, Q16_1e4, distance, Q16_1e5, distance, Q16_1e6, distance, Q16_1e7, distance, Q16_1e8)
xlabel('Distance (km)')
title('Q^2 - 16-QAM')
legend('1e3 Hz', '1e4 Hz', '1e5 Hz', '1e6 Hz', '1e7 Hz', '1e8 Hz')
legend('Location', 'best')
