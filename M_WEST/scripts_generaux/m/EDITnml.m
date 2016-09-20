function [ OK ] = EDITnml( filein, cle,valeurs,verbose )
%EDITNML Summary of this function goes here
%   Detailed explanation goes here
OK=false;
%
multi=false;
if iscell(valeurs)
	valeur=valeurs{1};
	multi=true;
else
	valeur=valeurs;
end
%
if verbose; fprintf( ...
        'filein[%s]\ncle[%s]\nvaleur[%s]\n',...
         filein, cle,valeur);end
try
    fin = fopen(filein,'r');
catch
    disp('EDITnml. Erreur avec fichier a traiter')
    return
end
%
k=0;i=0;
All='';Allout=All;  % all the edited file
while ~feof(fin)
   sin = fgetl(fin); i=i+1; 
   sout = strrep (sin, cle, valeur);  %regexprep
   if i==1
       Allout=sprintf('%s\n',sout);   % \r ou \n
   else
       Allout=sprintf('%s%s\n',All,sout);   % \r ou \n
	end
	if ~strcmp(sin,sout)
       k=k+1;
       if verbose; fprintf('%s\n',sout);end
   end
   All=Allout;
	%
	if multi && ~strcmp(sin,sout)
		AllMulti=All;
		for j=2:numel(valeurs)
			sout = strrep (sin, cle, valeurs{j});
			AllMultiout=sprintf('%s%s\n',AllMulti,sout);
			AllMulti=AllMultiout;
		end
		All=AllMulti;
	end
end
if verbose;fprintf('# hits=%i\n',k);end
fclose(fin);
fin = fopen(filein,'w');
fprintf(fin,'%s',All);
fclose(fin);
%
OK=true;

end

