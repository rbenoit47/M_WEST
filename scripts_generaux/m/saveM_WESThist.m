function saveM_WESThist( M, verbose )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
format compact
%
M_WESThist=getenv('M_WEST_HIST');
if verbose;disp(['M_WESThist:',M_WESThist]);end
if exist(M_WESThist,'file')
	load (M_WESThist,'H')  %holds structure H
	if verbose;disp('M_WEST history loaded');end
else
	% initialize the History structure to holds steps of WEST
	Helements=WESTsteps();
	[~,N]=size(Helements);
	for elem=1:N
		H.(Helements{elem})=[];
	end
end
%
mystack = dbstack;
CallerFileNameWithPath = which(mystack(2).file);
[~,f,~]=fileparts(CallerFileNameWithPath);
%
if ismember(f,WESTsteps())
	WESTstep=f;
else
	disp(f)
	APEmsg1('invalid WESTstep','exit')
end
%
M.timestamp=clock();
%
H.(WESTstep)=M;
save (M_WESThist, 'H' )
if verbose
	disp('M_WEST history updated')
	disp('History structure:')
	disp(H)
	disp(['History element updated:',WESTstep])
	disp(H.(WESTstep))
end
end

