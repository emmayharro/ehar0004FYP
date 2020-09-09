function [Ex,Ey]=func_phaseComp_BlindPhaseSearch(Ex,Ey,Ntest,Nwin,M)
% inputs:
% Ex - complex field (no phase noise)
% Ey - complex field (no phase noise)
% Ntest - number of test phases over the interval -pi/4:pi/4
% Nwin - number of samples in averaging window for estimationalgorithm
% M - order of M-QAM modulation of signal
%
% outputs:
% Ex - complex field (with fphase noise)
% Ey - complex field (with phase noise)

Ex=Ex./sqrt(mean(abs(Ex).^2));
Ex=Ex./sqrt(mean(abs(Ex).^2));

const=qammod(0:M-1,M);
const=const./sqrt(mean(abs(const)).^2);

ph_test=linspace(-pi/4,pi/4,Ntest);

% %run Ex phase
% Ex_ph_test_win=zeros(length(Ex)-Nwin,Nwin);
% for ii=1:length(Ex)-Nwin-1
%     Ex_ph_test_win(ii,:)=Ex_ph4((1:Nwin)+ii-1);
%     for jj=1:Ntest
%         tmp=Ex_ph_test_win(ii,jj).*exp(1i*ph_test);
%         dist(kk) = min(abs(tmp(jj)-const).^2);
% end

%%% old trial %%%
for ii=1:length(Ex)-Nwin
    for jj=1:length(ph_test)
        Ex_tmp=Ex((0:Nwin)+ii).*exp(1i*ph_test(jj));
        for kk=1:length(Ex_tmp)
            dist(kk) = min(abs(Ex_tmp(kk)-const).^2);
        end
        dist_sum(jj)=sum(dist);
    end
    [val ind]=min(dist_sum);
    ph_x(ii)=ph_test(ind);
end
ph_x=unwrap(ph_x*4)/4;
figure(1000);plot(ph_x);
Ex=Ex(1:length(Ex)-Nwin).*exp(1i*ph_x);
%run Ey phase
for ii=1:length(Ey)-Nwin
    for jj=1:length(ph_test)
        Ey_tmp=Ey((0:Nwin)+ii).*exp(1i*ph_test(jj));
        for kk=1:length(Ey_tmp)
            dist(kk) = min(abs(Ey_tmp(kk)-const).^2);
        end
        dist_sum(jj)=sum(dist);
    end
    [val ind]=min(dist_sum);
    ph_y(ii)=ph_test(ind);
end
ph_y=unwrap(ph_y*4)/4;
Ey=Ey(1:length(Ey)-Nwin).*exp(1i*ph_y);

%dump edges
Ex=Ex(500:end-500);
Ey=Ey(500:end-500);