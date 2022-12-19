function [Individual, Position, EAStruct] = EA_Roulette(EAStruct, Number_Of_Individuals, Method)
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


if (distinct_mode == 1 && Number_Of_Individuals > (length(EAStruct.Individuals)-length(EAStruct.selected_individuals)))
	error('Cant do distinct Roulette. Number of individuals to draw exceeds generation size.');			
end

max_fitness = -10000;
min_fitness = 10000;

for i=1:1:length(EAStruct.Individuals)
	
	if (max_fitness < EAStruct.Individuals(i).fitness+share_weight*EAStruct.Individuals(i).sharing)
		max_fitness = EAStruct.Individuals(i).fitness+share_weight*EAStruct.Individuals(i).sharing;
	end
	
	if (min_fitness > EAStruct.Individuals(i).fitness+share_weight*EAStruct.Individuals(i).sharing)
		min_fitness = EAStruct.Individuals(i).fitness+share_weight*EAStruct.Individuals(i).sharing;
	end	
end



Roulette = [];
% buildup roulette
for i=1:1:length(EAStruct.Individuals)
	Roulette = [Roulette, i*ones(1,round(scale_value(EAStruct.Individuals(i).fitness+share_weight*EAStruct.Individuals(i).sharing, min_fitness, max_fitness, 1, 100)))];
end

% reduce roulette when in distinct mode
if (distinct_mode == 1)
    for k=1:1:length(EAStruct.selected_individuals)
        Roulette = Roulette(find(Roulette ~= EAStruct.selected_individuals(k) ));
    end
end

Roulette_Size = length(Roulette);

Position = [];
Individual = [];

% draw individuals from roulette
for count=1:1:Number_Of_Individuals
	
	if (count == 1)
		Position = Roulette(1 + round(rand * (Roulette_Size-1) ));
		Individual = EAStruct.Individuals(Position(count));
	else
		Position(count) = Roulette(1 + round(rand * (Roulette_Size-1) ));
		Individual(count) = EAStruct.Individuals(Position(count));
	end
	
	if (distinct_mode == 1)
		
			affected = find(Roulette == Position(count));
			Roulette(affected) = [];
			Roulette_Size = Roulette_Size - length(affected);
			EAStruct.selected_individuals = [EAStruct.selected_individuals, Position(count)];
		
	end
	
end


