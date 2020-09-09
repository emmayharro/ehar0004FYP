function [RxX RxY] = func_FreqOffsetComp4th(fs, RxX, RxY)
% inputs:
% RxX - complex field
% RxY - complex field
% fs - sampling frequnecy of fields [GHz]
%
% outputs:
% RxX - complex field
% RxY - complex field

% len = 40000;
len = length(RxX);

estX = RxX(1:len);
estY = RxY(1:len);

%     aa=ones(length(estX),1);
%     sca_fac = 0.001;
%     aa(1:round(length(estX)*12/40))=sca_fac;
%     aa(end-round(length(estX)*10.5/40):end)=sca_fac;
%     estX = ifft(ifftshift(fftshift(fft(estX)).*aa));
% estY = ifft(ifftshift(fftshift(fft(estY)).*aa));

load('LPF_40_1_8.mat');
% % 
estX = filter(Num,1,estX);     % filter
estY = filter(Num,1,estY);

% figure(11); plot(real(estX)); hold on; plot(imag(estX),'r'); plot(real(estY), 'g'); plot(imag(estY), 'm'); hold off

% estX = fftshift(abs(fft(estX)).^2);
% estY = fftshift(abs(fft(estY)).^2);
estX = abs(fftshift(fft(estX.^4)));
estY = abs(fftshift(fft(estY.^4)));

% %%% kill DC term
% %kill 1
% fX=estX;fY=estY;
% FD = estX + estY;
% [~, ind] = max(FD);
% estX(ind)=(estX(ind-1)+estX(ind+1))/2;
% estY(ind)=(estY(ind-1)+estY(ind+1))/2;
% FD = estX + estY;
% [~, ind] = max(FD);
% win=10;
% estX(ind-win:ind+win)=(estX(ind-win-1)+estX(ind+win+1))/2;
% estY(ind-win:ind+win)=(estY(ind-win-1)+estY(ind+win+1))/2;

FD = estX + estY; % find peak
% figure(13); plot(10*log10(abs(FD)));

 % remove 3 lowest freq points
[~, ind] = max(FD);
% ind = 248364;
freq = ((ind-len/2)/len*2*pi)/4;
FreqOS = (freq*fs/(2*pi)/1e6);
figure(12); plot(10*log10(abs(estX))); hold on; plot(10*log10(abs(estY)), 'r'); 
text(300e3,120,['FreqOS=' num2str(FreqOS)],'fontsize',12), hold off;

len = length(RxX);
carrier = [1:len]';
carrier = exp(-1i*freq*carrier);
RxX = RxX.*carrier;
RxY = RxY.*carrier;
% figure (201)
% plot(20*log10(fftshift(abs(fft(carrier)))));
end