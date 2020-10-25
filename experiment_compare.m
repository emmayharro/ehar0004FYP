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

%% Phase Comp
% with DC_fact = 0.01
BER4_PC = [0, 0, 0, 0, 0, 0, 0, 0.0020429, 0, 0.0033227, 0.4962, 0.21472];
Q4_PC = [21.0327, 20.9928, 20.8474, 20.7104, 20.2194, 19.5545, 18.2705, ...
    7.3202, 13.5702, 10.6795, -2.9658, 1.5473];

BER16_PC = [0, 0, 1.1741e-05, 1.7611e-05, 2.3482e-05, 9.3928e-05, ...
    0.00056357, 0.0056298, 0.49749, 0.49801, 0.49919];
Q16_PC = [20.0634, 20.0819, 19.9079, 19.8323, 19.4071, 18.73, 17.8979, ...
    15.7378, -3.0026, -3.0029, -2.9865];

BER64_PC = [0.010841, 0.010481, 0.012015, 0.012633, 0.014934, 0.4961, ...
    0.49854, 0.10082, 0.093892, 0.4976, 0.19803, 0.5];
Q64_PC = [19.6874, 19.6899, 19.5067, 19.382, 19.1021, -2.9853, -2.9664, ...
    12.5088, 12.4979, -3.0047, 6.7074, -3.0089];

%with DC_fact = 0.05
BER4_PC = [0, 0, 0, 0, 0, 0, 0, 0, 3.5223e-05, 0.0025595, 0.030961, 0.093317];
Q4_PC = [19.043, 19.1439, 19.1053, 19.0994, 18.2878, 17.8377, 16.9011, ...
    15.0812, 13.2791, 10.8569, 7.4662, 4.7524];

BER16_PC = [5.8705e-05, 5.2834e-05, 8.2187e-05, 8.8057e-05, 0.00017024, ...
    0.00047551, 0.0013267, 0.0084006, 0.024979, 0.056028, 0.11105, 0.17276];
Q16_PC = [18.5685, 18.5435, 18.4371, 18.5619, 18.0029, 17.5951, 16.8302, ...
    14.9551, 12.902, 10.4971, 7.2805, 4.4792];

BER64_PC = [0.016422, 0.015541, 0.017075, 0.017713, 0.019412, 0.025595, ...
    0.034816, 0.055421, 0.085251, 0.1169, 0.18235, 0.23853];
Q64_PC = [18.9167, 19.0227, 18.8118, 18.7328, 18.5769, 17.9618, 17.1158,...
    15.3688, 13.1654, 11.0928, 7.4542, 4.5628];
GMIx64_PC = [5.4635, 5.4445, 5.316, 5.3738, 5.2487, 5.0727, 5.0374, 4.5026, ...
    3.9349, 3.2747, 2.3143, 1.5862];
GMIy64_PC = [5.4988, 5.4964, 5.3486, 5.4304, 5.2907, 5.1108, 5.0649, 4.533, ...
    3.9695, 3.2869, 2.3244, 1.5947];

%with DC_fact = 0.02
% BER4_PC = [0, 0, 0, 0, 0, 0, 0, 0, 4.6964e-05, 0.0011976, 0.038592, 0.1322];
% Q4_PC = [20.7375, 20.7394, 20.616, 20.5289, 20.0745, 19.1627, 18.2379, ...
%     15.8426, 13.8107, 11.3783, 7.1802, 2.9094];
% 
% BER16_PC = [0, 0, 0, 1.1741e-05, 1.7611e-05, 0.00012328, 0.00089231, ...
%     0.0058529, 0.021462, 0.04859, 0.11288, 0.17105];
% Q16_PC = [19.9258, 19.9083, 19.7671, 19.6348, 19.2627, 18.7182, 17.6002, ...
%     15.6676, 13.4411, 10.9782, 7.1675, 4.4302];
% 
% BER64_PC = [0.010586, 0.011209, 0.011522, 0.012794, 0.01542, 0.019952, ...
%     0.029591, 0.053817, 0.0785, 0.12851, 0.35089, 0.49716];
% Q64_PC = [19.6867, 19.5874, 19.5256, 19.3953, 19.0637, 18.4967, 17.5301, ...
%     15.3756, 13.5606, 10.3556, 1.6073, -2.9651];
% GMIx64_PC = [];
% GMIy64_PC = [];

% figure(1)
% loglog(linewidth, BER4_PC, '-o', linewidth(1:end-1), BER16_PC, '-*', linewidth, BER64_PC, '-s')
% title('Phase Comp')
% xlabel('Linewidth (Hz)')
% ylabel('Bit Error Rate')
% legend('4 QAM', '16 QAM', '64 QAM')

% figure(2)
% semilogx(linewidth, Q4_PC, '-o', linewidth(1:end-1), Q16_PC, '-*', linewidth, Q64_PC, '-s')
% title('Phase Comp')
% xlabel('Linewidth (Hz)')
% ylabel('Q^2')
% legend('4 QAM', '16 QAM', '64 QAM')

%% Steep Brick Wall
BER4_BW = [0, 0, 0, 0, 0, 0, 0, 0, 1.1741e-05, 0.0001996, 0.0096511, 0.04242];
Q4_BW = [19.675, 19.7083, 19.6148, 19.5867, 19.4335, 19.1662, 18.1702, ...
    16.7462, 14.8333, 12.9213, 9.4046, 6.9552];

BER16_BW = [3.5223e-05, 5.2834e-05, 9.3928e-05, 8.2187e-05, 9.9798e-05,...
    0.0001585, 0.00090992, 0.0033697, 0.01153, 0.027151, 0.071232, 0.11434];
Q16_BW = [18.9253, 18.8628, 18.7845, 18.8118, 18.637, 18.4512, 17.5855, ...
    16.4144, 14.7369, 12.8175, 9.4871, 7.0038];

BER64_BW = [0.021513, 0.021396, 0.021881, 0.022398, 0.023141, 0.025177, ...
    0.03361, 0.046702, 0.06598, 0.094479, 0.1472, 0.19933];
Q64_BW = [18.3291, 18.3388, 18.2865, 18.2331, 18.1555, 17.9454, 17.2002, ...
    16.0683, 14.5517, 12.4409, 9.4131, 6.6386];
GMIx64_BW = [5.5389, 5.5438, 5.5474, 5.5266, 5.5209, 5.4697, 5.3136, 5.0075, ...
    4.6205, 4.0064, 3.0324, 2.2528];
GMIy64_BW = [5.5487, 5.5501, 5.5365, 5.5428, 5.5158, 5.4615, 5.3028, 4.9935, ...
    4.6353, 4.0046, 3.0335, 2.245];

%% Slopey Brick Wall
BER4_BWs = [0, 0, 0, 0, 0, 0, 0, 0, 2.3482e-05, 0.00037571, 0.010402, 0.052036];
Q4_BWs = [18.5952, 18.5755, 18.4829, 18.4139, 18.2541, 17.9725, 17.4009, ...
    16.0089, 14.4694, 12.4114, 9.1869, 6.4526];

BER16_BWs = [0.00026417, 0.00024656, 0.00031701, 0.00034049, 0.00052247, ...
    0.00086883, 0.00172, 0.0050486, 0.0145, 0.034601, 0.077056, 0.1327];
Q16_BWs = [17.9133, 17.9516, 17.8611, 17.8067, 17.6276, 17.3308, 16.8159, ...
    15.7591, 14.1542, 12.0744, 9.0526, 6.0858];

BER64_BWs = [0.029834, 0.02882, 0.029372, 0.03017, 0.032221, 0.035125, ...
    0.041164, 0.055034, 0.073537, 0.10162, 0.15566, 0.20703];
Q64_BWs = [17.5565, 17.6375, 17.5725, 17.5259, 17.3451, 17.093, 16.5695, ...
    15.4905, 14.0351, 12.0865, 8.929, 6.3988];
GMIx64_BWs = [5.2864, 5.3123, 5.291, 5.2826, 5.2376, 5.1769, 5.0409, 4.7316, ...
    4.3329, 3.7517, 2.8184, 2.0759];
GMIy64_BWs = [5.3313, 5.3511, 5.3281, 5.3155, 5.2684, 5.2017, 5.0593, 4.7742, ...
    4.3318, 3.776, 2.812, 2.0877];

figure(3)
loglog(linewidth, BER4_BW, '-d', linewidth, BER16_BW, '-+', linewidth, ...
    BER64_BW, '-x', linewidth, BER4_BWs, '-d', linewidth, BER16_BWs, '-+', ...
    linewidth, BER64_BWs, '-x')
title('Brick Wall')
xlabel('Linewidth (Hz)')
ylabel('Bit Error Rate')
legend('4 QAM', '16 QAM', '64 QAM')

figure(4)
semilogx(linewidth, Q4_BW, '-d', linewidth, Q16_BW, '-+', linewidth, Q64_BW, ...
    '-x', linewidth, Q4_BWs, '-d', linewidth, Q16_BWs, '-+', linewidth, Q64_BWs, '-x')
title('Brick Wall')
xlabel('Linewidth (Hz)')
ylabel('Q^2')
legend('4 QAM', '16 QAM', '64 QAM')


%% Lorentzian 
% with tone fact = 0.2 and HWHM = 0.5, zero outside 1GHz gap
BER4_L0 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.3482e-05, 0.00083361];
Q4_L0 = [19.8291, 19.856, 19.8168, 19.7344, 19.6876, 19.6064, 19.363, ...
    18.6381, 17.8502, 16.4848, 14.0921, 11.8904];

BER16_L0 = [2.9352e-05, 5.2834e-05, 7.6316e-05, 4.1093e-05, 4.6964e-05, ...
    5.2834e-05, 8.8057e-05, 0.00032288,0.0010273, 0.0037278, 0.016132, 0.039855];
Q16_L0 = [19.0369, 19.034, 18.9988, 19.0068, 18.9427,18.7911, 18.6149, ...
    18.0584, 17.3215, 16.1394, 13.9125, 11.6003];

BER64_L0 = [0.017486, 0.018093, 0.017204, 0.017799, 0.018335, 0.019275, ...
    0.021149, 0.025505, 0.034722, 0.047852, 0.078386, 0.1125];
Q64_L0 = [18.7665, 18.7211,18.7746, 18.7293, 18.6767, 18.5767, 18.3649, ...
    17.9215, 17.1029, 15.9904, 13.7237, 11.4681];
GMIx64_L0 = [5.5229, 5.5271, 5.5286, 5.5234, 5.5055, 5.4833, 5.4338, 5.3462, ...
    5.1598, 4.8651, 4.2218, 3.5921];
GMIy64_L0 = [5.539, 5.5418, 5.5778, 5.5596, 5.5281, 5.5174, 5.4605, 5.3789, ...
    5.1776, 4.9162, 4.2519, 3.5579];

% tone_fact=0.2, DC_fact = 0.02, zero below -9dB(12.6%)
BER4_L9 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.3482e-05, 0.00093928];
Q4_L9 = [18.5914, 18.5909, 18.5239, 18.5395, 18.4776, 18.4084, 18.2208, ...
    17.7501, 17.0869, 16.0105, 13.8521, 11.8598];

BER16_L9 = [0.00041093, 0.00052247, 0.00046964, 0.00043442, 0.00046377, ...
    0.00055182, 0.00069859, 0.0013091, 0.0022249, 0.0056826, 0.019073, 0.039661];
Q16_L9 = [17.9237, 17.9074, 17.8933, 17.883, 17.8374, 17.7612, 17.5491, ...
    17.1448, 16.6088, 15.6603, 13.555, 11.5727];

BER64_L9 = [0.02866, 0.028617, 0.028859, 0.02902, 0.029963, 0.030409, ...
    0.031888, 0.036291, 0.04341, 0.055848, 0.082281, 0.11769];
Q64_L9 = [17.6465, 17.6435, 17.6132, 17.5846, 17.5292, 17.4891, 17.3435, ...
    16.9411, 16.3424, 15.4068, 13.4395, 11.2837];
GMIx64_L9 = [5.3297, 5.3447, 5.3506, 5.325, 5.3273, 5.3002, 5.2772, 5.1615, ...
    5.0227, 4.736, 4.1754, 3.5455];
GMIy64_L9 = [5.3912, 5.39, 5.3943, 5.3993, 5.375, 5.3613, 5.3173, 5.2065, ...
    5.0597, 4.7631, 4.1884, 3.5919];

% tone_fact=0.2, DC_fact = 0.02, full lineshape
BER4_L = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7.0446e-05, 0.0013502];
Q4_L = [17.9147, 17.9105, 17.8786, 17.8542, 17.8398, 17.7934, 17.5963, ...
    17.2345, 16.6614, 15.7021, 13.7844, 11.7535];

BER16_L = [0.0010919, 0.0010508, 0.0010743, 0.0012093, 0.0011506, 0.0013854, ...
    0.00145, 0.0020781, 0.0034225, 0.0067804, 0.021363, 0.04107];
Q16_L = [17.212, 17.2118, 17.1798, 17.1914, 17.1352, 17.0969, 16.9733, ...
    16.6524, 16.1274, 15.282, 13.2737, 11.4414];

BER64_L = [0.03579, 0.035732, 0.036663, 0.036135, 0.036315, 0.037563, ...
    0.039, 0.042827, 0.049347, 0.05964, 0.086914, 0.11548];
Q64_L = [17.0364, 17.041, 16.9755, 17.0148, 16.9779, 16.9228, 16.7851, ...
    16.4575, 15.9483, 15.1004, 13.1938, 11.3391];
GMIx64_L = [5.1816, 5.2038, 5.1847, 5.1935, 5.1851, 5.1574, 5.1228, 5.0391, ...
    4.9113, 4.6378, 4.1168, 3.5709];
GMIy64_L = [5.1662, 5.1657, 5.1768, 5.175, 5.1763, 5.1603, 5.1203, 5.0176, ...
    4.8674, 4.6406, 4.1089, 3.5853];

figure(5)
loglog(linewidth, BER4_L0, '-^', linewidth, BER16_L0, '-p', linewidth, BER64_L0, '-.', ...
    linewidth, BER4_L9, '-^', linewidth, BER16_L9, '-p', linewidth, BER64_L9, '-.', ...
    linewidth, BER4_L, '-^', linewidth, BER16_L, '-p', linewidth, BER64_L, '-.')
title('Lorentzian')
xlabel('Linewidth (Hz)')
ylabel('Bit Error Rate')
legend('4 QAM - 0', '16 QAM - 0', '64 QAM - 0', '4 QAM - 9', '16 QAM - 9', '64 QAM - 9', '4 QAM', '16 QAM', '64 QAM')

figure(6)
semilogx(linewidth, Q4_L0, '-^', linewidth, Q16_L0, '-p', linewidth, Q64_L0, '-.', ...
    linewidth, Q4_L9, '-^', linewidth, Q16_L9, '-p', linewidth, Q64_L9, '-.',...
    linewidth, Q4_L, '-^', linewidth, Q16_L, '-p', linewidth, Q64_L, '-.')
title('Lorentzian')
xlabel('Linewidth (Hz)')
ylabel('Q^2')
legend('4 QAM - 0', '16 QAM - 0', '64 QAM - 0', '4 QAM - 9', '16 QAM - 9', '64 QAM - 9', '4 QAM', '16 QAM', '64 QAM')

%% Comparison
deltaBER4_BW = BER4_PC - BER4_BW; 
meanBER4_BW = sprintf('4 QAM Brickwall, mean delta=%0.4f', mean(deltaBER4_BW));
deltaQ4_BW = Q4_BW - Q4_PC;
meanQ4_BW = sprintf('4 QAM Brickwall, mean delta=%0.4f', mean(deltaQ4_BW));
deltaBER16_BW = BER16_PC - BER16_BW;%(1:end-1);
meanBER16_BW = sprintf('16 QAM Brickwall, mean delta=%0.4f', mean(deltaBER16_BW));
deltaQ16_BW = Q16_BW - Q16_PC;
meanQ16_BW = sprintf('16 QAM Brickwall, mean delta=%0.4f', mean(deltaQ16_BW));
deltaBER64_BW = BER64_PC - BER64_BW;
meanBER64_BW = sprintf('64 QAM Brickwall, mean delta=%0.4f', mean(deltaBER64_BW));
deltaQ64_BW = Q64_BW - Q64_PC;
meanQ64_BW = sprintf('64 QAM Brickwall, mean delta=%0.4f', mean(deltaQ64_BW));

deltaBER4_L0 = BER4_PC - BER4_L0;
meanBER4_L0 = sprintf('4 QAM 0 Lorentzian, mean delta=%0.4f', mean(deltaBER4_L0));
deltaQ4_L0 = Q4_L0 - Q4_PC;
meanQ4_L0 = sprintf('4 QAM 0 Lorentzian, mean delta=%0.4f', mean(deltaQ4_L0));
deltaBER16_L0 = BER16_PC - BER16_L0;%(1:end-1);
meanBER16_L0 = sprintf('16 QAM 0 Lorentzian, mean delta=%0.4f', mean(deltaBER16_L0));
deltaQ16_L0 = Q16_L0 - Q16_PC;
meanQ16_L0 = sprintf('16 QAM 0 Lorentzian, mean delta=%0.4f', mean(deltaQ16_L0));
deltaBER64_L0 = BER64_PC - BER64_L0;
meanBER64_L0 = sprintf('64 QAM 0 Lorentzian, mean delta=%0.4f', mean(deltaBER64_L0));
deltaQ64_L0 = Q64_L0 - Q64_PC;
meanQ64_L0 = sprintf('64 QAM 0 Lorentzian, mean delta=%0.4f', mean(deltaQ64_L0));

deltaBER4_L9 = BER4_PC - BER4_L9;
meanBER4_L9 = sprintf('4 QAM 9dB Lorentzian, mean delta=%0.4f', mean(deltaBER4_L9));
deltaQ4_L9 = Q4_L9 - Q4_PC;
meanQ4_L9 = sprintf('4 QAM 9dB Lorentzian, mean delta=%0.4f', mean(deltaQ4_L9));
deltaBER16_L9 = BER16_PC - BER16_L9;%(1:end-1);
meanBER16_L9 = sprintf('16 QAM 9dB Lorentzian, mean delta=%0.4f', mean(deltaBER16_L9));
deltaQ16_L9 = Q16_L9 - Q16_PC;
meanQ16_L9 = sprintf('16 QAM 9dB Lorentzian, mean delta=%0.4f', mean(deltaQ16_L9));
deltaBER64_L9 = BER64_PC - BER64_L9;
meanBER64_L9 = sprintf('64 QAM 9dB Lorentzian, mean delta=%0.4f', mean(deltaBER64_L9));
deltaQ64_L9 = Q64_L9 - Q64_PC;
meanQ64_L9 = sprintf('64 QAM 9dB Lorentzian, mean delta=%0.4f', mean(deltaQ64_L9));

deltaBER4_L = BER4_PC - BER4_L;
meanBER4_L = sprintf('4 QAM Lorentzian, mean delta=%0.4f', mean(deltaBER4_L));
deltaQ4_L = Q4_L - Q4_PC;
meanQ4_L = sprintf('4 QAM Lorentzian, mean delta=%0.4f', mean(deltaQ4_L));
deltaBER16_L = BER16_PC - BER16_L;%(1:end-1);
meanBER16_L = sprintf('16 QAM Lorentzian, mean delta=%0.4f', mean(deltaBER16_L));
deltaQ16_L = Q16_L - Q16_PC;
meanQ16_L = sprintf('16 QAM Lorentzian, mean delta=%0.4f', mean(deltaQ16_L));
deltaBER64_L = BER64_PC - BER64_L;
meanBER64_L = sprintf('64 QAM Lorentzian, mean delta=%0.4f', mean(deltaBER64_L));
deltaQ64_L = Q64_L - Q64_PC;
meanQ64_L = sprintf('64 QAM Lorentzian, mean delta=%0.4f', mean(deltaQ64_L));

figure(100)
semilogx(linewidth, deltaBER4_BW,'-d', linewidth, deltaBER16_BW,'-+', ...
    linewidth, deltaBER64_BW,'-x', linewidth, deltaBER4_L,'-^',...
    linewidth, deltaBER16_L,'-p', linewidth, deltaBER64_L, '-.',...
    linewidth, deltaBER4_L0,'-^',linewidth, deltaBER16_L0,'-p', ...
    linewidth, deltaBER64_L0, '-.', linewidth, deltaBER4_L9,'-^',...
    linewidth, deltaBER16_L9,'-p', linewidth, deltaBER64_L9, '-.')
title('BER Improvement')
xlabel('Linewidth (Hz)')
ylabel('BER PC - BER x')
legend(meanBER4_BW, meanBER16_BW, meanBER64_BW, meanBER4_L, meanBER16_L, ...
    meanBER64_L, meanBER4_L0, meanBER16_L0, meanBER64_L0, meanBER4_L9, meanBER16_L9, meanBER64_L9)
legend('Location', 'best')

figure(101)
semilogx(linewidth, deltaQ4_BW,'-d', linewidth, deltaQ16_BW,'-+',...
    linewidth, deltaQ64_BW,'-x', linewidth, deltaQ4_L,'-^',...
    linewidth, deltaQ16_L,'-p', linewidth, deltaQ64_L, '-.', ...
    linewidth, deltaQ4_L0,'-^', linewidth, deltaQ16_L0,'-p', ...
    linewidth, deltaQ64_L0, '-.', linewidth, deltaQ4_L9,'-^',...
    linewidth, deltaQ16_L9,'-p', linewidth, deltaQ64_L9, '-.')
title('Q^2 Improvement')
xlabel('Linewidth (Hz)')
ylabel('Q x - Q PC')
legend(meanQ4_BW, meanQ16_BW, meanQ64_BW, meanQ4_L, meanQ16_L, meanQ64_L, ...
    meanQ4_L0, meanQ16_L0, meanQ64_L0, meanQ4_L9, meanQ16_L9, meanQ64_L9)
legend('Location', 'best')


figure(7)
loglog(linewidth, BER4_PC, '-o', linewidth, BER16_PC, '-*', ...
    linewidth, BER64_PC, '-s', linewidth, BER4_BW, '-d', ...
    linewidth, BER16_BW, '-+', linewidth, BER64_BW, '-x', ...
    linewidth, BER4_L0, '-^', linewidth, BER16_L0, '-p', linewidth, BER64_L0, '-.')
title('Comparison')
xlabel('Linewidth (Hz)')
ylabel('Bit Error Rate')
legend('Phasecomp 4 QAM', 'Phasecomp 16 QAM', 'Phasecomp 64 QAM', ...
    'Brickwall 4 QAM', 'Brickwall 16 QAM', 'Brickwall 64 QAM', ...
    'Lorentzian 4 QAM', 'Lorentzian 16 QAM', 'Lorentzian 64 QAM')
legend('Location', 'best')

figure(8)
semilogx(linewidth, Q4_PC, '-o', linewidth, Q16_PC, '-*', ...
    linewidth, Q64_PC, '-s', linewidth, Q4_BW, '-d', ...
    linewidth, Q16_BW, '-+', linewidth, Q64_BW, '-x', ...
    linewidth, Q4_L0, '-^', linewidth, Q16_L0, '-p', linewidth, Q64_L0, '-.')
title('Comparison')
xlabel('Linewidth (Hz)')
ylabel('Q^2')
legend('Phasecomp 4 QAM', 'Phasecomp 16 QAM', 'Phasecomp 64 QAM', ...
    'Brickwall 4 QAM', 'Brickwall 16 QAM', 'Brickwall 64 QAM',...
    'Lorentzian 4 QAM', 'Lorentzian 16 QAM', 'Lorentzian 64 QAM')
legend('Location', 'best')

% figure(9)
% semilogx(linewidth, GMIx64_PC, '-s',linewidth, GMIy64_PC, '-s', ...
%     linewidth, GMIx64_BW, '-x',linewidth, GMIy64_BW, '-x', ...
%     linewidth, GMIx64_L0, '-.', linewidth, GMIy64_L0, '-.')
% title('Comparison')
% xlabel('Linewidth (Hz)')
% ylabel('GMI')
% legend('Phasecomp x','Phasecomp y','Brickwall x','Brickwall y','Lorentzian x', 'Lorentzian y')
% legend('Location', 'best')


