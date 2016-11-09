function [status] = ascii2fst(asciifile,fstfile,logfile)
%
%  convertisseur ascii vers FST
%
% R Benoit ETS janvier 2012
%
global  pathCode olddospath
%
% path1=[pathCode ';' olddospath];
% ajout path pour my_ascii2fst.exe
M_WEST=getenv('M_WEST_PATH');
pathNewExe=[M_WEST,'\scripts_generaux\m\M_FST_upgrade'];
path1=[pathNewExe ';' pathCode ';' olddospath];
setenv('PATH', path1)
%
if exist(fstfile)==0
else
   delete (fstfile);
end
%
cmd=sprintf('my_ascii2fst.exe < %s > %s',asciifile,logfile);
%disp (cmd)
%
[status]=system(cmd,'-echo');
%
setenv('PATH', olddospath)
end
