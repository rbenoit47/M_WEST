function [ i1,i2,j1,j2,status ] = FillIt( mesostats,microgeo,...
	                                       deltameso,deltamicro,nu)  %,sigma )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
status=false;
debug=false;
%
%  meso
%
[FSTpath,FSTname,FSText]=fileparts(mesostats);
ShortFST=[FSTname,FSText];
Here=pwd;
if numel(FSTpath)> 0
	cd (FSTpath)
else
	FSTpath=dirWEstat;
	cd (FSTpath)
end
%
IP1=-1; 	IP2=-1;	IP3=-1;	ETIKET='';	TYPVAR='';	DATEV=-1;
LALO='OUI';	CATALOG=0;  verbose=0;  incdat=0;  	monotonic=0;
[fstinfo1,rec,fst2binOutput]=lire_fst_APE(ShortFST,'EU',IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose,incdat,monotonic);
LLmeso(:,:,1)=rec(1).data(:,:);
LLmeso(:,:,2)=rec(2).data(:,:);
cd (Here)
%
%  micro
%
[FSTpath,FSTname,FSText]=fileparts(microgeo);
ShortFST=[FSTname,FSText];

if numel(FSTpath)> 0
	cd (FSTpath)
else
	FSTpath=dirWEstat;
	cd (FSTpath)
end
%
IP1=-1; 	IP2=-1;	IP3=-1;	ETIKET='';	TYPVAR='';	DATEV=-1;
LALO='OUI';	CATALOG=0;  verbose=0;  incdat=0;  	monotonic=0;
[fstinfo2,rec,fst2binOutput]=lire_fst_APE(ShortFST,'ME',IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose,incdat,monotonic);
LAmicro=rec(1).data(:,:);
LOmicro=rec(2).data(:,:);
cd (Here)
nimeso= fstinfo1.ni; njmeso=fstinfo1.nj;
nimicro=fstinfo2.ni;njmicro=fstinfo2.nj;
%
% trouver coins de micro dans meso
%
% LL=(lat,lon360)
%  [ILL,JLL]=LatLon2IJ(LO,LA,LoIJ,LaIJ)
ni=nimicro;nj=njmicro;
IJ4=[1,ni,1,ni;1,1,nj,nj];
Topo4={'BL','BR','TR','TL'};
for koin=1:4
% 	Lat4(koin)=LLmicro(IJ4(1,koin),IJ4(2,koin),1)';
% 	Lon4(koin)=LLmicro(IJ4(1,koin),IJ4(2,koin),2)';
	Lat4(koin)=LAmicro(IJ4(1,koin),IJ4(2,koin))';
	Lon4(koin)=LOmicro(IJ4(1,koin),IJ4(2,koin))';

end
%Lon4=mod(Lon4,-180); %360);  %les LON venant du FST sont 0-360°
Lon4=wrapTo180(Lon4);
ILL4=single([]);JLL4=single([]);
inside=true;
for i=1:numel(Lat4)
	Lon4i=Lon4(i);Lat4i=Lat4(i);
	[ILL4(i),JLL4(i)]=LatLon2IJ(LLmeso(:,:,2),LLmeso(:,:,1), Lon4i,Lat4i,inside,Topo4{i});
end
% the above solution gives NEAREST point but not necessairily INSIDE micro
% grid

%
deltamicro=single(deltamicro);
microframe=nu*0.8*deltamicro;
disp('------------Fill It-------------')
% disp([deltameso,deltamicro,nu,sigma])
if debug
	fprintf('deltameso:%12.4f, deltamicro:%12.4f, nu:%i \n',deltameso,deltamicro,nu) %,sigma)
end
if false
DI=(microframe/deltameso);  %DI tient le role du mesoframe
i1=ceil (ILL4(1) + DI);     %)+1;  %un 1 de securité
i2=floor(ILL4(2) - DI-1);   %-1;
j1=ceil (JLL4(1) + DI);     %+1;
j2=floor(JLL4(4) - DI-1);   %-1;
else
	%DI=(microframe/deltameso);
	DI=ceil(double(microframe)/double(deltameso));
	i1=ILL4(1) + DI;
	i2=ILL4(2) - DI;
	j1=JLL4(1) + DI;
	j2=JLL4(4) - DI;
end
%
status=true;
if debug
	disp(ILL4)
	disp(JLL4)
end
%
end

