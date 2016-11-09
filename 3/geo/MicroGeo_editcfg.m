function [ M, WESTtab ] = editcfg(loadstruct,loadname,useprevious)
%FUNCTION_NAME - editcfg   M_WEST
%editcfg function of the 'MicroGeo' step of WEST
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
WESTtab='MicroGeo';
if nargin == 0; return; end
%
Here=pwd;
M_WESTgetenv;
if loadstruct
	if isequal(loadname,'');loadname=[WESTtab,'Struct.mat'];end
	load(loadname)  %loads config as M_MicroGeo structure
	fprintf('config loaded from %s\n',loadname)
	M=M_MicroGeo;
else
	%
	% EDIT LINES BELOW FOR YOUR CONFIGURATION
	% ---------------------------------------
	M.gridfile= '--- SELECT ---';
	M.outfile= [Here,'\','microgeo.fst'];
	M.basedir= [WEST,'\GenGeoDB'];
	M.topodir= '--- SELECT ---';
	M.vegdir= '--- SELECT ---';
	M.verbose= int32(4);
	M.log= '.true.';
	% ---------------------------------------
	% END OF EDIT BLOCK
	%
end
if useprevious
	disp(['Using previous step for some config elements of ', WESTtab])
	PREVIOUS=loadM_WESThist( 'MicroGrid' , false); %logical is a verbosity switch
% 	PREVIOUS
	M.gridfile=PREVIOUS.Grd_output;
end
%
structdisp(M)
return
