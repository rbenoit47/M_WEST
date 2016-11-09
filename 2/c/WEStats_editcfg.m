function [ M, WESTtab, varargout ] = editcfg(loadstruct,loadname,useprevious)
%FUNCTION_NAME - editcfg   M_WEST
%editcfg function of the 'WEStats' step of WEST
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
% Syntax:  [ M, WESTtab, varargout ] = editcfg(loadstruct,loadname,useprevious)
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
WESTtab='WEStats';
if nargin == 0; return; end
%
Here=pwd;
M_WESTgetenv;
if loadstruct
	if isequal(loadname,'');loadname=[WESTtab,'Struct.mat'];end
	load(loadname)  %loads config as M_WEStats structure
	fprintf('config loaded from %s\n',loadname)
	M=M_WEStats;
else
	%
	% EDIT LINES BELOW FOR YOUR CONFIGURATION
	% ---------------------------------------	
	M.ModelDirectory = [TutoDir,'\Meso\MC2\','--- SELECT ---'];
	M.IP1 = int32(12002);
	%  en premier vous pouvez laisser M.IP1 tel quel.
	%  lorsque vous ferez 'valider', on vous donnera les valeurs existantes possibles pour M.IP1
	M.DynamicsTimeStepNumber = int32(270);   %Seul 270 est valide pour Atlas Canadien et 360 pour Tutorial.
	M.delete = '.true.';
	M.geophy = '--- SELECT ---';
	M.table_ef = '--- SELECT ---_table.ef';
	M.StatsLevel = 50;
	M.MaxWindSpeed = 25;
	M.AveragingLength = 1;
	M.Stats = [Here,'--- SELECT ---'];; %'\myMesoStats.fst'
	% ---------------------------------------
	% END OF EDIT BLOCK
	%
end
if useprevious
	disp(['Using previous step for some config elements of ', WESTtab])
	PREVIOUS=loadM_WESThist( 'MC2' , false); %logical is a verbosity switch
    M.geophy=PREVIOUS.geophy;
    M.table_ef = PREVIOUS.climatetable;
end
%
structdisp(M)
return
