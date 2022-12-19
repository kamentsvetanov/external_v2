function [Individual, Position, EAStruct] = EA_Cycle(EAStruct, Number_Of_Individuals, Method)
% This method selects a number of individuals by cycling through the best
% 'evol_cycle_best_individuals'

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

sharing = eval(['EAStruct.Config.evol_' lower(Method) '_selection_sharing']);

if (sharing == 1)
    share_weight = eval(['EAStruct.Config.evol_' lower(Method) '_selection_sharing_weight']);
else
    share_weight = 0;
end

fittest_index = [1:1:length(EAStruct.Individuals)];


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

Position = [];
Individual = [];

%fittest_index

% draw the individuals
for count=1:1:Number_Of_Individuals
	
	idx = mod(length(EAStruct.selected_individuals),EAStruct.Config.evol_cycle_best_individuals)+1;
	
	if (count == 1)
		Position = fittest_index(idx);
		Individual = EAStruct.Individuals(fittest_index(idx));	
	else
		Position(count) = fittest_index(idx);
		Individual(count) = EAStruct.Individuals(fittest_index(idx));	
	end
	EAStruct.selected_individuals = [EAStruct.selected_individuals, Position(count)];
	
end
	
