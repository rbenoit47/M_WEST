%  demo pour utiliser roseDvents
%  simple rose des vents de direction
%  DIFFERENT DE windrose  ne pas confondre.  Les deux vous sont utiles.
%  celui-ci , roseDvents, est utile pour LES TACHES MESO ET MICRO.
%
%  R Benoit ETS fevrier 2014
%
clear all;clc;close all;
Ndir=12;  %nombre de directions
deltaDir=360/Ndir;
Dirs=0:deltaDir:360-deltaDir;
Freqs=rand(Ndir,1,'single');  %frequences aleatoires
% normaliser les Freqs
Freqs=Freqs./sum(Freqs);
%  faire le graphe de rose
hFigure=figure;  %handle pour la figure
hpol=roseDvents(Freqs,'mon titre.  ici les freqs sont aleatoires',...
    'nom du site. ajuster aussi lat,lon=45,285',45.,285.);
%
if hpol == 0
    display('graphique réussi et enregistré en png')
    print (hFigure,'-dpng','demoRoseDvents.png')
else
    display('erreur dans roseDvents.  stop')
    return
end
%
display('Voici les fréquences utilisées et leurs directions et leur somme')
display(Freqs)
display(Dirs')
sommeFreqs=sum(Freqs);
display(sommeFreqs)
