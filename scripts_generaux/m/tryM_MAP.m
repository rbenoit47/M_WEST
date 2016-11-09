clear
clc
format compact
close all

% test de M_MAP v 1.4 update de 2014 cf website
% m_proj('set','stereographic');
%{
m_proj('set','stereographic');
     'Stereographic'                                   
     <,'lon<gitude>',center_long>                      
     <,'lat<itude>', center_lat>                       
     <,'rad<ius>', ( degrees | [longitude latitude] )>
     <,'rec<tbox>', ( 'on' | 'off' )>   
     <,'rot<angle>', degrees CCW>    
%}
center_long=0.;
center_lat=90.;
dgrw=100.;
%      'radius', ( degrees | [longitude latitude] )>
%      <,'rec<tbox>', ( 'on' | 'off' )
load MesoWEStats.mat
[jME,RECME]=searchFSTMAT('EU',MAT)
[jE1,RECE1]=searchFSTMAT('E1',MAT)
LON=RECE1.lon;
LAT=RECE1.lat;
LON=mod(LON,-360.);
ME=RECME.data.data;
%
% m_proj('Stereographic' ,...                                
%      'lon',[LON(1,1) LON(end:end)],'lat',[LAT(1,1) LAT(end:end)] ,'rot',dgrw,...
% 	  'rectbox','on')   %  rot is rotation CCW of the GM                   
for imap=1:2
	figure
	switch imap
		case 1
			m_proj('Stereographic' ,...
				'lon',center_long,'lat',center_lat ,'rot',dgrw,...
				'rectbox','on')   %  rot is rotation CCW of the GM
		case 2
			m_proj('Equidistant Cylindrical')
	end
	m_contourf(LON,LAT,ME);
	shading flat
	caxis([min(min(ME)) max(max(ME))]);  % pour bonne echelle selon le ME
	colormap('default'); %map)
	cbar=colorbar;
	colorbar
	% m_coast('color','r');
	%  geographie autre facon
    % M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\m\basemaps\web
	Canada=m_shaperead('M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\m\basemaps\web\My_Canada');
	Rivers=m_shaperead('M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\m\basemaps\web\My_RiversAndLakes_7.5m');
	%{
m_shaperead(FNAME,UBR) returns only those
    elements with a minimum bounding rectangle (MBR)
    that intersects with the User-specified minimum
    bounding rectangle (UBR), in the format
       [minX  minY  maxX maxY]
	%}
	% côte du Canada
	for k=1:length(Canada.ncst),
		m_line(Canada.ncst{k}(:,1),Canada.ncst{k}(:,2),'Color','k','LineWidth',2);
	end;
	for k=1:length(Rivers.ncst),
		m_line(Rivers.ncst{k}(:,1),Rivers.ncst{k}(:,2),'Color','w','LineWidth',1);
	end;
	%{
3e facon:  GSHHS:
Using GSHHS high-resolution coastline database in M_MAP voir doc de M_MAP
	%}
	
	%
	hold on
	[cs,h]=m_contour(LON,LAT,LON,'color',[0.3,0.3,0.3]); %,'w');
	clabel(cs,h,'fontsize',8,'color',[0.3,0.3,0.3]); %,'w');
	[cs,h]=m_contour(LON,LAT,LAT,'color',[0.3,0.3,0.3]); %,'w');
	clabel(cs,h,'fontsize',8,'color',[0.3,0.3,0.3]); %'w');
	% m_grid('box','on');
	%
	%  ajouyter des points
	%    m_text(LONG,LAT,'string')             % Text
	m_text(-64,48,'x <--:point a -64,48')
	%
end
