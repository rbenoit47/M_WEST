function [ ok, i,j, freqs, bins ] = HistogrammeDePoint_fst( FST, Lon, Lat )
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
verbose=0;CATALOG=0;
NOMVAR='UH';
IP1=-1;IP2=-1;IP3=-1;
%
LALO='NON';
ETIKET='';TYPVAR='';DATEV=-1;
%
[fst_info,UH,fst2binOutput]=...
	lire_fst_short( FST,NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
%
NIV=[fst_info(:).niveau];
NbinUH=numel(NIV);
fprintf('UH lu Nb de bins=%d. FST=%s\n',NbinUH,FST)
nx=fst_info(1).ni;
ny=fst_info(1).nj;
nz=fst_info(1).nrec;
fprintf('Grille de UH. nx=%d,ny=%d\n',nx,ny)
%
%  Troisieme dimension de UH est 1,2,3,...,nz.  nz=27
%  NIVeau=IP1=0,1,2,,,,26.
%
%  obtenir indices i,j pour le point demandé
%
LALO='OUI';
fst2binOutput=[];
[fst_info,LALO2D,fst2binOutput]=lire_fst_short(FST,NOMVAR,...
    IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
LA=LALO2D(1).data(:,:);LO=LALO2D(2).data(:,:);
%  ======================================
[i,j]=LatLon2IJ(LO,LA,Lon,Lat);
%  ======================================
fprintf('bin freq\n----------------\n')
for k=1:nz
    UHk=UH(k).data(:,:);
    freqs(k)=UHk(i,j)'; %attention au transpose j,i
	 bins(k)=NIV(k);
    fprintf('%i  %f\n',bins(k),freqs(k)) 
end
fprintf('somme histogr=%f\n',sum(freqs))
fprintf('Histogramme evalue au point i=%i j=%i ainsi =UH(i,j)''\n',i,j)
ok=true;
return

