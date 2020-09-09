function Gen_SBS_tones(DACrate,tone_fact,BFS)

% %manditory inputs
% M = 64; %%%%%%% moindex-QAM (4 = 4-QAM = QPSK ...)
% Baud = 46; %%desired total baud rate [Gbd]
% DACrate = 64; %AWG sampling rate [GSa/s]


if (~exist('tone_fact','var'))
tone_fact=0.1;
end
if (~exist('BFS','var'))
BFS=10.893;
end


L_target = 2^18; %%%total number of samples
L_total = L_target;

TxX=zeros(L_target,1);
TxY=zeros(L_target,1);

t=(0:1:(length(TxX(:,1))-1))'/(DACrate*1e9); %time array for resampled data

tonef=20;

TxX=TxX+exp(-1i*2*pi*tonef*1e9.*t)+tone_fact.*exp(-1i*2*pi*(tonef+BFS)*1e9.*t);


sav_dir='data_files';
if exist(sav_dir,'dir')~=7
    mkdir(sav_dir)
end

fid = fopen([sav_dir '/' 'sbs_real_X.txt'], 'wt');
fprintf(fid, '%2.8f\n',real(TxX));
fclose(fid);
fid = fopen([sav_dir '/' 'sbs_imag_X.txt'], 'wt');
fprintf(fid, '%2.8f\n',imag(TxX));
fclose(fid);
fid = fopen([sav_dir '/' 'sbs_real_y.txt'], 'wt');
fprintf(fid, '%2.8f\n',real(TxY));
fclose(fid);
fid = fopen([sav_dir '/' 'sbs_imag_y.txt'], 'wt');
fprintf(fid, '%2.8f\n',imag(TxY));
fclose(fid);
namefile = [sav_dir '/' 'sbs_transmit_data.mat'];
save(namefile,'TxX','TxY','tonef','BFS');
