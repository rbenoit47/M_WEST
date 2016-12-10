function [ ok ] = isPythonhere( )
%UNTITLED ispythonthere() checks for availability of Python, needed for
%M_WEST
%   Detailed explanation goes here
persistent was_shown dir_was_shown
p=getenv('Python_Path');
ok=false;
cmd='python -V';
if isempty(was_shown);was_shown=false;end
if isempty(dir_was_shown);dir_was_shown=false;end
%
[status,cmdout]=system(cmd);
if isequal (status, 0) && numel(cmdout) > 0
    if ~was_shown;
        display (['python is available ', cmdout])
        was_shown=true;
    end
elseif exist(p,'dir')
    if ~dir_was_shown ;display(['Checking for python.exe on your ''Python_Path'' ',p]);end
    [status,z]=system(['cd C:\&C:&dir ',p,'\python.exe /s /b']);
    if numel(z) > 0 && status == 0
        if ~dir_was_shown 
            display('Python executable was found in your ''Python_Path'' folder')
            fprintf('%s\n',z)
            display('Python is here')
            dir_was_shown=true;
        end
    else
        display('Python executable was NOT found in your ''Python_Path'' folder')
        APEmsg1('You MUST ADJUST your ''Python_Path'' folder','exit')
    end
else
    display('python is not on your current system PATH nor is your ''Python_Path'' a valid folder')
    APEmsg1('python is unavailable on your PC.  Required for M_WEST. Please install it or adjust your Python_Path','exit')
    ok=false;
end
ok=true;
end

