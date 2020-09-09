function Gen_PM_MQAM(M,Baud,DACrate,Beta,Att_stop,Nsc,sep_fact,dc_fact,PE_on)

% manditory inputs:
%
% M - modulation index (4 = 4-QAM = QPSK, 16 = 16QAM, etc.)
% Baud - desired baud rate [Gbd]
% DACrate - sampling rate of the DAC in the transmitter (e.g. AWG) [GSa/s]

% outputs:
%
% outputs to files, real and imgainary comonants of generated signal and a
% .mat file with all of the signal information (good for bit-error
% checking, amonst other things)

% optional inputs:
%
% Beta - roll-off of the RRC filter used for pulse shaping. For NRZ, Beta =
% 1 (i.e. 100%) is ok, for Nyquist-shaping, generall 0.1 < Beta < 0.01 
% (i.e. 10% - 1%) is used.
% Att_stop - stop band attenuation of the RRC filter [dB]. Set to about 25
% dB, higher values make for more complex filters (... comp. time)
% Nsc - Number of sub-carriers. Have a chat to Bill about this if
% interested
% sep_fact - sub carrier separation factor ... again, ask if you're keen
% dc_fact - add in a little residual carrier ... good for SCs
% PE_on - pre-emphasis filter to eliminate transceiver roll-off ...

if (~exist('Beta','var'))
Beta = 1; %%%%%%Roll-off factor
end
if (~exist('Att_stop','var'))
Att_stop = 25; %%%%Stop band attenuation
end
if (~exist('Nsc','var'))
Nsc = 1; %%number of subcarriers
end
if (~exist('sep_fact','var'))
sep_fact=1; %% separation factor beyone sc rate ...
end
if (~exist('dc_fact','var'))
dc_fact=0;
end
if (~exist('PE_on','var'))
PE_on=0;
end

L_target = 2^18; %%%total number of samples
L_total = L_target;
sps = 2;
os = DACrate/(Baud/Nsc);


%%%%%%RRC filter design%%%%%
rrc = fdesign.pulseshaping(sps,'Square Root Raised Cosine','Ast,Beta',Att_stop,Beta);
rrc_filter = design(rrc);

L_data = round(L_total/os)-1;
for ii_Nsc=1:Nsc
TxX_bits(ii_Nsc,:) = randi([0 M-1],L_data,1);
dataX(ii_Nsc,:) = qammod(TxX_bits(ii_Nsc,:),M,'gray');
TX(ii_Nsc,:) = [dataX(ii_Nsc,:)];
TxY_bits(ii_Nsc,:) = randi([0 M-1],L_data,1);
dataY(ii_Nsc,:) = qammod(TxY_bits(ii_Nsc,:),M,'gray');
TY(ii_Nsc,:) = [dataY(ii_Nsc,:)];
end

%%% pulse shape
up_x = upsample(TX.',sps);
RRC_x = filter(rrc_filter,up_x);
up_y = upsample(TY.',sps);
RRC_y = filter(rrc_filter,up_y);

up_x=resample(RRC_x,DACrate*1000,sps*Baud/Nsc*1000,100);
up_y=resample(RRC_y,DACrate*1000,sps*Baud/Nsc*1000,100);

TxX=[up_x;zeros(L_target-length(up_x(:,1)),Nsc)];
TxY=[up_y;zeros(L_target-length(up_y(:,1)),Nsc)];

t=(0:1:(length(TxX(:,1))-1))'/(DACrate*1e9); %time array for resampled data
f=linspace(-DACrate/2,DACrate/2,length(TxX(:,1))); %freq array for resampled data FFT

df=Baud/Nsc;
dfs=((0:1:(Nsc-1))*df-((Nsc-1)*df/2))*sep_fact;
TxX=(TxX+(dc_fact*log2(M))).*exp(-1i*2*pi*dfs*1e9.*t); %frequency shifted signal
TxY=(TxY+(dc_fact*log2(M))).*exp(-1i*2*pi*dfs*1e9.*t); %frequency shifted signal
TxX=sum(TxX,2);
TxY=sum(TxY,2);
 
% figure(1); plot(t,real(TxX),'b'); hold on; plot(t,imag(TxX),'r');
% figure(2); plot(f,20*log10(fftshift(abs(fft(TxX)))));

if PE_on==1;
    %apply optically measured preemphasis
    f_dsp=linspace(0,DACrate/2,length(TxX)/2)*1e-3; %sample domain frequnecy [THz]
    load('Sumi_64GSaps_50Gbd_PE_filt.mat');
    pe_filt_interp=interp1(f_ssb,pe_filt,f_dsp).';
    pe_filt_interp(isnan(pe_filt_interp))=max(pe_filt_interp(~isnan(pe_filt_interp)));
    pe_filt_dsp=[flipud(pe_filt_interp);pe_filt_interp];
    TxX_PE=ifft(ifftshift(fftshift(fft(TxX)).*sqrt(10.^(pe_filt_dsp/10))));
    TxY_PE=ifft(ifftshift(fftshift(fft(TxY)).*sqrt(10.^(pe_filt_dsp/10))));
    xreal_PE=real(TxX_PE);
    ximag_PE=imag(TxX_PE);
    yreal_PE=real(TxY_PE);
    yimag_PE=imag(TxY_PE);
%     figure; plot(linspace(-DACrate/2,DACrate/2,length(TxX_PE)),20*log10(fftshift(abs(fft(TxX_PE)))))
end

if M==4
    form='QPSK';
else
    form=[num2str(M) 'QAM'];
end

sav_dir='data_files';
if exist(sav_dir,'dir')~=7
    mkdir(sav_dir)
end

fid = fopen([sav_dir '/' 'tmp_real_X.txt'], 'wt');
fprintf(fid, '%2.8f\n',real(TxX));
fclose(fid);
fid = fopen([sav_dir '/' 'tmp_imag_X.txt'], 'wt');
fprintf(fid, '%2.8f\n',imag(TxX));
fclose(fid);
fid = fopen([sav_dir '/' 'tmp_real_y.txt'], 'wt');
fprintf(fid, '%2.8f\n',real(TxY));
fclose(fid);
fid = fopen([sav_dir '/' 'tmp_imag_y.txt'], 'wt');
fprintf(fid, '%2.8f\n',imag(TxY));
fclose(fid);
namefile = [sav_dir '/' 'tmp_transmit_data.mat'];
save(namefile,'TxX','TxY','dataX','dataY','rrc_filter','TxX_bits','TxY_bits','Beta','Att_stop');