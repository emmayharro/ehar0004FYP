function [start] = func_synch_2pol(TDsynch, os, samples, delay, RxX, RxY)
TDsynch = resample(TDsynch,os,1,20);

SL = length(TDsynch);
TDsynch = flipud(TDsynch(1:SL));
R(:,1) = filter(TDsynch,1,real(RxX(1:samples)));
R(:,2) = filter(TDsynch,1,imag(RxX(1:samples)));
R(:,3) = filter(TDsynch,1,real(RxY(1:samples)));
R(:,4) = filter(TDsynch,1,imag(RxY(1:samples)));
R = abs(R);
% figure(13); plot(R);
R = sum(R,2);
[Rmax, Imax] = max(R);
% figure(13); plot(R);
thresh = 0.5*Rmax;
Ith = find(R>=thresh); % indexes of where threshold is reached

Nth = length(Ith); % times threshold is reached
start =0;

err = 5;
delayTh = (delay-err:delay+err);
if (Imax-max(delayTh))>0
    [R_del_max,I_del_max]=max(R(Imax-delayTh));
    if R_del_max>thresh;
        start = Imax-I_del_max;
        delayMeas = delayTh(I_del_max);
        %     display(delayMeas)
        Imax_alt=Imax-delayMeas;
    else
        [R_del_max,I_del_max]=max(R(Imax+delayTh));
        start = Imax+delay;
        delayMeas = delayTh(I_del_max);
        %     display(delayMeas)
        Imax_alt=Imax+delayMeas;
    end
else
    start = Imax;
    display('possible synch error')
end

% figure(13); plot(R); hold on; plot(Imax,Rmax,'ro'); plot(Imax_alt,R_del_max,'ro'); hold off;
% axis([start-delay*2 start+delay*2 0 Rmax*1.1])

% for i=1:Nth
%     for j = 1:2*err+1;
%         if abs(Imax-Ith(i))==delayTh(j) % index SL away from highest peak
%             if Ith(i)>Imax
%                 start = Imax+delay;
%             else
%                 start = Imax;
%             end
%             break
%         end
%     end
%     if start
%         break
%     end
% end
% if start==0
%     disp('synch error')
%     start = 7597;
% end

end