% M_WEST - wind resource modelling toolbox (Author: robert.benoit.47@gmail.com)
%
% M_WEST is the MATLAB-based version of WEST (Wind Energy Simulation Toolkit)
%   robert.benoit.47@gmail.com
% Version 1.0 October 2015
%
%M_WEST permet d’utiliser la même base de modélisation numérique que WEST
%lui-même, mais sans passer par l’application Java particulière de WEST; au
%lieu de celle-ci, on contrôle tout le processus de modélisation
%directement depuis MATLAB.  De plus, l’utilisation de Green Kenue pour
%l’imagerie géographique est éliminée : toute la cartographie est faite
%directement sous MATLAB. Enfin, les fichiers FST produits par WEST sont
%tous transformés en fichiers matriciels natifs de MATLAB (format .mat),
%facilitant l’accès aux informations générées par la modélisation sous
%M_WEST.
%
% WEST History 
% In the year 2000, Environment Canada began development of a
% multi-scale wind climate mapping methodology called WEST: the Wind Energy
% Simulation Toolkit. The approach WEST combined two modeling engines, MC2
% and MS-Micro. Both models were the outcome of several decades of research
% from scientist of Environment Canada (see AnemoScope Reference Guide).
% The WEST system was used in several specific applications by both public
% and private sector groups, and was refined over the next few years. As an
% example, it was used to achieve the Canadian Wind Energy Atlas
% (www.windatlas.ca). 
%
% In 2005, a user-friendly version of the WEST system
% was developed for Windows based computers. The WEST approach was combined
% with EnSimTM (now Green KenueTM), a proprietary Geographical Information
% System (GIS) developed by the Canadian Hydraulics Centre (CHC), to
% produce AnemoScopeTM.  It was the first commercial software to integrate
% seamlessly meso- and microscale wind energy modeling capabilities and to
% provide database allowing for wind resource mapping up to the microscale
% level anywhere on earth. 
%
% In 2011, the development of the WEST approach
% took place with the release, by Environment Canada, of an open source
% version of the WEST system. The latter integrates all the abilities of
% AnemoScopeTM without a GIS. It is called WEST or WESTOSE. In 2015, after
% about 10 years of use of first AnemoScope and then WEST, in a graduate
% course on «Wind power technology» at the École de technologie supérieure
% (ÉTS, Montréal, Canada), a further evolution of WEST was achieved under
% the name of M_WEST: this enables the entire control of the underlying
% WEST fluid models (MC2 and MSMicro) directly from MATLAB or Octave as
% well as providing the geographic imaging capability under these two
% analysis softwares.  M_WEST relies on several Python scripts, plus the
% executables for the MC2 and MMC (meso-micro coupler) as well as those of
% several utilities underlying WEST: all of these are contained in a folder
% named .m_west. Of course, M_WEST relies also on special MATLAB code
% (functions, scripts and data) to operate: these are contained in a second
% folder named M_WEST.  Both .m_west and M_WEST are stored in an archive
% called M_WEST.zip, to be obtained. The present tutorial describes how to
% use M_WEST to achieve wind power climatological modelling using the WEST
% algorithms/models from MATLAB.
