function [ J,I ] = getIJClimateTable( lon,lat,ClimateDB)
%FUNCTION_NAME - getIJClimateTable   M_WEST
%getIJClimateTable returns the centroid indices of the ClimateDB table
%closest to point coordinates (lon,lat)
% the frequency table name will be ClimateDB\J\I_table.ef
%
% Syntax:  [J,I]=getIJClimateTable(lon,lat,ClimateDB)
%
% Inputs:
%    lon - longitude of the target point (degrees)
%    lat - latitude  --"--
%    ClimateDB - pathname to the Climate DataBase to be used
%
% Outputs:
%    J - north-south index
%    I - west-east index
%
% Example: 
% 	[J,I]=getIJClimateTable(294,48.5,'E:\M_WEST_tutorial\WEST\WindClimateDB_Annual')
% 	La recherche peut prendre quelques minutes...
% 	Fin de la recherche. La suite est rapide
% 	J =
% 		 56
% 	I =
% 		118
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
% See also: 

%------------- BEGIN CODE --------------
% lon, lat=centre grille meso
I=[];J=[];
% lon in 0-360
if lon <0
	lon=lon+360;
end
if ~ (0<=lon & lon<360)
	disp(lon)
	APEmsg1('problem with lon. must be in [0,360)','exit')
end
if ~ exist(ClimateDB,'dir')==7
	APEmsg1('ClimateDB inexistant','exit')
end
disp('La recherche peut prendre quelques minutes...')
ClimateDB=strrep(ClimateDB,'\','/');
fpat=[ClimateDB];%,'/3.*']; %,'/[0-9]+/.*ef'];
IL='3.*';
[fl,p]=grep('-s -r -R','-I?',IL,'Latitude',fpat);
disp('Fin de la recherche. La suite est rapide')
%
nhits=numel(p.match);
for k=1:nhits
	terms=strsplit(p.match{k});
	LAT(k)=str2num(terms{7});
	LON(k)=str2num(terms{9});
end
% sort them
% unique also for LAT
[LAT1s,iaLAT,icLAT]=unique(LAT,'sorted');
[LON1s,iaLON,icLON]=unique(LON,'sorted');
% strategy depends if the files cover a rectangle or not
nx=numel(LON1s);ny=numel(LAT1s);
% spherique
% dist=@(x1,y1,x2,y2) sqrt((cosd((y1+y2)/2)*(x2-x1))^2 + (y2-y1)^2)*pi/180;
% avec m_map geodesique plus precis
% dist=@(x1,y1,x2,y2) m_idist(x1,y1,x2,y2)

%
if nhits >= nx*ny
	%
	[LATle,lat,LATge,j1,j2]=fdntrv(lat,LAT1s);
	[LONle,lon,LONge,i1,i2]=fdntrv(lon,LON1s);
	box=[LONle LONge LONge LONle];
	boy=[LATle LATle LATge LATge];
	x=lon;y=lat;
% 	dmin=dist(box(1),boy(1),box(2),boy(2));
	dmin=m_idist(box(1),boy(1),box(2),boy(2))*360/40000000;  % m_map distance geodesique
	imin=[];
	for i=1:4
		%disti=dist(box(i),boy(i),x,y);
		disti=m_idist(box(i),boy(i),x,y)*360/40000000;
		if disti<dmin
			imin=i;
			dmin=disti;
		end
	end	
	box;
	boy;
	[imin,box(imin),boy(imin)];
	flIJ=fl(LON==box(imin) & LAT==boy(imin));
else
	% do the long way...probably not all values correspond to a table
	% e.g. AtlasWindClimateDB
	dmin=360.;
	imin=[];
	for i=1:nhits
		%disti=dist(LON(i),LAT(i),lon,lat);
		disti=m_idist(LON(i),LAT(i),lon,lat)*360/40000000;
		if disti<dmin
			imin=i;
			dmin=disti;
		end
	end
	flIJ=fl(LON==LON(imin) & LAT==LAT(imin));
end
tokens=strsplit_re(char(flIJ),'/');
J=str2num(tokens{end-1});
tokensI=strsplit(tokens{end},'_');
I=str2num(tokensI{1});

end

function [Xle,x,Xge,i1,i2]=fdntrv(x,X)
	ile=find(X<=x);
	ige=find(x<=X);
	if ~isempty(ile)
		i1=ile(end);
		Xle=X(i1);
	else
		i1=NaN(1);
		Xle=i1;
	end
	if ~isempty(ige)
		i2=ige(1);
		Xge=X(i2);
	else
		i2=NaN(1);
		Xge=i2;
	end
end


