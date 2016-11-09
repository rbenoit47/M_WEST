function ok=HereDoFST2MAT(varargin)
%
%  convertir tous les fst du répertoire courant en .mat
%
ok=false;
if nargin > 0
	extra='tologfile';
else
	extra='';
end
%
if ~exist('dirCode','var'); 
	display('M_FST_win initialisé')
	init_M_FST_win; 
end
%
%format compact
liste=ls('.\*.fst');
[n,~]=size(liste)
%
for i=1:n
    FST=char(liste(i,:));
    FST=['.\',FST];
    disp(FST)
    %
    savemat=true;
    [Vars,Infos]=FST2MAT(FST,savemat,extra);  %option de enregistrer en .mat
end
%
ok=true;
%
return
