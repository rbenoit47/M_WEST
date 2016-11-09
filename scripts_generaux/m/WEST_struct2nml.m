function [varargout] = WEST_struct2nml( M, Mynml, CleMprefix, debug, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
		vin=varargin;
		splitf=false;splitfields={};splitchar='';
		for i=1:length(vin)
			if isequal(vin{i},'splitfields')
				splitf=true;
				splitfields=vin(i+1);
				splitchar=vin{i+2};
			end
		end
		nsf=numel(splitfields);
		%
		ClesChar=char(fieldnames(M));
		Cles=cellstr(ClesChar);
		%
		NCles=numel(Cles);
		for ii=1:NCles
			ClesNumStr(ii)=isnumeric(M.(Cles{ii}));
		end
%
		Mcell=struct2cell(M);
		inum=0;ichar=0;
		Valeurs=[];
		ValeursC=cell(NCles,1);
		for ii=1:NCles
			if ClesNumStr(ii)
				inum=inum+1;
				Valeurs(inum)=M.(Cles{ii});
			else
				ichar=ichar+1;
				ValeursC(ichar)=Mcell(ii);
			end
		end
		if debug
            display(Valeurs)
            display(ValeursC)
        end
		%
		ic=0;inum=0;
		for Cle=1:numel(Cles)
			Cle;
			CleM=[CleMprefix char(Cles(Cle))];  %'M.'
			if ClesNumStr(Cle)
				inum=inum+1;
				Valeur=num2str(Valeurs(inum));  %Cle
			else
				ic=ic+1;
				Valeur=ValeursC{ic};
			end
			if ~splitf || ~ismember(Cles(Cle),splitfields{:})
				EDITnml(Mynml,CleM,Valeur,false);
			else
				tosplit=Valeur;
				valeurs=strsplit(Valeur,splitchar);
				EDITnml(Mynml,CleM,valeurs,false);
				varargout{1}=valeurs;
			end
		end
end

