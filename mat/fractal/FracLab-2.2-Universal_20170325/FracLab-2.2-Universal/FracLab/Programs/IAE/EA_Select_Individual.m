function [Individual, Position, EAStruct] = EA_Select_Individual(EAStruct, Number_Of_Individuals, Method)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

selection = eval(['EAStruct.Config.evol_' lower(Method) '_selection_method']);


switch lower(selection)
	case 'fittest'
		
		[Individual, Position, EAStruct] = EA_Fittest(EAStruct, Number_Of_Individuals, Method);
		
	case 'roulette'
		
		[Individual, Position, EAStruct] = EA_Roulette(EAStruct, Number_Of_Individuals, Method);
		
		
	case 'cycle'
		
		[Individual, Position, EAStruct] = EA_Cycle(EAStruct, Number_Of_Individuals, Method);
		
		
	case 'rank'
		
		[Individual, Position, EAStruct] = EA_Rank(EAStruct, Number_Of_Individuals, Method);
        
	otherwise
		error('Unknown selection method.');
	
	
end


