function [RxInew, RxQnew] = func_hybridIQcomp(RxI, RxQ)

% Gram-Smitt Orthognalization for reciever front-end compensation
%
% inputs:
% RxI - real part of field from receiver
% RxQ - imaginary part of field from reciever
%
% outputs:
% 
% RxInew - orthogonalized real part of field from receiver 
% RxQnew - orthogonalized imaginary part of field from receiver 


Pt = mean(RxI.^2+RxQ.^2);

rho = mean(RxI.*RxQ);
Pi = mean(RxI.^2);

RxInew = RxI/sqrt(Pi);
RxQ = RxQ - rho.*RxI/Pi;

Pq = mean(RxQ.^2);
RxQnew = RxQ/sqrt(Pq);

RxInew = sqrt(Pt/2)*RxInew;
RxQnew = sqrt(Pt/2)*RxQnew;