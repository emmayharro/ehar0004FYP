function [RxX RxY] = func_FreqOffsetComp(fs, RxX, RxY, kill_sw)
% inputs:
% RxX - complex field
% RxY - complex field
% fs - sampling frequnecy of fields [GHz]
%
% outputs:
% RxX - complex field
% RxY - complex field

if ~exist('kill_sw','var')
    kill_sw=0;
end

f=linspace(-fs/2,fs/2,length(RxX));

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

%figure(11); plot(real(estX)); hold on; plot(imag(estX),'r'); plot(real(estY), 'g'); plot(imag(estY), 'm'); hold off

% estX = fftshift(abs(fft(estX)).^2);
% estY = fftshift(abs(fft(estY)).^2);
estX = fftshift(abs(fft(estX)).^2);
estY = fftshift(abs(fft(estY)).^2);


FD = estX + estY; % find peak
% figure(13); plot(10*log10(abs(FD)));

 % remove 3 lowest freq points
[maxFD, ind] = max(FD);
% ind = 248364;
freq = ((ind-len/2)/len*2*pi);
FreqOS = f(ind);

% figure(12); plot(10*log10(abs(estX))); hold on; plot(10*log10(abs(estY)), 'r'); 
% text(300e3,120,['FreqOS=' num2str(FreqOS)],'fontsize',12), hold off;

len = length(RxX);
carrier = [1:len]';
carrier = exp(-1i*freq*carrier);
RxX = RxX.*carrier;
RxY = RxY.*carrier;
% figure (201)
% plot(20*log10(fftshift(abs(fft(carrier)))));

if kill_sw==1
%carrier kill
win=100;
fftX=fftshift(fft(RxX));
fftY=fftshift(fft(RxY));
fftX(ind-win:ind+win)=0;
fftY(ind-win:ind+win)=0;
RxX=ifft(ifftshift(fftX));
RxY=ifft(ifftshift(fftY));
end

end