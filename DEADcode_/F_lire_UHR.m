function [UHR,nx,ny,nsect,nu,LO,LA,IP1,IP2]=F_lire_UHR(FST)
%  ============================================================
%  ce fichier  F_lire_UHR.m va 
%  LIRE TOUS LES ENREGISTREMENTS de UHR
%  dans un matrice 4D
%  ============================================================
%
init_M_FST_win   %ceci est requis et demarre usage du plugin M_FST_win
% ================================================================
% LIRE TOUS LES ENREGISTREMENTS POUR UN NOMVAR DONNE dans un matrice 3D
% ================================================================
verbose=0;  %0 ou 1
CATALOG=0;  %0 ou 1
NOMVAR='UHR';
% dans le cas de UHR on a DEUX cles qui varient: 
% IP1=[0:30:360] IP2=[0:26]
% IP1=secteur de 0 a 270 et un total dans 360
% IP2=bin de vitesse de 0 a 26 m/s
% il FAUT alors faire une boucle sur un des IP 
% car lire_fst ne peut traiter une double clé
IP1=[0:30:360]; IP2=[0:26]; IP3=-1;
% IP1=[0:90:360]; IP2=[0:3:26]; IP3=-1;
%
%FST='..\..\Demo_FST\MesoWEStats.fst';
% FST='../../Demo_FST/MesoWEStats.fst';   %PATH en / POSIX
LALO='NON';
ETIKET='';
TYPVAR='';
DATEV=0;
incdat=0;
%  boucle de lecture sur U (=IP2) dans le cas de UHR
clear fst_data fst_info
for u=1:numel(IP2)
    message=sprintf('lire vitesse=%d',u);
    disp(message)
    IP2_=IP2(u);
    IP1_=-1;
    fst2binOutput=[];
    [fst_info_,fst_data_,fst2binOutput]=lire_fst_short(FST,NOMVAR,...
    IP1_,LALO,IP2_,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose,incdat);
    %
    disp(sprintf('Nb records lus=%d',fst_info_(1,1).nrec))
    fst_data(:,:,:,u)=fst_data_(:,:,:);
    fst_info(:,:,u)=fst_info_(:,:);  
end
%
UHR4D=fst_data;
UHR=UHR4D;
ss=squeeze(fst_info);  %IP1xIP2
[nsect,nu]=size(ss);
nx=fst_info(1,1).ni;
ny=fst_info(1,1).nj;
% ================================================================
%
% obtenir les lat lon
LALO='OUI';
[~,LALO2D,fst2binOutput]=lire_fst_short(FST,NOMVAR,...
	IP1_,LALO,IP2_,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose,incdat);
LA=LALO2D(1).data(:,:);LO=LALO2D(2).data(:,:);
%
NU=nu;NSect=nsect;
%  contourf sur un bin de vitesse et direction voulu
% figure
myU=5;
myDir=360;
myIP2=find(IP2==myU);
myIP1=find(IP1==myDir);
%
% if myIP2 & myIP1
%     titre=sprintf('UHR(%i,%i) pour U=%d Secteur=%d',myIP1,myIP2,myU,myDir);
%     disp(titre)
%     contourf(UHR4D(:,:,myIP1,myIP2)',10);
%     colorbar
%     title(titre)
%     print -dpng UHR.png
% else
%     sprintf(' pas trouvé U=%d ou Secteur=%d dans le UHR\n',myU,myDir)
% end


