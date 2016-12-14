function goWEST(WESTstep)
%FUNCTION_NAME - goWEST   M_WEST
%goWEST returns the list of all steps of WEST
%
% Syntax:  goWEST(WESTstep)
%
% Inputs:
%    WESTstep - name of the WEST step you want to initiate (string)
%               (=any of those returned by WESTsteps)
%
% Outputs:
%    none
%
% Action produced:
% 	When invoked from a specific working directory, goWEST will generate a
% 	script named editcfg.m in that directory.
% 	The editcfg.m script contains a template of all settings appropriate for
% 	the WESTstep WEST step.
% 	The user will have to edit the central portion of editcfg.m and save it
% 	before proceeding with the checking and execution of the WESTstep WEST
% 	step.
%
% Example: 
% 	goWEST('MesoGrid')
% 	WEST step is MesoGrid
% 	Configuration editor (function editcfg.m) has been created here
% 	Edit its content and then use the WESTpad() function to perform the current WEST step
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% For more information, see <a href="matlab: 
% web('http://www.mathworks.com')">the MathWorks Web site</a>.
% 
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 
%
% See also: WESTsteps, WESTpad, editcfg

%------------- BEGIN CODE --------------
Here=pwd;
editcfgMasterName=[WESTstep,'_editcfg.m'];
editcfg=[Here,'\editcfg.m'];

if ismember(WESTstep,WESTsteps())
		this=which(editcfgMasterName);
        if exist(editcfg)
            %warning off backtrace
            APEmsg1('There is already an editcfg.m file in your folder. REMOVE/RENAME it','exit')
            %warning on backtrace
            return
        end
		copyfile(this,editcfg);
else
	disp(['WEST step is ',WESTstep])
	disp('Invalide...doit être membre de ...')
	disp(WESTsteps())
	return
end
%
disp(['WEST step is ',WESTstep])
disp('Configuration editor (function editcfg.m) has been created here')
disp('Edit its content and then use the WESTpad() function to perform the current WEST step') 
% idea for future work: Capture the Hash of the initial editcfg to warn
% against user not editing it rather than checkit'ing
return
