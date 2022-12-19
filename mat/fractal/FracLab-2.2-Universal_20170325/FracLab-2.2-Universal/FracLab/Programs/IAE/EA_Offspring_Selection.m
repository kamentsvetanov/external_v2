function [EASelect, modified_individuals] = EA_Offspring_Selection(EAStruct)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

OffspringStruct = EAStruct.OffspringStruct;

EASelect = EAStruct;

%EASelect.Individuals = OffspringStruct; return;

EASelect.Individuals = [];

EAOffspring = EAStruct;
EAOffspring.Individuals = OffspringStruct;

%calculate fitness of offspring
EAOffspring = EA_Fitness(EAOffspring);
EAOffspring = EA_Sort(EAOffspring);
EAOffspring = EA_Sharing(EAOffspring);

Limits = {[EAStruct.Config.evol_amin_min,EAStruct.Config.evol_amin_max], [EAStruct.Config.evol_gmin_min,EAStruct.Config.evol_gmin_max], [EAStruct.Config.evol_amax_min,EAStruct.Config.evol_amax_max], [EAStruct.Config.evol_gmax_min,EAStruct.Config.evol_gmax_max], [EAStruct.Config.evol_anod_min,EAStruct.Config.evol_anod_max], [EAStruct.Config.evol_sigma_min,EAStruct.Config.evol_sigma_max], [1,9]};

modified_individuals = [];

locked_individuals = [];

% carry all locked individuals to the next generation
for i=1:1:length(EAStruct.Individuals)
	if (EAStruct.Individuals(i).is_locked == 1)
		
		locked_individuals = [locked_individuals,i];
		if (length(EASelect.Individuals)+1 == 1)
			EASelect.Individuals = EAStruct.Individuals(i);
		else
			EASelect.Individuals(length(EASelect.Individuals)+1) = EAStruct.Individuals(i);
		end
		
	end
end


if (EAStruct.Config.evol_offspring_selection_weighted_fitness == 1)
	% create new sharing polynoms
	if (length(EASelect.Individuals) >= 2 && length(EAOffspring.Individuals)>0)

		map_select = [];
		for n=1:1:length(EASelect.Individuals)
			map_select(1,n) = 	EASelect.Individuals(n).genotype.amin;
			map_select(2,n) = 	EASelect.Individuals(n).genotype.gmin;
			map_select(3,n) = 	EASelect.Individuals(n).genotype.amax;
			map_select(4,n) = 	EASelect.Individuals(n).genotype.gmax;
			map_select(5,n) = 	EASelect.Individuals(n).genotype.anod;
			map_select(6,n) = 	EASelect.Individuals(n).genotype.sigma;
			map_select(7,n) = 	EASelect.Individuals(n).genotype.filter;
		end

		map_offspring = [];
		for n=1:1:length(EAOffspring.Individuals)
			map_offspring(1,n) = 	EAOffspring.Individuals(n).genotype.amin;
			map_offspring(2,n) = 	EAOffspring.Individuals(n).genotype.gmin;
			map_offspring(3,n) = 	EAOffspring.Individuals(n).genotype.amax;
			map_offspring(4,n) = 	EAOffspring.Individuals(n).genotype.gmax;
			map_offspring(5,n) = 	EAOffspring.Individuals(n).genotype.anod;
			map_offspring(6,n) = 	EAOffspring.Individuals(n).genotype.sigma;
			map_offspring(7,n) = 	EAOffspring.Individuals(n).genotype.filter;
		end

		EASelect_sharing_points = [];
		EASelect_sharing_curve = [];

		for gene=1:1:7
			[points_sharing, curve_sharing, polynom_sharing] = calc_sharing(map_offspring(gene,:), map_select(gene,:), Limits{gene}, [0,1], 15, 100, []);
			EASelect_sharing_points{gene} = points_sharing;
			EASelect_sharing_curve{gene} = curve_sharing;
		end

	end
end



% fill the rest of the population with individuals from EAOffspring
while (length(EASelect.Individuals) < EAStruct.Config.evol_population_size && length(EAOffspring.Individuals)>0)
	
	best_individuals_pos = 1;
	best_individuals_fitness = -1000;
	
	EAOffspring.selected_individuals = [];
	
	% evaluate all the individuals that are left in the offspring struct
	for i=1:1:length(EAOffspring.Individuals)
        
        if (EAStruct.Config.evol_offspring_selection_weighted_fitness == 0)
            
            [Individual,Position,EAOffspring] = EA_Select_Individual(EAOffspring,1,'offspring');
            best_individuals_fitness = EAOffspring.Individuals(Position).fitness;
						best_individuals_pos = Position;
                     
            break;
            
        elseif (length(EASelect.Individuals) < 2 && EAStruct.Config.evol_offspring_selection_weighted_fitness == 1)
			% still not enough individuals in EASelect to do sharing measurement

			if (EAOffspring.Individuals(i).fitness > best_individuals_fitness)
				best_individuals_fitness = EAOffspring.Individuals(i).fitness;
				best_individuals_pos = i;
			end

		elseif (EAStruct.Config.evol_offspring_selection_weighted_fitness == 1)
			% include sharing measurement into weighted fitness measurement

			share = 0;

			sharing_curve = EASelect_sharing_curve{1};
			position 			= find(EASelect_sharing_points{1} == EAOffspring.Individuals(i).genotype.amin);
			position 			= position(1);
			share 				= [share, sharing_curve(position)];

			sharing_curve = EASelect_sharing_curve{2};
			position 			= find(EASelect_sharing_points{2} == EAOffspring.Individuals(i).genotype.gmin);
			position 			= position(1);
			share 				= [share, sharing_curve(position)];

			sharing_curve = EASelect_sharing_curve{3};
			position 			= find(EASelect_sharing_points{3} == EAOffspring.Individuals(i).genotype.amax);
			position 			= position(1);
			share 				= [share, sharing_curve(position)];

			sharing_curve = EASelect_sharing_curve{4};
			position 			= find(EASelect_sharing_points{4} == EAOffspring.Individuals(i).genotype.gmax);
			position 			= position(1);
			share 				= [share, sharing_curve(position)];

			sharing_curve = EASelect_sharing_curve{5};
			position 			= find(EASelect_sharing_points{5} == EAOffspring.Individuals(i).genotype.anod);
			position 			= position(1);
			share 				= [share, sharing_curve(position)];

			sharing_curve = EASelect_sharing_curve{6};
			position 			= find(EASelect_sharing_points{6} == EAOffspring.Individuals(i).genotype.sigma);
			position 			= position(1);
			share 				= [share, sharing_curve(position)];

			sharing_curve = EASelect_sharing_curve{7};
			position 			= find(EASelect_sharing_points{7} == EAOffspring.Individuals(i).genotype.filter);
			position 			= position(1);
			share 				= [share, sharing_curve(position)];

			share = (max(share)-mean(share))/2;
			share = 1 - share;

			%share =0;

			individual_fitness_weighted = scale_value(share * scale_value(EAOffspring.Individuals(i).fitness, -6, 6, 0, 1),  0, 1, -6,6);

			if (individual_fitness_weighted > best_individuals_fitness)
				best_individuals_fitness = individual_fitness_weighted;
				best_individuals_pos = i;
			end

		end


	end % of for

	% add individual to new generation
	if (length(EASelect.Individuals)+1 == 1)
		EASelect.Individuals = EAOffspring.Individuals(best_individuals_pos);
	else
		EASelect.Individuals(length(EASelect.Individuals)+1) = EAOffspring.Individuals(best_individuals_pos);
	end

	modified_individuals = [modified_individuals, length(EASelect.Individuals)];

	% delete from offspring
	EAOffspring.Individuals(best_individuals_pos) = [];

	if (EAStruct.Config.evol_offspring_selection_weighted_fitness == 1)
		% create new sharing polynoms
		if (length(EASelect.Individuals) >= 2 && length(EAOffspring.Individuals)>0)

			map_select = [];
			for n=1:1:length(EASelect.Individuals)
				map_select(1,n) = 	EASelect.Individuals(n).genotype.amin;
				map_select(2,n) = 	EASelect.Individuals(n).genotype.gmin;
				map_select(3,n) = 	EASelect.Individuals(n).genotype.amax;
				map_select(4,n) = 	EASelect.Individuals(n).genotype.gmax;
				map_select(5,n) = 	EASelect.Individuals(n).genotype.anod;
				map_select(6,n) = 	EASelect.Individuals(n).genotype.sigma;
				map_select(7,n) = 	EASelect.Individuals(n).genotype.filter;
			end

			map_offspring = [];
			for n=1:1:length(EAOffspring.Individuals)
				map_offspring(1,n) = 	EAOffspring.Individuals(n).genotype.amin;
				map_offspring(2,n) = 	EAOffspring.Individuals(n).genotype.gmin;
				map_offspring(3,n) = 	EAOffspring.Individuals(n).genotype.amax;
				map_offspring(4,n) = 	EAOffspring.Individuals(n).genotype.gmax;
				map_offspring(5,n) = 	EAOffspring.Individuals(n).genotype.anod;
				map_offspring(6,n) = 	EAOffspring.Individuals(n).genotype.sigma;
				map_offspring(7,n) = 	EAOffspring.Individuals(n).genotype.filter;
			end

			EASelect_sharing_points = [];
			EASelect_sharing_curve = [];

			for gene=1:1:7
				[points_sharing, curve_sharing, polynom_sharing] = calc_sharing(map_offspring(gene,:), map_select(gene,:), Limits{gene}, [0,1], 15, 100, []);
				EASelect_sharing_points{gene} = points_sharing;
				EASelect_sharing_curve{gene} = curve_sharing;
			end

		end
	end


end % of while

%disp('---------');
%selected_so_far = length(EASelect.Individuals)

ff = [];
for f =1:length(EASelect.Individuals)
	ff = [ff,EASelect.Individuals(f).bound_image_number];
end

%disp(['Images from Offspring (should not be bound, except superindividual):' mat2str(ff)]);


% fill remaining free places in the new population EASelect.Individuals with individuals from the parent generation EAStruct.Individuals
EAStruct.selected_individuals = locked_individuals;
while (length(EASelect.Individuals) < EAStruct.Config.evol_population_size)
    
    
	[Individual,Position,EAStruct] = EA_Select_Individual(EAStruct,1,'offspring_fill');
    
    if (EAStruct.Config.allow_superindividuals == 1)
        Individual.bound_image_number=0;
        Individual.is_locked=0;
    end
    
    if (EAStruct.Config.evol_mutate_offspring_fill == 1)
        Individual = EA_Mutation(EAStruct, Individual);
    end
    
	EASelect.Individuals(length(EASelect.Individuals)+1) = Individual;
    
    if (EAStruct.Config.allow_superindividuals == 1)
        modified_individuals = [modified_individuals, length(EASelect.Individuals)];
    end
	
end


ff = [];
for f =1:length(EASelect.Individuals)
	ff = [ff,EASelect.Individuals(f).bound_image_number];
end

%disp(['Images from Offspring :' mat2str(ff)]);
