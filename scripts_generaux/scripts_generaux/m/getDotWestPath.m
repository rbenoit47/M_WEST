function DotWestPath=getDotWestPath()
%
DotWestPath=[];
%
M_WESThome=getenv('M_WEST_HOME');
if ~exist(M_WESThome,'dir');disp(M_WESThome);APEmsg1('M_WEST_HOME inexistant','exit');end
%
DotWestPath=[M_WESThome,'\.m_west'];
return
