function varargout=MesoGrid (action, varargin)
%
% actions toutes requises sequentiellement: 'cfg' 'valider' 'exec'
%
persistent valid Mhash
%
%
switch action
	case 'cfg'
		%
		%  grid meso
		%
        if isempty(valid);valid=false;end
        M=struct ( 'Grd_dx',-1,'Grd_ni',int32(-1),'Grd_nj',int32(-1),...
            'Grd_iref',int32(-1),'Grd_jref',int32(-1),'Grd_latr',-1,...
            'Grd_lonr',-1,'Grd_dgrw',-1, 'Grd_output','' );
        display('M initialisé aux valeurs par défaut suivantes:')
        display(M)
        display('Veuiller ajuster les valeurs dans la structure M')
		  display(' au moyen du Pad script fourni ici')
        display(' et relancer la commande: MesoGrid(''exec'',votre M)')
        varargout{1}=M;
		  % 		  display(nargout)
		  % 		  if nargout > 1
		  % 			  pad=SavePad(M,'MesoGrid');
		  % 			  % 			  varargout(2)=pad
		  % % 			  whos pad
		  % 			  varargout(2)=cellstr(pad);
		  % % 			  pad
		  % 		  end
		  valid=false;
		  return
	
    case 'valider'
        %{
        'Grd_dx',-1,'Grd_ni',-1,'Grd_nj',-1,...
			'Grd_iref',-1,'Grd_jref',-1,'Grd_latr',-1,...
			'Grd_lonr',-1,'Grd_dgrw',-1, 'Grd_output',''
        %}
        M=varargin{1};
        valid=false;
        if ~QC('isfloat(M.Grd_dx) & M.Grd_dx > 1000 & M.Grd_dx < 10000',M.Grd_dx)    ;return;end
        if ~QC('isinteger(M.Grd_ni) & M.Grd_ni > 30',M.Grd_ni)                       ;return;end
        if ~QC('isinteger(M.Grd_nj) & M.Grd_nj > 30',M.Grd_nj)                       ;return;end
        if ~QC('isinteger(M.Grd_iref) & M.Grd_iref > 0 & M.Grd_iref <= M.Grd_ni',M.Grd_iref) ;return;end
        if ~QC('isinteger(M.Grd_jref) & M.Grd_jref > 0 & M.Grd_jref <= M.Grd_nj',M.Grd_jref) ;return;end
        if ~QC('isfloat(M.Grd_latr) & M.Grd_latr > -90 & M.Grd_latr < 90',M.Grd_latr);return;end
        if ~QC('isfloat(M.Grd_lonr) & M.Grd_lonr >= 0 & M.Grd_lonr < 360',M.Grd_lonr);return;end
        if ~QC('isfloat(M.Grd_dgrw) & M.Grd_dgrw >= 0 & M.Grd_dgrw < 360',M.Grd_dgrw);return;end
        %
        [pathstr, ~, ~] = fileparts(M.Grd_output);
        test=['exist(''',pathstr,''',''dir'')'];
        if ~QC(test,M.Grd_output,'M.Grd_output')                       ;return;end
 		  %  no blanks in full FST path
		  if ~QC('isempty(findstr('' '',M.Grd_output))',M.Grd_output,'M.Grd_output');return;end
       %
        valid=true;
		  Mhash=DataHash(M);
        disp('Structure M valide')
        %  enregistrer la structure
        vin=varargin;
        savename='MesoGridStruct.mat';saveStruct=false;  %par defaut
        for i=3:length(vin)   % why 3 instead of 2 ???
            if isequal(vin{i},'saveStruct')
                saveStruct=true;
            end
            if isequal(vin{i},'saveAs')
                savename=vin{i+1};
                saveStruct=true;
            end
        end
        if saveStruct
            M_MesoGrid=M;
            save(savename,'M_MesoGrid')
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
		%Mynml=strcat(Here,'\grid.nml');  
		% do not use fixed name (due to MC2 step) adjust with M.Grd_output
		[~,f,~]=fileparts(char(M.Grd_output));
		Grd_nml=['\',f,'.nml'];clear f
		Mynml=strcat(Here,Grd_nml);	
		M_WEST=getenv('M_WEST_PATH');
		Template=[M_WEST,'\2\Templates\M.mesogrid.nml'];
		copyfile(Template,Mynml,'f'); %forced
		%
		WEST_struct2nml( M, Mynml, 'M.', debug )
		%{
		===========================================
		construction de STRING_2 pour script python
		
		STRING_2=r'''^&grid\\n  Grd_typ_S="LU"\\n  Grd_proj_S="P"\\n  Grd_dx=100.0\\n  Grd_dy=100.0\\n  Grd_ni=100\\n  Grd_nj=100\\n  Grd_iref=1\\n  Grd_jref=1\\n  Grd_latr=45.0\\n  Grd_lonr=300.0\\n  Grd_dgrw=100.0\\n\\n\\n\\n\\n\\n\\n\\n/\\n\\n^&grid_output\\n  filename="C:\Users\rbenoit\Documents\WORK\D.fst"\\n/'''
		%}
		z1=importdata(Mynml,'\n');
		z2=strjoin(z1);
		i1=regexp(z2,'&grid ');
		
		z3=z2(i1:end);
		STRING_2=regexprep(z3,'"','''');  %z3 '\s+',' \n'
        i2=regexp(z2,'&grid_output');
        z4=z2(i1:i2-1); STRING_3=regexprep(z4,'"','''');
		if debug
			display(STRING_2)
			whos STRING_2
		end
		%{
		===========================================
		%}
		%
		% avant execution, mettre a jour historique M_WEST
		%
		saveM_WESThist(M,true)
		%
		% puis executer
		PythonPath=getenv('PYTHON_PATH'); %'C:\Python27';
		% 		DotWestPath='M:\EOLE\projets\1_APE\M_WEST\scripts_generaux\p\.m_west';
		% 		userHome=getUserHome();
		%		DotWestPath=[userHome,'\APEhome\.m_west'];  % utiliser copie du .m_west sur le user comme avec WEST lui-meme
		DotWestPath=getDotWestPath();
		PyDir='\grid';
		GridScript='m_runModelGrid.py';
		ModelSettings=Mynml;
		%
		DotPyDir=[DotWestPath PyDir];
		pdb=false;
		if pdb
			cmd0='python -m pdb ';
		else
			cmd0='python ';
		end
		
% 		cmdString=['python ',GridScript,' -dotwest ',...
		cmdString=[cmd0,GridScript,' -dotwest ',...
			DotWestPath,' -settings ',ModelSettings,' -gridfile ',M.Grd_output,' -dx ',num2str(M.Grd_dx),' -gridstring "',STRING_2,'"'];
		pyCmd=['set PATH=',PythonPath, ';%PATH%&' ,cmdString,'&exit &'];
        if debug; display(pyCmd);end
        % newline for dos is '&' here.  Last one is to get a window
        % 'M_WEST_CALCULATEUR'
        mwestguest=getenv('M_WEST_CALCULATEUR'); % si non vide alors on va faire le calcul de MesoGrid sur cette autre machine
        if ~isempty(regexp(mwestguest,'\d'))
            M_WEST_CALC_DotWestPath=getenv('M_WEST_CALC_DotWestPath')
            [~,from1,from2]=fileparts(M.Grd_output);
            CALCname=['./',from1,from2];  %short form of Grd_output
            PyDir='grid';
            DotPyDir=[M_WEST_CALC_DotWestPath,'/',PyDir];
            pyCmd=[cmd0,DotPyDir,'/',GridScript,' -dotwest ',M_WEST_CALC_DotWestPath, ...
			' -settings ','./ModelSettings',' -gridfile ',CALCname,' -dx ',num2str(M.Grd_dx), ...
            ' -gridstring "',STRING_2,'"']; 
        %   plink.exe -pw --- -l --- -ssh -X 192.168.1.11 "xterm -e '4plink/runMMC.sh;exit'"
            ssh_path=getenv('M_WEST_ssh_path'); ssh_cmd_=getenv('M_WEST_ssh_cmd'); scp_cmd=getenv('M_WEST_scp_cmd');
            sshCmd=[ssh_path, '\', ssh_cmd_];
            sshid=getenv('M_WEST_CALC_id');sshpw=getenv('M_WEST_CALC_pw');
            sshArgs=['-X -ssh ',mwestguest,' -l ' ,sshid,  ' -pw ' ,sshpw];
            % ssh_eArg=['"xterm -e ','''',pyCmd,';exit','''','"'];
            % sshCmd=[sshCmd,' ',sshArgs,' ',ssh_eArg] %;
            M_WEST_CALC_dir=getenv('M_WEST_CALC_dir')
            % ship input files to CALC
            toship=ModelSettings;CALCname='ModelSettings';
            scpCmd1=[ssh_path, '\', scp_cmd,' -pw ',sshpw,' ',toship,' ',...
                sshid,'@',mwestguest,':',M_WEST_CALC_dir,'/',CALCname]
            system(scpCmd1)
            CALCname=[from1,from2];  %short form of Grd_output
            scpCmd2=[ssh_path, '\', scp_cmd,' -pw ',sshpw,' ',...
                sshid,'@',mwestguest,':',M_WEST_CALC_dir,'/',CALCname,' ',M.Grd_output]
            %  generate a command text file
            LACOM='LACOM';
            fid_LACOM=fopen(LACOM,'w');
            fprintf(fid_LACOM,'GridString="%s"\n',STRING_3);
            CALCname=['./',from1,from2];  %short form of Grd_output
            pyCmd=[cmd0,DotPyDir,'/',GridScript,' -dotwest ',M_WEST_CALC_DotWestPath, ...
			' -settings ','./ModelSettings',' -gridfile ',CALCname,' -dx ',num2str(M.Grd_dx), ...
            ' -gridstring "${GridString}"']; 
            fprintf(fid_LACOM,'%s\n',pyCmd);
            fclose(fid_LACOM)
            ssh_eArg=['"xterm -e ','''','cd ',M_WEST_CALC_dir,';chmod +x ',LACOM,';./LACOM',';exit','''','"'];
            sshCmd=[sshCmd,' ',sshArgs,' ',ssh_eArg,'&exit &'] %;
            scpCmd3=[ssh_path, '\', scp_cmd,' -pw ',sshpw,' ',LACOM,' ',...
                sshid,'@',mwestguest,':',M_WEST_CALC_dir,'/',LACOM]
            system(scpCmd3)          
            dos(sshCmd) %,'-echo')
            system(scpCmd2)
            return
        end
		cd (DotPyDir)
        try
			[status,result]=dos(pyCmd); %,'-echo')
		catch
			cd (Here)
		end
		%
		reponse=input('faire [Enter] ici APRES le Python [Enter]','s');
		%  
		fprintf('\nConverting output to .mat format...\nCheck outcome in logfile\n')
		pause (2)  %just to ensure FST file has been commited to disk
		FST2MATtc(M.Grd_output,true,'tologfile');
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
    fprintf('%s=\n',char(varargin{1}))
    disp(var)
    end
return
