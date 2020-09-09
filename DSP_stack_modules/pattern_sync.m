function [Ex,Ey,Xdat_sync,Ydat_sync] = pattern_sync(Ex,Ey,dataX,dataY,M,search_win,synch_win,synch_st)
% inputs:
% Ex - complex field (no phase noise)
% Ey - complex field (no phase noise)
% dataX - complex field of data pattern
% dataY - complex field of data pattern
% search_win - number of sample to check for synch pattern over
%
% outputs:
% Ex - complex field (with fphase noise)
% Ey - complex field (with phase noise)
%
% optional inputs:
% synch_win - length of chosen data pattern segment to correlate over
% synch_st - start position of chosen data pattern segment in array


Ex = Ex/sqrt(mean(abs(Ex).^2));
Ey = Ey/sqrt(mean(abs(Ey).^2));
Ex = Ex*sqrt(2/3*(M-1));
Ey = Ey*sqrt(2/3*(M-1));

% figure(11)
% plot(real(Ex),imag(Ex),'.')
% 
% figure(12)
% plot(real(dataX),imag(dataX),'.')

if ~exist('synch_win','var')
synch_win=100;
end
if ~exist('synch_st','var')
synch_st=2001;
end
syncX = dataX(synch_st:synch_st+synch_win);
syncY = dataY(synch_st:synch_st+synch_win);
indexXX=[];
indexYY=[];
indexXY=[];
indexYX=[];
for k=1:search_win
    indexXX=[indexXX abs(sum(conj(syncX).*Ex(k:k+synch_win)))];
    indexYY=[indexYY abs(sum(conj(syncY).*Ey(k:k+synch_win)))];
    indexXY=[indexXY abs(sum(conj(syncY).*Ex(k:k+synch_win)))];
    indexYX=[indexYX abs(sum(conj(syncX).*Ey(k:k+synch_win)))];
end

%         figure(2000)
%         plot(indexXX,'b')
%         hold on
%         plot(indexXY,'r')
%         hold off
%         figure(2010)
%         plot(indexYY,'k')
%         hold on
%         plot(indexYX,'g')
%         hold off

[maxXX,poXX]=max(indexXX);
[maxYY,poYY]=max(indexYY);
[maxXY,poXY]=max(indexXY);
[maxYX,poYX]=max(indexYX);

if maxXX>maxXY
    poX=poXX;
    pattX=dataX;
else
    poX=poXY;
    pattX=dataY;
end
if maxYY>maxYX
    poY=poYY;
    pattY=dataY;
else
    poY=poYX;
    pattY=dataX;
end
posX=synch_st-poX+1;
posY=synch_st-poY+1;

if posX>0;
    if (posX-1+length(Ex))<length(pattX)
        pix=pattX(posX:posX-1+length(Ex));
%         display(['patt: ' num2str(length(pix)) ', data: ' num2str(length(Ex))])
    else
        pix=pattX(posX:end);
        Ex=Ex(1:length(pix));
%         display(['patt: ' num2str(length(pix)) ', data: ' num2str(length(Ex))])
    end
else
    pix=pattX(1:length(Ex)+posX-1);
    Ex=Ex(2-posX:end);
%     display(['patt: ' num2str(length(pix)) ', data: ' num2str(length(Ex))])
end
if posY>0
    if (posY-1+length(Ey))<length(pattY)
        piy=pattY(posY:posY-1+length(Ey));
    else
        piy=pattY(posY:end);
        Ey=Ey(1:length(piy));
    end
else
    piy=pattY(1:length(Ey)+posY-1);
    Ey=Ey(2-posY:end);
end

Xdat_sync=pix;
Ydat_sync=piy;

%and let's just sneak a little phase correction in here:
% [p,Ex,Ey] = ML_phase_PDL(Ex,Ey,pix,piy,64,2);
