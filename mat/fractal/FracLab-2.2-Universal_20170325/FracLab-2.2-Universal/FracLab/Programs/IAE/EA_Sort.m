function EAStruct = EA_Sort(EAStruct)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

for i=1:1:length(EAStruct.Individuals)-1
	for j=i+1:1:length(EAStruct.Individuals)
		if (EAStruct.Individuals(i).fitness < EAStruct.Individuals(j).fitness)
            
			help = EAStruct.Individuals(i);
			EAStruct.Individuals(i) = EAStruct.Individuals(j);
			EAStruct.Individuals(j) = help;
           
		end
	end
end

