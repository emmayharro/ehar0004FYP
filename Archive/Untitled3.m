close all; clear all; clc;

R = 2/pi;
x0 = 0;
x = linspace(-5, 5, 101);

L = (1/pi)*(0.5*R)./((x-x0).^2+(0.5*R)^2);

plot(x, L)


% 
% F = linspace(0,1,101);
% A = (1/pi)*(0.5*R)./((F-x0).^2+(0.5*R)^2);
% R = 0.0002; % ripple
% W = .1-20*log10(abs(A)); % weights
% d = fdesign.arbmag('F,A,R', F,A,R);
% Hd = design(d,'equiripple','weights',W,'SystemObject',true);
% fvtool(Hd,'MagnitudeDisplay','Zero-phase', 'FrequencyRange','[0, pi)',...
%     'Color','White');
