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
Qboth = [24.2639, 24.2148, 24.1867, 24.1379, 23.8623, 23.7044, 23.5841, 22.9936, 21.5793, 20.4413, 19.842, 17.6293, 14.4173, 12.4406, 11.4519];

figure(1)
loglog(Laser, BERwo, Laser, BERw, Laser(end-2:end), BERboth)
title('BER - 4-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')

figure(2)
semilogx(Laser, Qwo, Laser, Qw, Laser, Qboth)
title('Q^2 - 4-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')

%% 16-QAM 
% Results from orginal phase comp only
BERwo = [0, 0, 0, 0, 0, 0, 0, 0.00011741, 0.01278, 0.010643, 0.17362, 0.04839, 0.10688, 0.49736, 0.21444];
Qwo = [24.2579, 24.2341, 23.8724, 23.5835, 22.7381, 21.9311, 21.5254, 19.804, 14.7829, 15.2146, 5.9546, 11.1128, 7.4822, -2.9661, 3.0433];

% Results from brick-wall filter only
BERw = [0.2539, 0.25369, 0.25423, 0.25372, 0.25387, 0.25341, 0.25345, 0.25332, 0.25368, 0.2539, 0.25413, 0.25449, 0.25483, 0.25776, 0.25736];
Qw = [2.3902, 2.3912, 2.3875, 2.3914, 2.3854, 2.3852, 2.388, 2.391, 2.3797, 2.3502, 2.3505, 2.329, 2.2404, 2.124, 2.0753];

% Results from using both algorithms
BERboth = [0, 0, 0, 0, 1.7611e-05, 0, 5.8705e-06, 2.9352e-05, 8.2187e-05, 0.00037571, 0.00061053, 0.003446, 0.018398, 0.03443, 0.043706];
Qboth = [22.1024, 22.0659, 22.0258, 21.9706, 21.861, 21.6876, 21.5927, 21.2437, 20.1524, 19.2386, 18.8309, 17.0311, 13.9157, 12.1114, 11.2764];

figure(3)
loglog(Laser, BERwo, Laser, BERw, Laser, BERboth)
title('BER - 16-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')

figure(4)
semilogx(Laser, Qwo, Laser, Qw, Laser, Qboth)
title('Q^2 - 16-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'west')
xlabel("Linewidth (Hz)")
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
Qboth = [21.4713, 21.4841, 21.4391, 21.4067, 21.2906, 21.1429, 21.0989, 20.7229, 19.8184, 19.0245, 18.5451, 16.9087, 13.8657, 12.084, 11.1393];
    
figure(5)
loglog(Laser, BERwo, Laser, BERw, Laser, BERboth)
title('BER - 64-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')

figure(6)
semilogx(Laser, Qwo, Laser, Qw, Laser, Qboth)
title('Q^2 - 64-QAM, 40dB OSNR')
legend('Only PhaseComp', 'Only my algorithm', 'Both')
legend('Location', 'best')
