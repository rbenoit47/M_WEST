%SCRIPT_NAME - M_WESTgetenv   M_WEST
%M_WESTgetenv returns the main folders of the M_WEST Tutorial
%
% Syntax:  M_WESTgetenv
%
% Outputs:
%    the following variables are created in your workspace:
%
%   Name         Size            Bytes  Class    Attributes
% 
%   M_WEST       1x9                18  char               
%   MyTuto       1x40               80  char               
%   TutoDir      1x18               36  char               
%   WEST         1x12               24  char               
% 
%   These variables are all main the directory names in the Tutorial
%
%   thus you can use them to navigate and access desired files
%   e.g. cd(MyTuto)
%
%   example:
%     ls (WEST)
% 
%     .      ..     GenGeoDB    WindClimateDB_Annual  
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
% See also: WESTsteps, WESTpad, editcfg

%------------- BEGIN CODE --------------
M_WEST=getenv('M_WEST_PATH');
MyTuto=getenv('M_WEST_HOME');
WEST=getenv('WEST_data');
TutoDir=getenv('M_WEST_tutorial');