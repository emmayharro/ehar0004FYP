%%Time-Domain MIMO-LMS
%%Chen Zhu
%%zhuc@student.unimelb.edu.au
%% *********************************************************************


function  [Hxx,Hyx,Hxy,Hyy,Ex_out, Ey_out] = MIMO_FIR_training_LMS(Ex_in, Ey_in, mu, FFE_length,ts_x,ts_y,sps)
%general parameters
sps = sps;                       % Samples per symbol
alpha =0.01;                  % Leaky factor alpha
ST = 0.05;                     % Weight of start-up taps

% Ex_in=sqrt(2)*Ex_in/(mean(abs(Ex_in)));
% Ey_in=sqrt(2)*Ey_in/(mean(abs(Ey_in)));

itertimes = floor((length(Ex_in) - FFE_length + 1) / sps);                    %exact total number of symbols to be processed
                              

%initialize filter components
Hxx=zeros(1,FFE_length);  
Hyx=zeros(1,FFE_length); 
Hxy=zeros(1,FFE_length); 
Hyy=zeros(1,FFE_length); 
Hxx(ceil(FFE_length/2)) = ST;
Hyy(ceil(FFE_length/2)) = ST;
% Hxx = Hxx;
% Hyy = Hyy;
%initialize detection vectors
Ex_out=zeros(1,itertimes);
Ey_out=zeros(1,itertimes);

for i = 1:length(ts_x);           %index refers to output symbols
    
    Ex_seq=zeros(FFE_length,1);
    Ey_seq=zeros(FFE_length,1);
    Ex_seq(1:FFE_length,1)=Ex_in(sps*i:sps*i+FFE_length-1);
    Ey_seq(1:FFE_length,1)=Ey_in(sps*i:sps*i+FFE_length-1);
  
    Ex_out(i)=Hxx*Ex_seq+Hyx*Ey_seq;
    Ey_out(i)=Hxy*Ex_seq+Hyy*Ey_seq;
    err_x=mu*(Ex_out(i)-ts_x(i));
    err_y=mu*(Ey_out(i)-ts_y(i));

    M = (1-mu*alpha);
    
    Hxx=M*Hxx-(err_x*conj(Ex_seq)).';
    Hyx=M*Hyx-(err_x*conj(Ey_seq)).';
    Hxy=M*Hxy-(err_y*conj(Ex_seq)).';
    Hyy=M*Hyy-(err_y*conj(Ey_seq)).';
    
end


for i = 1:itertimes                     %index refers to output symbols
    
    Ex_seq=zeros(FFE_length,1);
    Ey_seq=zeros(FFE_length,1);
    Ex_seq(1:FFE_length,1)=Ex_in(sps*i:sps*i+FFE_length-1);
    Ey_seq(1:FFE_length,1)=Ey_in(sps*i:sps*i+FFE_length-1);
    Ex_out(i)=Hxx*Ex_seq+Hyx*Ey_seq;
    Ey_out(i)=Hxy*Ex_seq+Hyy*Ey_seq;

end
    



