function [Ex,Ey]=func_phaseComp_ViterbiViterbi(Ex,Ey,Nwin)
% inputs:
% Ex - complex field (no phase noise)
% Ey - complex field (no phase noise)
% Nwin - number of samples in averaging window for estimationalgorithm
%
% outputs:
% Ex - complex field (with fphase noise)
% Ey - complex field (with phase noise)

%x-pol
ph_x = angle(Ex);
Ex_ph4 = exp(1i*ph_x*4);
Ex_ph4_win=zeros(length(Ex)-Nwin,Nwin);
for ii=1:length(Ex)-Nwin-1
    Ex_ph4_win(ii,:)=Ex_ph4((1:Nwin)+ii-1);
end
ph_x_est=sum(Ex_ph4_win,2);
dims_in=size(Ex);
if dims_in(1)==1
    ph_x_est=ph_x_est.';
end
ph_x_est=unwrap(angle(ph_x_est));
ph_x_est=(ph_x_est-pi)/4;
Ex=Ex(ceil(Nwin/2):length(Ex)-floor(Nwin/2)-1).*exp(-1i*ph_x_est);

% figure(100);plot(ph_x_est)

%y-pol
ph_y = angle(Ey);
Ey_ph4 = exp(1i*ph_y*4);
Ey_ph4_win=zeros(length(Ey)-Nwin,Nwin);
for ii=1:length(Ey)-Nwin-1
    Ey_ph4_win(ii,:)=Ey_ph4((1:Nwin)+ii-1);
end
ph_y_est=sum(Ey_ph4_win,2);
dims_in=size(Ey);
if dims_in(1)==1
    ph_y_est=ph_y_est.';
end
ph_y_est=unwrap(angle(ph_y_est));
ph_y_est=(ph_y_est-pi)/4;
Ey=Ey(ceil(Nwin/2):length(Ey)-floor(Nwin/2)-1).*exp(-1i*ph_y_est);

%dump edges
Ex=Ex(300:end-300);
Ey=Ey(300:end-300);