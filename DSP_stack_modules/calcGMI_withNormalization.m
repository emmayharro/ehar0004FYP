function [GMI]=calcGMI_withNormalization(x,y,labeling)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caclulates GMI with scaling of the signal power + noise power           %
%                                                                         %
%                                                                         %
% Written by Tobias Eriksson, tobias.eriksson@nokia.com, 20-jun-2016      %
% Original GMI file obtained from http://fehenberger.de/#sourcecode       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = x/sqrt(mean(abs(x).^2));
h = y*(x')/(x*x');
y = y/real(h);
sigma = var(y-x);
GMI = calcGMI2(x,y,labeling,sigma);


end