function [ H ] = ShowPrevious( )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
history=which ('mwrc.mat');
if isempty (history)
    display ('There is no previous history content')
    return
end
clear 'H'
load (history)
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

