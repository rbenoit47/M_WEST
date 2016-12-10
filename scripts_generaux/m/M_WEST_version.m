function [ version ] = M_WEST_version()
%M_WEST_VERSION Summary of this function goes here
%   Detailed explanation goes here
M_WEST=getenv('M_WEST_PATH');
fid=fopen([M_WEST,'\M_WEST_tags.txt']);
version=fgetl(fid);
fclose(fid);
fprintf('M_WEST version is %s\n',version)
%
fid=fopen([M_WEST,'\M_WEST_log.txt']);
display('Latest commit infos')
for lines=1:5
    line=fgetl(fid);
    fprintf('%s\n',line)
end
fclose(fid);
end

