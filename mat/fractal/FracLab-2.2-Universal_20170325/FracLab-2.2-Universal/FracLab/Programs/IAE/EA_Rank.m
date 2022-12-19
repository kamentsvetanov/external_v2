function [Individual, Position, EAStruct] = EA_Rank(EAStruct, Number_Of_Individuals, Method)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

distinct_mode = eval(['EAStruct.Config.evol_' lower(Method) '_distinct_individuals']);
sharing = eval(['EAStruct.Config.evol_' lower(Method) '_selection_sharing']);


if (distinct_mode == 1 && Number_Of_Individuals > (length(EAStruct.Individuals)-length(EAStruct.selected_individuals)))
    error('Cant do distinct Rank. Number of individuals to draw exceeds generation size.');
end


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



rank = [];
% buildup rank
for i=1:1:length(EAStruct.Individuals)
    r = (EAStruct.Config.evol_rank_selection_pressure^-i);
       
    rank = [rank, fittest_index(i) * ones(1, round( scale_value( r, 0, 1, 1, 500) ))];
end

% reduce rank when in distinct mode
if (distinct_mode == 1)
    for k=1:1:length(EAStruct.selected_individuals)
        rank = rank(find(rank ~= EAStruct.selected_individuals(k) ));
    end
end

rank_Size = length(rank);

Position = [];
Individual = [];

% draw individuals from rank
for count=1:1:Number_Of_Individuals

    if (count == 1)
        Position = rank(1 + round(rand * (rank_Size-1) ));
        Individual = EAStruct.Individuals(Position(count));
    else
        Position(count) = rank(1 + round(rand * (rank_Size-1) ));
        Individual(count) = EAStruct.Individuals(Position(count));
    end

    if (distinct_mode == 1)

        affected = find(rank == Position(count));
        rank(affected) = [];
        rank_Size = rank_Size - length(affected);
        EAStruct.selected_individuals = [EAStruct.selected_individuals, Position(count)];

    end

end

