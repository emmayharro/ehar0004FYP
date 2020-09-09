function Gen_linewidth(linewidth,DACrate)



L_target = 2^18; %%%total number of samples
L_total = L_target;

t=(1:1:L_target).'./DACrate;

TxX=ones(L_target,1).*exp(-1i*2*pi*10*t);
TxY=zeros(L_target,1);

%phase noise
[TxX,TxY] = impair_phaseNoise(TxX,TxY,DACrate.*1e9,linewidth);

sav_dir='data_files';
if exist(sav_dir,'dir')~=7
    mkdir(sav_dir)
end

fid = fopen([sav_dir '/' 'lw_real_X.txt'], 'wt');
fprintf(fid, '%2.8f\n',real(TxX));
fclose(fid);
fid = fopen([sav_dir '/' 'lw_imag_X.txt'], 'wt');
fprintf(fid, '%2.8f\n',imag(TxX));
fclose(fid);
fid = fopen([sav_dir '/' 'lw_real_y.txt'], 'wt');
fprintf(fid, '%2.8f\n',real(TxY));
fclose(fid);
fid = fopen([sav_dir '/' 'lw_imag_y.txt'], 'wt');
fprintf(fid, '%2.8f\n',imag(TxY));
fclose(fid);
namefile = [sav_dir '/' 'lw_transmit_data.mat'];
save(namefile,'TxX','TxY','DACrate','linewidth');
