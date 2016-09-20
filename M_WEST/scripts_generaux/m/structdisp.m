function structdisp( M )
%STRUCTDISP Summary of this function goes here
%   Detailed explanation goes here
namesM=fieldnames(M);
cM=struct2cell(M);
format compact
nameM=inputname(1);
disp(['Structure ',nameM,' content::'])
disp('- - - - - - - - - - - - - - -')
for i=1:numel(namesM)
	if isnumeric(cM{i})
		disp([namesM{i},': [',num2str(cM{i}),']'])
	else
		disp([namesM{i},': [',cM{i},']'])
	end
end
disp('- - - - - - - - - - - - - - -')
end
