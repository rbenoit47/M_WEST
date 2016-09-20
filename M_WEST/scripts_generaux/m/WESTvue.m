function WESTvue( Vars,action,fighold,varargin )
%FUNCTION_NAME - WESTvue geographic imager for M_WEST
%WESTvue makes (part of) a map plot of WEST-produced spatial data
%WESTvue is based on the M_MAP plotting package ... see further below for
% the M_MAP website
%
% Syntax:  WESTvue( Vars,action,fighold,varargin )
%
% Inputs:
%    Vars - structure array containing all converted variables (see FST2MAT)
%    action - one of {'globe', 'cotes', 'hydro', 'blank', 
%             'contour', 'contourf', 'point', 'vecteur', 'titre', 'graticule'}
%       globe - to add a global/world coastline to map
%       cotes - to add a Canadian coastline to map
%       hydro - to add a Canadian rivers outline to map
%       blank - NO geographic outline on map
%       contour - to add a contoured field to map
%       contourf - to add a filled-contour field to map
%       point - to add a point to map
%       vecteur - to add a vector field to map
%       titre - to add a main title to map
%       graticule - to add a graticule (=lat-lon grid) to map
%
%    fighold - one of {'fig','hold'}
%             'fig' for a new figure 'hold' to continue on same figure
%    varargin - additional/optional arguments:
%      Typically one or more 'token',value(s) sequences:
%      'nomvar',nomvar - name of the variable to be plotted
%      'niveau',niveau - level (height) of the variable to be plotted
%      'irec',irec - record number of the variable to be plotted
%                    useful only for multi-record variables
%      'pointdata',lonpoint,latpoint,idpoint - to plot a point at the given
%      coordinates, labelled by idpoint (string)
%      'proj',proj - choice of the projection. proj=one of 'LL','PS'
%      'color',color - color to use for plotting line or points (string).
%      Can include a dot for dot plotting
%      'markersize',size - size of the marker for dot plotting (integer)
%      'marker',marker - marker to be used (string)
%      'sample',sample - sampling increment in arrays (integer). Useful for
%      grid plots
%      'titredata',titre - title string if desired
%      'vectsample',vectsample - similar to 'sample' but in vector plots
%      (quiver) (integer)
%      'vectmode',vectmode - type of vector plotting. One of 'V','M','VM'.
%      V for vector arrows, M to include magnitude, VM to have both
%      'nosearch' - don't search in the Vars structure for the nomvar variable, just
%      use the single Var provided in the call
%      'crop',lonctr,latctr,loncrop,latcrop - to force the plotting window
%      to be at the given centre (lon/latctr) and with the widths given (lon/latcrop).
%      Vars argument MUST be empty (=[]) when using 'crop'
%      'justgrid' - plot only dots for the grid on which the chosen Vars is
%      defined.  Available only with 'contourf'.  The 'sampling' settings
%      are used herein.
%      
%
% Outputs:
%    none
%
% Example: 
%    WESTsteps()
%    ans =
% 		  Columns 1 through 5
% 			 'MesoGrid'    'MesoGeo'    'MC2'    'WEStats'    'MicroGrid'
% 		  Columns 6 through 7
% 			 'MicroGeo'    'MMC'
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% For more information, see <a href="matlab: 
% web('http://www.mathworks.com')">the MathWorks Web site</a>,
%   see also <a href="matlab: 
% web('http://www.eos.ubc.ca/~rich/map.html')">the M_MAP Web site</a>
% 
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 
%
% This software is provided "as is" without warranty of any kind. But
% it's mine, so you can't sell it.
%
% See also: Contents FST2MAT m_proj m_line m_text m_plot m_contour m_contourf
% m_quiver m_grid m_ll2xy

%------------- BEGIN CODE --------------
persistent lonma lonmi latma latmi
switch fighold
	case 'fig'
		fig=true;
		figure
	case 'hold'
		fig=false;
		hold on
	otherwise
		fprintf('WESTvue. valeur de fighold donnee (%s) inconnue. Corriger\n',action)
		return
end
%
nomvar='';
niveau=-1; %[];
latpoint=[];lonpoint=[];idpoint='';
proj='LL';
color='k'; %''; %'k'
titre='';
vectsample=10;
vectmode='V';  % 'V/M/VM'.  par defaut: V
search=true;
markersize=5;
cloudText=true;
sample=10;
marker='+';
crop=false;
irec=[];
justgrid=false;
%
if nargin > 3
vin=varargin;
for i=1:length(vin)
	if isequal(vin{i},'nomvar')
		nomvar=vin{i+1};
	elseif isequal(vin{i},'niveau')
		niveau=vin{i+1};
	elseif isequal(vin{i},'irec')
		irec=vin{i+1};
	elseif isequal(vin{i},'pointdata')
		lonpoint=vin{i+1};
		latpoint=vin{i+2};
		idpoint=vin{i+3};
	elseif isequal(vin{i},'proj')
		proj=vin{i+1};
	elseif isequal(vin{i},'color')
		color=vin{i+1};
	elseif isequal(vin{i},'markersize')
		markersize=vin{i+1};
		if markersize < 0
			markersize=-markersize;
			cloudText=false;
		end
	elseif isequal(vin{i},'marker')
		marker=vin{i+1};
	elseif isequal(vin{i},'sample')
		sample=vin{i+1};
	elseif isequal(vin{i},'titredata')
		titre=vin{i+1};
	elseif isequal(vin{i},'vectsample')
		vectsample=vin{i+1};
	elseif isequal(vin{i},'vectmode')
		vectmode=vin{i+1};  % 'V/M/VM'
	elseif isequal(vin{i},'nosearch')
		search=false;
	elseif isequal(vin{i},'justgrid')
		justgrid=true;
	elseif isequal(vin{i},'crop')
		crop=true;
		lonctr=vin{i+1};
		latctr=vin{i+2};
		loncrop=vin{i+3};
		latcrop=vin{i+4};
		if ~isempty(Vars)
			disp('Vars argument must be empty when cropping.  correct the argument and retry')
			close
			return
		end
	end
end
end
%
if fig
	% demarrer la figure avec un m_proj
	if ~isempty(Vars)
		if isequal(nomvar,'') | isempty(niveau) ;disp('Fournir un nomvar et niveau');close;return;end
		if search
			[j,REC]=searchFSTMAT(nomvar,Vars,'IP1',niveau,'irec',irec);
			BUF=REC.data.data;
		else
			j=1;
			REC=Vars;
		end
		if isempty(j);disp('variable demandéee inexistante dans le Vars');return;end
		LON=REC.lon;
		LAT=REC.lat;
		%LON=mod(LON,-360.);
		% 	if max(max(LON)) > 180.;LON=LON-180.;end
		LON=wrapTo180(LON);
		lonmi=min(min(LON));lonma=max(max(LON));
		latmi=min(min(LAT));latma=max(max(LAT));
	else
		if crop
			disp('Cropping')
			lonmi=wrapTo180(lonctr-loncrop/2);
			lonma=wrapTo180(lonctr+loncrop/2);
			latmi=(latctr-latcrop/2);
			latma=(latctr+latcrop/2);
		else
			APEmsg1('Vars is empty and crop is false.  Cannot handle','exit')
		end
	end
	% 	contour(BUF')
	if isequal(proj,'');disp('Donner un type de projection (''proj'')');close;return;end
	if isequal(proj,'LL')
		m_proj('Equidistant Cylindrical','lon',[lonmi lonma],'lat',[latmi latma])
	%
	elseif isequal(proj,'PS')
		center_long=(lonmi+lonma)/2 %0.;
		center_lat=(latmi+latma)/2  %90.;
		dgrw=10 %dans le cas test
		CM=-(dgrw+90)
		radius=3*max([lonma-lonmi, latma-latmi]/2)
		radius=max([lonma-lonmi, latma-latmi]/2)
% 		radius=90
		rot=center_long-CM
		% la formule de rot est ok
		m_proj('Stereographic' ,...
			'lon',center_long,'lat',center_lat ,'rot',rot,...
			'rectbox','on')   %  rot is rotation CCW of the GM 'rad',radius,
	end
end
%
%
%
M_WEST=getenv('M_WEST_PATH');
switch action
%  ---------------------------------------------------	
	case 'globe'
		load ([M_WEST,'\scripts_generaux\m\basemaps\web\My_World98_shp.mat'])
		disp('Globe: cotes chargees de .mat')
		linein=false;
		%x={S.X};y={S.Y};
		for k=1:numel(S)
			%Globe.ncst{k}={S(k).X;S(k).Y};
			%Globe.ncst{k}=[S(k).X(1:end-1);S(k).Y(1:end-1)];
			
			Globe.ncst{k}=[S(k).X(1:end-1);S(k).Y(1:end-1)]';
		end
% 		Globe.ncst{2}={S.Y};
		clear S;
		for k=1:length(Globe.ncst),
			if find(lonmi<= Globe.ncst{k}(:,1) & Globe.ncst{k}(:,1) <= lonma & latmi<= Globe.ncst{k}(:,2) & Globe.ncst{k}(:,2) <=latma)
				m_line(Globe.ncst{k}(:,1),Globe.ncst{k}(:,2),'Color',color,'LineWidth',2);
				linein=true;
			end
		end;
		if ~linein
			m_line([lonmi,lonma],[latmi,latmi],'Color',color);
			m_line([lonmi,lonmi],[latmi,latma],'Color',color);
			x=double(lonmi+lonma)/2;y=double(latmi+latma)/2;
			m_text(x,y,'No ''cotes'' here...can continue','Color','k')
		end
%  ---------------------------------------------------	
	case 'cotes'
		load ([M_WEST,'\scripts_generaux\m\basemaps\web\Canada_shp.mat'])
		disp('Canada: cotes chargees de .mat')
		linein=false;
		for k=1:length(Canada.ncst),
			if find(lonmi<= Canada.ncst{k}(:,1) & Canada.ncst{k}(:,1) <= lonma & latmi<= Canada.ncst{k}(:,2) & Canada.ncst{k}(:,2) <=latma)
				m_line(Canada.ncst{k}(:,1),Canada.ncst{k}(:,2),'Color',color,'LineWidth',2);
				linein=true;
			end
		end;
		if ~linein
			m_line([lonmi,lonma],[latmi,latmi],'Color',color);
			m_line([lonmi,lonmi],[latmi,latma],'Color',color);
			x=double(lonmi+lonma)/2;y=double(latmi+latma)/2;
			m_text(x,y,'No ''cotes'' here...can continue','Color','k')
		end
%  ---------------------------------------------------		
	case 'hydro'
		load ([M_WEST,'\scripts_generaux\m\basemaps\web\RiversCanada_shp.mat'])
		disp('Canada: rivieres chargees de .mat')
		linein=false;
		for k=1:length(Rivers.ncst),
			if find(lonmi<= Rivers.ncst{k}(:,1) & Rivers.ncst{k}(:,1) <= lonma & latmi<= Rivers.ncst{k}(:,2) & Rivers.ncst{k}(:,2) <=latma)
				m_line(Rivers.ncst{k}(:,1),Rivers.ncst{k}(:,2),'Color',color,'LineWidth',1);
				linein=true;
			end
		end;
		if ~linein
			m_line([lonmi,lonma],[latmi,latmi],'Color',color);
			m_line([lonmi,lonmi],[latmi,latma],'Color',color);
			x=double(lonmi+lonma)/2;y=double(latmi+latma)/2;
			m_text(x,y,'No ''hydro'' here...can continue','Color','k')
		end
	case 'blank'
		% no geo line...ok
		m_line([lonmi,lonma],[latmi,latmi],'Color','w');
		m_line([lonmi,lonmi],[latmi,latma],'Color','w');
%  ---------------------------------------------------		
	case 'contour'
		if isequal(nomvar,'') | isempty(niveau) ;disp('Fournir un nomvar et niveau');close;return;end
		% 		[j,REC]=searchFSTMAT(nomvar,Vars,'IP1',niveau);
		if search
			[j,REC]=searchFSTMAT(nomvar,Vars,'IP1',niveau,'irec',irec);
		else
			j=1;
			REC=Vars;
		end
		if isempty(j);disp('variable demandéee inexistante dans le Vars');return;end
		BUF=REC.data.data;
		LON=REC.lon;
		LAT=REC.lat;
		%LON=mod(LON,-360.);
		%if max(max(LON)) > 180.;LON=LON-180.;end
		LON=wrapTo180(LON);
		[X,Y]=m_ll2xy(LON,LAT);
		X=X/(1+sind(60));
		Y=Y/(1+sind(60));
		% 		contour(X',Y',BUF',color)
		if isequal(color,'')
			m_contour(LON',LAT',BUF')
		else
			m_contour(LON',LAT',BUF',color)
		end
%  ---------------------------------------------------		
	case 'contourf'
		if isequal(nomvar,'') | isempty(niveau) ;disp('Fournir un nomvar et niveau');close;return;end
% 		[j,REC]=searchFSTMAT(nomvar,Vars,'IP1',niveau);
		if search
			[j,REC]=searchFSTMAT(nomvar,Vars,'IP1',niveau,'irec',irec);
		else
			j=1;
			REC=Vars;
		end
		if isempty(j);disp('variable demandée inexistante dans le Vars');return;end
		BUF=REC.data.data;
		LON=REC.lon;
		LAT=REC.lat;
		%LON=mod(LON,-360.);
		LON=wrapTo180(LON);
		%if max(max(LON)) > 180.;LON=LON-180.;end
		[ni,nj]=size(LON);
		%
		%  detect case of a constant field (such as a GRID record)
		%
		minBUF=min(min(BUF));
		maxBUF=max(max(BUF));
		%
		% handle grtyp=Y  cloud of points
		%
		cloud=isequal(REC.info.grtyp,'Y');
		if ~ isequal(minBUF,maxBUF) && ~cloud && ~justgrid
			m_contourf(LON',LAT',BUF','EdgeColor','none')  % to remove the contour lines
			%RB nov 2015 rather than with this: shading flat
			caxis([min(min(BUF)) max(max(BUF))]);  % pour bonne echelle
			colormap('jet'); %prior to 2014, defautlt is jet  ('default'); %map)
			colorbar
		elseif cloud
			disp('We have a cloud of points (grtyp=Y). Plot as points(=marker)')
			% find the points in the plotting window
			lon1d=squeeze(LON);lat1d=squeeze(LAT);
            if ~isempty(lonmi)
                in=find(lonmi<= lon1d(:) & lon1d(:) <= lonma & latmi<= lat1d(:) & lat1d(:) <=latma);
            else
                in=[1:ni*nj];
            end
			%
            m_plot(lon1d(in),lat1d(in),marker,'Color',color,'MarkerSize',markersize)
			if cloudText
				for i=1:numel(in)
					sBUFi=['  ',num2str(BUF(in(i),1))];
					x=double(LON(in(i),1));y=double(LAT(in(i),1));
                    %x=double(LON(Iin(i),Jin(i)));y=double(LAT(Iin(i),Jin(i)));
					%
					%  CAVEAT:  by 2015, text requires DOUBLEs for the coordinates
					%  text(x,y, etc)
					%  m_text original uses SINGLE .  bug fixed therein by RBenoit
					%
					m_text(x,y,sBUFi,'Color',color,'FontSize',6); % points (1/72 "),'FontUnits','normalized');
				end
            end
        elseif justgrid
			disp('Field shown as grid dots only (justgrid)')
			isample=[1:sample:ni,ni];  % to include both endpoints
			jsample=[1:sample:nj,nj];
            LONs=LON(isample,jsample);LATs=LAT(isample,jsample);
            in=find(lonmi<= LONs & LONs <= lonma & latmi<= LATs & LATs <=latma);
            %m_plot(LON(in(1:sample*sample:end)),LAT(in(1:sample*sample:end)),marker,'Color',color,'MarkerSize',markersize)
            m_plot(LONs(in),LATs(in),marker,'Color',color,'MarkerSize',markersize)
			titre=sprintf('Grille echantillonee a chaque %i x %i points \n',sample,sample);
			title(titre)
        else
			% case of a flat field.  Just plot dots
			disp('Field is constant.  Show as dots')
			stridei=sample;  %int32(nearest(ni/10));
			stridej=sample;  %int32(nearest(nj/10));
			isample=[1:stridei:ni,ni];  % to include both endpoints
			jsample=[1:stridej:nj,nj];
			m_plot(LON(isample,jsample)',LAT(isample,jsample)',color,'MarkerSize',markersize) %'.r')
			titre=sprintf('Grille echantillonee a chaque %i x %i points\nProjection: %s',...
				stridei,stridej,proj);
			title(titre)
		end
%  ---------------------------------------------------	
	case 'point'
% 		lonpoint=mod(lonpoint,-360.);
		lonpoint=wrapTo180(lonpoint);
		m_plot(lonpoint,latpoint,'+','Color',color,'MarkerSize',markersize)
		%
		%  CAVEAT on m_text: see a bit above herein
		%
		m_text(lonpoint,latpoint,idpoint,'Color',color)
%  ---------------------------------------------------		
	case 'vecteur'
		if isequal(nomvar,'') | isempty(niveau) ;disp('Fournir un nomvar et niveau');close;return;end
		if ~search;disp('option nosearch non supportee pour ''vecteur''');return;end
		% nomvar doit etre UU+VV
		if ~isequal(nomvar,'UU+VV');disp('nomvar doit etre UU+VV');close;return;end
		[jU,RECU]=searchFSTMAT(nomvar(1:2),Vars,'IP1',niveau,'irec',irec);
		if isempty(jU);disp('variable demandéee inexistante dans le Vars');close;return;end
		[jV,RECV]=searchFSTMAT(nomvar(4:5),Vars,'IP1',niveau,'irec',irec);
		if isempty(jV);disp('variable demandéee inexistante dans le Vars');close;return;end
		LON=RECU.lon;
		LAT=RECU.lat;
% 		LON=mod(LON,-360.);
		LON=wrapTo180(LON);
		U=RECU.data.data;
		V=RECV.data.data;
		ni=RECU.info.ni;
		nj=RECU.info.nj;
		if isequal(vectmode,'V') || isequal(vectmode,'VM') || isequal(vectmode,'MV')
			samplingj=[1:vectsample:nj,nj];
			samplingi=[1:vectsample:ni,ni];
			% m_quiver : U et V sont est et nord
			if isequal(color,'')
				m_quiver(LON(samplingi,samplingj)',LAT(samplingi,samplingj)',...
					U(samplingi,samplingj)',V(samplingi,samplingj)')
			else
				m_quiver(LON(samplingi,samplingj)',LAT(samplingi,samplingj)',...
					U(samplingi,samplingj)',V(samplingi,samplingj)',color)
			end
		end
		if isequal(vectmode,'M') || isequal(vectmode,'VM') || isequal(vectmode,'MV')
			BUF=sqrt(U.*U+V.*V);
			if isequal(color,'')
				m_contour(LON',LAT',BUF')
			else
				m_contour(LON',LAT',BUF',color)
			end
		end
%  ---------------------------------------------------		
	case 'titre'
		title(titre)
%  ---------------------------------------------------		
	case 'graticule'
		m_grid()
%  ---------------------------------------------------		
	otherwise
		fprintf('WESTvue action (%s) inconnue. return\n',action)
		return
end
end
	

