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

BERwo = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.003851, 0.49748, 0.49563, 0.49565];
Qwo = [28.0845, 27.9975, 27.245, 26.6873, 24.9296, 23.679, 23.1953, 20.843, 17.3233, 15.4446, 14.4774, 10.5628, -2.9852, -2.987, -2.9672];

% Results using both algorithms
BERboth = [0.00015263, 0.0014559, 0.0034988];
Qboth4 = [24.2639, 24.2148, 24.1867, 24.1379, 23.8623, 23.7044, 23.5841, 22.9936, 21.5793, 20.4413, 19.842, 17.6293, 14.4173, 12.4406, 11.4519];

% Results from Lorentzian filer width = 0.1
BER4_L01 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 4.6964e-05, 0.0001996, 0.0072207, 0.067604, 0.11878, 0.13813];
Q4_L01 = [27.0187, 26.9105, 26.1034, 25.1971, 22.9726, 22.0363, 21.0457, 18.7712, 15.156, 13.5581, 12.4664, 9.9341, 5.8372, 3.9135, 3.1453];
GMIx4_L01 = [7.0051e-10, 2.394e-09, 2.5419e-10, 9.5282e-08, 1.2788e-09, 3.0976e-07, 9.4098e-08, 6.7981e-08, 3.4677e-07, 2.0917e-07, 1.8003e-06, 1.3287e-05, 2.5804e-07, 1.2621e-05, 4.3933e-06];
GMIy4_L01 = [3.0001e-06, 2.0342e-06, 1.8199e-06, 1.7057e-06, 4.0121e-06, 1.3403e-07, 3.1694e-06, 6.4667e-07, 5.3354e-06, 4.5767e-06, 3.4274e-06, 1.3361e-05, 9.1486e-07, 2.1638e-08, 4.8611e-06];

% Results from first try of Lorentzian filter = width = 0.5
BER4_L05 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00044616, 0.0078077, 0.070434, 0.12637, 0.13845];
Q4_L05 = [26.9457, 26.8612, 25.9188, 25.0762, 23.1318, 21.8355, 21.2671, 18.6536, 15.936, 13.5397, 12.3225, 9.8656, 5.785, 3.7203, 3.2057];
GMIx4_L05 = [2.913e-05, 2.799e-05, 2.8358e-05, 3.3763e-05, 3.0957e-05, 2.6876e-05, 2.5549e-05, 3.5646e-05, 3.7191e-05, 1.5983e-05, 5.2868e-06, 2.823e-05, 3.4058e-05, 9.0521e-07, 4.0984e-05];
GMIy4_L05 = [3.1298e-06, 3.5385e-06, 3.2615e-06, 3.3731e-06, 5.5146e-06, 6.2295e-06, 1.7256e-06, 4.062e-06, 1.734e-07, 7.2821e-06, 2.257e-05, 5.682e-06, 1.1378e-05, 4.5381e-06, 1.332e-08];

% Results from Lorentzian width = 1
BER4_L1 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 9.3928e-05, 0.00052834, 0.011342, 0.073956, 0.12853, 0.14801];
Q4_L1 = [26.7252, 26.6446, 25.7151, 24.8969, 23.032, 21.9079, 21.3185, 18.7498, 15.1734, 13.3364, 12.5269, 9.2843, 5.499, 3.5747, 3.0184];
GMIx4_L1 = [7.2059e-05, 7.1258e-05, 6.816e-05, 7.4153e-05, 7.8331e-05, 8.7777e-05, 6.8853e-05, 6.6614e-05, 8.2712e-05, 0.00010224, 9.1345e-05, 7.8563e-05, 5.9546e-06, 2.1144e-05, 7.684e-05];
GMIy4_L1 = [1.3374e-05, 1.3679e-05, 1.3435e-05, 1.2284e-05, 1.0033e-05, 1.4263e-05, 8.5207e-06, 1.6085e-05, 8.9296e-06, 1.3321e-05, 4.4284e-05, 1.83e-05, 7.757e-09, 2.5764e-05, 2.0441e-05];

% Graphs
% figure(1)
% loglog(Laser, BERwo, Laser(end-2:end), BERboth, Laser, BER4_L01, Laser, BER4_L05, Laser, BER4_L1)
% title('BER: 4-QAM Lorentzian')
% legend('OG Phasecomp','Brick-wall','Width = 0.1', 'Width = 0.5','Width = 1')
% 
% figure(2)
% semilogx(Laser, Qwo, Laser, Qboth4, Laser, Q4_L01, Laser, Q4_L05, Laser, Q4_L1)
% title('Q^2: 4-QAM Lorentzian')
% legend('OG Phasecomp','Brick-wall','Width = 0.1', 'Width = 0.5','Width = 1')
% 
% figure(3)
% semilogx(Laser, GMIx4_L01, Laser, GMIy4_L01, Laser, GMIx4_L05, Laser, GMIy4_L05, Laser, GMIx4_L1, Laser, GMIy4_L1)
% title('GMI: 4-QAM Lorentzian')
% legend('X: Width = 0.1', 'Y: Width = 0.1','X: Width = 0.5','Y: Width = 0.5','X: Width = 1', 'Y: Width = 1')

%% 16-QAM
BER16_L01 = [0, 0, 0, 0, 0, 1.1741e-05, 3.5223e-05, 0.0013326, 0.012921, 0.023828, 0.030333, 0.073187, 0.14602, 0.18214, 0.21077];
Q16_L01 = [24.1165, 24.0807, 23.5162, 22.9914, 21.7836, 20.9072, 20.2313, 18.249, 14.9756, 13.4138, 12.6931, 9.3407, 5.5938, 4.0923, 2.9582];
GMIx16_L01 = [0.00010799, 0.00010941, 0.00010441, 0.00010536, 0.00011026, 0.00012756, 0.00011455, 8.4366e-05, 9.009e-05, 0.00010081, 0.00013587, 0.00015457, 0.00029936, 6.0247e-05, 4.8017e-05];
GMIy16_L01 = [3.8364e-05, 3.6432e-05, 3.5362e-05, 3.953e-05, 3.9869e-05, 4.2879e-05, 3.8272e-05, 4.1579e-05, 4.6112e-05, 3.0216e-05, 4.5583e-05, 1.0847e-05, 1.2741e-05, 5.2714e-05, 2.77e-05];

BER16_L05 = [0, 0, 0, 0, 5.8705e-06, 4.6964e-05, 9.9798e-05, 0.0012445, 0.010455, 0.027456, 0.030403, 0.073868, 0.14053, 0.45382, 0.19778];
Q16_L05 = [23.963, 23.9281, 23.4455, 22.9165, 21.7581, 20.6609, 20.0056, 18.1616, 15.2268, 12.9758, 12.7243, 9.3596, 5.6913, -2.9497, 3.3958];
GMIx16_L05 = [-3.7511e-07, -3.2736e-07, -5.7758e-07, -6.7114e-07, -9.8505e-07, 2.5761e-06, 1.9003e-06, -3.3202e-07, -6.0046e-07, 5.8477e-06, 7.0887e-07, 1.8543e-06, 6.0846e-05, 8.6118e-07, 1.7757e-05];
GMIy16_L05 = [2.5939e-05, 2.5328e-05, 2.4144e-05, 2.4422e-05, 2.2903e-05, 2.5359e-05, 2.7897e-05, 1.5707e-05, 3.2436e-05, 2.4655e-05, 2.1506e-05, 2.8969e-05, 4.5888e-05, 9.5918e-05, 0.00010392];

BER16_L1 = [0, 0, 0, 0, 0, 5.2834e-05, 7.0446e-05, 0.0010449, 0.012551, 0.024357, 0.035651, 0.073915, 0.14742, 0.49909, 0.49905];
Q16_L1 = [23.6519, 23.6117, 23.1603, 22.6948, 21.4653, 20.4434, 19.9716, 18.2681, 14.847, 13.3454, 12.2076, 9.2501, 5.4514, -2.992, -2.9955];
GMIx16_L1 = [-4.2913e-07, -4.343e-07, -2.4578e-07, -5.285e-07, -6.1804e-07, -1.0994e-07, -8.983e-07, -3.6003e-07, -1.2161e-06, 2.7917e-06, 1.6202e-07, 1.5267e-05, 7.7033e-06, 0.00012259, 3.7193e-05];
GMIy16_L1 = [-4.3643e-06, -3.8168e-06, -4.1563e-06, -4.3767e-06, -4.1868e-06, -3.7752e-06, -3.4368e-06, -5.8165e-06, -1.7338e-06, -3.0872e-06, 1.2529e-06, -3.5255e-06, 2.8435e-06, 7.4714e-05, -4.2269e-06];

% % Graphs
% figure(4)
% loglog(Laser, BER16_L01, Laser, BER16_L05, Laser, BER16_L1)
% title('BER: 16-QAM Lorentzian')
% legend('Width = 0.1', 'Width = 0.5','Width = 1')
% 
% figure(5)
% semilogx(Laser, Q16_L01, Laser, Q16_L05, Laser, Q16_L1)
% title('Q^2: 16-QAM Lorentzian')
% legend('Width = 0.1', 'Width = 0.5','Width = 1')
% 
% figure(6)
% semilogx(Laser, GMIx16_L01, Laser, GMIy16_L01, Laser, GMIx16_L05, Laser, GMIy16_L05, Laser, GMIx16_L1, Laser, GMIy16_L1)
% title('GMI: 16-QAM Lorentzian')
% legend('X: Width = 0.1', 'Y: Width = 0.1','X: Width = 0.5','Y: Width = 0.5','X: Width = 1', 'Y: Width = 1')

%% Recovery_compare
% Comparing standard phase-comp, brick-wall filter with phase-comp and
% Lorentzian filter with phase-comp over a subset of linewidths, most
% interested in higher linewidths (>10e7 Hz).

LaserSub = Laser([1,5,11:15]);

BER4_L = [0, 0, 0, 1.1741e-05, 0.00012915, 0.00099798, 0.0017846];
Q4_L = [18.2515, 18.1693, 16.7582, 15.6309, 13.7185, 12.0726, 11.4784];

BER16_L = [0.0020018, 0.0021662, 0.0051836, 0.0095571, 0.02259, 0.036655, 0.045854];
Q16_L = [17.6237, 17.5479, 16.3195, 15.2986, 13.4162, 11.9509, 11.2398];

BER64_L = [0.031548, 0.031865, 0.04449, 0.054678, 0.082132, 0.10177, 0.11248];
Q64_L = [17.3684, 17.2935, 16.0752, 15.2221, 13.1248, 11.8308, 11.1654];


BER4_BW = [0, 0, 0, 0.00032875, 0.0074438, 0.026147, 0.03581];
Q4_BW = [27.2963, 26.0118, 16.4, 13.7308, 9.9371, 8.0349, 7.3249];

BER16_BW = [0, 0, 0.0064106, 0.021879, 0.06879, 0.093986, 0.11421];
Q16_BW = [23.7033, 23.1058, 16.109, 13.535, 9.6017, 8.0571, 6.9971];

BER64_BW = [0.0011937, 0.001949, 0.046005, 0.079952, 0.13571, 0.17113, 0.18757];
Q64_BW = [22.4922, 22.0196, 15.9616, 13.2982, 9.778, 7.861, 7.085];


BER4_PC = [0, 0, 0.49625, 0.49576, 0.4957, 0.49609, 0.4981];
Q4_PC = [27.2447, 24.6119, -2.9886, -2.9797, -2.9821, -2.9803, -2.9913];

BER16_PC = [0, 0, 0.028366, 0.49949, 0.49795, 0.4715, 0.45536];
Q16_PC = [24.5425, 22.7668, 12.8949, -2.9855, -2.9992, -2.3466, -3.002];

BER64_PC = [0.00032875, 0.0020742, 0.45843, 0.49875, 0.49984, 0.27803, 0.4978];
Q64_PC = [23.464, 22.0544, -2.9313, -2.9964, -3.0345, 3.1894, -3.0013];

% subband gap = 2GHz instead of 1GHz - VERY similar (just BER =/= 0) for 16/64 QAM
BER4_L2 = [1.1741e-05, 0.00016437, 0.00084535];
Q4_L2 = [22.2704, 22.2745, 22.241, 22.1965, 22.0662, 21.9745, 21.8941, 21.5408, 20.6566, 19.8223, 19.3903, 17.711, 15.0053, 13.2547, 12.3784];

BER4_BW2 = [0.0047199, 0.023552, 0.038076];
Q4_BW2 = [27.1648, 27.0884, 26.8513, 26.602, 25.9102, 25.4894, 25.048, 22.4994, 19.1774, 17.4648, 16.5513, 13.9969, 10.3616, 8.1783, 7.303];

% subband gap = 2GHz and lorentzian = 0 outside this gap, HWHM = 0.5
BER4_L20 = [1.1741e-05, 0.00032875, 0.00075142];
Q4_L20 = [23.7932, 23.7748, 23.73, 23.7003, 23.516, 23.3633, 23.2601, 22.7862, 21.5936, 20.7061, 20.1385, 18.1481, 15.189, 13.1989, 12.4125];

% subband gap = 1GHz and lorentzian =0 outside this gap, HWHM = 0.5
BER4_L10 = [0.00014089, 0.00059879, 0.0020077];
Q4_L10 = [24.5998, 24.5869, 24.4743, 24.449, 24.23, 23.9698, 23.8606, 23.1232, 21.8405, 20.8528, 20.1396, 17.9851, 14.6213, 12.7117, 11.946];

% subband gap = 2GHz, lorentzian = 0 outside, HWHM = 1 (0.5*gap)
BER4_L201 = [0, 0, 0, 0, 1.1741e-05, 0, 0, 1.1741e-05, 1.1741e-05, 2.3482e-05, 0, 3.5223e-05, 0.00029352, 0.00096276, 0.001949];
Q4_L201 = [15.5621, 15.5691, 15.5521, 15.5465, 15.5334, 15.52, 15.4912, 15.4331, 15.3087, 15.1021, 14.9875, 14.5062, 13.3098, 12.2991, 11.7638];

% subband gap = 1GHz, lorentzian = 0 outside, HWHM = 0.25
BER4_L025 = [0.00015263, 0.0035223, 0.0057531];
Q4_L025 = [26.9872, 26.9644, 26.7714, 26.5611, 25.9532, 25.5435, 25.2329, 23.8795, 21.1565, 19.7396, 19.0061, 16.3941, 12.9378, 10.8355, 10.1677];

BER4_L2025 = [0.0002583, 0.0024186,  0.0045672];
Q4_L2025 = [27.1169, 27.0807, 26.8845, 26.6783, 26.0604, 25.6033, 25.2711, 23.8468, 21.4521, 19.8022, 19.189, 16.6556, 13.1486, 10.9999, 10.3327];

% figure(7)
% loglog(LaserSub, BER4_L, LaserSub, BER16_L, LaserSub, BER64_L, LaserSub, BER4_BW, LaserSub, BER16_BW, LaserSub, BER64_BW, LaserSub, BER4_PC, LaserSub, BER16_PC, LaserSub, BER64_PC)
% legend('4 Lorentzian', '16 Lorentzian', '64 Lorentzian', '4 Brick Wall', '16 Brick Wall','64 Brick Wall', '4 Phasecomp', '16 Phasecomp', '64 Phasecomp')
% legend('location', 'southwest')
% xlabel('Linewidth (Hz)')
% ylabel('BER')

figure(8)
semilogx(LaserSub, Q4_L, LaserSub, Q16_L, LaserSub, Q64_L, LaserSub, Q4_BW, LaserSub, Q16_BW, LaserSub, Q64_BW, LaserSub, Q4_PC, LaserSub, Q16_PC, LaserSub, Q64_PC, Laser, Q4_L2)
legend('4 Lorentzian', '16 Lorentzian', '64 Lorentzian', '4 Brick Wall', '16 Brick Wall','64 Brick Wall', '4 Phasecomp', '16 Phasecomp', '64 Phasecomp', '4 Lorentzian 2GHz Gap')
legend('location', 'southwest')
xlabel('Linewidth (Hz)')
ylabel('Q^2')

figure(9)
semilogx(LaserSub, Q4_L, LaserSub, Q4_BW, LaserSub, Q4_PC, Laser, Q4_L2, Laser, Q4_BW2, Laser, Q4_L20, Laser, Q4_L10)
legend('Lorentzian', 'Brick Wall', 'Phasecomp', 'Lorentzian 2GHz Gap', 'Brick Wall 2GHz Gap', 'Lorentzian=0 outside 2GHz gap', 'Lorentzian=0 outside 1GHz gap')
legend('location', 'southwest')
xlabel('Linewidth (Hz)')
ylabel('Q^2')
title('4 QAM')

figure(10)
semilogx(LaserSub, Q4_L, Laser, Q4_L2, Laser, Q4_L20, Laser, Q4_L10, Laser, Q4_L201, Laser, Q4_L025, Laser, Q4_L2025)
legend('Lorentzian 1GHz Gap', 'Lorentzian 2GHz Gap', 'Lorentzian=0 outside 2GHz gap HWHM=0.5', 'Lorentzian=0 outside 1GHz gap HWHM=0.5', 'Lorentzian=0 outside 2GHz gap HWHM=1', 'Lorentzian=0 ouside 1GHz gap HWHM=0.25', 'Lorentzian=0 ouside 2GHz gap HWHM=0.25')
legend('location', 'southwest')
xlabel('Linewidth (Hz)')
ylabel('Q^2')
title('4 QAM')