function [fst2binOutput] = cat_fst_v2(FST,catText,verbose)
%FUNCTION_NAME - cat_fst_v2   M_WEST
%   cat_fst_v2 retourne le Catalogue des données sur un fichier FST RPN
%
% Syntax:  [fst2binOutput] = cat_fst_v2(FST,catText,verbose)
%
% Inputs:
%    FST - nom du fichier FST à lire
%    catText - Description
%    verbose - contrôle de la verbosité du script (=0/1)
%
% Outputs:
%    fst2binOutput - texte contenant le catalogue demandé
%
%
% Plus d'infos sur les FST: 
% URL  collaboration.cmc.ec.gc.ca/science/si/eng/si/libraries/index.html
% user/password=science/science
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: M_WEST_startup

% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 

%------------- BEGIN CODE --------------

%
%==========================================================================
%
% Syntax
% fst2binOutput = cat_fst(FST, catText,verbose)
%
% 
% Description
%
% Catalogue des données sur un fichier FST RPN
% 
% arguments d entrée:
% FST     : nom du fichier FST à lire
% verbose : verbosité  (0/1)
%
% arguments de sortie:
% fst2binOutput: texte contenant le catalogue demandé
%
% Plus d'infos sur les FST: 
% http://collaboration.cmc.ec.gc.ca/science/si/eng/si/libraries/index.html
% user & nip: science science
%
% Auteur   : Robert Benoit ÉTS 2012
%
% Language : matlab système: WINdows uniquement
%
%==========================================================================
% 
global  pathCode olddospath
%
path1=[pathCode ';' olddospath];
setenv('PATH', path1)

% verbose=1;

if verbose ==1 
    !echo %PATH% 
end

if exist(FST)==0
    fprintf('Fichier FST %s inexistant\n\n',FST)
    fst2binOutput='';
    return
end
% a la facon de ShortFST
% catTextFullPath1=which(catText)
if verbose;	catText;end
Here=pwd;
[FSTpath,FSTname,FSText]=fileparts(FST);
ShortFST=[FSTname,FSText];
if numel(FSTpath)> 0
	cd (FSTpath)
else
	FSTpath='.';
	cd (FSTpath)
end
%
try
cmd1=sprintf('fst2bin_plus.exe -FST %s -catalog > %s',ShortFST,catText);
commande=cmd1;
fst2binOutput_='';
[status,fst2binOutput_]=system(commande);
%
catch
	'erreur dans lire_fst'
	cd (Here)
end
% catTextFullPath2=[FSTpath, '\',  %which(catText)
cd (Here)
% movefile(catText,'.\' )  % catTextFullPath2  catTextFullPath1
%
setenv('PATH', olddospath)
if verbose ==1 
    !echo %PATH% 
end
%
if status ~= 0
   %besoin d'au moins 2 args pour que newline \n fontionne
   disp(commande)
   disp('Erreur avec fst2bin.')
   disp('Contenu de la variable fst2binOutput=');
   fst2binOutput=fst2binOutput_;
   fst2binOutput
end
fst2binOutput=fst2binOutput_;
if  verbose == 1 
    disp(commande)
    disp('====================')
    disp(fst2binOutput)
end
%
end


