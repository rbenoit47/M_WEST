%SCRIPT_NAME - M_WEST_startup   M_WEST
%M_WEST_startup performs required tasks to initiate the use of the M_WEST
%kit in MATLAB.
%This script SHOULD typically be called by a startup* script located in
%your MATLAB home directory.
%
% Syntax:  M_WEST_startup
%
% Inputs:
%    none
%
% Outputs:
%    none
%
% Actions produced:
% =================
% Reads some environment variables (needed!!) M_WEST_HOME, M_WEST_PATH
% Defines some environment variables: M_WESThist, 
% Adds several elements to the MATLAB path
% Creates or updates the .mwest folder located direct under the M_WEST_HOME
% folder.  .mwest contains the user copy of all the Python portion of
% M_WEST. The updates are based on the master (not the user) copy of .mwest
% located under M_WEST_PATH.
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% For more information, see <a href="matlab: 
% web('http://www.anemoscope.ca/Intro_en.html')">the AnemoScope site</a>,
% and also <a href="matlab:web('http://sourceforge.net/projects/westose')">the WEST site</a>.
%  
% 
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 
%
% See also: 

%------------- BEGIN CODE --------------
%
M_WESThome=getenv('M_WEST_HOME');
M_WESThist=[M_WESThome,'\mwrc.mat'];
setenv('M_WEST_HIST',M_WESThist)
%
M_WEST=getenv('M_WEST_PATH');
M_WEST_m=[M_WEST,'\scripts_generaux\m'];
M_WEST_taches=M_WEST;
%
addpath(genpath(M_WEST_m))
%
addpath(genpath([M_WEST_taches,'\1']))
addpath(genpath([M_WEST_taches,'\2']))
addpath(genpath([M_WEST_taches,'\3']))
%
% mettre a jour le contenu de .m_west
%
DotWestMasterPath=[M_WEST,'\scripts_generaux\p\.m_west'];
DotWestPath=getDotWestPath();
fprintf('\nPath for .mwest is [%s]\n\n',DotWestPath)
if exist(DotWestPath,'dir')
	disp('.m_west sera mis a jour')
else
    disp('.m_west inexistant. Sera cree')
end
% et rafraichir depuis le master
copyCmd=['xcopy /DEHIRQY ',DotWestMasterPath,' ',DotWestPath]; 
%v1/QSID  attention delicat!!! v2 /EHIRSTQY
dos(copyCmd);
disp('.m_west est à jour. OK')
%
fprintf('\n----------------------\n  Configuration de MATLAB pour M_WEST faite\n----------------------\n')
% clear M_WEST_m M_WEST_taches APEhome home
M_path=path;
splits=regexp(M_path,';','split');
pc=char(splits);
[nstr,nlen]=size(pc);
fprintf('\n\n Portion M_WEST du search path de MATLAB: \n----------------------------\n')
for i=1:nstr
    pci=pc(i,:);
    j=strfind(pci,'M_WEST');
    if ~isempty(j)
        fprintf('%s\n',pci)
    end
end
fprintf('\n--------------------------\n')
%
