function [ Vars, Infos ] = FST2MAT( FST,savemat,varargin )
%FUNCTION_NAME - FST2MAT   M_WEST
%FST2MAT converts an FST file to a MATLAB .mat file
%
% Syntax: [Vars,Infos]=FST2MAT(FST,savemat,varargin)
%
% Inputs:
%	FST - name of the FST file (string)
%	savemat - boolean to save the .mat file or not (true/false)
%            if FST='path\name.fst', then .mat file='path\name.fst.mat'
%	varargin: - optional arguments list
%		'tologfile':send all messages to a logfile named after the FST name +'.mat.log'
%
% Outputs:
%	Vars - structure array containing all converted variables
% 	  with fields:
% 		 info - list (~20 items) of characteristics such as name, dimensions,
% 		        geographical descriptors, vertical level, date, number of
% 		        levels
% 		 grilleID - grid index to the variable holding the grid details for
% 		            current variable
% 		 data - the actual 1 or 2D numerical matrices of the variable are in
% 		        data.data
% 		 lat - latitudes of each point of the data matrix if variable holds
% 		       directly the grid details (otherwise see the grilleID index
% 		       value)
% 		 lon - longitudes of ... see just above in lat
%	Infos - structure array containing informations on the FST and MAT files
%		with fields: 
%		Metavars - Summary or metadata of the Vars (char)
%		ok - return status of the FST2MAT converter (boolean). true for success
%		FST - Text Catalog of all records in the FST file (char)
%		MAT - Text Catalog of all Vars in the MAT file (char)
%
% Example:
% 	[ Vars,Infos ] = FST2MAT('E:\M_WEST_tutorial\MyTuto\MyMesoGrid\MesoGrid.fst',true);
% 	=========== FST2MAT start... ================
% 	=========== analyse CATALOG... ================
% 	M_FST_win initialisé
% 	FST=E:\M_WEST_tutorial\MyTuto\MyMesoGrid\MesoGrid.fst
% 	liste des variables dans ce FST
% 	1 [>>]
% 	2 [^^]
% 	3 [GRID]
% 	[CHAR] is on the BlackList.  Not processed to the mat file
% 	=========== FST2MAT FST-> .mat ... ================
% 	1 >>
% 	2 ^^
% 	3 GRID
% 	Grille nouvelle ajoutée, 1.  Champ 3 GRID 
% 	Lon et Lat enregistrés pour champ (GRID)
% 	Nombre de grilles distinctes dans E:\M_WEST_tutorial\MyTuto\MyMesoGrid\MesoGrid.fst =1
% 	fichier .mat enregistré contenant la structure Vars: (E:\M_WEST_tutorial\MyTuto\MyMesoGrid\MesoGrid.mat)
% 	Catalogue FST ajouté dans le fichier .mat
% 	Catalogue FST est dans Records. Pour afficher faire celldisp(Records); entete=RecordsHeader
% 	=========== FST2MAT end      ================
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:
% CAVEAT: browse following site OUTSIDE matlab. 
% Otherwise will freeze MATLAB.
% http://collaboration.cmc.ec.gc.ca/science/si/eng/si/libraries/rmnlib/fstd89/index.html
% required authentication=science/science
%
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com
%
% See also: M_WEST_startup, varargin

%------------- BEGIN CODE --------------
format compact
vin=varargin;
tologfile=false;
for i=1:length(varargin)
	if isequal(vin{i},'tologfile')
		tologfile=true;
	end
end
if tologfile
	[pathstr, name, ~] = fileparts(FST);
	dotLOG=[pathstr,'\', name, '.fst.mat.log'];
	MsgsFile=dotLOG;
	disp(['FST2MAT.  Messages stored in logfile: ',MsgsFile])
	MsgsFileId=fopen(MsgsFile,'w');
else
	% ............
	MsgsFileId=1;
end
%
mydisp('=========== FST2MAT start... ================')
%
struct_warnings=warning('off','all');
if exist(FST,'file')
	[p,~,~]=fileparts(FST);
	if isequal(p,'');
		FST=['.\',FST];
	end
else
	disp(FST)
	APEmsg1('FST fourni est inexistant','exit')
end
ok=false;
CatFST='';
clear Vars
% Vars=structure contenant tout le FST
Vars=struct([]);  % structure vide
%
mydisp('=========== analyse CATALOG... ================')
%------------------------------------------------------
%   OBJECTIF:
%
% obtenir et analyser le catalogue du FST pour les noms de variable 
% «uniques»  Au sens de regrouper tous les enregistrements ayant même
% grille comme une seul element de la structure Vars.
% Cela s'applique aussi aux positionnels (>> et ^^)
%------------------------------------------------------

% tmpName = tempname returns a string, tmpName, suitable for use 
% as a temporary file path in your system's temporary folder
tmp=tempname;
catfile=[tmp,'.txt'];
%
if ~exist('dirCode','var'); 
	mydisp('M_FST_win initialisé')
	init_M_FST_win; 
end
%
cat_fst_v2(FST,catfile,0);
CatFST=fileread(catfile);
delete(catfile);
% petit menage requis dans CatFST avant usage
% cause: des blancs occasionnels
%  '0 mb'  et 'I 3' ou les 0 et 3 peuvent etre autres nombres
% regexprep(ll,'I ([0-9]+)','I_$1')
CatFST=regexprep(CatFST,'I ([0-9]+)','I_$1');
CatFST=regexprep(CatFST,'([0-9]+) m','$1_m'); %mb ou m
%  replace blank etiquette s by -----------
CatFST=regexprep(CatFST,'(\n[ 0-9]+-)(\s+\S+\s+\S+)(?:\s+){12,}(\S+)','$1$2  ------------   $3');
%
NVdel='\n[ 0-9]+-';  % pour trouver les enregistrements dans un listing de type VOIR rmnlib
%
CATSPLIT=strsplit_re(CatFST,NVdel);
% 
%  les enregistrements sont dans les elements 2...end
%clean up last element of CATSPLIT
cleanend=strsplit_re(CATSPLIT{end},'\n\s+.*\n');
CATSPLIT{end}=cleanend{1};
Records=CATSPLIT(2:end);
RecordsHeader=CATSPLIT{1}(8:end);
% eliminate last record if empty
if isequal(Records{end},'');Records=Records(1:end-1);end
%
NRecords=numel(Records);
% le array NVs et GRIDs ne doit pas exister au prealable
% clear NVs GRIDs
%
mydisp(['FST=',FST])
mydisp('liste des variables dans ce FST')
%
%  BlackList:  records qu on ne va pas traiter
%
BlackList={'CHAR','VF','J1','J2','Y7','Y8','Y9'};  %modifiable au besoin
Positionnels={'^^  ','>>  '};
%
j=0;
NVs={};GRIDs={};
BLnv='';
for i=1:NRecords
	nomvar=strtrim(Records{i}(2:5));
	% on veut les IP et les IG pour decider...
	GRID=getgridinfos(Records{i});
	%
	BLwarning=isequal(nomvar,BLnv);
	if ~ismember({nomvar},BlackList)
		%TRAITER LES POSITIONNELS ET LES AUTRES SELON OBJECTIF DONNÉ PLUS HAUT
		% nouveau nom ou positionnel => ajouter
		% meme nom, ... nouvelle grille?
		if j==0 || ~ismember(nomvar,NVs) || ismember(nomvar,Positionnels) || ~findgrid(GRID,GRIDs)
			j=j+1;
			NVs{j}=nomvar;
			GRIDs{j}=GRID;
			nomvar_=nomvar;
			fprintf(MsgsFileId,'%i [%s]\n',j,char(nomvar));
		end
	else
		if ~BLwarning
			fprintf(MsgsFileId,'[%s] is on the BlackList.  Not processed to the mat file\n',char(nomvar));
			BLwarning=true;
		end
		BLnv=nomvar;
	end
end
%
mydisp('=========== FST2MAT FST-> .mat ... ================')
%
nNVs=numel(NVs);
iVars={1:nNVs};
%
lat=struct();lon=struct();info=struct();data=struct();
Vars=catstruct(info,data,lat,lon);
kGRIDsMAT=0;  % compteur de grilles distinctes mises dans Vars
GRIDsMAT={};
iGRIDsMAT=[];  %numero de variable n(de NVs) contenant les details de la GRIDsMAT(j)
%
% use GRIDs as built above
%
for i=1:nNVs
%
	nomvar=char(NVs{i});
	nomvar=strtrim(nomvar); %ote les blancs debut et fin
	%
	fprintf(MsgsFileId,'%i %s\n',i,nomvar);
	%
	% strategie des grilles
	%
	if  ~ismember({nomvar},Positionnels)
		%  cas de non Positionnel, donc = le cas usuel
		%  cles wild...tout recuperer
		IP1=-1;LALO='NON';IP2=-1;IP3=-1;ETIKET='';TYPVAR='';DATEV=-1;CATALOG=0;verbose=0;
		%
		if kGRIDsMAT==0
			getLALO=true;
			grilleID_=1;
		else
			GRID=GRIDs{i};
			grilleID_=findgrid(GRID,GRIDsMAT);
			if ~grilleID_
				getLALO=true;
			else
				getLALO=false;
			end
		end
	else
		% cas speciaux: Positionnels
		%  pas wild card.  specifique un par un
		IP1=GRIDs{i}(1);IP2=GRIDs{i}(2);IP3=GRIDs{i}(3);
		IP1=str2num(char(IP1));IP2=str2num(char(IP2));IP3=str2num(char(IP3));
		LALO='NON';ETIKET='';TYPVAR='';DATEV=-1;CATALOG=0;verbose=0;
		getLALO=false;
		grilleID_=-1;  %pas de grilleID
	end
	%
	[fst_info,fst_data,fst2binOutput]=...
		lire_fst_short( FST,nomvar,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
	% corriger info.grtyp num=>char
	for ii=1:numel(fst_info)
		if isnumeric(fst_info(ii).grtyp); fst_info(ii).grtyp=char(fst_info(ii).grtyp);end
	end
	%  multi/mono-rec=OK
	for j=1:fst_info(1).nrec
		Vars(i).info(j)=fst_info(j);
	end	
	%
	if getLALO
		% ajouter la grille courante dans GRIDsMAT
		kGRIDsMAT=kGRIDsMAT+1;
		GRIDsMAT(kGRIDsMAT)=GRIDs(i);
		iGRIDsMAT(kGRIDsMAT)=i;
		Vars(i).grilleID=i;
		fprintf(MsgsFileId,'Grille nouvelle ajoutée, %i.  Champ %i %s \n',kGRIDsMAT,i,nomvar);
	else
		if grilleID_ == -1
			Vars(i).grilleID=grilleID_;
		else
			Vars(i).grilleID=iGRIDsMAT(grilleID_);
		end
	end
	%
	%  multi/mono-rec=OK
	for j=1:fst_info(1).nrec
		Vars(i).data(j)=fst_data(j);
	end
	%		on ajoute les LALO pour chaque grille rencontrée
	if getLALO
		LALO='OUI';
		[fst_info,fst_data,fst2binOutput]=...
			lire_fst_short( FST,nomvar,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
		LALO='NON';
		Vars(i).lat=fst_data(1).data;
		Vars(i).lon=fst_data(2).data;
%
		mydisp(['Lon et Lat enregistrés pour champ (',nomvar,')'])
		getLALO=false;
	end
end
mydisp(['Nombre de grilles distinctes dans ',FST,' =',num2str(kGRIDsMAT)])
struct_warnings=warning('on','all');
MetaVars=Meta(Vars);
%
mydisp('Catalogue FST est dans Infos. Pour afficher taper Infos.FST')
ok=true;
Infos.Metavars=MetaVars;
Infos.ok=ok;
s=sprintf('%s',RecordsHeader);
for i=1:numel(Records);s=sprintf('%s%s\n',s,Records{i});end
Infos.FST=s;
s=sprintf('%s\n',...
	' NOMV NI  NJ  NLYRS DATE-V   h m s LEVEL IP1 DEET NPAS G   XG1  XG2  XG3  XG4');
for i=1:numel(Vars)
	info=Vars(i).info(1); %(1) to handle multi layers
%
	nlyr=numel(Vars(i).data);
	if nlyr==1
		level=info.eta;ip1=info.niveau;
	elseif nlyr>1
		level=NaN;ip1=NaN;
	end
	s=sprintf('%s %4s %3i %3i %3i %8i%8i %3i %5i %4i %4i %1s %5i%5i%5i%5i\n',s,info.nomvar,info.ni,info.nj,nlyr,...
		info.aaaammjj_o,info.hhmmssss_o,level,ip1,...
		info.deet,info.npas,(info.grtyp),info.xg1,info.xg2,info.xg3,info.xg4);
end
Infos.MAT=s;
%
if savemat
	[pathstr, name, ext] = fileparts(FST);
	dotMAT=[pathstr,'\', name, '.fst.mat'];  % to clearly identify the mat file as coming from a FST
	save (dotMAT, 'Vars','-v7.3')  %to enable partial load of Vars struct v7.3 is needed (with use of matfile())
	save (dotMAT, 'Infos', '-append') % argument superflu lorsque -append: ,'-v7.3')
%
	mydisp(['fichier fst.mat enregistré contenant les structures Vars et Infos : (',dotMAT,')'])
%
else
	display(['Contenu du FST ',FST,') retournée dans la structure Infos '])
end
%
mydisp('=========== FST2MAT end      ================')
if tologfile
	fclose(MsgsFileId);
end
end

function mydisp(msg)
	tolog=evalin('caller', 'tologfile');
	Id=evalin('caller', 'MsgsFileId');
	if tolog
		fprintf(Id,'%s\n',msg);
	else
		disp(msg)
	end
end

function GRIDc=getgridinfos(CATline)
vars=strsplit_re(CATline, '\s+');
GRID.ip1=vars{12};
GRID.ip2=vars{13};
GRID.ip3=vars{14};
GRID.grtyp=vars{18};
GRID.xg1=vars{19};
GRID.xg2=vars{20};
GRID.xg3=vars{21};
GRID.xg4=vars{22};
GRIDc=struct2cell(GRID);
end

function i=findgrid(GRID,GRIDs)
i=0;
if isequal(GRID{4},'Z')
	k1=5;
else
	k1=1;
end
for j=1:numel(GRIDs)
	if isequal(GRID(k1:end),GRIDs{j}(k1:end)) && i==0
		% juste une chance
		i=j;
	end
end
end
function MetaVars=Meta(Vars)
% MetaVars is a string built from Vars
MetaVars=sprintf('#  nomvar nrec bytes\n');
for i=1:numel(Vars)
	x=Vars(i);
	nomvar=Vars(i).info.nomvar;
	nrec=Vars(i).info.nrec;
	metax=whos('x');
	%metax=structure('name','size','bytes','class')
	xbytes=metax.bytes;
	smetax=sprintf('%-3i%4s   %-4i %i\n',i,nomvar,nrec,xbytes);
	MetaVars=[MetaVars,smetax];
end
clear x
end



