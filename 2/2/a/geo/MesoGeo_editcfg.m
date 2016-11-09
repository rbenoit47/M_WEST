function [ M, WESTtab ] = editcfg(loadstruct,loadname,useprevious)
%FUNCTION_NAME - editcfg   M_WEST
%editcfg function of the 'MesoGeo' step of WEST
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
WESTtab='MesoGeo';
if nargin == 0; return; end
%
Here=pwd;
M_WESTgetenv;
if loadstruct
	if isequal(loadname,'');loadname=[WESTtab,'Struct.mat'];end
	load(loadname)  %loads config as M_MesoGeo structure
	fprintf('config loaded from %s\n',loadname)
	M=M_MesoGeo;
else
	%
	% EDIT LINES BELOW FOR YOUR CONFIGURATION
	% ---------------------------------------
	M.gridfile= '--- SELECT ---';
	M.outfile= [Here,'\','MesoGeo.fst'];
	M.basedir= [WEST,'\GengeoDB']; %'--- SELECT ---';
	M.verbose= int32(1);
	M.log= '.false.';
	% ---------------------------------------
	% END OF EDIT BLOCK
	%
end
if useprevious
	disp(['Using previous step for some config elements of ', WESTtab])
	PREVIOUS=loadM_WESThist( 'MesoGrid' , false); %logical is a verbosity switch
% 	PREVIOUS
	M.gridfile=PREVIOUS.Grd_output;
end
%
structdisp(M)
return
