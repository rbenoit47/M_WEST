function varargout=MC2(action, varargin)
%
% action: 'cfg' 'valider' 'exec'
format compact
persistent valid Mhash

switch action
	case 'cfg'
		%
        %   MC2
        %
        % 		M=struct ( 'mc2.rundir','mc2.step','mc2.tstep','mc2.sample','mc2.nlvls','mc2.nlvspbl',
        %                  'mc2.vmh_ndt','mc2.log','mc2.delete','mc2.processors','mc2.geophy','mc2.climatetable',
        %                  'mc2.climatestate','mc2.upolist','mc2.udolist','mc2.eole.cfgs.htop' );
        %
        if isempty(valid);valid=false;end
        %
        M=struct( 'rundir', '' ,'step', int32(-1) ,'tstep', 0  ,'sample', int32(-1) ,'nlvls', int32(-1) ,'nlvspbl', int32(-1),...
                  'vmh_ndt', int32(-1) ,'log', '.true.' ,'delete', '.true.' ,'processors', int32(1)  ,'geophy', '' ,'climatetable', '', ...
                  'climatestate', '' ,'upolist', '''DLATEN:-1'', ''DLONEN:-1'', ''MG:-1'', ''Z0EN:-1''' , ...
                  'udolist', '''TT'',''PN'',''UU'',''VV''' ,'eole_cfgs_htop', 5000 );  % pas de point dans un struct
		%display(M)
		display('Veuiller completer les valeurs dans la structure M')
		display(' et relancer la commande: MC2(''exec'',votre M)')
		varargout{1}=M;
        valid=false;
		return
	
    case 'valider'
		 %{
 		    M=struct('mc2.rundir','mc2.step','mc2.tstep','mc2.sample','mc2.nlvls','mc2.nlvspbl',
                   'mc2.vmh_ndt','mc2.log','mc2.delete','mc2.processors','mc2.geophy','mc2.climatetable',
                   'mc2.climatestate','mc2.upolist','mc2.udolist','mc2.eole.cfgs.htop' )       
		 %}
		 M=varargin{1};
		 valid=false;
		 %
		 if ~check_rundir();return;end
		 %
		 if ~QC('isinteger(M.step) & M.step > 30',M.step);return;end
		 if ~QC('isinteger(M.tstep) & M.tstep > 0',M.tstep);return;end
		 if ~QC('isinteger(M.sample) & M.sample > 0 & M.sample <= M.tstep',M.sample);return;end
		 if ~QC('isinteger(M.nlvls) & M.nlvls > 20',M.nlvls);return;end
		 if ~QC('isinteger(M.nlvspbl) & M.nlvspbl < M.nlvls',M.nlvspbl);return;end
		 if ~QC('isinteger(M.vmh_ndt) & M.vmh_ndt > 10',M.vmh_ndt);return;end
		 if ~QC('isinteger(M.processors) & M.processors < 2',M.processors);return;end  % pour la MV
		 if ~QC('ischar(M.log) & ( strcmp(M.log,''.true.'') | strcmp(M.log,''.false.'')) ',M.log);return;end
		 if ~QC('ischar(M.delete) & ( strcmp(M.delete,''.true.'') | strcmp(M.delete,''.false.'')) ',...
				 M.delete);return;end
		 if ~QC('exist(M.geophy,''file'')',M.geophy,'M.geophy');return;end
		 if ~QC('exist(M.climatetable,''file'')',M.climatetable,'M.climatetable');return;end
		 %
		 ClimateStatePrefix=getenv('WEST_CLIMATE_PREFIX');
		 % ''CAN1''
		 % allow climatestate to hold multiple states :
		 %                       'state1+state2+...+stateN'
		 statesList=[];
		 if ~isempty(strfind(M.climatestate,'+'))
			 statesList=strsplit(M.climatestate,'+');
		 else
			 statesList={M.climatestate};
		 end
		 for iState=1:numel(statesList)
			 climState=char(statesList(iState));
			 if ~QC('ischar(climState) & ~isempty(climState) & ~isempty(strfind(climState,ClimateStatePrefix))',...
					 climState,'M.climatestate');return;end
		 end
% 		 if ~QC('ischar(M.climatestate) & ~isempty(M.climatestate) & ~isempty(strfind(M.climatestate,ClimateStatePrefix))',...
% 				 M.climatestate,'M.climatestate');return;end
		 if ~QC('isfloat(M.eole_cfgs_htop) & M.eole_cfgs_htop > 3000',M.eole_cfgs_htop)    ;return;end
		 if ~QC('ischar(M.upolist)',M.upolist,'M.upolist');return;end
		 if ~QC('ischar(M.udolist)',M.udolist,'M.udolist');return;end
		 %
         %  python must be available!
         isPythonhere();
		 valid=true;
		 Mhash=DataHash(M);
		 disp('Structure M valide')
		 %  enregistrer la structure
		 vin=varargin;
		 savename='MC2Struct.mat';saveStruct=false;  %par defaut
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
			 M_MC2=M;
			 save(savename,'M_MC2')
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
		Grd_output=varargin(3);
		%
		debug=false;
		vin=varargin;
		debug=false;mc2verbose=0;  %par defaut
		for i=3:length(vin)   %why 3:  because of Here and M= varargin#1 and 2
			if isequal(vin{i},'debug')
				debug=vin{i+1};
			end
			if isequal(vin{i},'mc2verbose')   % 0/1
				mc2verbose=vin{i+1};
			end
		end
		if strcmp(char(M.log),'.true.')
			mc2log=1;
		else
			mc2log=0;
		end
		%
		if ~check_rundir();return;end  % do it again, just in case !!!
		%
		if debug;display(Grd_output);end
		[p,f,e]=fileparts(char(Grd_output));
		Grd_nml=[p,'\',f,'.nml'];clear  p f e
		%
		if debug;
			display(Here)
			display(Grd_nml)
		end
		rep=input('On continue? Y/N [N]: ','s');
		if isempty(rep)
			rep = 'N';
		end
		if yes_answer(rep) %strcmp
		else
			return
		end
		display('on continue...')
% 		pause(1)
		Mynml=strcat(Here,'\mc2.mc2');
		M_WEST=getenv('M_WEST_PATH');
		Template=[M_WEST,'\2\Templates\M.mc2.mc2'];
		copyfile(Template,Mynml,'f'); %forced
		statesList=WEST_struct2nml( M, Mynml, 'M.mc2.', debug, 'splitfields',{'climatestate'},'+' );
		%  statesList ==> for the fst 2 mat converter
		%
		% avant execution, mettre a jour historique M_WEST
		%
		saveM_WESThist(M,true)
		%
		% puis executer:
		%
		% NB: DEUX scripts python à lancer successivement
		% a)  m_MC2PrepareRun.py   b) m_runAll.py
		%
		PythonPath=getenv('PYTHON_PATH');
		%
		DotWestPath=getDotWestPath();
		PyDir='\mc2';
		DotPyDir=[DotWestPath PyDir];
		ModelSettings=Mynml;
		cd (DotPyDir)
		if debug;display(['cd DotPydir: ', DotPyDir]);end
		%Feb 2016 make sure to use the proper geophy file!!!
		propergeophy=M.geophy;
		targetgeophy=[DotWestPath '\mc2\CommonDirectory\geophy.fst'];
		if exist(targetgeophy); delete (targetgeophy);end
		copyfile(propergeophy,targetgeophy,'f');
		%
		% a)
		%
		GridScript='m_MC2PrepareRun.py ';
		%{
        -dotwest DOTWEST      La racine des repertoires de M_WEST
        -settings SETTINGS    La configuration MC2 preparee avec Matlab
        -gridfile GRIDFILE    La configuration de grille meso preparee avec Matlab
        -climatetable CLIMATETABLE
                       La table de frequence climatique fournie (soit WEST
                       soit Atlas Canada)
        -mc2template MC2TEMPLATE
                       Le gabarit de configuration MC2 qui sera ajuste pour
                       chaque classe climatique
        -rundirectory RUNDIRECTORY
                       Repertoire dexecution du MC2 (vide)
        -verbose VERBOSE      Controle de la verbosite (0/1)
		%}
		gridfile=char(Grd_nml);
		if debug;display(gridfile);end
		%
		cmdString=['python ',GridScript,' -dotwest ', DotWestPath ,' -settings ', ModelSettings ,...
			' -gridfile ', gridfile, ' -verbose ', num2str(mc2verbose),...
			' -climatetable ',char(M.climatetable), ' -rundirectory ', M.rundir ];
		%
		pyCmd=['set PATH=',PythonPath, ';%PATH%&' ,cmdString,'&exit &'];
		if debug;display(pyCmd);end
		% newline for dos is '&' here.  Last one is to get a window
		try
			[status,result]=dos(pyCmd); %,'-echo')
		catch
			cd (Here)
		end
		%  =================================================
		rep=input('Apres avoir ferme le premier script python ... faire [Enter]: ','s');
		%  =================================================
		%
		% b)
		%
		GridScript='m_runAll.py';
		ClimateStatePrefix=getenv('WEST_CLIMATE_PREFIX');
		disp('second script python a ete lance ...')
		%{
          -rundirectory RUNDIRECTORY
                        Repertoire dexecution du MC2 (deja prepare)
          -uselogfiles USELOGFILES
                        Pour ecrire des log file par MC2 (0/1)
          -verbose VERBOSE      Controle de la verbosite (0/1)
   		 -ClimateStatePrefix   CLIMATESTATEPREFIX Prefixe des noms de classe climatique
		%}
		%
		cmdString=['python ',GridScript,' -rundirectory ', M.rundir ,...
			' -verbose ', num2str(mc2verbose), ' -uselogfiles ',num2str(mc2log) ,...
			' -ClimateStatePrefix ', ClimateStatePrefix];
		%
		pyCmd=['set PATH=',PythonPath, ';%PATH%&' ,cmdString,'&exit &'];
		if debug;display(pyCmd);end
		%
		try
			[status,result]=dos(pyCmd);
		catch
			cd (Here)
		end
		
		%
		reponse=input('faire [Enter] ici APRES le Python [Enter]','s');
		%
		% doing one state at a time
		for i=1:numel(statesList)
			state=statesList{i};
			targetdir=[M.rundir '\' state '\output'];  %M.climatestate
			fprintf('\nTarget directory is:%s\nConverting output to .mat format...\nCheck outcome in logfile\n',targetdir)
			%
			cd (targetdir)
			%
			HereDoFST2MAT('logit');
		end
		cd (Here)
	otherwise
		'action inconnue'
		return
end

function ok=check_rundir
	ok=false;
	if ~QC('exist(char(M.rundir),''dir'')',M.rundir,'M.rundir')
		fprintf('Le rundir [%s] est inexistant.  Le creer puis revalider\n',char(M.rundir))
		return
	else
		if ~QC('emptyfolder(char(M.rundir))',M.rundir,'M.rundir')
			fprintf('Le rundir [%s] doit être vide pour continuer, mais il ne l''est pas...\n',char(M.rundir))
			ls(char(M.rundir))
			rep=input('Voulez-vous qu''il soit vidé? Y/N [N]: ','s');
			warning ('off','all')
			if strcmp(rep,'Y')
				delete([char(M.rundir),'\*'])
				rmdir ([char(M.rundir),'\*'],'s')
				ls(char(M.rundir))
			else
				return
			end
			warning ('on','all')
		end
	end
	ok=true;
end

end  % for MC2 function

function ok=QC(test,var,varargin)
%
ok=evalin('caller',test);
if ~ok
    fprintf('Variable ne satisfait pas le test [%s]\n Corriger\n',test)
    fprintf('%s=\n',char(varargin{1}))
    disp(var)
    end
%return
end

function empty=emptyfolder(folder)
content=dir(folder);
if numel(content) > 2   % 2 est pour le . et ..
    empty=false;
else
    empty=true;
end
%return
end
