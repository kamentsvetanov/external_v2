function [EAStruct,modified_individuals, modified_images] = EA_Evolution(EAStruct)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%%evaluate the population%%%%%%%%%%%%%%%%%%%%
EAStruct = EA_Fitness(EAStruct);
EAStruct = EA_Sharing(EAStruct);
%s_offset = calc_sharing_offset(EAStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ff = [];
bb = [];
for i=1:1:length(EAStruct.Individuals)
	ff = [ff, EAStruct.Individuals(i).fitness];
	bb = [bb, EAStruct.Individuals(i).bound_image_number];
end

%disp(['Eingabefitness :' mat2str(ff)]);
%disp(['Bild                :' mat2str(bb)]);
	
%%sort the population%%%%%%%%%%%%%%%%%%%%
EAStruct = EA_Sort(EAStruct);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%convert relative generation gap to absolute value
if (EAStruct.Config.evol_generation_gap ~= round(EAStruct.Config.evol_generation_gap))
	EAStruct.Config.evol_generation_gap = round(EAStruct.Config.evol_generation_gap*EAStruct.Config.evol_population_size);
end


EAStruct.Offspring_Size = 0;
EAStruct.OffspringStruct = [];
EAStruct.selected_individuals = [];

while (EAStruct.Offspring_Size < EAStruct.Config.evol_generation_gap)
	
	%%take one individual%%%%%%%%%%%%%%%%%%%%%%%
	[IndividualStruct,Positions,EAStruct] = EA_Select_Individual(EAStruct,1,'Parent');
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	%disp(['selected parent: ' mat2str(Positions)]);
	
	%%crossover%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if (rand <= EAStruct.Config.evol_do_crossover)
		
		% take a second individual
		[Individual,Pos,EAStruct] = EA_Select_Individual(EAStruct,1,'Parent');
		%disp(['selected parent: ' mat2str(Pos)]);
		
        
		IndividualStruct(2) = Individual;
		Positions(2) 				= Pos;
		
		
		%do crossover on IndividualStruct
		IndividualStruct = EA_Crossover(EAStruct, IndividualStruct);
		
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	%%mutation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if (rand <= EAStruct.Config.evol_do_mutation)
		
		%do mutation on IndividualStruct
		IndividualStruct = EA_Mutation(EAStruct, IndividualStruct);
		
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	%%add children to offspring%%%%%%%%%%%%%%%%%
	%disp(['Add ' num2str(length(IndividualStruct)) ' Individuals to Offspring']);
	
	for i=1:1:length(IndividualStruct)
	
		
		EAStruct.Offspring_Size = EAStruct.Offspring_Size + 1;
		if (EAStruct.Offspring_Size == 1)
			EAStruct.OffspringStruct = IndividualStruct(i);
		else
			EAStruct.OffspringStruct(EAStruct.Offspring_Size) = IndividualStruct(i);
		end
		
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end % of while	
	


%%do selection of individuals for the next generation
EAStruct.selected_individuals = [];
[EAStruct, modified_individuals] = EA_Offspring_Selection(EAStruct);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%do image selection%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EAStruct.selected_individuals = [];
EAStruct = EA_Sort(EAStruct);
EAStruct = EA_Sharing(EAStruct);
[EAStruct,modified_images] = EA_Image_Selection(EAStruct);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%disp(['Modified images: ' mat2str(modified_images)]);