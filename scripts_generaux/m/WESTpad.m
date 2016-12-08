function WESTpad(Action,varargin)
%FUNCTION_NAME - WESTpad   M_WEST
%WESTpad returns the list of all steps of WEST
%
% Syntax:  WESTpad(Action,varargin)
%
% Inputs:
%    Action - one of {'checkit','runit'}
%      'checkit' - validate the settings
%      'runit' - execute the current WEST step. Settings must have been
%      validated in a previous WESTpad('checkit',...) call
%
%    varargin - optional/additional arguments.  
%      Usually pairs of 'token',value
%      'loadstruct',loadname - to load a full set of settings for current
%      WEST step rather than using the edit block
%      'savestruct',savename - to save a full set of validated settings to
%      a .mat file, for further referral
%      'useprevious' - logical key to use pertinent settings from previous
%      WEST steps
%      'debug' - logical key to activate some debugging printout during
%      execution
%      'mc2verbose' - logical key to activate some debugging printout
%      during MC2 execution
%      'MesoDxAndZref' - logical key to execute Dx , Zref detection and
%      I1,I2,J1,J2 calculations to assist in choosing the settings for the
%      MMC step
%
% Outputs:
%    none
%
% Example: 
%    WESTpad('checkit','useprevious')
%    WESTpad('runit','useprevious','debug')
%    WESTpad('runit')
%    too much output.  see M_WEST tutorial for examples
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% For more information, see <a href="matlab: 
% web('http://www.mathworks.com')">the MathWorks Web site</a>.
%
% For more information, see <a href="matlab: 
% web('http://www.anemoscope.ca/Intro_en.html')">the AnemoScope site</a>,
% and also <a href="matlab:web('http://sourceforge.net/projects/westose')">the WEST site</a>.
% 
% Author: Robert Benoit, Ph.D.
% email address: robert.benoit.47@gmail.com 
%
% See also: M_WEST_startup

%------------- BEGIN CODE --------------
format compact
Actions={'checkit','runit'};
if nargin < 1;disp('Usage: WESTpad(action,...) with action in ');disp(Actions);return;end
%
% parse the variable arguments
%
%defaults
loadstruct=false;
loadname='';
savestruct='';
savename='';
useprevious=false;
debugit=false;
mc2verbose=0;
Grd_output='';
MesoDxAndZref=false;
MS3R_ioInPlace=true; %false;
if nargin > 1
	vin=varargin;
for i=1:length(vin)
	if isequal(vin{i},'loadstruct')
		loadstruct=true;
% 	elseif isequal(vin{i},'loadname')
		loadname=vin{i+1};
	elseif isequal(vin{i},'savestruct')
		savestruct='saveStruct';
 	elseif isequal(vin{i},'savename')
		savename=vin{i+1};
	elseif isequal(vin{i},'useprevious')
		useprevious=true;
	elseif isequal(vin{i},'debug')
		debugit=true;
	elseif isequal(vin{i},'mc2verbose')   % 0/1
		mc2verbose=1;
	elseif isequal(vin{i},'MesoDxAndZref')
		MesoDxAndZref=true;
% 	elseif isequal(vin{i},'MS3R_ioInPlace')
% 		MS3R_ioInPlace=true;
	end
end
end
%
if ~ismember(Action,Actions);disp(['Action=',Action,' is invalid']);APEmsg1('invalid action request','exit');end
%
Here=pwd;
if debugit; fprintf('Executing in %s\n',Here); end
thisedit=which ('editcfg');
if debugit; disp(['calling ',thisedit,' ...']);end
[~,WESTstep]=editcfg();  %just get the step name
if ~isequal(WESTstep,'MC2')
	[M,WESTstep]=editcfg(loadstruct,loadname,useprevious);
else
	[M,WESTstep,vout]=editcfg(loadstruct,loadname,useprevious);  % vout used for MC2 step only sofar
end
disp(['WEST step is ',WESTstep])
if debugit
	disp(['Values of config after calling ',thisedit])
	structdisp(M)
end
%{
Create a handle to a named function:
fh = @functionName;
fh = str2func('functionName');
%}
if ismember(WESTstep,WESTsteps())
	WESTstepHandle=str2func(WESTstep);
else
	APEmsg1('WESTstep inexistant','exit')
end
% 
if isequal(Action,'checkit')
	if isequal(WESTstep,'MMC') & MesoDxAndZref
		WESTstepHandle('MesoDxAndZref',M,Here)
		return
	end
	if isequal(savename,'')
		WESTstepHandle('valider',M,Here,savestruct);
	else
		WESTstepHandle('valider',M,Here,savestruct,'saveAs',savename)
	end
end
if isequal(Action,'runit')
	if ~isequal(WESTstep,'MC2')
		if ~isequal(WESTstep,'MMC')
			WESTstepHandle('exec',M,Here,'debug',debugit)
		else
			if MS3R_ioInPlace
				WESTstepHandle('exec',M,Here,'debug',debugit,'MS3R_ioInPlace')
			else
				WESTstepHandle('exec',M,Here,'debug',debugit)
			end
		end
	else
		Grd_output=vout;
		WESTstepHandle('exec',M,Here,Grd_output,'debug',debugit,'mc2verbose',mc2verbose)
	end
end
return
