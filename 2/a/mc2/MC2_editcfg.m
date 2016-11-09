function [ M, WESTtab, varargout ] = editcfg(loadstruct,loadname,useprevious)
%FUNCTION_NAME - editcfg   M_WEST
%editcfg function of the 'MC2' step of WEST
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
WESTtab='MC2';
if nargin == 0; return; end
%
Here=pwd;
M_WESTgetenv;
if loadstruct
	if isequal(loadname,'');loadname=[WESTtab,'Struct.mat'];end
	load(loadname)  %loads config as M_MC2 structure
	fprintf('config loaded from %s\n',loadname)
	M=M_MC2;
else
	%
	% EDIT LINES BELOW FOR YOUR CONFIGURATION
	% ---------------------------------------	
	M.rundir = '--- SELECT ---';
	M.step = int32(120);
	M.tstep = int32(270);
	M.sample = int32(270);
	M.nlvls = int32(28);
	M.nlvspbl = int32(10);
	M.vmh_ndt = int32(29);
	M.log = '.true.';
	M.delete = '.false.';
	M.processors = int32(1);
	M.geophy = '--- SELECT ---';
	M.climatetable = [WEST,'\WindClimateDB_Annual\','--- SELECT ---','_table.ef'];
	M.climatestate = '--- SELECT ---';
	M.upolist = '''DLATEN =-1'', ''DLONEN =-1'', ''MG =-1'', ''Z0EN =-1''';
	M.udolist = '''TT'',''P0'',''UU'',''VV''';
	M.eole_cfgs_htop = 20000;
	%  special for MC2 step: 
	%     provide output file name of MesoGrid step
	%     or leave it so and rely on 'useprevious'
	Grd_output='--- SELECT ---';
	% ---------------------------------------
	% END OF EDIT BLOCK
	%
end
if useprevious
	disp(['Using previous step for some config elements of ', WESTtab])
	PREVIOUS=loadM_WESThist( 'MesoGeo' , false); %logical is a verbosity switch
	M.geophy=PREVIOUS.outfile;
	if ~exist(Grd_output,'file')
		clear 'PREVIOUS'
		PREVIOUS=loadM_WESThist( 'MesoGrid' , false); %logical is a verbosity switch
		Grd_output = PREVIOUS.Grd_output;
	end
	varargout{1}=Grd_output;
end
%
structdisp(M)
return
