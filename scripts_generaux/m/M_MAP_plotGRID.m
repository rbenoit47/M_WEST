function [ok]=M_MAP_plotGRID(MAT)
%
ok=false;
%
center_long=0.;
center_lat=90.;
dgrw=100.;
%      'radius', ( degrees | [longitude latitude] )>
%      <,'rec<tbox>', ( 'on' | 'off' )
%
[j,REC]=searchFSTMAT('GRID',MAT)
LON=REC.lon;
LAT=REC.lat;
LON=mod(LON,-360.);
GRID=REC.data.data;
[ni,nj]=size(LON);
%

%{
	     m_shaperead(FNAME,UBR) returns only those
    elements with a minimum bounding rectangle (MBR)
    that intersects with the User-specified minimum
    bounding rectangle (UBR), in the format
       [minX  minY  maxX maxY]
%}
UBR=[min(min(LON)) min(min(LAT)) max(max(LON)) max(max(LAT))];
% disp(UBR)
% Canada=m_shaperead('M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\m\basemaps\web\My_Canada',UBR);
% Rivers=m_shaperead('M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\m\basemaps\web\My_RiversAndLakes_7.5m',UBR);

load ('M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\m\basemaps\web\Canada_shp.mat')
load ('M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\m\basemaps\web\RiversCanada_shp.mat')
disp('Canada: cote et rivieres chargees de .mat')

%
for imap=1:2
	figure
	switch imap
		case 1
			m_proj('Stereographic' ,...
				'lon',center_long,'lat',center_lat ,'rot',dgrw,...
				'rectbox','on')   %  rot is rotation CCW of the GM
			thisproj=sprintf(...
				'Stereographique. lon=%f, lat=%f, rot=%f',...
				center_long,center_lat,dgrw);
		case 2
			m_proj('Equidistant Cylindrical')
			thisproj='Equidistant Cylindrical';
	end
	minGRID=min(min(GRID));
	maxGRID=max(max(GRID));
	display(minGRID)
	display(maxGRID)
	if ~ minGRID == maxGRID
		m_contourf(LON,LAT,GRID);
		shading flat
		caxis([min(min(GRID)) max(max(GRID))]); 
		colormap('default');
		cbar=colorbar;
		colorbar
	else
		disp('grid=const')
		stridei=int32(nearest(ni/10));
		stridej=int32(nearest(nj/10));
		m_plot(LON(1:stridei:ni,1:stridej:nj),LAT(1:stridei:ni,1:stridej:nj),'.r')
		titre=sprintf('Grille GRID echantillonee a chaques %i x %i points\nProjection %s:',...
			stridei,stridej,thisproj);
		title(titre)
	end

	%
	% côte du Canada
% 	whos Canada
% 	Canada
% 	whos Rivers
% 	Rivers
% 	return
	for k=1:length(Canada.ncst),
		m_line(Canada.ncst{k}(:,1),Canada.ncst{k}(:,2),'Color','k','LineWidth',2);
	end;
	for k=1:length(Rivers.ncst),
		m_line(Rivers.ncst{k}(:,1),Rivers.ncst{k}(:,2),'Color','b','LineWidth',1);
	end;
	
	%
	hold on
	
	[cs,h]=m_contour(LON,LAT,LON,'color',[0.3,0.3,0.3]); %,'w');
	clabel(cs,h,'fontsize',8,'color',[0.3,0.3,0.3]); %,'w');
	[cs,h]=m_contour(LON,LAT,LAT,'color',[0.3,0.3,0.3]); %,'w');
	clabel(cs,h,'fontsize',8,'color',[0.3,0.3,0.3]); %'w');
	%
end
ok=true;
return
