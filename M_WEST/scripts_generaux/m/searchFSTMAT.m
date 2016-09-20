function [j,REC]=searchFSTMAT(nom,MAT,varargin)
%FUNCTION_NAME - searchFSTMAT   M_WEST
%searchFSTMAT searches a particular record defined by nom and varargin 
%             in a MAT structure array
%
% Syntax:  [j,REC]=searchFSTMAT(nom,MAT,varargin)
%
% Inputs:
%    nom - name of the variable to be found (1 to 4 characters)
%    MAT - structure array containing all converted variables in a .fst.mat
%    file obtained with FST2MAT from an FST file
%    varargin - optional arguments
%        pairs of 'token',value
%        'IP1',value  - desired level (encoded 12001+... integer) (-1)
%        'niveau',value - desired level (meters, integer) ([])
%        'irec',value - desired record (integer) ([])
%                       (for multi record variable)
%
% Outputs:
%    j - index of the found variable within the MAT structure array
%    REC - structure holding the found variable (same structure as a MAT
%    element)
%
% Example: 
% 	[j,REC]=searchFSTMAT('GRID',Vars)
% 	On cherche [GRID,IP1=-1]
% 	Nombre de niveaux extraits dans REC:1
% 	type de grille:Z
% 	j =
% 		  3
% 	REC = 
% 			  info: [1x1 struct]
% 		 grilleID: 3
% 			  data: [1x1 struct]
% 				lat: [100x100 single]
% 				lon: [100x100 single]
%
% NOTE:
% This allows to perform whatever calculations on the contents of the .mat
% files obtained from FST files and then perform geographical plotting of
% the calculations, using WESTvue().
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% For more information, see <a href="matlab: 
% web('http://www.mathworks.com')">the MathWorks Web site</a>.
% and
% CAVEAT: browse following site OUTSIDE matlab. 
% Otherwise will freeze MATLAB.
% http://collaboration.cmc.ec.gc.ca/science/si/eng/si/libraries/rmnlib/fstd89/index.html
% required authentication=science/science
% 
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 
%
% See also: FST2MAT WESTvue

%------------- BEGIN CODE --------------
format compact
j=[];REC=struct();
%
%
IP1=-1;niveau=[];irec=[];
if nargin > 2
vin=varargin;
for i=1:length(vin)
	if isequal(vin{i},'IP1')
		IP1=vin{i+1};
	elseif isequal(vin{i},'niveau')
		niveau=vin{i+1};
	elseif isequal(vin{i},'irec')
		irec=vin{i+1};
	end
end
end
%
disp(['On cherche [',nom,',IP1=',num2str(IP1),']'])
for i=1:numel(MAT)
	if ~isempty(MAT(i).info)
		zz=MAT(i).info.nomvar;
		%
		zz1=strtrim(zz');
		if strcmp(zz1,strtrim(nom))
			j=i;
% 			zz1
		end
	end
end
if isempty(j);disp([nom ' pas trouvé']);return;end
numHits=numel(MAT(j).info);
if numHits > 1
    if isempty(irec)
        APEmsg1('More than one find and no ''irec'' specified. Trying with IP1')  %RB fev 2016
    else
        % reduce to one hit with 'irec' as provided ...
        disp(['Multiple hits condition (',num2str(numHits),'). Choosing irec=',num2str(irec)])
        %MAT(j)
        MAT(j).info=MAT(j).info(irec);
        if ~isempty(MAT(j).lat);MAT(j).lat=MAT(j).lat(irec);end
        if ~isempty(MAT(j).lon);MAT(j).lon=MAT(j).lon(irec);end
        MAT(j).data=MAT(j).data(irec);
        %MAT(j)
        numHits=1;
    end
end
IP1;
if ~isequal(IP1,-1)
	% chercher le niveau demandé
	iIP1=0;
	for i=1:numHits
		%
		if isequal(IP1,MAT(j).info(i).niveau)
			iIP1=i;
		end
	end
	if iIP1>0
		disp(['niveau trouvé:',num2str(iIP1)])
% 		iIP1
	else
		disp([num2str(IP1) '=niveau inexistant. changer pour un des suivants:'])
		for i=1:numHits
			fprintf('%i %i\n',i,MAT(j).info(i).niveau)
        end
        APEmsg1('niveau manquant. corriger le IP1','exit')
		return
	end
	i=iIP1;
	%
	REC.info=MAT(j).info(i);
	REC.info.nrec= 1;  % zap à 1 car extrait un seul niveau
	REC.data=MAT(j).data(i);
	jGRILLE=MAT(j).grilleID
	if isequal( REC.info.nomvar', 'GRID'); jGRILLE=j; end  % cas special pour GRID
	REC.grilleID=jGRILLE;      %MAT(j).grilleID; %(i);
	REC.lat=MAT(jGRILLE).lat; %(i); j
	REC.lon=MAT(jGRILLE).lon; %(i); j
%
else
	% j
	REC=MAT(j);
	REC.info.nrec= 1;  % zap à 1 car extrait un seul niveau
	jGRILLE=MAT(j).grilleID;
	if isequal( REC.info.nomvar', 'GRID'); jGRILLE=j; end  % cas special pour GRID
	REC.grilleID=jGRILLE;
	REC.lat=MAT(jGRILLE).lat; %(i); j
	REC.lon=MAT(jGRILLE).lon; %(i); j
end
% whos REC
fprintf('Nombre de niveaux extraits dans REC:%i\n',REC.info(1).nrec)
if isa(REC.info(1).grtyp,'char')
	fprintf('type de grille:%s\n',REC.info(:).grtyp)
elseif class(REC.info(1).grtyp) == 'double'
	fprintf('Grille de type Z definie par grille #%i\n',REC.grilleID);  %  info(1).grtyp)
end
%
end
