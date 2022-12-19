function [Individual, Position, EAStruct] = EA_Fittest(EAStruct, Number_Of_Individuals, Method)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

distinct_mode = eval(['EAStruct.Config.evol_' lower(Method) '_distinct_individuals']);

sharing = eval(['EAStruct.Config.evol_' lower(Method) '_selection_sharing']);

if (sharing == 1)
    share_weight = eval(['EAStruct.Config.evol_' lower(Method) '_selection_sharing_weight']);
else
    share_weight = 0;
end


% remove allready drawn individuals in distinct mode
fittest_index = [1:1:length(EAStruct.Individuals)];
if (distinct_mode == 1 && length(EAStruct.selected_individuals)>0)
	%selected = EAStruct.selected_individuals
	fittest_index(EAStruct.selected_individuals) = [];
end

% sort population

if (sharing == 1)
    for i=1:1:length(fittest_index)-1
        for j=i+1:1:length(fittest_index)

            if (EAStruct.Individuals(fittest_index(i)).fitness + share_weight * EAStruct.Individuals(fittest_index(i)).sharing < EAStruct.Individuals(fittest_index(j)).fitness + share_weight * EAStruct.Individuals(fittest_index(j)).sharing)
               
                help = fittest_index(i);
                fittest_index(i) = fittest_index(j);
                fittest_index(j) = help;
            end

        end
    end
end

if (Number_Of_Individuals > length(fittest_index))
	disp('Number of drawn individuals exceeds population size. Using mod operation on individual index.');
	
	if (isempty(fittest_index))
		error('No individuals left to draw. Change distinct mode, selection method, generation gap or population size.');	
	end
	
end

% draw the individuals
for count=1:1:Number_Of_Individuals
	
	idx = mod(count-1,length(fittest_index))+1;
	
	Position(count) = fittest_index(idx);
	Individual(count) = EAStruct.Individuals(fittest_index(idx));	
	
end
	
EAStruct.selected_individuals = [EAStruct.selected_individuals, Position];