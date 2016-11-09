function [PREVIOUS] = loadM_WESThist( WESTstep, verbose )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
format compact
%
M_WESThist=getenv('M_WEST_HIST');
if verbose;disp(['M_WESThist:',M_WESThist]);end
if exist(M_WESThist,'file')
	load (M_WESThist,'H')  %holds structure H
    if isempty (H.(WESTstep))
        APEmsg1(['M_WEST history unavailable/empty for step ',WESTstep],'exit')
    end
	histime=datestr(H.(WESTstep).timestamp,'HH:MM:SS dd mmm yyyy');
	disp(['History structure for step <', WESTstep,'> recorded at ',histime])
	if verbose;disp('M_WEST history loaded');end
else
	APEmsg1('M_WEST history unavailable. Load fails','exit')
end
%
if verbose
	disp(H.(WESTstep))
end
PREVIOUS=H.(WESTstep);
end

