function varargout=MicroGeo (action, varargin)
%
% action: 'cfg' 'valider' 'exec'

% Here=pwd;
persistent valid Mhash

switch action
	case 'cfg'
		%
        if isempty(valid);valid=false;end
        %
        M=struct( 'gridfile','','outfile','','basedir','','topodir','','vegdir','',...
			'verbose',int32(4),'log','.false.' );
		display(M)
		display('Veuiller completer les valeurs dans la structure M')
		display(' et relancer la commande: MesoGeo(''exec'',votre M)')
		varargout{1}=M;
        valid=false;
		return
	
    case 'valider'
        %{
        		M=struct ( 'GengeoMicro.gridfile','','GengeoMicro.outfile','','GengeoMicro.basedir','',...
                       'M.GengeoMicro.topodir','','M.GengeoMicro.vegdir','',...
                       'GengeoMicro.verbose',0,'GengeoMicro.log',0 );
        %}
        M=varargin{1};
        valid=false;
        if ~QC('isinteger(M.verbose) & M.verbose >= 0 & M.verbose <= 4',M.verbose,'M.verbose')                       ;return;end
        if ~QC('ischar(M.log) & ( strcmp(M.log,''.true.'') | strcmp(M.log,''.false.'')) ',M.log,'M.log')                      ;return;end
        %
        if ~QC('exist(M.gridfile,''file'')',M.gridfile,'M.gridfile');return;end
        if ~QC('exist(M.basedir,''dir'')',M.basedir,'M.basedir');return;end
        if ~isempty(M.topodir)
			  if ~QC('exist(M.topodir,''dir'')',M.topodir,'M.topodir');return;end
		  end
		  if ~isempty(M.vegdir)
			  if ~QC('exist(M.vegdir,''dir'')',M.vegdir,'M.vegdir');return;end
		  end
		  [pathstr, ~, ~] = fileparts(M.outfile);
        test=['exist(''',pathstr,''',''dir'')'];
        if ~QC(test,M.outfile,'M.outfile')                       ;return;end
        if  ~QC('~exist(M.outfile,''file'')',M.outfile,'M.outfile');
			  disp('fichier M.outfile ne doit PAS exister au prealable. L''effacer et revalider')
			  return;
		  end
        %
        valid=true;
		  Mhash=DataHash(M);
        disp('Structure M valide')
        %  enregistrer la structure
        vin=varargin;
        savename='MicroGeoStruct.mat';saveStruct=false;  %par defaut
        for i=3:length(vin)
            if isequal(vin{i},'saveStruct')
                saveStruct=true;
            end
            if isequal(vin{i},'saveAs')
                savename=vin{i+1};
                saveStruct=true;
            end
        end
        if saveStruct
            M_MicroGeo=M;
			
            save(savename,'M_MicroGeo')
            disp(['Structure M enregistrée sous le nom ',savename])
        end
   
        return
        
	case 'exec'
        if ~valid
            display('Il faut faire le ''valider'' avant ''exec''')
            return
        end
		M=varargin{1};
		Here=varargin{2};
		MhashNew=DataHash(M);
		if ~isequal(Mhash, MhashNew)
			APEmsg1('Structure M has changed since last validation.  Must checkit again','exit')
		end
		
		if  ~QC('~exist(M.outfile,''file'')',M.outfile,'M.outfile');
			disp('fichier M.outfile ne doit PAS exister au prealable. L''effacer et revalider')
			return;
		end
		
		% en premier generer le nml file
		debug=false;
		vin=varargin;
        for i=3:length(vin)
            if isequal(vin{i},'debug')
                debug=vin{i+1};
            end
        end
        if debug;display(Here);end
		rep=input('On continue? Y/N [N]: ','s');
		if isempty(rep)
			rep = 'N';
		end
		if yes_answer(rep) %strcmp
		else
			return
		end
		display('on continue...')
		pause(1)
		%
		Mynml=strcat(Here,'\microgeo.nml');
		M_WEST=getenv('M_WEST_PATH');
		Template=[M_WEST,'\3\Templates\M.microgeo.nml'];
		copyfile(Template,Mynml,'f'); %forced
		%
		% cas special des champs M.topodir et M.vegdir:
		% si vides:ok si non-vides:ajouter une chaine ',' finale (3 caract)
		% but: eviter erreur de gengeo
		%
		if ~isempty(M.topodir);M.topodir=[M.topodir,''','''];end
		if ~isempty(M.vegdir);M.vegdir=[M.vegdir,''','''];end
		%
		WEST_struct2nml( M, Mynml, 'M.GengeoMicro.', debug )
		%
		% avant execution, mettre a jour historique M_WEST
		%
		saveM_WESThist(M,true)
        %
		% puis executer
		PythonPath=getenv('PYTHON_PATH'); 'C:\Python27';
% 		DotWestPath='M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\p\.m_west';
		DotWestPath=getDotWestPath();
		PyDir='\gengeo';
		GridScript='m_runEoleGengeo.py';
		ModelSettings=Mynml;
		%
		DotPyDir=[DotWestPath PyDir];
		cd (DotPyDir)
      %
		logfileVal=0;
		if isequal(M.log,'.true.');logfileVal=1;end
		if isequal(M.log,'.false.');logfileVal=0;end
		cmdString=[GridScript,' -dotwest ',...
			DotWestPath,' -settings ',ModelSettings,' -gridfile ',M.gridfile, ' -geofile ', M.outfile, ...
            ' -verbose ', num2str(min(M.verbose,1)), ' -logfile ',num2str(logfileVal)];  %
		pyCmd=[';set PATH=',PythonPath, ';%PATH%&' ,cmdString,'&exit &'];
        if debug;display(pyCmd);end
		% newline for dos is '&' here.  Last one is to get a window
		
		try
			[status,result]=dos(pyCmd); %,'-echo')
		catch
			cd (Here)
		end
		%
		reponse=input('faire [Enter] ici APRES le Python [Enter]','s');
		%
		fprintf('\nOutput file is:%s\nConverting output to .mat format...\nCheck outcome in logfile\n',M.outfile)
		pause (2)  %just to ensure FST file has been commited to disk
		FST2MATtc(M.outfile,true,'tologfile');
		%
		cd (Here)
	otherwise
		'action inconnue'
		return
end

function ok=QC(test,var,varargin)
%
ok=evalin('caller',test);
if ~ok
    fprintf('Variable ne satisfait pas le test [%s]\n Corriger\n',test)
    fprintf('Nom de variable=%s\nValeur de variable est <',char(varargin{1}))
    disp([var,'>'])
    end
return
