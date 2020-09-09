%%Time-Domain MIMO-CMA
%%Chen Zhu (modified by Bill Corcoran)

function  [Hxx, Hyy, Hxy, Hyx, Ex_out, Ey_out] = MIMO_FIR_CMA(Ex_in, Ey_in, mu, FFE_length)
% inputs:
% Ex_in - complex field
% Ey_in - complex field
% mu - step size for adaptive equalizer algorithm
% FFE-length - Feed-forward equalizer length, number of taps in FIR filter
%
% outputs:
% Ex_out - complex field
% Ey_out - complex field
% Hxx - Tap weights for x-to-x component of butterfly filter arrangment
% Hyy - Tap weights for y-to-y component of butterfly filter arrangment
% Hyx - Tap weights for x-to-y component of butterfly filter arrangment
% Hxy - Tap weights for y-to-x component of butterfly filter arrangment


%general parameters
sps = 2;                       % Samples per symbol
alpha =0.01;                  % Leaky factor alpha
ST = 0.05;                     % Weight of start-up taps

%equalizer parameters
R2 = 1;             % expectation power for CMA      
Rl=1;

%adjust power level
power_Ex = sum(abs(Ex_in).^2)/length(Ex_in);
power_Ey = sum(abs(Ey_in).^2)/length(Ey_in);
Ex_in = Ex_in / sqrt((power_Ex+power_Ey)/4*sps);
Ey_in = Ey_in / sqrt((power_Ex+power_Ey)/4*sps);


itertimes = floor((length(Ex_in) - FFE_length + 1) / sps);                    %exact total number of symbols to be processed
                              

%initialize filter components
Hxx=zeros(1,FFE_length);  
Hyx=zeros(1,FFE_length); 
Hxy=zeros(1,FFE_length); 
Hyy=zeros(1,FFE_length); 
Hxx(ceil(FFE_length/2)) = ST;
Hyy(ceil(FFE_length/2)) = ST;

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
    err_x=mu*(abs(Ex_out(i))-R2)*Ex_out(i);
    err_y=mu*(abs(Ey_out(i))-R2)*Ey_out(i);
%     err_x=real(Ex_out(i)).*(real(Ex_out(i)).^2-Rl^2)+1j*(imag(Ex_out(i)).*(imag(Ex_out(i)).^2-Rl^2));
%     err_y=real(Ey_out(i)).*(real(Ey_out(i)).^2-Rl^2)+1j*(imag(Ey_out(i)).*(imag(Ey_out(i)).^2-Rl^2));
%     err_x=mu*err_x*Ex_out(i);
%     err_y=mu*err_y*Ey_out(i);
    
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
    err_x=mu*(abs(Ex_out(i))-R2)*Ex_out(i);
    err_y=mu*(abs(Ey_out(i))-R2)*Ey_out(i);
%     err_x=real(Ex_out(i)).*(real(Ex_out(i)).^2-Rl^2)+1j*(imag(Ex_out(i)).*(imag(Ex_out(i)).^2-Rl^2));
%     err_y=real(Ey_out(i)).*(real(Ey_out(i)).^2-Rl^2)+1j*(imag(Ey_out(i)).*(imag(Ey_out(i)).^2-Rl^2));
%     err_x=mu*err_x*Ex_out(i);
%     err_y=mu*err_y*Ey_out(i);

    M = (1-mu*alpha);

    Hxx=M*Hxx-(err_x*conj(Ex_seq)).';
    Hyx=M*Hyx-(err_x*conj(Ey_seq)).';
    Hxy=M*Hxy-(err_y*conj(Ex_seq)).';
    Hyy=M*Hyy-(err_y*conj(Ey_seq)).';
end

    



