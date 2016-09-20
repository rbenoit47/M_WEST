function [fst_info,fst_data,fst2binOutput] = lire_fst_APE(FST,...
    NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose,varargin)
%==========================================================================
%
% Syntax
% [fst_info,fst_data,fst2binOutput] = lire_fst(FST,
%    NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,verbose)
% 
% Description
%
% Lecture de données sur un fichier FST RPN
% 
% arguments d entrée:
% FST     : nom du fichier FST à lire
% NOMVAR  : name of variable to be read (e.g. 'TT')  up to 4 characters
% IP1     : 1st IP key (usually level index) 
% LALO    : to get the Latitudes and Longitudes of the data [NON or OUI]
% IP2     : 2nd IP key
% IP3     : 3rd IP key
% ETIKET  : label of the record
% TYPVAR  : variable type
% DATEV   : date of validity
% CATALOG : to obtain the list of contents of the FST file (voir) (0/1)
% verbose : verbosity 0/1 (controls amount of informative messages)
% incdat  : 0/1 (si datev=-1, calculer ou non date de validité)
% monotonic : 0/1 (imposer ou non monotonicité sur les niveaux lus, i.e. IP1)
% For all numerical keys (IP1 etc) a -1 value means 'unspecified'
% For all literal keys (ETIKET etc) a '' value means 'unspecified'
%
% arguments de sortie:
% fst_info: parametres descriptifs des données (une structure)
% fst_data: données lues (2D ou 3D si enregistrements multiples)
% fst2binOutput: texte contenant les messages d'exécution du convertisseur
%                fst2bin (à consulter si problème)
%
% Plus d'infos sur les FST: 
% http://collaboration.cmc.ec.gc.ca/science/si/eng/si/libraries/index.html
% user & nip: science science
%
% Auteur   : Robert Benoit ÉTS 2010-2012
%
% Language : matlab système: WINdows uniquement
%
%==========================================================================
% 
global  pathCode olddospath
%
if verbose ==1 , fprintf('nb arguments appel:%i\n',nargin), end
optargin = size(varargin,2);
stdargin = nargin - optargin;

if verbose ==1 
    fprintf('Number of inputs = %d\n', nargin)
    fprintf('Number of standard inputs = %d\n', stdargin)
    fprintf('Number of optional inputs = %d\n', optargin)
end
%{
fprintf('  Inputs from individual arguments(%d):\n', ...
        stdargin)
if stdargin >= 1
    fprintf('     %s\n', FST)
end
if stdargin == 2
    fprintf('     %s\n', NOMVAR)
end
%}
incdat=0;monotonic=0;
if optargin > 0 && verbose == 1
if verbose ==1, fprintf('  Inputs packaged in varargin(%d):\n', optargin), end
 for k= 1 : size(varargin,2) 
     fprintf('     %d\n', varargin{k})
     switch k
     case 1
        incdat=varargin{1};
     case 2
         monotonic=varargin{2};
     end     
 end
end
if verbose ==1, fprintf('incdat=%i monotonic=%i\n',incdat,monotonic), end
%
% ajout path pour fst2bin_plusAPEratio
M_WEST=getenv('M_WEST_PATH');
pathNewExe=[M_WEST,'\scripts_generaux\m\M_FST_upgrade'];  %'E:\APEratio\code\M_FST_upgrade';
if verbose ==1, display(['lire_fst_APE .' pathNewExe]), end
path1=[pathNewExe ';' pathCode ';' olddospath];
setenv('PATH', path1)
if verbose ==1 
    !echo %PATH% 
end
%
% Lancer le programme fortran fst2bin pour lire les donnees en format FST.
% fst2bin lit le FST et génère un fichier binaire simple
% qui sera ensuite lu par le script lire_bin
%
%{
sequence d'appel de fst2bin:
 fst2bin
     -FST [undef:undef]
     -BIN [undef:undef]
     -NOMVAR [undef:undef]
     -NIVEAU [-1:-1]
     -I1 [-1:-1]
     -J1 [-1:-1]
     -I2 [-1:-1]
     -J2 [-1:-1]
     -LALO [NON:OUI]
     -IP2 [-1:-1]
     -IP3 [-1:-1]
     -ETIKET [:]
     -TYPVAR [:]
     -DATEV [-1:-1]
     -CATALOG [NON:OUI]
     -INCDAT [NON:OUI]
     -MONOTONIC [NON:OUI]
%}
clear status commande fst2binOutput_
%
here=pwd;
[s,attribs]=fileattrib(here);
if attribs.UserWrite
	bin='my_bin';
else
	disp(['FST folder ',here,' is not user write.  using tempdir'])
	bin='my_bin'; %[tempdir,'my_bin'];
	if exist(FST)
		[~, FSTname, FSText] = fileparts(FST);
		copyfile(FST,[tempdir,FSTname,FSText]);
		cd (tempdir)
		disp(['Running lire_fst in tempdir ',tempdir])
	end
end

%
%  inutile de faire un delete car fortran ouvre my_bin en mode 'REPLACE'
%  ce qui efface l'ancien fichier.  RB 08/2015
%
% if exist(bin,'file')==0
% else
%     delete (bin);
% end
if exist(FST)==0
    fprintf('Fichier FST [%s] inexistant\nSTOP\n',FST)
    fst2binOutput='';
    fst_info='';
    fst_data=[];
    error('Script courant arrêté par lire_fst');
end
%
switch CATALOG
    case 0
        catalog_ouinon='NON';
    case 1
        catalog_ouinon='OUI';
end
%
monotonicC='NON';incdatC='NON';
if monotonic == 1, monotonicC='OUI',end;
if incdat == 1, incdatC='OUI',end;
%
%  le nouveau binaire: fst2bin_plusAPEratio
cmd1=sprintf('fst2bin_plusAPEratio.exe -FST %s -bin %s -nomvar="%s" -incdat "%s" -monotonic "%s" ',FST,bin,NOMVAR,incdatC,monotonicC);
cmd2=sprintf(' -niveau=%i -LALO %s -ip2=%i -ip3=%i',IP1,LALO,IP2,IP3);
cmd3=sprintf(' -etiket %s -typvar %s -datev=%i -catalog %s',ETIKET,TYPVAR,DATEV,catalog_ouinon);
commande=[cmd1 cmd2 cmd3];
if verbose == 1, fprintf('commande=%s\n',commande),end
fst2binOutput_='';
[status,fst2binOutput_]=system(commande);
% system('fst2bin.exe -FST cible -catalog')
%
setenv('PATH', olddospath)
if verbose ==1 
    !echo %PATH% 
end
%
if status ~= 0
   %besoin d'au moins 2 args pour que newline \n fontionne
   fst2binOutput=fst2binOutput_;
   disp('Contenu de la variable fst2binOutput=');
   fst2binOutput
   disp('Erreur avec fst2bin.  Commande était:')
   disp(commande)
   disp('STOP')
   error('Script courant arrêté par lire_fst');
end
fst2binOutput=fst2binOutput_;
if  verbose == 1 
    disp(commande)
    disp('====================')
    disp(fst2binOutput)
end
if status == 0
%=======================================================================================
% Ouvrir le fichier fortran non formate IEEE big endian.
fid=fopen(bin,'r','b');  %'my_bin'
%=======================================================================================
% Lire le record ecrit plus haut par le program fortran
[fst_info,fst_data]=lire_bin_APE(fid,verbose);
fclose(fid);
warning('off','all')   % to suppress warning if the bin file is on the MATLAB path
delete (bin);
warning('on','all')
%=======================================================================================
end
%
end


