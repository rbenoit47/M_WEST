function [ ok, dx, dgrw ] = getDXfromFSTfield( FST,nomvar,ip1 )
%GETDXFROMFST Summary of this function goes here
%   Detailed explanation goes here
%
%	besoin du global ... pour les FST ??
%
global  pathCode olddospath dirCode
% persistent dirCode %modif 16 sept 2015
format compact
ok=false;
dx=[];
%
if isempty(dirCode)  %~exist('dirCode','var'); 
	display('M_FST_win initialisé')
	init_M_FST_win; 
end
if ~exist(FST,'file')
	APEmsg(mfilename(),'fichier FST inexistant')
	return
end
%
NOMVAR=nomvar;IP1=ip1;
verbose=0;CATALOG=0;
IP1=-1;IP2=-1;IP3=-1;
LALO='NON';
ETIKET='';TYPVAR='';DATEV=-1;
%
%  on utilise lire_fst_short-->lire_fst_APE car il est le seul lire_fst qui donne le
%  metadata geographique
%
[fst_info,fst_data,fst2binOutput]=...
	lire_fst_short( FST,NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
%
nx=fst_info(1).ni;
ny=fst_info(1).nj;
nz=fst_info(1).nrec;
NIV=[fst_info(:).niveau];
%
if nz >1;APEmsg1(['nombre d''enregistrements: ',num2str(nz),' non supporté'],'exit' );end
%
switch  class(fst_info.grtyp)
	case 'double'
		grtyp=char(fst_info.grtyp);
	case 'char'
		grtyp=fst_info.grtyp;
	otherwise
		disp('fst_info.grtyp est de classe inconnue')
		return
end
%
if isequal (grtyp,'N')
	dx=fst_info.xg3;
	dgrw=fst_info.xg4;
elseif  isequal (grtyp,'Z')
	% lire l'enregistrement pointé par le Z (ig1,2,3)
	IP1=fst_info.ig1;
	IP2=fst_info.ig2;
	IP3=fst_info.ig3;
	%
	NOMVAR='>>';
	[fst_infoX,fst_dataX,fst2binOutput]=...
		lire_fst_short( FST,NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
	nxX=fst_infoX(1).ni;
	nyX=fst_infoX(1).nj;
	nzX=fst_infoX(1).nrec;
	switch  class(fst_infoX.grtyp)
		case 'double'
			grtypX=char(fst_infoX.grtyp);
		case 'char'
			grtypX=fst_infoX.grtyp;
		otherwise
			APEmsg1(['fst_infoX.grtyp: ',fst_infoX.grtyp,' non supporté'],'exit' )
	end
	if isequal(grtypX,'N')
		dxUnit=fst_infoX.xg3;
		dgrw=fst_infoX.xg4;
		X=fst_dataX.data;
		dx=nearest((X(end)-X(1))*dxUnit/(numel(X)-1));
	else
		APEmsg1(['grtypX: ',grtypX,' non supporté. doit être N'],'exit' )
	end
else
	APEmsg1(['type de grille: ',grtyp,' non supporté'],'exit' )
end

ok=true;
end

