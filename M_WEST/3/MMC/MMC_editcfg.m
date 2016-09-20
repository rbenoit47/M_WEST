function [ M, WESTtab ] = editcfg(loadstruct,loadname,useprevious)
%FUNCTION_NAME - editcfg   M_WEST
%editcfg function of the 'MMC' step of WEST
%NOTE: this function is NOT called by the user. It is called by the WESTpad
%function. The user justs has to edit the central text part marked with
%
% EDIT LINES BELOW FOR YOUR CONFIGURATION
% ---------------------------------------
% text
% ---------------------------------------
% END OF EDIT BLOCK
% 
%of editcfg and save it as needed.
%
% Syntax:  [ M, WESTtab ] = editcfg(loadstruct,loadname,useprevious)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% For more information, see <a href="matlab: 
% web('http://www.mathworks.com')">the MathWorks Web site</a>.
% 
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 
%
% See also: WESTpad

%------------- BEGIN CODE --------------
%
M=[];
WESTtab='MMC';
if nargin == 0; return; end
%
Here=pwd;
if loadstruct
	if isequal(loadname,'');loadname=[WESTtab,'Struct.mat'];end
	load(loadname)  %loads config as M_MMC structure
	fprintf('config loaded from %s\n',loadname)
	M=M_MMC;
else
	%
	% EDIT LINES BELOW FOR YOUR CONFIGURATION
	% ---------------------------------------
	M.mesostats= '--- SELECT ---';
	M.microgeo= '--- SELECT ---';
	M.msmicrotilesdir= '--- SELECT ---' ;
	M.microstats=[Here,'\--- SELECT ---'];
	M.z0defines=[getDotWestPath(),'\mmc\z0_define_GenGeo.txt'];  %valeur par defaut
	M.outvar= 'EUMI,E1MI'; 
	% outvar: 'TG,RG,EUMI,E1MI,NS,ND'
	M.outdir= '--- SELECT ---';
	% outdir: '  0, 30, 60, 90,120,150,180,210,240,270,300,330' blancs sont critiques
	M.rzm=50;
	M.zref=-1;
	M.runmsmicro='.true.';
	M.deleteintermediatefiles='.true.';
	M.i1= '--- SELECT ---';  %entier
	M.i2= '--- SELECT ---';  %entier
	M.j1= '--- SELECT ---';  %entier
	M.j2= '--- SELECT ---';  %entier
	M.nu= 128;  %entier
	M.sigma=[];
	M.stride= 1;
	M.delta=[];
	M.verbose= '.true.';
	%
	%   certains facteurs du M. sont laissés indéterminés car 'valider' va les
	%   générer.
	%   'valider' calcule les indices i1,i2,j1,j2 maximaux
	%
	%   reduire si voulu la fenetre de simulation du MMC [i1:i2]x[j1:j2].
	%   M.i1=.........   M.i2=...........  M.j1=...........   M.j2=...........
	%   Les i,j sont des indices de la grille mesostat et non micro
	% ---------------------------------------
	% END OF EDIT BLOCK
	%
end
if useprevious
	disp(['Using previous step for some config elements of ', WESTtab])
	PREVIOUS=loadM_WESThist( 'MicroGeo' , false); %logical is a verbosity switch
% 	PREVIOUS
	M.microgeo=PREVIOUS.outfile;
	clear PREVIOUS
	PREVIOUS=loadM_WESThist( 'WEStats' , false); %logical is a verbosity switch
	M.mesostats=PREVIOUS.Stats;
	clear PREVIOUS
end
%
structdisp(M)
return

