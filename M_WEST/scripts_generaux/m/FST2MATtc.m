function [ Vars, Infos ] = FST2MATtc( FST,savemat,varargin )
%  enveloppe try/catch autour de FSTMAT.  Pour les grands scripts de M_WEST
%  par exemple mesogeo.m, MMC.m
%  qui font des conversion FST vers MAT en fin d'exécution
try
    [ Vars, Infos ] = FST2MAT( FST,savemat,varargin );
catch ME
    display('==================')
    display('erreur avec FST2MAT=')
    display(ME.message)
    display('==================')
    display('sequence des appels:')
    appels={ME.stack.name};celldisp(appels)
    display('==================')
    stack=dbstack(1);
    name=stack.name;
    display(['on continue dans ' name])
end
end