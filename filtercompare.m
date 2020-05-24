% compareing filter widths in phase recovery stage, using the 2 phase_comp
% algorithms together, with 40dB OSNR & OSNR Impair
close all; clear all; clc;

Laser = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8]; %[Hz]

%% 4-QAM
% filters implemented with pass/stop of 0.75/1 Hz across all linewidths
BER0751 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00015263, 0.0014559, 0.0034988];
Q0751 = [24.2639, 24.2148, 24.1867, 24.1379, 23.8623, 23.7044, 23.5841, 22.9936, 21.5793, 20.4413, 19.842, 17.6293, 14.4173, 12.4406, 11.4519];

% filters implemented with pass/stop of 0.5/0.75 Hz across all linewidths
BER05075 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0022895, 0.0075847, 0.013925];
Q05075 = [27.036, 27.0154, 26.7635, 26.5539, 25.772, 25.236, 24.9764, 23.4076, 20.7718, 19.0403, 18.3361, 15.7227, 11.765, 9.9953, 9.1861];

% filters implemented with pass/stop of 1/1.5 Hz across all linewidths
BER115 = [0.022402, 0.022531, 0.022155, 0.022284, 0.022672, 0.022566, 0.02293, 0.023259, 0.024057, 0.02475, 0.025666, 0.029165, 0.038064, 0.055253, 0.055182];
Q115 = [8.2402, 8.2393, 8.2387, 8.227, 8.2141, 8.239, 8.2069, 8.1798, 8.075, 8.0374, 7.9667, 7.7267, 7.0845, 6.2419, 6.1458];

% filters implemented with pass/stop 0.25/1.25 Hz across all linewidths
BER025125 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00028178, 0.0046259, 0.0083243];
Q025125 = [25.7159, 25.6931, 25.5403, 25.3937, 24.9993, 24.6189, 24.3706, 23.3458, 21.1433, 19.779, 18.9869, 16.2984, 13.0255, 10.8793, 10.106];

% figure(1)
% loglog(Laser, BERwo, Laser, BERw, Laser(end-2:end), BERboth, Laser, BERwoO, Laser, BERbothO)
% title('BER - 4-QAM, 40dB OSNR')
% legend('Only PhaseComp', 'Only my algorithm', 'Both', 'Only PhaseComp - wo OSNRImpair', 'Both - wo OSNRImpair')
% legend('Location', 'best')

figure(2)
semilogx(Laser, Q0751, Laser, Q05075, Laser, Q115, Laser, Q025125)%, Laser, QbothO)
title('Q^2 - 4-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25')%, 'Both - wo OSNRImpair')
legend('Location', 'best')

%% 16-QAM
% filters implemented with pass/stop of 0.75/1 Hz across all linewidths
BER0751 = [0, 0, 0, 0, 1.7611e-05, 0, 5.8705e-06, 2.9352e-05, 8.2187e-05, 0.00037571, 0.00061053, 0.003446, 0.018398, 0.03443, 0.043706];
Q0751 = [22.1024, 22.0659, 22.0258, 21.9706, 21.861, 21.6876, 21.5927, 21.2437, 20.1524, 19.2386, 18.8309, 17.0311, 13.9157, 12.1114, 11.2764];

% filters implemented with pass/stop of 0.5/0.75 Hz across all linewidths
BER05075 = [0, 0, 0, 0, 0, 0, 0, 0, 0.00013502, 0.00082187, 0.0021134, 0.010402, 0.03824, 0.066524, 0.078236];
Q05075 = [23.9371, 23.9118, 23.7948, 23.676, 23.3421, 22.8817, 22.7282, 21.8475, 19.9448, 18.3904, 17.6679, 15.2337, 11.8709, 9.7491, 8.9484];

% filters implemented with pass/stop of 1/1.5 Hz across all linewidths
BER115 = [0.091444, 0.091585, 0.091932, 0.091632, 0.092119, 0.091844, 0.092319, 0.092102, 0.094016, 0.093916, 0.096792, 0.10016, 0.11324, 0.12559, 0.13334];
Q115 = [8.1663, 8.1712, 8.1545, 8.159, 8.1412, 8.1615, 8.1477, 8.1303, 8.0265, 8.02, 7.9028, 7.6341, 6.9852, 6.2817, 5.908];

% filters implemented with pass/stop 0.25/1.25 Hz across all linewidths
BER025125 = [0, 0, 0, 0, 0, 0, 0, 5.8705e-06, 3.5223e-05, 0.00047551, 0.0010156, 0.0054948, 0.02947, 0.052488, 0.060519];
Q025125 = [23.0217, 23.0198, 22.9194, 22.8732, 22.5944, 22.3645, 22.2356, 21.5834, 20.1453, 18.8811, 18.1851, 16.1807, 12.6299, 10.7061, 10.1267];

% figure(3)
% loglog(Laser, BERwo, Laser, BERw, Laser, BERboth, Laser, BERwoO, Laser, BERbothO)
% title('BER - 4-QAM, 40dB OSNR')
% legend('Only PhaseComp', 'Only my algorithm', 'Both', 'Only PhaseComp - wo OSNRImpair', 'Both - wo OSNRImpair')
% legend('Location', 'best')

figure(4)
semilogx(Laser, Q0751, Laser, Q05075, Laser, Q115, Laser, Q025125)%, Laser, QbothO)
title('Q^2 - 16-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25')%, 'Both - wo OSNRImpair')
legend('Location', 'best')

%% 64-QAM
% filters implemented with pass/stop of 0.75/1 Hz across all linewidths
BER0751 = [0.0034714, 0.0033383, 0.0036162, 0.0037454, 0.0040389, 0.0046807, 0.004802, 0.0064223, 0.01171, 0.01695, 0.020641, 0.035689, 0.069988, 0.096225, 0.11071];
Q0751 = [21.4713, 21.4841, 21.4391, 21.4067, 21.2906, 21.1429, 21.0989, 20.7229, 19.8184, 19.0245, 18.5451, 16.9087, 13.8657, 12.084, 11.1393];

% filters implemented with pass/stop of 0.5/0.75 Hz across all linewidths
BER05075 = [0.0008884, 0.00092753, 0.0010332, 0.0011506, 0.0015107, 0.0020077, 0.0027161, 0.004939, 0.014434, 0.023877, 0.02963, 0.056998, 0.10541, 0.13852, 0.15423];
Q05075 = [22.8845, 22.8694, 22.7583, 22.6646, 22.4209, 22.148, 21.862, 21.1296, 19.4012, 18.1993, 17.5121, 15.0143, 11.5409, 9.6617, 8.8294];

% filters implemented with pass/stop of 1/1.5 Hz across all linewidths
BER115 = [0.49775, 0.49753, 0.49734, 0.49726, 0.49784, 0.4975, 0.4982, 0.49813, 0.49613, 0.49645, 0.49636, 0.18842, 0.19473, 0.20544, 0.49716];
Q115 = [-2.9719, -2.9714, -2.9696, -2.9915, -2.9814, -2.9949, -2.9802, -2.9786, -2.9912, -2.9675, -2.9738, 7.2996, 6.8807, 6.3226, -3.0185];

% filters implemented with pass/stop 0.25/1.25 Hz across all linewidths
BER025125 = [0.0017925, 0.001812, 0.0018394, 0.0021721, 0.002493, 0.003037, 0.0032836, 0.00535, 0.012665, 0.021462, 0.025595, 0.047336, 0.088038, 0.12218, 0.13443];
Q025125 = [22.0911, 22.0939, 22.0246, 21.9181, 21.756, 21.5497, 21.435, 20.8714, 19.5887, 18.4648, 17.971, 15.8225, 12.7458, 10.5028, 9.7944];

% figure(3)
% loglog(Laser, BERwo, Laser, BERw, Laser, BERboth, Laser, BERwoO, Laser, BERbothO)
% title('BER - 4-QAM, 40dB OSNR')
% legend('Only PhaseComp', 'Only my algorithm', 'Both', 'Only PhaseComp - wo OSNRImpair', 'Both - wo OSNRImpair')
% legend('Location', 'best')

figure(6)
semilogx(Laser, Q0751, Laser, Q05075, Laser, Q115, Laser, Q025125)%, Laser, QbothO)
title('Q^2 - 64-QAM, 40dB OSNR')
legend('0.75 - 1 Hz', '0.5 - 0.75 Hz', '1 - 1.5 Hz', '0.25 - 1.25')%, 'Both - wo OSNRImpair')
legend('Location', 'best')