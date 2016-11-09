function APEmsg1( Msg,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
mode='';
if nargin > 1; mode=varargin{1};end
mystack = dbstack;
CallerFileNameWithPath = which(mystack(2).file);
[~,f,~]=fileparts(CallerFileNameWithPath);
if isequal (mode,'exit')
    error(Msg);%  )errStruct
else
	fprintf('Message from %s\n%s\n',f,Msg)
end
end

