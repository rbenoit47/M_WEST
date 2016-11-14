function hpol = roseDvents(vable,titre_in, nom_site_in, lat_in, lon_in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function that plot a wind rose from vable 
%       (speed, roughness, power density, etc.)
% Others arguments are non-mandatory (only for display):
%   titre_in, nom_site_in : the title of the rose (strings)
%   nom_site_in :  the site name (strings)
%   lat_in, lon_in :latitude and longitude of the site (reals)
%
% Note that :
%    - first sector (thus vable(1)) is centered on North
%    - the numbers of sector to plot are equal to the vable dimension
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adaptation of polargeo.m from The MathWorks, Inc.
% $Revision: 5.20 $  $Date: 2000/06/01 02:53:22 $
%%%%%%%%%%%
% Monelle Comeau, fevrier 2005
% Nicolas Gasset, février 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Declare defaults values
lat = -999;
lon = -999;
titre = '';
nom_site = '';
hpol=-1;  %RB  ppour definir hpol

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test input arguments                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1 || nargin == 4 || nargin > 5
    error('Requires 1, 2, 3 or 5 input arguments: variable [title [site_name[latitude, longiude]]]')
end
if nargin >= 1
    [mr,nr] = size(vable);
    if mr == 1
        nbsect = nr;
    elseif(nr == 1)
        nbsect = mr;
    else
        error('problem -- vable has a bad dimension - a one column vector is needed')
    end
    theta= 2*pi/nbsect*(0:nbsect-1);
end
if nargin >= 2 
    titre = titre_in;
end
if nargin >= 3 
    nom_site = nom_site_in;
end
if nargin == 5 
    lat = lat_in;
    lon = lon_in;
end

if isstr(vable)
    error('arg 1 : vable must be numeric.');
end
if isstr(lat) || isstr(lon)
    error('arg 4 & 6 : lat and lon must be numeric.');
end
if ~isstr(titre)
    error('arg 2 : titre must be numeric.');
end
if ~isstr(nom_site)
    error('arg 3 : nom_site must be numeric.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot standards mesh and text (mainly from polargeo.m)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get hold state
cax = newplot;
next = lower(get(cax,'NextPlot'));
hold_state = ishold;

% get x-axis text color so grid is in same color
tc = get(cax,'xcolor');
ls = get(cax,'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data')

% only do grids if hold is off
if ~hold_state

% make a radial grid
% (to maxvable = maximum value of vable)
    hold on;
    maxvable = max(abs(vable(:)));
    hhh=plot([-maxvable -maxvable maxvable maxvable],[-maxvable maxvable maxvable -maxvable]);
    set(gca,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
    v = [get(cax,'xlim') get(cax,'ylim')];
    ticks = sum(get(cax,'ytick')>=0);
    delete(hhh);
    
% check radial limits and ticks 
    rmin = 0; rmax = v(4); rticks = max(ticks-1,5);

% define a circle (resolution pi/50)
    th = 0:pi/50:2*pi;
    xunit = cos(th);
    yunit = sin(th);
    
% now really force points on x/y axes to lie on them exactly
    inds = 1:(length(th)-1)/4:length(th);
    xunit(inds(2:2:4)) = zeros(2,1);
    yunit(inds(1:2:5)) = zeros(3,1);
    
% plot background if necessary
    if ~isstr(get(cax,'color')),
       patch('xdata',xunit*rmax,'ydata',yunit*rmax, ...
             'edgecolor',tc,'facecolor',get(gca,'color'),...
             'handlevisibility','off');
    end

% draw radial circles
    c82 = cos(82*pi/180);
    s82 = sin(82*pi/180);
    rinc = (rmax-rmin)/rticks;
    for i=(rmin+rinc):rinc:rmax
        hhh = plot(xunit*i,yunit*i,ls,'color',tc,'linewidth',1,...
                   'handlevisibility','off');
        text((i+rinc/20)*c82,(i+rinc/20)*s82, ...
            ['  ' num2str(i)],'verticalalignment','bottom',...
            'handlevisibility','off')
    end
    set(hhh,'linestyle','-') % Make outer circle solid

% plot graduations
% lignes from centre : defines for an half, and
% are copied on the other half
    if nbsect > 36
        factgrad = 4;
    elseif nbsect >= 16
        factgrad = 2;
    elseif nbsect < 16
        factgrad = 1;
    end
    th = (1:(nbsect/2/factgrad))*2*pi/(nbsect/factgrad);
    cst = sin(th); snt = cos(th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    plot(rmax*cs,rmax*sn,ls,'color',tc,'linewidth',1,...
         'handlevisibility','off')

% annotate graduations in degree (what si around the graph)
% radius are separated by 360/nbsect degrees
    rt = 1.1*rmax;
    for i = 1:length(th)
        angle = i*(360/nbsect*factgrad);
        text(rt*cst(i),rt*snt(i),num2str(angle),...
             'horizontalalignment','center',...
             'handlevisibility','off');
        if i == length(th)
            loc = num2str(0);
        else
            loc = num2str(180+angle);
        end
        text(-rt*cst(i),-rt*snt(i),loc,...
             'horizontalalignment','center',...
             'handlevisibility','off')
    end

% set view to 2-D
    view(2);
    
% set axis limits
    axis(rmax*[-1 1 -1.15 1.15]);
end

% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName',   fName , ...
    'DefaultTextFontSize',   fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits',fUnits );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot polygons (from the data in vable)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% radius of central circle (have to be 0)
r=0;

% angle of mid bins (a) and width (aw)
milbin=0 ;%-360/nbsect/2;
a=transpose(-(theta*180/pi+milbin)+90);
aw=360/nbsect*2/3;
as=transpose(vable);

% interior circle only - at resolution of 1 degre (ar)
ar=1; % resolution/may be an option
ang=0:ar:360;
xc=r*cosd(ang);
yc=r*sind(ang);
line(xc,yc,'color',[0 0 0]);

% plot polygons
for i=1:numel(a)
    rr=(r+vable(i)); % interior radius + value to plot
    ang=(a(i)-.5*aw:ar:a(i)+.5*aw).';
    cang=cosd(ang);
    sang=sind(ang);
    x=[r*cang;rr*cang(end:-1:1)];
    y=[r*sang;rr*sang(end:-1:1)];
    patch(x,y,[1,0.4,0.6]);
end

if ~hold_state
    set(gca,'dataaspectratio',[1 1 1]), axis off; set(cax,'NextPlot',next);
end

set(get(gca,'xlabel'),'visible','on')
set(get(gca,'ylabel'),'visible','on')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display :                                            %
%           title, site name, latitude, longitude      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
if lat ~= -999 && lon ~= -999 &&  ~isempty(nom_site)
    textlatlon = [ 'latitude : ' num2str(lat) ', longitude : '  num2str(lon) ];
    text(-(rmax+0.18*rmax),-(rmax+0.15*rmax),[char(nom_site,textlatlon)],...
        'VerticalAlignment','top',...
        'HorizontalAlignment','left',...
        'FontSize',10)
elseif (lat == -999 || lon ~= -999) && ~isempty(nom_site)
    text(-(rmax+0.18*rmax),-(rmax+0.15*rmax),[char(nom_site)],...
        'VerticalAlignment','top',...
        'HorizontalAlignment','left',...
        'FontSize',10)
end

if ~isempty(titre)
    text(0,(rmax+0.18*rmax),[char(titre)],...
        'VerticalAlignment','bottom',...
        'HorizontalAlignment','center',...
        'FontSize',14)
%  pas derreur  mettre hpol=0
hpol=0;
end


