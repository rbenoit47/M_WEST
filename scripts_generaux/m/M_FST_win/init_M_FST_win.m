% init pour fst2matlabWin
global dirCode pathCode olddospath
dirCode=which('lire_bin.m');
[pathCode, name, ext] = fileparts(dirCode); 
olddospath=getenv('PATH');