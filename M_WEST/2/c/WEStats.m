function varargout=WEStats(action, varargin)
%
% action: 'cfg' 'valider' 'exec'

persistent valid Mhash
%
PythonPath='C:\Python27';
DotWestPath=getDotWestPath();
%
switch action
	case 'cfg'
		%
		%   WEStats
		%
		if isempty(valid);valid=false;end
		%
		M=struct( 'ModelDirectory', '' ,'IP1', int32(-1) ,'DynamicsTimeStepNumber', int32(-1)  , ...
			'delete', '.true.' ,'geophy', '' ,'table_ef', '', ...
			'StatsLevel', 0, 'MaxWindSpeed', 0, 'Stats', '', 'AveragingLength', int32(-1) );  % pas de point dans un struct
		%
		display('Veuiller completer les valeurs dans la structure M')
		display(' et relancer la commande: WEStats(''exec'',votre M)')
		varargout{1}=M;
		valid=false;
		return
		
	case 'valider'
		%{
		%}
		M=varargin{1};
		Here=varargin{2};
		valid=false;
		%
		if ~QC('exist(char(M.ModelDirectory),''dir'')',M.ModelDirectory,'M.ModelDirectory')
			fprintf('Le ModelDirectory [%s] est inexistant.  Ajuster puis revalider\n',char(M.ModelDirectory))
			return
		else
			ClimateStatePrefix=getenv('WEST_CLIMATE_PREFIX');
			listMC2Runs=ls([M.ModelDirectory,'\',ClimateStatePrefix,'*']);
			whos listMC2Runs;
			[Nruns,~]=size(listMC2Runs);
			if Nruns < 50
				fprintf('Le ModelDirectory [%s] a moins que 50 classes: trop peu.  Remplir avec une des archives J_I.7z puis revalider\n',char(M.ModelDirectory))
				return
			else
				fprintf('%i simulations MC2 dans %s\n',Nruns,M.ModelDirectory)
				for i=1:10:Nruns
					fprintf('%3i ',i)
					for j=i:min(i+9,Nruns)
						fprintf('%s ',listMC2Runs(i,:))
					end
					fprintf('\n')
				end
			end
		end
		%
		disp(' ')
		disp('voici la liste des niveaux verticaux disponibles dans les fichiers fst MC2 choisis')
		%{
			PythonPath='C:\Python27';
		   DotWestPath='C:\Users\rbenoit\APEhome\.m_west';
			getLevels rpnStandardFile outputFilename logFilename
		%}
		FichierMC2tests=ls([M.ModelDirectory,'\',listMC2Runs(1,:),'\output\dm*.fst']);
		FichierMC2test=[M.ModelDirectory,'\',listMC2Runs(1,:),'\output\',FichierMC2tests(end,:)];
		LevelsOut='.\Levels.txt';
		LevelsLog='.\Levels.log';
		%
		try
			cd ([DotWestPath,'\getLevels'])
		catch
			disp('Votre repertoire .m_west nest pas a date.  relancer MATLAB')
			return
		end
		Cmd=['getLevels.exe ', FichierMC2test,' ',LevelsOut,' ', LevelsLog];
		[status,result] =dos(Cmd);
		type(LevelsOut)
		% 			type(LevelsLog)
		fprintf('Liste des niveaux prise dans fichier test:%s\n',FichierMC2test)
		levIP1=num2str(M.IP1);
		sLevelsOut=fileread(LevelsOut);
		if isempty(strfind(sLevelsOut,levIP1));disp(['Niveau ',levIP1,' pas dans cette liste']);cd (Here);APEmsg1('wrong M.IP1...adjust','exit');end
		cd (Here)
		disp(' ')
		%
		if ~QC('isinteger(M.IP1) & M.IP1 > 12001',M.IP1,'M.IP1')
			return
		end
		%
		if ~QC('isinteger(M.DynamicsTimeStepNumber) & M.DynamicsTimeStepNumber > 0',M.DynamicsTimeStepNumber,'M.DynamicsTimeStepNumber');return;end
		if ~QC('ischar(M.delete) & ( strcmp(M.delete,''.true.'') | strcmp(M.delete,''.false.'')) ',...
				M.delete,'M.delete');return;end
		if ~QC('exist(M.geophy,''file'')',M.geophy,'M.geophy');return;end
		if ~QC('exist(M.table_ef,''file'')',M.table_ef,'M.table_ef');return;end
		if ~QC('M.StatsLevel > 0 & M.StatsLevel <= 100',M.StatsLevel,'M.StatsLevel');return;end
		if ~QC('M.MaxWindSpeed > 0 & M.MaxWindSpeed <= 30',M.MaxWindSpeed,'M.MaxWindSpeed');return;end
		[pathstr, ~, ~] = fileparts(M.Stats) ;
		if ~QC('exist(pathstr,''dir'')',M.Stats,'M.Stats')
			fprintf('Le repertoire (%s) devant recevoir M.Stats (%s) est inexistant. Corriger\n',pathstr,M.Stats) 
			return
		end
		if ~QC('M.AveragingLength > 0 & M.AveragingLength <= 3',M.AveragingLength,'M.AveragingLength');return;end
		%
		valid=true;
		Mhash=DataHash(M);
		disp('Structure M valide')
		%  enregistrer la structure
		vin=varargin;
		savename='WEStatsStruct.mat';saveStruct=false;  %par defaut
		for i=3:length(vin)
			if isequal(vin{i},'saveStruct')
				saveStruct=true;
			end
			if isequal(vin{i},'saveAs')
				if ~isequal(vin{i+1},'');savename=vin{i+1};end
				saveStruct=true;
			end
		end
		if saveStruct
			M_WEStats=M;
			save(savename,'M_WEStats')
			disp(['Structure M enregistrée sous le nom ',savename])
		end
		return
		
	case 'exec'
		if ~valid
			display('Il faut faire le ''valider'' avant ''exec''')
			return
		end
		% en premier generer le nml file
		M=varargin{1};
		Here=varargin{2};
		MhashNew=DataHash(M);
		if ~isequal(Mhash, MhashNew)
			APEmsg1('Structure M has changed since last validation.  Must checkit again','exit')
		end		
% 		Grd_output=varargin(3);
		%
		debug=false;
		vin=varargin;
		verbose=0;  %par defaut
		for i=3:length(vin)
			if isequal(vin{i},'debug')
				debug=vin{i+1};
			end
			if isequal(vin{i},'verbose')   % 0/1
				verbose=vin{i+1};
			end
		end
		%
		if debug;
			display(Here)
% 			display(Grd_nml)
		end
		rep=input('On continue? Y/N [N]: ','s');
		if isempty(rep)
			rep = 'N';
		end
		if yes_answer(rep)
		else
			return
		end
		display('on continue...')
% 		pause(1)

		M_WEST=getenv('M_WEST_PATH');
		Template=[M_WEST,'\2\Templates\M.westats.nml'];
		Mynml=strcat(Here,'\westats.nml');
		copyfile(Template,Mynml,'f'); %forced
		WEST_struct2nml( M, Mynml, 'M.', debug);
		%
		% avant execution, mettre a jour historique M_WEST
		%
		saveM_WESThist(M,true)
		%
		% puis executer
		%
		PyDir='\westats';
		DotPyDir=[DotWestPath PyDir];
		ModelSettings=Mynml;
		cd (DotPyDir)
		%
		PyScript='m_runWEStats.py ';
		%{
     -dotwest DOTWEST
     -settings SETTINGS
     -mesogeoin MESOGEOIN
     -westatsout WESTATSOUT
     -verbose VERBOSE
		%}
% 		gridfile=char(Grd_nml);
% 		if debug;whos M_MesoGrid ;display(gridfile);end
		%
		cmdString=['python ',PyScript,' -dotwest ', DotWestPath ,' -settings ', ModelSettings ,...
			' -mesogeoin ', M.geophy, ' -westatsout ', M.Stats,...
			' -verbose ', num2str(verbose)];
		%
		pyCmd=['set PATH=',PythonPath, ';%PATH%&' ,cmdString,'&exit &'];
		if debug;display(pyCmd);end
		% newline for dos is '&' here.  Last one is to get a window
		try
			[status,result]=dos(pyCmd); %,'-echo')
		catch
			cd (Here)
		end
		cd (Here)
		%
		reponse=input('faire [Enter] ici APRES le Python script','s');
		%
		target=[M.Stats];
		fprintf('\nTarget file is:%s\nConverting WEStats output to .mat format...\nCheck outcome in logfile\n',target)
		FST2MATtc(target,true,'tologfile');
		
	otherwise
		'action inconnue'
		return
end

function ok=QC(test,var,varargin)
%
ok=evalin('caller',test);
if ~ok
	fprintf('Variable ne satisfait pas le test [%s]\n Corriger\n',test)
	fprintf('%s=\n',char(varargin{1}))
	disp(var)
end
return

function empty=emptyfolder(folder)
content=dir(folder);
if numel(content) > 2   % 2 est pour le . et ..
	empty=false;
else
	empty=true;
end
return
