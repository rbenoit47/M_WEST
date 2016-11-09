function [ ok ] = WESTfast_imager( LON,LAT,BUF, dofigure, fighandle )
%WESTFAST-IMAGER Fast Imaging for noisy large array (such as land-use LU)
%   can be called from WESTvue too
%   Detailed explanation goes here
% interp to rectangular lat-lon
ok=false;
LONmi=min(min(LON));
LONma=max(max(LON));
LATmi=min(min(LAT));
LATma=max(max(LAT));
[m,n]=size(BUF);
%
LON1=reshape(LON,[],1);
LAT1=reshape(LAT,[],1);
BUF1=reshape(BUF,[],1);
% P=[squeeze(LON1),squeeze(LAT1)];
[X1,Y1]=m_ll2xy(LON1,LAT1);
% X1=LON1;Y1=LAT1;
% P=[squeeze(X1),squeeze(Y1)];
P=[X1,Y1];

dX1=min(diff(X1))/m;dY1=min(diff(Y1))/n;
X1mi=min(X1);X1ma=max(X1);dX1=(X1ma-X1mi)/m;
Y1mi=min(Y1);Y1ma=max(Y1);dY1=(Y1ma-Y1mi)/n;
% Edge=min(abs(LONma-LONmi)/m,abs(LATma-LATmi)/n);
Edge=max(dX1,dY1);% to have overlap
X=[P(:,1)'; P(:,1)'+Edge; P(:,1)'+Edge; P(:,1)'];
Y=[P(:,2)'; P(:,2)'; P(:,2)'+Edge; P(:,2)'+Edge];

if dofigure; 
    figure; 
else
    figure(fighandle);
end

caxis([min(min(BUF)) max(max(BUF))]);  % pour bonne echelle
colormap('jet'); %prior to 2014, defautlt is jet  ('default'); %map)
colorbar

h=patch(X,Y,'r','FaceColor','none','EdgeColor','none');  %pas de perimetre
set(h,'facevertexcdata',BUF1,'facecolor','flat','edgecolor','none')
drawnow

% image(LON1d,LAT1d,BUFi);
ok=true;

end

