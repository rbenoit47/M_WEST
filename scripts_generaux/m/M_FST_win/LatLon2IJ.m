function [ILL,JLL]=LatLon2IJ(LO,LA,LoIJ,LaIJ,varargin)
%
%  usage
%  [ILL,JLL]=LatLon2IJ(LO,LA,LoIJ,LaIJ)
%  retourne les indices de grille ILL JLL correspondant
%  au point cible LaIJ LoIJ
%  NB: ces indices sont valides pour le TRANSPOSE de la grille
%      e.g.  LoIJ=LO(ILL,JLL)'=maille la plus près de LoIJ
%  LO:  matrice de longitudes de la grille
%  LA: matrice de latitudes de la grille

debug=0; %1;
inside= nargin>4; %pas >0; jan2016
if inside;Topo=varargin{2};end
%
ILL=[];JLL=[];
[ni,nj]=size(LO);
LO1=reshape(LO,ni*nj,1);LA1=reshape(LA,ni*nj,1);
if max(LO1) > 180, LO1=LO1-360;, end
if debug==1
    ni
    nj
    max(LO1)
end
% check bornes
if min(LO1) < LoIJ & LoIJ < max(LO1) & ...
   min(LA1) < LaIJ & LaIJ < max(LA1)
    % ok
else
    disp('lat long erreur')
    [min(LO1) LoIJ max(LO1)]
    [min(LA1) LaIJ max(LA1)]
    return
end
Dist1=(cosd(0.5*(LA1+LaIJ)).*(LO1-LoIJ)).^2+(LA1-LaIJ).^2;%abs(LO1-LoIJ)+abs(LA1-LaIJ);%(LO1-LoIJ).^2+(LA1-LaIJ).^2;  % matrice des distances
[Distij,ij] = min(Dist1);  % les minima
if debug ==1
    Dist1
    ij
end
%  un seul minimum sinon pathologique
if numel(ij) > 1
    disp('pathologique')
    ij
end
%{
IND = [3 4 5 6]
s = [3,3];
[I,J] = ind2sub(s,IND)
%}
[ILL,JLL]=ind2sub([ni,nj],ij);
% apply inside if required
if inside
	if debug
		disp('inside=true')
		disp('some assumptions taken here ARE NOT general')
		disp(Topo)
		disp([ILL,JLL])
		fprintf('%f %f %f\n',LA(ILL,JLL)',LaIJ,LA(ILL,JLL+1)')
		fprintf('%f %f %f\n',LO(ILL,JLL)',wrapTo360(LoIJ),LO(ILL,JLL+1)')
	end
	if Topo=='BL'
		if LA(ILL,JLL)'<LaIJ;jLL=JLL+1;if debug;disp('JLL not inside');end;else;jLL=JLL;end
		if LO(ILL,JLL)'<wrapTo360(LoIJ);iLL=ILL+1;if debug;disp('ILL not inside');end;else;iLL=ILL;end
	end
	if Topo=='BR'
		if LA(ILL,JLL)'<LaIJ;jLL=JLL+1;if debug;disp('JLL not inside');end;else;jLL=JLL;end
		if LO(ILL,JLL)'>wrapTo360(LoIJ);iLL=ILL-1;if debug;disp('ILL not inside');end;else;iLL=ILL;end
	end
	if Topo=='TR'
		if LA(ILL,JLL)'>LaIJ;jLL=JLL-1;if debug;disp('JLL not inside');end;else;jLL=JLL;end
		if LO(ILL,JLL)'>wrapTo360(LoIJ);iLL=ILL-1;if debug;disp('ILL not inside');end;else;iLL=ILL;end
	end
	if Topo=='TL'
		if LA(ILL,JLL)'>LaIJ;jLL=JLL-1;if debug;disp('JLL not inside');end;else;jLL=JLL;end
		if LO(ILL,JLL)'<wrapTo360(LoIJ);iLL=ILL+1;if debug;disp('ILL not inside');end;else;iLL=ILL;end
	end
	ILL=iLL;JLL=jLL;
	if debug;disp([ILL,JLL]);end
end

ILL=int32(ILL);JLL=int32(JLL); %RB

if debug==1
    whos ILL JLL
    ILL
    JLL
end

% Dist2=reshape(Dist1,ni,nj);
% contourf(LO,LA,Dist2)
% contour(Dist2)
% hold on
% plot(single(JLL),single(ILL),'o',...
%     'MarkerFaceColor','k','MarkerSize',5,'MarkerEdgeColor','k')
% [C,h]=contour(LA);clabel(C,h);
% [C,h]=contour(LO);clabel(C,h);
% hold off
%
end
