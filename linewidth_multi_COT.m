close all; clear all; 
clc;

Laser = [1e3, 1e4, 1e5, 2e5, 5e5, 8e5, 1e6, 2e6, 5e6, 8e6, 1e7, 2e7, 5e7, 8e7, 1e8];

%Multiband code, with COT phase processing, 4-QAM, 80 baud, OSNR=20, pass 1 only
BER480 = [0.00041046, 0.00046308, 0.00048939, 0.00047887, 0.00050518, 0.00039993, 0.00039467, 0.00048413, 0.0005578, 0.00048939, 0.00059464, 0.00099457, 0.0024522, 0.0051255, 0.0068725];
Q480 = [10.9594, 10.955, 10.9143, 10.9159, 10.9328, 10.9556, 10.9145, 10.8623, 10.8087, 10.7825, 10.7452, 10.4669, 9.8599, 9.2612, 8.9666];

%Multiband code, with COT phase processing, 16-QAM, 80 baud, OSNR=20, pass 1 only
BER1680 = [0.05021, 0.050094, 0.048763, 0.050192, 0.049947, 0.049755, 0.049899, 0.050623, 0.051599, 0.053867, 0.054975, 0.057759, 0.070057, 0.079508, 0.08683];
Q1680 = [10.8159, 10.835, 10.8849, 10.8277, 10.8189, 10.82, 10.8426, 10.8133, 10.7388, 10.6208, 10.5516, 10.3758, 9.7352, 9.1971, 8.8116];

%Multiband code, with COT phase processing, 64-QAM, 80 baud, OSNR=20, pass 1 only
BER6480 = [0.141751, 0.142125, 0.141355, 0.142535, 0.143028, 0.142439, 0.142239, 0.142109, 0.144217, 0.145377, 0.146522, 0.152332, 0.161579, 0.172178, 0.177078];
Q6480 = [10.8052, 10.7681, 10.8397, 10.7747, 10.7517, 10.7872, 10.7819, 10.7644, 10.6710, 10.6176, 10.5606, 10.2557, 9.7488, 9.2255, 8.9382];

%Multiband code, with COT phase processing, 4-QAM, 40 baud, OSNR=20, pass 1 only
BER440 = [9.3928e-05, 4.6964e-05, 4.6964e-05, 2.3482e-05, 5.8705e-05, 3.5223e-05, 2.3482e-05, 3.5223e-05, 0.00010567, 9.3928e-05, 0.00011741, 0.00029352, 0.0022308, 0.0073498, 0.010849];
Q440 = [12.6886, 12.6895, 12.715, 12.6211, 12.5894, 12.6708, 12.5999, 12.5413, 12.3298, 12.2414, 12.1454, 11.7357, 10.5527, 9.4994, 8.9673];

%Multiband code, with COT phase processing, 16-QAM, 40 baud, OSNR=20, pass 1 only
BER1640 = [0.026088, 0.026435, 0.025754, 0.026288, 0.026752, 0.026734, 0.027556, 0.027967, 0.031102, 0.031624, 0.032434, 0.038904, 0.056791, 0.070346, 0.079398];
Q1640 = [12.4449, 12.4858, 12.525, 12.4877, 12.4188, 12.4456, 12.3729, 12.3353, 12.1047, 12.034, 11.9689, 11.5058, 10.3311, 9.5054, 8.8968];

%Multiband code, with COT phase processing, 64-QAM, 40 baud, OSNR=20, pass 1 only
BER6440 = [0.10872, 0.10957, 0.10916, 0.10877, 0.10979, 0.10837, 0.10972, 0.11049, 0.11426, 0.1158, 0.11669, 0.12397, 0.14192, 0.15886, 0.16714];
Q6440 = [12.4157, 12.333, 12.34, 12.3745, 12.3694, 12.3939, 12.3288, 12.2754, 12.049, 11.9436, 11.8917, 11.4736, 10.3655, 9.4238, 8.9706];

%Multiband code, with COT phase processing, 4-QAM, 40 baud, OSNR=40, pass 1 only
ber444 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9.3928e-05, 0.0014559, 0.0030644];
q444 = [24.2918, 24.2735, 24.2204, 24.1602, 23.9029, 23.6391, 23.5344, 22.9276, 21.5042, 20.4451, 19.787, 17.7366, 14.2656, 12.4018, 11.4381];

%Multiband code, with COT phase processing, 16-QAM, 40 baud, OSNR=40, pass 1 only
ber1644 = [0, 0, 0, 0, 0, 0, 0, 5.8705e-06, 5.8705e-05, 0.00031701, 0.00046964, 0.003082, 0.018134, 0.03355, 0.042479];
q1644 = [22.2684, 22.2569, 22.22, 22.163, 22.0554, 21.8492, 21.8419, 21.3712, 20.214, 19.3471, 18.9447, 17.1521, 13.9438, 12.1303, 11.3689];

%Multiband code, with COT phase processing, 64-QAM, 40 baud, OSNR=40, pass 1 only
ber6444 = [0.0033031, 0.0034088, 0.0034636, 0.0036475, 0.0039254, 0.0041524, 0.0046612, 0.0062931, 0.010586, 0.016402, 0.019877, 0.03662, 0.071217, 0.095117, 0.11268];
q6444 = [21.6469, 21.6134, 21.5948, 21.5763, 21.4544, 21.3596, 21.23, 20.8831, 20.0157, 19.1466, 18.6679, 16.7502, 13.8554, 12.2237, 11.0175];

%Multiband code, with COT phase processing, 4-QAM, 40 baud, OSNR=100, pass 1 only
ber441 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00022308, 0.00096276, 0.0030292];
q441 = [25.0079, 25.0006, 24.9162, 24.8259, 24.5386, 24.3677, 24.1978, 23.547, 21.8523, 20.6962, 20.1071, 17.831, 14.4093, 12.4126, 11.5055];

%Multiband code, with COT phase processing, 16-QAM, 40 baud, OSNR=100, pass 1 only
ber1641 = [0, 0, 0, 0, 0, 0, 0, 0, 9.9798e-05, 0.00034049, 0.00051073, 0.0032111, 0.019877, 0.033039, 0.044692];
q1641 = [22.2079, 22.2029, 22.1698, 22.1084, 21.9388, 21.7874, 21.7446, 21.3233, 20.2231, 19.3826, 18.8986, 17.0171, 13.7754, 12.237, 11.2625];

%Multiband code, with COT phase processing, 64-QAM, 40 baud, OSNR=100, pass 1 only
ber6441 = [0.0026182, 0.0026261, 0.002673, 0.00281, 0.0032209, 0.0034597, 0.0039684, 0.0053617, 0.010457, 0.014888, 0.018042, 0.034878, 0.06915, 0.095794, 0.10923];
q6441 = [21.9097, 21.9011, 21.8678, 21.8278, 21.6643, 21.5498, 21.4841, 21.0878, 20.065, 19.3471, 18.9054, 16.9617, 13.9875, 12.1058, 11.228];

%Multiband code, with COT phase processing, 4-QAM, 40 baud, OSNR=200, pass 1 only
ber442 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00015263, 0.0013032, 0.002947];
q442 = [25.0677, 25.0547, 24.9911, 24.8573, 24.6323, 24.442, 24.148, 23.5594, 21.9894, 20.6006, 20.1751, 17.7437, 14.3853, 12.4598, 11.5267];

%Multiband code, with COT phase processing, 16-QAM, 40 baud, OSNR=200, pass 1 only
ber1642 = [0, 0, 0, 0, 0, 0, 5.8705e-06, 5.8705e-06, 9.9798e-05, 0.00034636, 0.00038158, 0.0029528, 0.018897, 0.035833, 0.044199];
q1642 = [22.6023, 22.5935, 22.5473, 22.4807, 22.3102, 22.147, 22.107, 21.6594, 20.4479, 19.5385, 19.1951, 17.283, 13.9665, 12.0311, 11.2428];

%Multiband code, with COT phase processing, 4-QAM, 80 baud, OSNR=200, pass 1 only
ber482 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00011577, 0.00025785];
q482 = [31.324, 31.2989, 31.0545, 30.7692, 30.066, 29.5348, 29.1726, 27.69, 24.9632, 23.4296, 22.5722, 19.6943, 16.1282, 14.1252, 13.2242];

%Multiband code, with COT phase processing, 16-QAM, 80 baud, OSNR=200, pass 1 only
ber1682 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 5.2623e-06, 7.8934e-06, 0.00049728, 0.007625, 0.017742, 0.026911];
q1682 = [26.7745, 26.766, 26.673, 26.5805, 26.2991, 26.0411, 25.8523, 25.1496, 23.427, 22.2526, 21.6194, 19.2208, 15.8973, 14.1313, 13.0105];

%Multiband code, with COT phase processing, 4-QAM, 100 baud, OSNR=200, pass 1 only
ber412 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4.5368e-05, 0.00025159];
q412 = [32.3577, 32.3263, 32.0128, 31.7066, 30.8975, 30.0948, 29.7411, 28.0766, 25.2355, 23.4221, 22.7314, 19.9546, 16.1956, 14.1941, 13.2919];

figure(1)
loglog(Laser, BER440, Laser, BER1640, Laser, BER6440, Laser, BER480, Laser, BER1680, Laser, BER6480, Laser, ber444, Laser, ber1644, Laser, ber6444, Laser, ber441, Laser, ber1641, Laser, ber6441, Laser, ber442, Laser, ber1642, Laser, ber482, Laser, ber1682, Laser, ber412)
title('Mean BER (pass1)')
legend('4-QAM, 40baud, 20OSNR','16-QAM, 40baud, 20OSNR','64-QAM, 40baud, 20OSNR','4-QAM, 80baud, 20OSNR','16-QAM, 80baud, 20OSNR','64-QAM, 80baud, 20OSNR','4-QAM, 40baud, 40OSNR', '16-QAM, 40baud, 40OSNR', '64-QAM, 40baud, 40OSNR','4-QAM, 40baud, 100OSNR','16-QAM, 40baud, 100OSNR', '64-QAM, 40baud, 100OSNR','4-QAM, 40baud, 200OSNR', '16-QAM, 40baud, 200OSNR', '4-QAM, 80baud, 200OSNR', '16-QAM, 80baud, 200OSNR', '4-QAM, 100baud, 200OSNR')
legend('Location', 'best')

figure(2)
semilogx(Laser, Q440, Laser, Q1640, Laser, Q6440, Laser, Q480, Laser, Q1680, Laser, Q6480, Laser, q444, Laser, q1644, Laser, q6444, Laser, q441, Laser, q1641, Laser, q6441, Laser, q442,Laser, q1642, Laser, q482, Laser, q1682, Laser, q412)
title('Mean Q^2 (pass1)')
legend('4-QAM, 40baud, 20OSNR','16-QAM, 40baud, 20OSNR','64-QAM, 40baud, 20OSNR','4-QAM, 80baud, 20OSNR', '16-QAM, 80baud, 20OSNR', '64-QAM, 80baud, 20OSNR', '4-QAM, 40baud, 40OSNR', '16-QAM, 40baud, 40OSNR', '64-QAM, 40baud, 40OSNR', '4-QAM, 40baud, 100OSNR', '16-QAM, 40baud, 100OSNR', '64-QAM, 40baud, 100OSNR','4-QAM, 40baud, 200OSNR', '16-QAM, 40baud, 200OSNR', '4-QAM, 80baud, 200OSNR', '16-QAM, 80baud, 200OSNR', '4-QAM, 100baud, 200OSNR')
legend('Location', 'best')