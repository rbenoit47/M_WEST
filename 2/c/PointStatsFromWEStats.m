function [ ok, i,j, stat, varargout  ] = PointStatsFromWEStats( FST, Lon, Lat, Moment )
% freqs, bins
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
format compact
ok=false;
freqs=[];bins=[];
if ~exist('dirCode','var'); 
	display('M_FST_win initialisé')
	init_M_FST_win; 
end
Lon=mod(Lon,-180);
if ~exist(FST,'file')
	APEmsg(mfilename(),'fichier FST inexistant')
	return
end
%
NOMVAR=Moment;
%  function [UHR,nx,ny,nsect,nu,LO,LA]=F_lire_UHR(FST)
%
if ~isequal(NOMVAR,'UHR')
	verbose=0;CATALOG=0;
	IP1=-1;IP2=-1;IP3=-1;
	LALO='NON';
	ETIKET='';TYPVAR='';DATEV=-1;
	%
	[fst_info,fst_data,fst2binOutput]=...
		lire_fst_short( FST,NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
	%
	nx=fst_info(1).ni;
	ny=fst_info(1).nj;
	nz=fst_info(1).nrec;
	NIV=[fst_info(:).niveau];
	Nbins=numel(NIV);
	fprintf('%s lu Nb de bins=%d. FST=%s\n',NOMVAR,Nbins,FST)
	%
	LALO='OUI';
	fst2binOutput=[];
	[~,LALO2D,fst2binOutput]=lire_fst_short(FST,NOMVAR,...
		IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
	LA=LALO2D(1).data(:,:);LO=LALO2D(2).data(:,:);
	%
else
	disp('On extrait UHR....')
	[UHR,nx,ny,nsect,nu,LO,LA,binsSect,binsU]=F_lire_UHR(FST);
	fprintf('%s lu Nb de bins=%i x %i. FST=%s\n',NOMVAR,nsect,nu,FST)
end
fprintf('Grille de %s. nx=%d,ny=%d\n',NOMVAR,nx,ny)
%
%  Troisieme dimension de UH est 1,2,3,...,nz.  nz=27
%  NIVeau=IP1=0,1,2,,,,26.
%
%  obtenir indices i,j pour le point demandé
%
% LALO='OUI';
% fst2binOutput=[];
% [~,LALO2D,fst2binOutput]=lire_fst_short(FST,NOMVAR,...
%     IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
% LA=LALO2D(1).data(:,:);LO=LALO2D(2).data(:,:);
%  ======================================
[i,j]=LatLon2IJ(LO,LA,Lon,Lat);
%  ======================================
fprintf('Moment %s evalue au point i=%i j=%i ainsi =%s(i,j)''\n',NOMVAR,i,j,NOMVAR)

nout=nargout-4;
varargout=cell(nout);
if ismember({NOMVAR},{'UH','UR','ER'})
	fprintf('bin freq\n----------------\n')
	for k=1:nz
		datak=fst_data(k).data(:,:);
		freqs(k)=datak(i,j)'; %attention au transpose j,i
		bins(k)=NIV(k);
		fprintf('%i  %f\n',bins(k),freqs(k))
	end
	stat=freqs;
	varargout{1}=bins;
	fprintf('somme histogr=%f\n',sum(freqs))
elseif isequal(NOMVAR,'UHR')
	fprintf('UHR est une statistique bivariee en secteur et vitesse\n')
	disp('bins vitesse')
	disp(binsU)
	disp('bins secteur')
	disp(binsSect)
	% 	stat=UHR;
	for k=1:nsect
		for l=1:nu
			UHRkl=UHR(k,l).data(:,:);
			whos UHRkl
			stat(k,l)=UHRkl(i,j)';
		end
	end
	varargout{1}=binsSect;
	varargout{2}=binsU;
else
	% moment scalaire
	datak=fst_data(1).data(:,:);
	stat=datak(i,j)';
	fprintf('Moment %s=%f\n',NOMVAR,stat)
% 	varargout={};
end
fprintf('Moment %s evalue au point i=%i j=%i ainsi =%s(i,j)''\n',NOMVAR,i,j,NOMVAR)
ok=true;
return

