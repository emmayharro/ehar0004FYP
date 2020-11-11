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

% THIS SCRIPT aims to find the optimal filter width for the brick-wall
% filter that will give the most consistent phase recovery across all
% linewidths. This will be done by comparing the BER and Q values across
% the QAM modulation levels. 
% The width and the frequencies of the pass/stop bands will be altered.

% NAMING of variables follows the pattern of "Metric""M-QAM"_"passband Hz"
% _"stopband Hz", except where the filter characteristics change
% dynamically across the linewidth range

%% Housekeeping
close all; clear all; clc;

% All graphs cover the following laser linewidths
Laser = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8]; %[Hz]

%% 4-QAM
% filters implemented with pass/stop of 0.75/1 Hz across all linewidths
BER4_075_1 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00015263, 0.0014559, 0.0034988];
Q4_075_1 = [24.2639, 24.2148, 24.1867, 24.1379, 23.8623, 23.7044, 23.5841, 22.9936, 21.5793, 20.4413, 19.842, 17.6293, 14.4173, 12.4406, 11.4519];

% filters implemented with pass/stop of 0.5/0.75 Hz across all linewidths
BER4_05_075 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0022895, 0.0075847, 0.013925];
Q4_05_075 = [27.036, 27.0154, 26.7635, 26.5539, 25.772, 25.236, 24.9764, 23.4076, 20.7718, 19.0403, 18.3361, 15.7227, 11.765, 9.9953, 9.1861];

% filters implemented with pass/stop of 1/1.5 Hz across all linewidths
BER4_1_15 = [0.022402, 0.022531, 0.022155, 0.022284, 0.022672, 0.022566, 0.02293, 0.023259, 0.024057, 0.02475, 0.025666, 0.029165, 0.038064, 0.055253, 0.055182];
Q4_1_15 = [8.2402, 8.2393, 8.2387, 8.227, 8.2141, 8.239, 8.2069, 8.1798, 8.075, 8.0374, 7.9667, 7.7267, 7.0845, 6.2419, 6.1458];

% filters implemented with pass/stop 0.25/1.25 Hz across all linewidths
BER4_025_125 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00028178, 0.0046259, 0.0083243];
Q4_025_125 = [25.7159, 25.6931, 25.5403, 25.3937, 24.9993, 24.6189, 24.3706, 23.3458, 21.1433, 19.779, 18.9869, 16.2984, 13.0255, 10.8793, 10.106];

figure(1)
loglog(Laser, BER4_075_1, Laser, BER4_05_075, Laser, BER4_1_15, Laser, BER4_025_125)
title('BER - 4-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25 Hz')
legend('Location', 'best')

figure(2)
semilogx(Laser, Q4_075_1, Laser, Q4_05_075, Laser, Q4_1_15, Laser, Q4_025_125)
ylim([-5 30])
title('Q - 4-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25 Hz')
legend('Location', 'best')

%% 16-QAM
% filters implemented with pass/stop of 0.75/1 Hz across all linewidths
BER16_075_1 = [0, 0, 0, 0, 1.7611e-05, 0, 5.8705e-06, 2.9352e-05, 8.2187e-05, 0.00037571, 0.00061053, 0.003446, 0.018398, 0.03443, 0.043706];
Q16_075_1 = [22.1024, 22.0659, 22.0258, 21.9706, 21.861, 21.6876, 21.5927, 21.2437, 20.1524, 19.2386, 18.8309, 17.0311, 13.9157, 12.1114, 11.2764];

% filters implemented with pass/stop of 0.5/0.75 Hz across all linewidths
BER16_05_075 = [0, 0, 0, 0, 0, 0, 0, 0, 0.00013502, 0.00082187, 0.0021134, 0.010402, 0.03824, 0.066524, 0.078236];
Q16_05_075 = [23.9371, 23.9118, 23.7948, 23.676, 23.3421, 22.8817, 22.7282, 21.8475, 19.9448, 18.3904, 17.6679, 15.2337, 11.8709, 9.7491, 8.9484];

% filters implemented with pass/stop of 1/1.5 Hz across all linewidths
BER16_1_15 = [0.091444, 0.091585, 0.091932, 0.091632, 0.092119, 0.091844, 0.092319, 0.092102, 0.094016, 0.093916, 0.096792, 0.10016, 0.11324, 0.12559, 0.13334];
Q16_1_15 = [8.1663, 8.1712, 8.1545, 8.159, 8.1412, 8.1615, 8.1477, 8.1303, 8.0265, 8.02, 7.9028, 7.6341, 6.9852, 6.2817, 5.908];

% filters implemented with pass/stop 0.25/1.25 Hz across all linewidths
BER16_025_125 = [0, 0, 0, 0, 0, 0, 0, 5.8705e-06, 3.5223e-05, 0.00047551, 0.0010156, 0.0054948, 0.02947, 0.052488, 0.060519];
Q16_025_125 = [23.0217, 23.0198, 22.9194, 22.8732, 22.5944, 22.3645, 22.2356, 21.5834, 20.1453, 18.8811, 18.1851, 16.1807, 12.6299, 10.7061, 10.1267];

% dynamic filter: 0.5/0.75 for low, 0.75/1 for high linewidths
BER_dyn = [0, 0, 0, 0, 0, 0, 0, 2.3482e-05, 4.1093e-05, 0.00031114, 0.00060466, 0.0034225, 0.018292, 0.033802, 0.044017];
Q_dyn = [23.4796, 23.4543, 23.3028, 23.2396, 22.9164, 22.6129, 22.4322, 21.3693, 20.1871, 19.4277, 18.9416, 17.0632, 13.9102, 12.1838, 11.2878];

% dynamic filter: 0.5/0.75 for low, 0.5/1.5 for high
BER_dyn3 = [0, 0, 0, 0, 0, 0, 0, 0.0039039, 0.0058529, 0.0092284, 0.010661, 0.019948, 0.045925, 0.071978, 0.081887];
Q_dyn3 = [23.8423, 23.7952, 23.7007, 23.5483, 23.2314, 22.9278, 22.614, 16.6245, 16.0045, 15.3184, 15.0084, 13.6936, 11.1198, 9.2597, 8.6039];

figure(3)
loglog(Laser, BER16_075_1, Laser, BER16_05_075, Laser, BER16_1_15, Laser, BER16_025_125, Laser, BER_dyn, Laser, BER_dyn3)
title('BER - 16-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25 Hz', 'Dynamic Filter 1', 'Dynamic Filter 4')
legend('Location', 'best')

figure(4)
semilogx(Laser, Q16_075_1, Laser, Q16_05_075, Laser, Q16_1_15, Laser, Q16_025_125, Laser, Q_dyn, Laser, Q_dyn3)
ylim([-5 30])
title('Q - 16-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25 Hz', 'Dynamic Filter 1', 'Dynamic Filter 4')
legend('Location', 'best')

%% 64-QAM
% filters implemented with pass/stop of 0.75/1 Hz across all linewidths
BER64_075_1 = [0.0034714, 0.0033383, 0.0036162, 0.0037454, 0.0040389, 0.0046807, 0.004802, 0.0064223, 0.01171, 0.01695, 0.020641, 0.035689, 0.069988, 0.096225, 0.11071];
Q64_075_1 = [21.4713, 21.4841, 21.4391, 21.4067, 21.2906, 21.1429, 21.0989, 20.7229, 19.8184, 19.0245, 18.5451, 16.9087, 13.8657, 12.084, 11.1393];

% filters implemented with pass/stop of 0.5/0.75 Hz across all linewidths
BER64_05_075 = [0.0008884, 0.00092753, 0.0010332, 0.0011506, 0.0015107, 0.0020077, 0.0027161, 0.004939, 0.014434, 0.023877, 0.02963, 0.056998, 0.10541, 0.13852, 0.15423];
Q64_05_075 = [22.8845, 22.8694, 22.7583, 22.6646, 22.4209, 22.148, 21.862, 21.1296, 19.4012, 18.1993, 17.5121, 15.0143, 11.5409, 9.6617, 8.8294];

% filters implemented with pass/stop of 1/1.5 Hz across all linewidths
BER64_1_15 = [0.49775, 0.49753, 0.49734, 0.49726, 0.49784, 0.4975, 0.4982, 0.49813, 0.49613, 0.49645, 0.49636, 0.18842, 0.19473, 0.20544, 0.49716];
Q64_1_15 = [-2.9719, -2.9714, -2.9696, -2.9915, -2.9814, -2.9949, -2.9802, -2.9786, -2.9912, -2.9675, -2.9738, 7.2996, 6.8807, 6.3226, -3.0185];

% filters implemented with pass/stop 0.25/1.25 Hz across all linewidths
BER64_025_125 = [0.0017925, 0.001812, 0.0018394, 0.0021721, 0.002493, 0.003037, 0.0032836, 0.00535, 0.012665, 0.021462, 0.025595, 0.047336, 0.088038, 0.12218, 0.13443];
Q64_025_125 = [22.0911, 22.0939, 22.0246, 21.9181, 21.756, 21.5497, 21.435, 20.8714, 19.5887, 18.4648, 17.971, 15.8225, 12.7458, 10.5028, 9.7944];

figure(3)
loglog(Laser, BER64_075_1, Laser, BER64_05_075, Laser, BER64_1_15, Laser, BER64_025_125)
title('BER - 4-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25 Hz')
legend('Location', 'best')

figure(6)
semilogx(Laser, Q64_075_1, Laser, Q64_05_075, Laser, Q64_1_15, Laser, Q64_025_125)
ylim([-5 30])
title('Q - 64-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25 Hz')
legend('Location', 'best')