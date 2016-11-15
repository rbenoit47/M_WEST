function [ ok ] = isPythonhere( )
%UNTITLED ispythonthere() checks for availability of Python, needed for
%M_WEST
%   Detailed explanation goes here
ok=false;
cmd='python -V';
%
[status,cmdout]=system(cmd);
if isequal (status, 0) && numel(cmdout) > 0
    display (['python is available ', cmdout])
    ok=true;
else
    APEmsg1('python is unavailable on your PC.  Required for M_WEST. Please install it','exit')
    ok=false;
end
end

