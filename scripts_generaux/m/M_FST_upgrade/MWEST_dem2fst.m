function [ MyFST ]=MWEST_dem2fst(dempath, demfile, demextension, DoPlots, Ici)
%FUNCTION_NAME - MWEST_dem2fst   M_WEST
%MWEST_dem2fst reads a topographical file in DEM format and converts it to
%FST format for use in WEST
%
% Syntax:  [ MyFST ]=MWEST_dem2fst(dempath, demfile, demextension, DoPlots, Ici)
%
% Inputs:
%    dempath - path to the topographic file
%    demfile - name of the topographic file
%    demextension - extension of the topographic file
%    DoPlots - logical key to activate the topographic plotting
%    Ici - path to the current directory
%
% Outputs:
%    MyFST - resulting FST filename (including its path)
%
% Example: 
% 	MWEST_dem2fst('.','022a_0100_deme','.dem',true,'.')
% 	MWEST_dem2fst. Conversion dem vers FST
% 	myDEM:E:\M_WEST_tutorial\WEST\Micro\HD_Geophysical_Data\raw_from_geobase\022a\022a_0100_deme.dem
% 
% 	=================
% 	fichier DEM:022a_0100_deme
% 	Lecture du fichier...
% 	=================
% 
% 	=================
% 	fichier DEM:022a_0100_deme
% 	Lecture du fichier terminée
% 	Image et Conversion FST...
% 	=================
% 	cygwin warning:
% 	  MS-DOS style path detected: .\022a_0100_deme.fst
% 	  Preferred POSIX equivalent is: ./022a_0100_deme.fst
% 	  CYGWIN environment variable option "nodosfilewarning" turns off this warning.
% 	  Consult the user's guide for more details about POSIX paths:
% 		 http://cygwin.com/cygwin-ug-net/using.html#using-pathnames
% 	Fin normale du convertisseur
% 	Journal (logfile) du convertisseur disponible:
% 	 dans .\022a_0100_deme.log
% 
% 	ans =
% 
% 	.\022a_0100_deme.fst
%
% 	and a contourf type of figure is generated with proper title
% 	identification
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% For more information, see <a href="matlab: 
% web('http://www.mathworks.com')">the MathWorks Web site</a>.
% 
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 
%
% See also: usgsdem

%------------- BEGIN CODE --------------
%
myDEM=[dempath,'\',demfile,demextension];
%
if exist(myDEM,'file');
else
    msg=sprintf('MWEST_dem2fst. Erreur\nFichier dem inexistant.\n%s',myDEM);
    myFST=[];
    APEmsg1(msg,'exit')
    return
end
myDEM=GetFullPath(myDEM);  %to ensure full path
fprintf('MWEST_dem2fst. Conversion dem vers FST\nmyDEM:%s\n',myDEM);
%
spacing=1;  %  pur lire à tous les 1 points, mettre=1
fprintf('\n=================\nfichier DEM:%s\nLecture du fichier...\n=================\n',demfile)
[Z, R] = usgsdem(myDEM,spacing);
% whos R
% R(1)
fprintf('\n=================\nfichier DEM:%s\nLecture du fichier terminée\nImage et Conversion FST...\n=================\n',demfile)
delta=1/R(1);  %en degré géographique
latNord=R(2); % bord.  0.5*dx à coté du dernier point
latNord=latNord-0.5*delta;
lonOuest=R(3)+0.5*delta;
[nx,ny]=size(Z);
latSud=latNord-(ny-1)*delta;
if DoPlots
    LON=lonOuest:delta:lonOuest+(nx-1)*delta;
    LAT=latSud:delta:latSud+(ny-1)*delta;
    titre=sprintf('Topographie DEM:%s. \nlonOuest:%d, latSud:%d, nx:%i, ny:%i, delta:%f deg',...
        [demfile,demextension],lonOuest, latSud, nx, ny, delta);
    figure
	 contourf(LON,LAT,Z); colorbar
	 %dont interpret special chars such as _ in the title
    title(titre,'Interpreter','none');xlabel('Longitude');ylabel('Latitude');
end
%
%   ecrire sur un fichier ascii
%
demfileascii=[Ici,'\',demfile,'.txt'] ;
demfilefst=[demfile,'.fst'] ;
% Ici=pwd;
MyFST=[Ici,'\',demfilefst]; 
% ['Nom du FST=',MyFST]
% caveat ajout du path pour couvrir usage sur autres drives e.g. D:
demlogfile=[Ici,'\',demfile,'.log'] ;
nomvar='ME';
%
if exist(demfileascii)==0
else
    delete (demfileascii);
end
%
demid=fopen(demfileascii,'w');
%
fprintf(demid,'&fstspecs\n');
fprintf(demid,' nx=%i, ny=%i, dx=%f, dy=%f, \n', nx,ny,delta,delta);
fprintf(demid,' iref=1, jref=1, lonref=%d, latref=%d,\n', lonOuest,latSud);
fprintf(demid,' diese=.true., grtyp=''Z'',\n');
fprintf(demid,' fstname=''%s'', nomvar=''%s'',\n',MyFST,nomvar);  %RB fev13
fprintf(demid,'/\n');
fprintf(demid,'===DATA===\n');  % marqueur de debut des données
%  ecrire le dem en transpose pour avoir orientation de la grille selon
%  convention fortran ou fst
fprintf(demid,'%i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i \n',Z');
%
fclose(demid);
%
%  appeler le convertisseur à FST
%
init_M_FST_win;
%
[status] = ascii2fst(demfileascii,demfilefst,demlogfile);  %  ; pour silencieux
if status == 0
    disp('Fin normale du convertisseur')
else
    disp('Condition d''erreur du convertisseur')
end
fprintf('Journal (logfile) du convertisseur disponible:\n dans %s\n',demlogfile)
%
