function userHome=getUserHome()
%
userHome=[];
if ispc
home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
else
home = getenv('HOME');
end
userHome=home;
return
