clc
clear
format compact
%
if ~exist('dirCode','var'); 
	display('M_FST_win initialisé')
	init_M_FST_win; 
end
%
FST='cible.fst';
FST='.\MesoWEStats.fst';
%
%
savemat=true;
[MAT,CATALOG,ok]=FST2MATcat(FST,savemat);  %option de enregistrer en .mat
