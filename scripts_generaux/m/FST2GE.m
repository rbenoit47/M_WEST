function  FST2GE (LON,LAT,CHAMP,nomvar)

X=LON';
Y=LAT';
Z=CHAMP';

% ge veut lon sur ±180°
if max(max(X)) > 180. , X=X-360.;, end

zmin=min(min(Z));zmax=max(max(Z));
zrange=zmax-zmin;
cLimLow=zmin+0.1*zrange;cLimHigh=zmax-0.1*zrange;
numLevels=5;
lineValues = linspace(cLimLow,cLimHigh,numLevels+2);
RGB=colormap(jet(numLevels+2));
RGB=min(255,256*RGB);
Transp=255;  %de 1 a 255

%------------------------------------------------------------------
% OCTAVE hack
%------------------------------------------------------------------
% first entry has to by created by hand, otherwise it would be null
%LineColors=[];
%LineLabels=[];

%for k=1:numLevels+2
%     string=sprintf('%02hx%02hx%02hx%02hx\n',Transp,(1*(RGB(k,1:3))));
%     LineColors=[LineColors;cellstr(string)];
%     LineLabels=[LineLabels;cellstr(sprintf('%7g',lineValues(k)))];
%end

string=sprintf('%02hx%02hx%02hx%02hx\n',Transp,(1*(RGB(1,1:3))));
LineColors=[cellstr(string)];
LineLabels=[cellstr(sprintf('%7g',lineValues(1)))];

for k=2:numLevels+2
     string=sprintf('%02hx%02hx%02hx%02hx\n',Transp,(1*(RGB(k,1:3))));
     LineColors=[LineColors;cellstr(string)];
     LineLabels=[LineLabels;cellstr(sprintf('%7g',lineValues(k)))];
end
%------------------------------------------------------------------

hf=figure ('Visible','on'); %off/on
[C,h]=contour(X,Y,Z,lineValues);
close all 

FichNomBase=sprintf('%s',nomvar);  %GEFromFST_
%boucler sur les niveaux de contour
kmlStrAll=[];
for kLev=1:numLevels+2
    nC=size(C,2);
    XC=[];YC=[];  %curves X Y
    k1=int32(1);k2=k1;k3=0;
    while k2<nC
        k2=k1+C(2,k1);valCi=C(1,k1);
        ki=find(lineValues==valCi);
        if ki==kLev
            XC=[XC C(1,k1+1:k2) NaN];
            YC=[YC C(2,k1+1:k2) NaN];
        end
        k1=k2+1;
        k3=k3+1;
    end
	
    kmlStr = ge_plot(XC,YC,...
        'lineColor',char(LineColors(kLev)),...
        'description',char(LineLabels(kLev)));
		
    kmlStrAll=[kmlStrAll,ge_folder(char(LineLabels(kLev)),kmlStr)];
end
ge_output([FichNomBase,'.kml'],kmlStrAll);

