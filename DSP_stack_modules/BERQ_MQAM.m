function [BER,Q]=BERQ_MQAM(recoverdata,originaldata,M)
% inputs:
% recoverdata - received complex field
% original data - data pattern complex field, synchronized to received
% field
% M - order of QAM (4=QPSK, 16=16QAM, ...)
%
% Outputs:
% BER - bit-error rate
% Q - signal qulaity factor in dB, extracted from error-vector-magnitude,
% directly proportional to signal SNR assuming gauissian noise statistics,
% and realted to linear Q as QdB=20*log10(Qlin) (... so strictly, a measure
% of Q^2 ...)


%normalize recieved field scale
recoverdata=recoverdata-mean(recoverdata);
recoverdata=recoverdata./sqrt(mean(abs(recoverdata).^2)).*sqrt(2/3*(M-1));

for ii=1:4
    recovtmp=recoverdata.*exp(1i*(ii-1)*pi/2);
    %demodulate data and recieved field
    Dec = qamdemod(recovtmp,M,'Gray');
    dec_bits= reshape(de2bi(Dec)',1,[]);
    ori_syms = qamdemod(originaldata,M,'Gray');
    ori_bits = reshape(de2bi(ori_syms)',1,[]);

%find BER
BERrot(ii)=length(find(dec_bits-ori_bits~=0))/(length(ori_bits));
end
[BER,ind]=min(BERrot);
recoverdata=recoverdata.*exp(1i*(ind-1)*pi/2);

%find Q from EVM    
noise=recoverdata-originaldata;
SNR=(2/3*(M-1))/mean(abs(noise).^2);
Q=10*log10(SNR);
end