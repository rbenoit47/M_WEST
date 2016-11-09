clc
clear
format compact
%
if ~exist('dirCode','var'); 
	display('M_FST_win initialisé')
	init_M_FST_win; 
end

FST='MesoWEStats.fst';
%
IP1=-1;LALO='NON';IP2=-1;IP3=-1;ETIKET='';TYPVAR='';DATEV=-1;CATALOG=0;verbose=1;
NOMVAR='>>';
	NOMVAR=strtrim(NOMVAR); %ote les blancs debut et fin
	fprintf('%s\n',i,NOMVAR)
	[fst_info,fst_data,fst2binOutput]=...
		lire_fst_short( FST,NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
