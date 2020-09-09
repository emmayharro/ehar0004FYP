function [Ex, Ey] = impair_phaseNoise(Ex, Ey, Fs, linewidth)
% inputs:
% Ex - complex field (no phase noise)
% Ey - complex field (no phase noise)
% Fs - sampling frequnecy of fields [Hz]
% linewidth - combined laser linewidth (LO+Sig) [Hz]
%
% outputs:
% Ex - complex field (with fphase noise)
% Ey - complex field (with phase noise)

n_samples = length(Ex);
rng('shuffle')
ts = 1/Fs;
deltaV = linewidth;
gauss_noise = sqrt(2*pi*deltaV*ts).*randn(n_samples, 1);
phase_noise = cumsum(gauss_noise);
t = ts.*(0:1:n_samples-1);
fnorm = linspace(-Fs/2, Fs/2, n_samples);
Ex = Ex.*exp(1i*phase_noise);
Ey = Ey.*exp(1i*phase_noise);
end