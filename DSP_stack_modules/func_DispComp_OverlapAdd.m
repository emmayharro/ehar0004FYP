function [sig] = func_DispComp_OverlapAdd(fs, Lspan, sig)
% inputs:
% sig - complex field 
% fs - sampling frequnecy of fields [Hz]
% Lspan - length of fibre to compensate for [km]
%
% outputs:
% sig - complex field (with frequnecy offset)

N = 1024;
n = N/2;
zp = N/4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating the CD channel response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialised link parameters (use SI units)
D = 16e-6;
lambda = 1550e-9;
L = Lspan*1e3; % coverts to metres
c = 3e8;
% create transfer function
H(:,1) = -N/2:N/2-1;
H = H.^2*2*pi*D*lambda^2*L*fs^2/(2*c*N^2);
H = fftshift(H);
% plot(H*180/pi);
H = exp(-1i*H);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compensation for CD with Overlap-Add
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Splitting signal into FFT blocks and apply CD
L = length(sig);
B = floor(L/n);
sigB = zeros(N,B);

for j=1:B
    % x pol
    sigB(zp+1:N-zp,j) = sig((j-1)*n+1:j*n); % sort into block
    sigB(:,j) = fft(sigB(:,j)); % fft
    sigB(:,j) = sigB(:,j).*H;   % apply channel
    sigB(:,j) = ifft(sigB(:,j));    % ifft back into TD
end

% Overlap Add
sig = zeros(L,1);
% do middle blocks
for j=2:B-1
    sig((j-1)*n-zp+1:j*n+zp) = sig((j-1)*n-zp+1:j*n+zp)+sigB(:,j);
end

% % wrap first and last blocks
% % x pol
% sig(1:n+zp) = sig(1:n+zp)+sigB(zp+1:N,1); % first block
% sig(L-zp+1:L) = sig(L-zp+1:L)+ sigB(1:zp,1); % start of first to end of last
% sig(L-zp-n+1:L) = sig(L-zp-n+1:L)+sigB(1:N-zp,B); % last block
% sig(1:zp) = sig(1:zp)+ sigB(N-zp+1:N,B); % end of last to start of first

