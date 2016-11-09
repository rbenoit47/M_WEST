function steps=WESTsteps()
%FUNCTION_NAME - WESTsteps   M_WEST
%   WESTsteps returns the list of all steps of WEST
%
% Syntax:  steps = WESTsteps()
%
% Inputs:
%    none
%
% Outputs:
%    steps - cell array containing the names of the steps of WEST
%
% Example: 
%    WESTsteps()
%    ans =
% 		  Columns 1 through 5
% 			 'MesoGrid'    'MesoGeo'    'MC2'    'WEStats'    'MicroGrid'
% 		  Columns 6 through 7
% 			 'MicroGeo'    'MMC'
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: M_WEST_startup

% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 

%------------- BEGIN CODE --------------

steps={'MesoGrid' 'MesoGeo' 'MC2' 'WEStats' 'MicroGrid' 'MicroGeo' 'MMC'};
end
