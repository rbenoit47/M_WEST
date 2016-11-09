function [fst_info,fst_data] = lire_bin_APE(fid,verbose)

   %
   % Fonction  : lire_bin
   %
   % Auteur    : Andre Plante, CMC pour projet SPEO
   %
   % But       : Lire un record  

   % Lecture de la version
	%  =====================================	
	%  NOTE: pour chaque enregistrement fortran binaire on a:
	%  enregistrement:
	%     marqueur DEBUT:  =4 bytes. valeur=nombre de bytes dans enregistrement
	%     données
	%     marqueur FIN:  même syntaxe que marqueur DEBUT
	%  =====================================
   [dummy,count]=fread(fid,1,'integer*4');
	[version_encodage,count]=fread(fid,1,'integer*4');
	[dummy,count]=fread(fid,1,'integer*4');

   if version_encodage ~= 1

     error(['Probleme d encodage : type lu = ' num2str(version_encodage) ', type suporte = 1'])

   end

   % Lecture du nombre de record
   [dummy,count]=fread(fid,1,'integer*4');
   [nrec,count]=fread(fid,1,'integer*4');
   [dummy,count]=fread(fid,1,'integer*4');
%
%  option to use 32bit or 64bit for the MATLAB storage of the data part of the FST
%  RB 08/2015
%
DATAbitOPTION=getenv('FSTDATA');
switch(DATAbitOPTION)
	case('32bit')
		DATAsingle=true;
	case('64bit')
		DATAsingle=false;
otherwise
	DATAsingle=false;
end
if DATAsingle;StorageMode='32bit';else;StorageMode='64bit';end
if verbose==1
	fprintf ...
		('\n*******************************\nFST data storage mode is %s\n*******************************\n',...
		StorageMode)
end
%
   if ( verbose == 1 ) 
      disp(['Trouve ' num2str(nrec) ' record(s)'])
   end

   for k = 1:nrec

      if ( verbose == 1 ) 
         disp(['On traite le record ' num2str(k)])
      end

      % Lecture du nom de la variable
      [dummy,count]=fread(fid,1,'integer*4');
      [nomvar,count]=fread(fid,4,'char');
      [dummy,count]=fread(fid,1,'integer*4');

      % Lecture du niveau eta
      [dummy,count]=fread(fid,1,'integer*4');
      [eta,count]=fread(fid,1,'real*4');
      [dummy,count]=fread(fid,1,'integer*4');

      % Lecture des informations sur le record
      [dummy,count]=fread(fid,1,'integer*4');
      [itable,count]=fread(fid,18,'integer*4');
      [dummy,count]=fread(fid,1,'integer*4');

      % Lecture des informations geographiques sur le record
      [dummy,count]=fread(fid,1,'integer*4');
      [grtyp,count]=fread(fid,1,'char');
      [ig14,count]=fread(fid,4,'integer*4');
      [xg14,count]=fread(fid,4,'real*4');
      [dummy,count]=fread(fid,1,'integer*4');

      % Lecture du champ
      ni=itable(7);
      nj=itable(8);
      [dummy,count]=fread(fid,1,'integer*4');
		%       [fst_data(:,:,k),count]=fread(fid,[ni,nj],'real*4');
		% pour accomoder dimensions variables
		%{
		datyp:
		data type of the elements
		0: binary, transparent
		1: floating point
		2: unsigned integer
		3: character (R4A in an integer)
		4: signed integer
		5: IEEE floating point 
		6: floating point (special format, 16 bit, reserved for use with the compressor)
		7: character string   (ni,nj,nk must be: ni = number of characters in the string, nj=1, nk=1)  valid only with fstecr_s
		8: complex IEEE
		130: compressed integer
		134: floating point
		%}
		z=sprintf('%s',char(nomvar));
		GIGJ={'GI  ','GJ  '};
		if ismember(z,GIGJ)
			datatype='int32';  %GI GJ are datyp=4!!
			fst_data(k).data=fread(fid,[ni,nj],datatype);
		elseif ismember(z,{'>>  ','^^  '})
			fst_data(k).data=single(fread(fid,[ni,nj],'float32'));
		else
			datatype='real*4';
			if DATAsingle
				[zz,count]=fread(fid,[ni,nj],datatype);
				%fst_data(k).data=single(fread(fid,[ni,nj],datatype)); %'real*4'  %NB: count est inutile=> enlevé
				fst_data(k).data=single(zz);
			else
				[fst_data(k).data,count]=fread(fid,[ni,nj],datatype); % 'real*4'
			end
		end
% 		if ~ismember(z,GIGJ)
% 		
% 		else
% 			datatype='int32';  %GI GJ are datyp=4!!
% 			fst_data(k).data=fread(fid,[ni,nj],datatype);
% 		end
% 		end !!!!semble mal placé il faut faire le fread avant le end RB 29
% 		sept 2015
      [dummy,count]=fread(fid,1,'integer*4');
% 	end
      fst_info(k).nrec       =nrec;
      fst_info(k).nomvar     =char(nomvar);
      fst_info(k).eta        =eta;
      fst_info(k).aaaammjj_o =itable(1);
      fst_info(k).hhmmssss_o =itable(2);
      fst_info(k).deet       =itable(3);
      fst_info(k).npas       =itable(4);
      fst_info(k).aaaammjj_v =itable(5);
      fst_info(k).hhmmssss_v =itable(6);
      fst_info(k).ni         =itable(7);
      fst_info(k).nj         =itable(8);
      fst_info(k).nk         =itable(9);
      fst_info(k).niveau     =itable(10);
      fst_info(k).nio        =itable(13);
      fst_info(k).njo        =itable(14);
      fst_info(k).i1         =itable(15);
      fst_info(k).i2         =itable(16);
      fst_info(k).j1         =itable(17);
      fst_info(k).j2         =itable(18);

      fst_info(k).grtyp      =grtyp;
		fst_info(k).ig1        =ig14(1);
		fst_info(k).ig2        =ig14(2);
		fst_info(k).ig3        =ig14(3);
		fst_info(k).ig4        =ig14(4);
		fst_info(k).xg1        =xg14(1);
		fst_info(k).xg2        =xg14(2);
		fst_info(k).xg3        =xg14(3);
		fst_info(k).xg4        =xg14(4);
	end

		
      if( verbose == 1 )

%          printf('Variable %s, eta=%f, niveau=%d\n',fst_info(k).nomvar,eta,fst_info(k).niveau)
%          printf('Date d origine   %d %d, dt=%d, npas=%d, prevision de %d heure(s)\n', ...
% 	     fst_info(k).aaaammjj_o,fst_info(k).hhmmssss_o,fst_info(k).deet,fst_info(k).npas,fst_info(k).deet*fst_info(k).npas/3600.)
%          printf('Date de validite %d %d\n',fst_info(k).aaaammjj_v,fst_info(k).hhmmssss_v)
%          printf('Taille de la grille ni=%d nj=%d nk=%d\n',fst_info(k).ni,fst_info(k).nj,fst_info(k).nk)
%          if ( fst_info(k).nio ~= fst_info(k).ni || fst_info(k).njo ~= fst_info(k).nj )
%             printf('Taille de la grille original nio=%d njo=%d ',fst_info(k).nio,fst_info(k).njo)
%             printf(', fenetre i1=%d, i2=%d, j1=%d, j2=%d\n',fst_info(k).i1,fst_info(k).i2,fst_info(k).j1,fst_info(k).j2)
%          end 

      end

   end
