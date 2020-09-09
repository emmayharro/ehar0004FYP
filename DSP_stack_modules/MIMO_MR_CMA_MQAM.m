%%Time-Domain MIMO-multi-ring-CMA
%%Chen Zhu & Bill Corcoran (@ Monash)
%% *********************************************************************

function  [Hxx, Hyx, Hxy, Hyy, Ex_out, Ey_out] = MIMO_MR_CMA_MQAM(Ex_in, Ey_in, M, mu, FFE_length, Hxx, Hyx, Hxy, Hyy)
%general parameters
sps = 2;                       % Samples per symbol
alpha =0.01;                  % Leaky factor alpha
ST = 0.05;                     % Weight of start-up taps

sca_fac = sqrt(2/3*(M-1))/sqrt((mean(abs(Ex_in).^2)+mean(abs(Ey_in).^2))/2);
Ex_in=Ex_in-mean(Ex_in);
Ey_in=Ey_in-mean(Ey_in);
Ex_in=Ex_in.*sca_fac;
Ey_in=Ey_in.*sca_fac;

%equalizer parameters
R = sqrt([2,10,18,26,34,50]);
if M==16;
    Nth=2;
elseif M==32;
    Nth=4;
elseif M==64;
    Nth=5;
elseif M==4;
    Nth=1;
else
    error([num2str(M) 'QAM not supported'])
end

for ii=1:Nth
    ring_th(ii)=(R(ii+1)-R(ii))/2+R(ii);
end

%adjust power level
power_Ex = sum(abs(Ex_in).^2)/length(Ex_in);
power_Ey = sum(abs(Ey_in).^2)/length(Ey_in);
Ex_in = Ex_in / sqrt((power_Ex+power_Ey)/4*sps);
Ey_in = Ey_in / sqrt((power_Ex+power_Ey)/4*sps);
% R = R ./ sqrt((power_Ex+power_Ey)/4*sps);
% ring_th = ring_th ./ sqrt((power_Ex+power_Ey)/4*sps);

itertimes = floor((length(Ex_in) - FFE_length + 1) / sps);                    %exact total number of symbols to be processed

%initialize detection vectors
Ex_out=zeros(1,itertimes);
Ey_out=zeros(1,itertimes);

for i = 1:itertimes                     %index refers to output symbols
    
    Ex_seq=zeros(FFE_length,1);
    Ey_seq=zeros(FFE_length,1);
    Ex_seq(1:FFE_length,1)=Ex_in(sps*i:sps*i+FFE_length-1);
    Ey_seq(1:FFE_length,1)=Ey_in(sps*i:sps*i+FFE_length-1);
    
    Ex_out(i)=Hxx*Ex_seq+Hyx*Ey_seq;
    Ey_out(i)=Hxy*Ex_seq+Hyy*Ey_seq;
    
    if abs(Ex_out(i))<=ring_th(1);
        err_x=mu*(abs(Ex_out(i))-R(1))*Ex_out(i);
    elseif Nth>1 && abs(Ex_out(i))>ring_th(1) && abs(Ex_out(i))<=ring_th(2);
        err_x=mu*(abs(Ex_out(i))-R(2))*Ex_out(i);
    elseif Nth>2 && abs(Ex_out(i))>ring_th(2) && abs(Ex_out(i))<=ring_th(3);
        err_x=mu*(abs(Ex_out(i))-R(3))*Ex_out(i);
    elseif Nth>3 && abs(Ex_out(i))>ring_th(3) && abs(Ex_out(i))<=ring_th(4);
        err_x=mu*(abs(Ex_out(i))-R(4))*Ex_out(i);
    elseif Nth>4 && abs(Ex_out(i))>ring_th(4) && abs(Ex_out(i))<=ring_th(5);
        err_x=mu*(abs(Ex_out(i))-R(5))*Ex_out(i);
    elseif Nth>5 && abs(Ex_out(i))>ring_th(5) && abs(Ex_out(i))<=ring_th(6);
        err_x=mu*(abs(Ex_out(i))-R(6))*Ex_out(i);
    elseif abs(Ex_out(i))>ring_th(Nth)
        err_x=mu*(abs(Ex_out(i))-R(Nth+1))*Ex_out(i);
    end
    
    if abs(Ey_out(i))<=ring_th(1);
        err_y=mu*(abs(Ey_out(i))-R(1))*Ey_out(i);
    elseif Nth>1 && abs(Ey_out(i))>ring_th(1) && abs(Ey_out(i))<=ring_th(2);
        err_y=mu*(abs(Ey_out(i))-R(2))*Ey_out(i);
    elseif Nth>2 && abs(Ey_out(i))>ring_th(2) && abs(Ey_out(i))<=ring_th(3);
        err_y=mu*(abs(Ey_out(i))-R(3))*Ey_out(i);
    elseif Nth>3 && abs(Ey_out(i))>ring_th(3) && abs(Ey_out(i))<=ring_th(4);
        err_y=mu*(abs(Ey_out(i))-R(4))*Ey_out(i);
    elseif Nth>4 && abs(Ey_out(i))>ring_th(4) && abs(Ey_out(i))<=ring_th(5);
        err_y=mu*(abs(Ey_out(i))-R(5))*Ey_out(i);
    elseif Nth>5 && abs(Ey_out(i))>ring_th(5) && abs(Ey_out(i))<=ring_th(6);
        err_y=mu*(abs(Ey_out(i))-R(6))*Ey_out(i);
    elseif abs(Ey_out(i))>ring_th(Nth)
        err_y=mu*(abs(Ey_out(i))-R(Nth+1))*Ey_out(i);
    end
    
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
    
    if abs(Ex_out(i))<=ring_th(1);
        err_x=mu*(abs(Ex_out(i))-R(1))*Ex_out(i);
    elseif Nth>1 && abs(Ex_out(i))>ring_th(1) && abs(Ex_out(i))<=ring_th(2);
        err_x=mu*(abs(Ex_out(i))-R(2))*Ex_out(i);
    elseif Nth>2 && abs(Ex_out(i))>ring_th(2) && abs(Ex_out(i))<=ring_th(3);
        err_x=mu*(abs(Ex_out(i))-R(3))*Ex_out(i);
    elseif Nth>3 && abs(Ex_out(i))>ring_th(3) && abs(Ex_out(i))<=ring_th(4);
        err_x=mu*(abs(Ex_out(i))-R(4))*Ex_out(i);
    elseif Nth>4 && abs(Ex_out(i))>ring_th(4) && abs(Ex_out(i))<=ring_th(5);
        err_x=mu*(abs(Ex_out(i))-R(5))*Ex_out(i);
    elseif Nth>5 && abs(Ex_out(i))>ring_th(5) && abs(Ex_out(i))<=ring_th(6);
        err_x=mu*(abs(Ex_out(i))-R(6))*Ex_out(i);
    elseif abs(Ex_out(i))>ring_th(Nth)
        err_x=mu*(abs(Ex_out(i))-R(Nth+1))*Ex_out(i);
    end
    
    if abs(Ey_out(i))<=ring_th(1);
        err_y=mu*(abs(Ey_out(i))-R(1))*Ey_out(i);
    elseif Nth>1 && abs(Ey_out(i))>ring_th(1) && abs(Ey_out(i))<=ring_th(2);
        err_y=mu*(abs(Ey_out(i))-R(2))*Ey_out(i);
    elseif Nth>2 && abs(Ey_out(i))>ring_th(2) && abs(Ey_out(i))<=ring_th(3);
        err_y=mu*(abs(Ey_out(i))-R(3))*Ey_out(i);
    elseif Nth>3 && abs(Ey_out(i))>ring_th(3) && abs(Ey_out(i))<=ring_th(4);
        err_y=mu*(abs(Ey_out(i))-R(4))*Ey_out(i);
    elseif Nth>4 && abs(Ey_out(i))>ring_th(4) && abs(Ey_out(i))<=ring_th(5);
        err_y=mu*(abs(Ey_out(i))-R(5))*Ey_out(i);
    elseif Nth>5 && abs(Ey_out(i))>ring_th(5) && abs(Ey_out(i))<=ring_th(6);
        err_y=mu*(abs(Ey_out(i))-R(6))*Ey_out(i);
    elseif abs(Ey_out(i))>ring_th(Nth)
        err_y=mu*(abs(Ey_out(i))-R(Nth+1))*Ey_out(i);
    end
    
    M = (1-mu*alpha);
    
    Hxx=M*Hxx-(err_x*conj(Ex_seq)).';
    Hyx=M*Hyx-(err_x*conj(Ey_seq)).';
    Hxy=M*Hxy-(err_y*conj(Ex_seq)).';
    Hyy=M*Hyy-(err_y*conj(Ey_seq)).';
    
    
end


