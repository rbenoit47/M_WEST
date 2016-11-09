function [ fst_info,fst_data,fst2binOutput ] = lire_fst_short( FST,...
    NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Here=pwd;
[FSTpath,FSTname,FSText]=fileparts(FST);
ShortFST=[FSTname,FSText];
if numel(FSTpath)> 0
	cd (FSTpath)
else
	FSTpath='.';
	cd (FSTpath)
end
try
%	attention a varargin
if (numel(varargin)>0)
	[fst_info,fst_data,fst2binOutput] = lire_fst_APE(ShortFST,...
    NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose,varargin);
else
	[fst_info,fst_data,fst2binOutput] = lire_fst_APE(ShortFST,...
    NOMVAR,IP1,LALO,IP2,IP3,ETIKET,TYPVAR,DATEV,CATALOG,verbose);
end
catch
	'erreur dans lire_fst_short'
	cd (Here)
end
cd (Here)
end

