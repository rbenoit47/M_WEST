function varargout=MMC (action, varargin)
%
% action: 'cfg' 'valider' 'exec'
persistent valid Mhash
%
PythonPath=getenv('PYTHON_PATH');
DotWestPath=getDotWestPath();
%
switch action
	case 'cfg'
		%
        %   MMC
        %
		  %{
			'M.MMC.mesostats'
			'M.MMC.microgeo'
			'M.MMC.z0defines'
			'M.MMC.msmicrotilesdir'
			'M.MMC.microstats'
			M.MMC.runmsmicro
			M.MMC.deleteintermediatefiles
			M.MMC.delta
			M.MMC.i1
			M.MMC.i2
			M.MMC.j1
			M.MMC.j2
			M.MMC.sigma
			M.MMC.verbose
			M.MMC.rzm
			M.MMC.zref
			'M.MMC.outvar' 
			'M.MMC.outdir' 
			M.MMC.verbose		
		  %}
        if isempty(valid);valid=false;end
        %
		  % attention outvar outdir sont les variables a sortir et les directions
        M=struct( 'mesostats','','microgeo','','z0defines','','msmicrotilesdir','','microstats','',...
			         'outvar','','outdir','',...
			         'runmsmicro','.false.','deleteintermediatefiles','.false.','delta',-1,'i1',int32(-1),'i2',int32(-1),'j1',int32(-1),'j2',int32(-1),...
						'sigma',-1,'rzm',-1,'zref',-1 ,'verbose','.true.');  % 
%
		display('Veuiller completer les valeurs dans la structure M')
		display(' et relancer la commande: MMC(''exec'',votre M)')
		varargout{1}=M;
		valid=false;
		return
				
	case 'MesoDxAndZref'
		fprintf('\n---------------\nMesoDxAndZref\n---------------\n\n')
		M=varargin{1};
		Here=varargin{2};
		[ok,dxmeso,dgrwmeso]=getDXfromFSTfield(M.mesostats,'ME',-1);
		if ~ok;APEmsg1('Probleme avec dx pour le mesostats','exit');end
		[ok,dxmicro,dgrwmicro]=getDXfromFSTfield(M.microgeo,'ME',-1);
		if ~ok;APEmsg1('Probleme avec dx pour le microgeo','exit');end
		if ~isequal(dgrwmeso,dgrwmicro)
			APEmsg1('2 grilles meso et micro doivent avoir meme dgrw (=angulation meridionale)','exit')
		else
			fprintf('OK!  The two grids have same angulation (dgrw=%f)\n\n',dgrwmeso)
		end
		try
			cd ([DotWestPath,'\getZref'])
		catch
			disp('Votre repertoire .m_west nest pas a date.  relancer MATLAB')
			return
		end
		zRefOut='.\zRefOut.txt';
		Cmd=['getZref.exe ', M.mesostats,' ',zRefOut];
		[status,result] =dos(Cmd);
		zref=fileread(zRefOut);
		zref=strtrim(zref);
		%
		delete(zRefOut)
		cd (Here)
		fprintf('Dx''s and Statistics altitude from the data files:...\n\nmesostats file: %s\n Meso Dx (dx meso): %f\n Stats Elevation (zref): %s\n',char(M.mesostats),dxmeso,zref)
		fprintf('microgeo  file: %s\n Micro Dx         : %f\n',char(M.microgeo),dxmicro)
		%
% 		[i1,i2,j1,j2,ok]=FillIt(M.mesostats,M.microgeo,dxmeso, dxmicro,M.nu);
% 		if ~ok
% 			'Erreur de FillIt.  return'
% 			return
% 		end
% 		fprintf('Using the 2 dx from the mesostats and microgeo files...\nFillIt. I1,J1: %i %i\n        I2,J2: %i %i\n',i1,j1,i2,j2)
		%
		if ~isempty(M.sigma)
			fprintf('\n (A): Getting Micro Dx from solver using current M.sigma (%f)\n',M.sigma)
			[ d,sigmaout ] = solve_microdx( M.stride,double(dxmeso),M.nu,M.sigma);
			fprintf('microdx solver:\n Micro Dx=%d for sigma(out)=%d\n',d,sigmaout)
			[i1,i2,j1,j2,ok]=FillIt(M.mesostats,M.microgeo,dxmeso, d,M.nu);
			fprintf('FillIt. I1,J1: %i %i\n        I2,J2: %i %i\n',i1,j1,i2,j2)
		end
		fprintf('\n (B): Getting Micro Dx from solver using current Micro Dx(microgeo file)=(%f)\n',dxmicro)
		[ d,sigmaout ] = solve_microdx( M.stride,double(dxmeso),M.nu,[],double(dxmicro));
		fprintf('microdx solver:\n Micro Dx=%d for sigma(out)=%d\n',d,sigmaout)
% 		disp('FillIt with above solution')
		[i1,i2,j1,j2,ok]=FillIt(M.mesostats,M.microgeo,dxmeso, d,M.nu);
		fprintf('FillIt. I1,J1: %i %i\n        I2,J2: %i %i\n\n',i1,j1,i2,j2)
		return
	
	case 'valider'
		M=varargin{1};
		Here=varargin{2};
% 		DoFillIt=true;
		valid=false;
		varargout{1}=[];
		if ~QC('ischar(M.runmsmicro) & ( strcmp(M.runmsmicro,''.true.'') | strcmp(M.runmsmicro,''.false.'')) ',...
				M.runmsmicro,'M.runmsmicro');return;end
		if ~QC('ischar(M.deleteintermediatefiles) & ( strcmp(M.deleteintermediatefiles,''.true.'') | strcmp(M.deleteintermediatefiles,''.false.'')) ',...
				M.deleteintermediatefiles,'M.deleteintermediatefiles');return;end
		%
		if ~QC('exist(M.mesostats,''file'')',M.mesostats,'M.mesostats');return;end
		if ~QC('exist(M.microgeo,''file'')',M.microgeo,'M.microgeo');return;end
		if ~QC('exist(M.msmicrotilesdir,''dir'')',M.msmicrotilesdir,'M.msmicrotilesdir');return;end
		
		if ~emptyfolder(M.msmicrotilesdir) && isequal(M.runmsmicro,'.false.')
			disp('Folder msmicrotilesdir doit etre vide avant execution MMC runmsmicro(false).')
			return
		end
		
		[pathstr, ~, ~] = fileparts(M.microstats);
		test=['exist(''',pathstr,''',''dir'')'];
		if ~QC(test,M.microstats,'M.microstats');return;end
		if  ~QC('~exist(M.microstats,''file'')',M.microstats,'M.microstats');
			disp('fichier M.microstats ne doit PAS exister. L''effacer et revalider')
			return;
		end
        if ~QC('ischar(M.outvar)',M.outvar,'M.outvar');return;end
        if ~QC('ischar(M.outdir)',M.outdir,'M.outdir');return;end
		if ~QC('~isequal('''',M.outvar)',M.outvar,'M.outvar');return;end
		if ~QC('M.rzm >= 10 && M.rzm <=200',M.rzm,'M.rzm');return;end
		%
		if M.zref <=0  %generer zref au besoin
			try
				cd ([DotWestPath,'\getZref'])
			catch
				disp('Votre repertoire .m_west nest pas a date.  relancer MATLAB')
				return
			end
			zRefOut='.\zRefOut.txt';
			Cmd=['getZref.exe ', M.mesostats,' ',zRefOut];
			[status,result] =dos(Cmd);
			zref=fileread(zRefOut);
			zref=strtrim(zref);
			M.zref=str2num(zref);
			delete(zRefOut)
			cd (Here)
		end
		%
		if ~QC('~isempty(M.zref) && M.zref >0',M.zref,'M.zref');return;end
		if ~QC('~isempty(M.sigma) && M.sigma >0 && M.sigma <1',M.sigma,'M.sigma');return;end
 		if ~QC('~isempty(M.delta) && M.delta >0',M.delta,'M.delta');return;end
		%
		% les i1 i2 j1 j2
		if ~QC('isnumeric(M.i1) && isequal(M.i1,floor(M.i1)) && M.i1 >0',M.i1,'M.i1');return;end
		if ~QC('isnumeric(M.i2) && isequal(M.i2,floor(M.i2)) && M.i2 >0',M.i2,'M.i2');return;end
		if ~QC('isnumeric(M.j1) && isequal(M.j1,floor(M.j1)) && M.j1 >0',M.j1,'M.j1');return;end
		if ~QC('isnumeric(M.j2) && isequal(M.j2,floor(M.j2)) && M.j2 >0',M.j2,'M.j2');return;end
		%
        %  python must be available!
        isPythonhere();
		valid=true;
		Mhash=DataHash(M);
		varargout{1}=M;
		disp('Structure M valide')
		%structdisp(M)
		%  enregistrer la structure
		vin=varargin;
		savename='MMCStruct.mat';saveStruct=false;  %par defaut
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
			M_MMC=M;
			save(savename,'M_MMC')
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
		
		debug=false;
		vin=varargin;
		MS3R_ioInPlace=false;
		for i=3:length(vin)
			if isequal(vin{i},'debug')
				debug=vin{i+1};
			elseif isequal(vin{i},'MS3R_ioInPlace')
				MS3R_ioInPlace=true;
			end
		end
		
		if ~emptyfolder(M.msmicrotilesdir) && isequal(M.runmsmicro,'.false.')
			disp('Folder msmicrotilesdir doit etre vide avant execution MMC runmsmicro(false).')
			return
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
		Mynml=strcat(Here,'\MMC.nml');
		M_WEST=getenv('M_WEST_PATH');
		Template=[M_WEST,'\3\Templates\M.MMC.nml'];
		copyfile(Template,Mynml,'f'); %forced
		%
		WEST_struct2nml( M, Mynml, 'M.MMC.', debug )
		%
		% avant execution, mettre a jour historique M_WEST
		%
		saveM_WESThist(M,true)
		%
		if false
			ClesChar=char('MMC.i1','MMC.i2','MMC.j1','MMC.j2','MMC.rzm',...
				'MMC.mesostats', 'MMC.microgeo', 'MMC.z0defines', 'MMC.msmicrotilesdir',...
				'MMC.microstats', 'MMC.outvar', 'MMC.outdir',...
				'MMC.deleteintermediatefiles','MMC.verbose','MMC.runmsmicro',...
				'MMC.zref','MMC.delta','MMC.sigma');
			Cles=cellstr(ClesChar);
			ClesNumStr=[ true true true true true ...
				false false false false ...
				false false false ...
				false false false ...
				true true true ];  %num (T) or string (F)

			Valeurs=[ M.i1,M.i2,M.j1,M.j2,M.rzm,M.zref,M.delta,M.sigma ];
			ValeursC=cellstr(char(...
				M.mesostats, M.microgeo, M.z0defines, M.msmicrotilesdir,...
				M.microstats, M.outvar, M.outdir,...
				M.deleteintermediatefiles,M.verbose,M.runmsmicro));  %chars
			if debug
				display(Valeurs)
				display(ValeursC)
			end
			%
			%  MMC
			%
			M_WEST=getenv('M_WEST_PATH');
			Template=[M_WEST,'\3\Templates\M.MMC.nml'];
			copyfile(Template,Mynml,'f'); %forced
			%
			ic=0;inum=0;
			for Cle=1:numel(Cles)
				Cle;
				CleM=['M.' char(Cles(Cle))];
				if ClesNumStr(Cle)
					inum=inum+1;
					Valeur=num2str(Valeurs(inum));
				else
					ic=ic+1;
					Valeur=char(ValeursC(ic));
				end
				EDITnml(Mynml,CleM,Valeur,false);
			end
		end
		% puis executer
		PyDir='\mmc';
		GridScript='m_runMMCplus.py';
		ModelSettings=Mynml;
		%
		DotPyDir=[DotWestPath PyDir];
		cd (DotPyDir)
      %
		cmdString=[GridScript,' ',ModelSettings,' ',num2str(MS3R_ioInPlace)];  %
		pyCmd=[';set PATH=',PythonPath, ';%PATH%&' ,cmdString,'&exit &'];
		if debug;display(pyCmd);end
		% newline for dos is '&' here.  Last one is to get a window
		try
			[status,result]=dos(pyCmd); %,'-echo')
		catch
			cd (Here)
		end
		cd (Here)
		%
		reponse=input('faire [Enter] ici APRES le Python [Enter]','s');
		%
		if isequal(M.runmsmicro,'.true.')
			fprintf('\nOutput file is:%s\nConverting output to .mat format...\nCheck outcome in logfile\n',M.microstats)
			pause (2)  %just to ensure FST file has been commited to disk
			FST2MATtc(M.microstats,true,'tologfile');
		end
		%
		if isequal(M.deleteintermediatefiles,'.false.') || isequal(M.runmsmicro,'.false.')
			cd (M.msmicrotilesdir)
			microGrid.fst='.\MMC_WORKING_DIR\microGrid.fst';
			fprintf('\nmicroGrid.fst file is:%s\nConverting output to .mat format...\nCheck outcome in logfile\n',microGrid.fst)
			pause (2)  %just to ensure FST file has been commited to disk
			FST2MATtc(microGrid.fst,true,'tologfile');
			cd (Here)
		end
		%		
	otherwise
		'action inconnue'
		return
end
end  %MMC function

function ok=QC(test,var,varargin)
%
ok=evalin('caller',test);
if ~ok
    fprintf('Variable ne satisfait pas le test [%s]\n Corriger\n',test)
    fprintf('%s=\n',char(varargin{1}))
    disp(var)
    end
end

function empty=emptyfolder(folder)
content=dir(folder);
if numel(content) > 2   % 2 est pour le . et ..
    empty=false;
else
    empty=true;
end
end

