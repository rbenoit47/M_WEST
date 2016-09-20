function [fst_info,fst_data] = lire_bin(fid,verbose)

   %
   % Fonction  : lire_bin
   %
   % Auteur    : Andre Plante, CMC pour projet SPEO
   %
   % But       : Lire un record  

   % Lecture de la version
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

      % Lecture du champ
      ni=itable(7);
      nj=itable(8);
      [dummy,count]=fread(fid,1,'integer*4');
      [fst_data(:,:,k),count]=fread(fid,[ni,nj],'real*4');
      [dummy,count]=fread(fid,1,'integer*4');

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
