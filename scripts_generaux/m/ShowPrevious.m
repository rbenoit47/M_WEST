function [ H ] = ShowPrevious( )
%SHow history of previous commands for M_WEST steps
%   Detailed explanation goes here
M_WESThist=getenv('M_WEST_HIST');
% hist=which(M_WESThist,'all'); % ('mwrc.mat');
if ~exist (M_WESThist)
    display ('There is no previous history content')
    return
end
clear 'H'
load (M_WESThist)
all=WESTsteps;
[~,nall]=size(all);
display(' ')
display ('Showing Previous history.')
display('timestamp values are time at which history was saved')
display('timestamp=[year month day hour minute second]')
display(' ')
for s=1:nall
    st=all {s};
    stname=genvarname(st);
    fprintf('\n=====================\nprevious %s:\n=====================\n',st)
    display(H.(stname))
end
display(' ')
display('NOTE !!!!!!!!!!')
display('If variable you are interested in the previous history')
display(' is truncated, say MMC.mesostats, then do the following')
display('run this command:')
display('H=ShowPrevious();')
display(' and then type this:')
display('H.MMC.mesostats')
display('.....that should show the full value of it')
end

