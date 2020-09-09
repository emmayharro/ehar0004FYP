function [Ex,Ey] = impair_freqOffset(Ex,Ey,f_samp,f_off)
% inputs:
% Ex - complex field (no frequnecy offset)
% Ey - complex field (no frequnecy offset)
% f_samp - sampling frequnecy of fields [GHz]
% f_off - offset frequnecy [GHz]
%
% outputs:
% Ex - complex field (with frequnecy offset)
% Ey - complex field (with frequnecy offset)

t=(1:1:length(Ex))./f_samp./1e9;
if sum(size(Ex)==size(t))==0
    t=t.';
end
Ex = Ex.*exp(1i*2*pi*f_off.*1e9.*t);
Ey = Ey.*exp(1i*2*pi*f_off.*1e9.*t);
