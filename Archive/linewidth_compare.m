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

% THIS SCRIPT compares the BER and Q^2 outputs of DPMQAM_Rx across the
% range of linewidths. The main focus is comparing the original algorithm
% for phase compensation with the brick-wall filter and the performance of
% them combined. The aim is to determine where the original phase comp
% algorithm can be benefitted by additional compensation measures.
% Comparisons are made based on QAM modulation level.
% The brick-wall filter has a pass/stop boundary of 0.75/1 Hz in all cases.

%% Housekeeping
close all; clear all; clc;

% All graphs cover the following laser linewidths
Laser = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8];

%% 4-QAM
% Results from original phase comp only
BERwo = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.003851, 0.49748, 0.49563, 0.49565];
Qwo = [28.0845, 27.9975, 27.245, 26.6873, 24.9296, 23.679, 23.1953, 20.843, 17.3233, 15.4446, 14.4774, 10.5628, -2.9852, -2.987, -2.9672];

% Results from only brick-wall filter
BERw = [0.20558, 0.20486, 0.20517, 0.20581, 0.20529, 0.20577, 0.20549, 0.20441, 0.20515, 0.20524, 0.20565, 0.20562, 0.20587, 0.20681, 0.20801];
Qw = [2.4175, 2.4243, 2.4195, 2.4188, 2.4213, 2.4128, 2.4151, 2.4125, 2.4044, 2.3986, 2.3912, 2.3503, 2.2566, 2.156, 2.0618];

% Results using both algorithms
BERboth = [0.00015263, 0.0014559, 0.0034988];
Qboth4 = [24.2639, 24.2148, 24.1867, 24.1379, 23.8623, 23.7044, 23.5841, 22.9936, 21.5793, 20.4413, 19.842, 17.6293, 14.4173, 12.4406, 11.4519];

comp4 = mean(Qwo(1:5)-Qboth4(1:5));

figure(1)
loglog(Laser, BERwo, Laser, BERw, Laser(end-2:end), BERboth)
title('BER - 4-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')

figure(2)
%semilogx(Laser, Qwo, Laser, Qw, Laser, Qboth4, Laser, Q4_L1)
semilogx(Laser, Qwo, Laser, Qboth4)
hold on
title('Q^2 - 4-QAM, 40dB OSNR')
%legend('Only PhaseComp', 'Only my algorithm', 'Both', 'Lorentzian 1')
%legend('Location', 'best')

%% 16-QAM 
% Results from orginal phase comp only
BERwo = [0, 0, 0, 0, 0, 0, 0, 0.00011741, 0.01278, 0.010643, 0.17362, 0.04839, 0.10688, 0.49736, 0.21444];
Qwo = [24.2579, 24.2341, 23.8724, 23.5835, 22.7381, 21.9311, 21.5254, 19.804, 14.7829, 15.2146, 5.9546, 11.1128, 7.4822, -2.9661, 3.0433];

% Results from brick-wall filter only
BERw = [0.2539, 0.25369, 0.25423, 0.25372, 0.25387, 0.25341, 0.25345, 0.25332, 0.25368, 0.2539, 0.25413, 0.25449, 0.25483, 0.25776, 0.25736];
Qw = [2.3902, 2.3912, 2.3875, 2.3914, 2.3854, 2.3852, 2.388, 2.391, 2.3797, 2.3502, 2.3505, 2.329, 2.2404, 2.124, 2.0753];

% Results from using both algorithms
BERboth = [0, 0, 0, 0, 1.7611e-05, 0, 5.8705e-06, 2.9352e-05, 8.2187e-05, 0.00037571, 0.00061053, 0.003446, 0.018398, 0.03443, 0.043706];
Qboth16 = [22.1024, 22.0659, 22.0258, 21.9706, 21.861, 21.6876, 21.5927, 21.2437, 20.1524, 19.2386, 18.8309, 17.0311, 13.9157, 12.1114, 11.2764];

comp16 = mean(Qwo(1:5)-Qboth16(1:5));

figure(3)
loglog(Laser, BERwo, Laser, BERw, Laser, BERboth)
title('BER - 16-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')

figure(2)
%semilogx(Laser, Qwo, Laser, Qw, Laser, Qboth16)
semilogx(Laser, Qwo, Laser, Qboth16)
title('Q^2 - 16-QAM, 40dB OSNR')
%legend('Only PhaseComp', 'Only my algorithm', 'Both', 'Lorentzian 1','16 Only PhaseComp', '16 Only my algorithm', '16 Both')
%legend('Location', 'west')
xlabel('Linewidth (Hz)')
ylabel("Q^2 (dB)")

%% 64-QAM 
% Results from original phase comp only
BERwo = [0.00049312, 0.00048921, 0.00062227, 0.0010489, 0.0026143, 0.0040115, 0.0060348, 0.017498, 0.50015, 0.389, 0.49779, 0.49807, 0.49867, 0.49777, 0.49901];
Qwo = [23.1361, 23.1283, 22.9002, 22.544, 21.8144, 21.366, 20.8525, 19.037, -3.0024, 1.465, -2.9727, -2.9749, -2.9857, -3.0005, -2.9867];

% Results from brick-wall filter only
BERw = [0.30844, 0.30819, 0.30854, 0.30809, 0.30784, 0.30868, 0.30819, 0.30819, 0.30822, 0.30809, 0.30833, 0.30991, 0.49815, 0.31415, 0.49695];
Qw = [2.3835, 2.3874, 2.3813, 2.3845, 2.3847, 2.3815, 2.3775, 2.3758, 2.3692, 2.3607, 2.3502, 2.3126, -2.9786, 2.1227, -2.9903];

% Results from using both algorithms
BERboth = [0.0034714, 0.0033383, 0.0036162, 0.0037454, 0.0040389, 0.0046807, 0.004802, 0.0064223, 0.01171, 0.01695, 0.020641, 0.035689, 0.069988, 0.096225, 0.11071];
Qboth64 = [21.4713, 21.4841, 21.4391, 21.4067, 21.2906, 21.1429, 21.0989, 20.7229, 19.8184, 19.0245, 18.5451, 16.9087, 13.8657, 12.084, 11.1393];

comp64 = mean(Qwo(1:5)-Qboth64(1:5));
comp = mean([comp4 comp16 comp64]);
minimum = mean([Qboth4(end) Qboth16(end) Qboth64(end)]);
%minimum = mean([Qwo4(end) Qwo16(end) Qwo64(end)])

figure(5)
loglog(Laser, BERwo, Laser, BERw, Laser, BERboth)
title('BER - 64-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')

figure(2)
%semilogx(Laser, Qwo, Laser, Qw, Laser, Qboth64)
semilogx(Laser, Qwo, Laser, Qboth64)
title('Q^2 - 40dB OSNR')
%legend('Only PhaseComp', 'Only my algorithm', 'Both', 'Lorentzian 1','16 Only PhaseComp', '16 Only my algorithm', '16 Both','64 Only PhaseComp', '64 Only my algorithm', '64 Both')
legend('Only PhaseComp','Both','16 Only PhaseComp', '16 Both','64 Only PhaseComp','64 Both')
legend('Location', 'best')

%% GMI Graphs
% Graph showing GMI for x and y polarisations across the QAM levels,
% results from phase_comp+brick-wall filters
GMIx4 = [4.9944e-05, 4.7443e-05, 4.8369e-05, 5.2934e-05, 4.6212e-05, 4.6874e-05, 4.8258e-05, 5.5322e-05, 5.7799e-05, 5.1994e-05, 5.8105e-05, 5.7577e-05, 2.7067e-05, 6.4095e-05, 4.4075e-05];
GMIy4 = [6.7605e-06, 7.8767e-06, 6.6666e-06, 8.3167e-06, 6.4001e-06, 7.4408e-06, 7.0187e-06, 5.5337e-06, 8.5174e-06, 6.8576e-06, 2.1124e-05, 1.0275e-05, 1.5658e-06, 1.8133e-09, 2.1558e-06];

GMIx16 = [-8.6231e-07, -9.9958e-07, -8.3358e-07, -1.0535e-06, -1.0971e-06, -1.2864e-06, -1.069e-06, -1.0741e-06, -1.6037e-06, -1.9038e-06, -1.1375e-06, -3.6781e-07, 1.4549e-06, -5.3411e-07, -3.3909e-06];
GMIy16 = [3.0536e-05, 3.0865e-05, 3.0136e-05, 3.3439e-05, 2.8999e-05, 2.5213e-05, 3.4936e-05, 3.0517e-05, 3.1622e-05, 5.4862e-05, 3.9887e-05, 6.2385e-05, 4.9966e-05, 3.1567e-05, 1.615e-05];

GMIx64 = [3.8043e-05, 4.1216e-05, 3.7448e-05, 3.9297e-05, 3.8326e-05, 4.6422e-05, 3.0453e-05, 3.0651e-05, 3.6271e-05, 2.723e-05, 3.0051e-05, 2.4648e-05, 1.0284e-05, 1.143e-05, 1.276e-05];
GMIy64 = [1.3832e-05, 1.4947e-05, 1.4775e-05, 1.3934e-05, 1.7813e-05, 1.1173e-05, 1.2159e-05, 8.0789e-06, 1.5728e-05, 1.5323e-05, 6.8778e-06, 1.866e-05, 1.2071e-05, 3.7852e-05, -9.2455e-07];

% Results from first try lorentzian
GMIx4_L1 = [2.913e-05, 2.799e-05, 2.8358e-05, 3.3763e-05, 3.0957e-05, 2.6876e-05, 2.5549e-05, 3.5646e-05, 3.7191e-05, 1.5983e-05, 5.2868e-06, 2.823e-05, 3.4058e-05, 9.0521e-07, 4.0984e-05];
GMIy4_L1 = [3.1298e-06, 3.5385e-06, 3.2615e-06, 3.3731e-06, 5.5146e-06, 6.2295e-06, 1.7256e-06, 4.062e-06, 1.734e-07, 7.2821e-06, 2.257e-05, 5.682e-06, 1.1378e-05, 4.5381e-06, 1.332e-08];

figure(7)
semilogx(Laser, GMIx4, Laser, GMIy4, Laser, GMIx16, Laser, GMIy16, Laser, GMIx64, Laser, GMIy64, Laser, GMIx4_L1, Laser, GMIy4_L1)
legend('GMIx 4-QAM', 'GMIy 4-QAM', 'GMIx 16-QAM', 'GMIy 16-QAM', 'GMIx 64-QAM', 'GMIy 64-QAM', 'GMIx 4L', 'GMIy 4L')
legend('Location', 'best')