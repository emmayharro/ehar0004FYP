function [Ex,Ey] = impair_OSNR(Ex,Ey,f_samp,OSNR)
% inputs:
% Ex - complex field (no noise)
% Ey - complex field (no noise)
% f_samp - sampling frequnecy of fields [GHz]
% OSNR - OSNR to set, 12.5 GHz ref. BW [dB]
%
% outputs:
% Ex - complex field (with noise)
% Ey - complex field (with noise)

Ex = Ex./sqrt(mean(abs(Ex).^2)); %scale field to unit power
Ey = Ey./sqrt(mean(abs(Ey).^2)); %scale field to unit power
% display(['p_ave: ' num2str(mean(abs(Ex).^2+abs(Ey).^2)/2)])
% display(['p_ave Ex: ' num2str(mean(abs(Ex).^2))])
% pdB_avg = 10*log10(mean(abs(Ex).^2+abs(Ey).^2)/2);

% noise_x=randn(length(Ex),1)./sqrt(2)+1i.*randn(length(Ex),1)./sqrt(2);  %unit power noise
% noise_y=randn(length(Ey),1)./sqrt(2)+1i.*randn(length(Ey),1)./sqrt(2);  %unit power noise
noise_scaling = f_samp/12.5;    %scaling factor for noise power confined to 12.5 GHz
% noise_field_factor=sqrt(noise_scaling./10^(OSNR/10));   %scaling factor for noise fields
% 
% Ex=Ex+noise_x.*noise_field_factor;
% Ey=Ey+noise_y.*noise_field_factor;

Ex=awgn(Ex,OSNR-10*log10(noise_scaling),'measured');%,pdB_avg); %this didn't really work ...
Ey=awgn(Ey,OSNR-10*log10(noise_scaling),'measured');%,pdB_avg);