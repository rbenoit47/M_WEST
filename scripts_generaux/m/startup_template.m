%
% to configure MATLAB for M_WEST
%
M_WEST=[M_WEST];
M_WESThome=[MyTuto];
setenv('M_WEST_PATH',M_WEST)
setenv('M_WEST_HOME',M_WESThome)
%
% extra environment variables for tutorial and databases
%
WEST_data=[WEST_data];% path to the WEST databases (terrain and wind climate)
M_WEST_tutorial=[Tutorial];% path to the M_WEST tutorial
setenv('WEST_data',WEST_data)
setenv('M_WEST_tutorial',M_WEST_tutorial)
%
% declarer la localisation de Python
PYTHON_PATH='C:\Python27'; % par exemple C:\Python27
setenv('PYTHON_PATH',PYTHON_PATH)
% on va utiliser un storage 32bit pour convertir les données FST en .mat
setenv('FSTDATA','32bit')
% on va utiliser la base de données climatique eolienne annuelle de WEST (et non
% celle de l'Atlas canadien, ou une des saisonnieres)
setenv('WEST_CLIMATE_PREFIX','ANU1')
%
addpath([M_WEST,'\ConfigurationDeMATLAB'],...
	     [M_WEST,'\scripts_generaux\m'])
%
M_WEST_startup
%
% then move to your M_WEST home folder
%
cd (M_WESThome)
%
clear
