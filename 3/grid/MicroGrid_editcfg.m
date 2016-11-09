function [ M, WESTtab ] = editcfg(loadstruct,loadname,useprevious)
%FUNCTION_NAME - editcfg   M_WEST
%editcfg function of the 'MicroGrid' step of WEST
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
WESTtab='MicroGrid';
if nargin == 0; return; end
%
Here=pwd;
if loadstruct
	if isequal(loadname,'');loadname=[WESTtab,'Struct.mat'];end
	load(loadname)  %loads config as M_MesoGrid structure
	fprintf('config loaded from %s\n',loadname)
	M=M_MesoGrid;
else
	%
	% EDIT LINES BELOW FOR YOUR CONFIGURATION
	% ---------------------------------------
    M.Grd_dx=100;
    M.Grd_ni=int32(100);
    M.Grd_nj=int32(100);
    M.Grd_iref=int32(51);
    M.Grd_jref=int32(51);
    M.Grd_latr=--- ajuster ---;
    M.Grd_lonr=--- ajuster ---;  % nb: 0-360 degrees
    M.Grd_dgrw=10;
    M.Grd_output=[Here,'\','--- ajuster ---'];
	% ---------------------------------------
	% END OF EDIT BLOCK
	%
end
if useprevious
	disp(['The useprevious option is unavailable for ',WESTtab ])
	APEmsg1('Do not use useprevious for this step','exit')
	disp(['Using previous step for some config elements of ', WESTtab])
end
%
structdisp(M)
return
