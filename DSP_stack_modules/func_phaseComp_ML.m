function  [recoverx recovery] = func_phaseComp_ML(Ex_out,Ey_out,pix,piy,cfactor,moindex)
if ~exist('moindex','var')
    moindex=2;
end
eqxx=Ex_out;
eqyy=Ey_out;
pilotx=zeros(1,length(eqxx));
piloty=zeros(1,length(eqyy));
pilotx(1:cfactor)=pix(1:cfactor);
piloty(1:cfactor)=piy(1:cfactor);
pcoex=zeros(1,length(eqxx));
pcoey=zeros(1,length(eqyy));
pcoex(1:cfactor)=angle(conj(pilotx(1:cfactor)).*eqxx(1:cfactor));
pcoey(1:cfactor)=angle(conj(piloty(1:cfactor)).*eqyy(1:cfactor));
switch moindex
    case 0
        for k=cfactor+1:length(eqxx);
            pcoex(k)=angle(sum(conj(pilotx((k-cfactor):(k-1))).*eqxx((k-cfactor):(k-1))));
            pilotx(k)=pix(k);
        end
        for k=cfactor+1:length(eqyy);
            pcoey(k)=angle(sum(conj(piloty((k-cfactor):(k-1))).*eqyy((k-cfactor):(k-1))));
            piloty(k)=piy(k);
        end
    case 2
        ci=qammod((1:2^2)-1,2^2);
        for k=cfactor+1:length(eqxx);
            pcoex(k)=angle(sum(conj(pilotx((k-cfactor):(k-1))).*eqxx((k-cfactor):(k-1))));
            pilotx(k)=findmax(eqxx(k),ci,sum(conj(pilotx((k-cfactor):(k-1))).*eqxx((k-cfactor):(k-1))));
            %             pilotx(k)=pix(k);
        end
        for k=cfactor+1:length(eqyy);
            pcoey(k)=angle(sum(conj(piloty((k-cfactor):(k-1))).*eqyy((k-cfactor):(k-1))));
            piloty(k)=findmax(eqyy(k),ci,sum(conj(piloty((k-cfactor):(k-1))).*eqyy((k-cfactor):(k-1))));
            %             piloty(k)=piy(k);
        end
        
    case 4
        ci=qammod((1:4^2)-1,4^2);
        for k=cfactor+1:length(eqxx)
            pcoex(k)=angle(sum(conj(pilotx((k-cfactor):(k-1))).*eqxx((k-cfactor):(k-1))));
            pilotx(k)=findmax(eqxx(k),ci,sum(conj(pilotx((k-cfactor):(k-1))).*eqxx((k-cfactor):(k-1))));
        end
        for k=cfactor+1:length(eqyy)
            pcoey(k)=angle(sum(conj(piloty((k-cfactor):(k-1))).*eqyy((k-cfactor):(k-1))));
            piloty(k)=findmax(eqyy(k),ci,sum(conj(piloty((k-cfactor):(k-1))).*eqyy((k-cfactor):(k-1))));
        end
        
end
recoverx=zeros(1,length(eqxx));
recovery=zeros(1,length(eqyy));
recoverx=eqxx.*exp(-1i*pcoex);
recovery=eqyy.*exp(-1i*pcoey);

% figure(101);
% hold on
% plot(unwrap(angle(exp(1i*pcoex(500:end-500)))))
% hold off
% figure (102);
% plot(angle(eqxx.*exp(1i*pcoex)));

recoverx=recoverx(500:end-500);
recovery=recovery(500:end-500);

end