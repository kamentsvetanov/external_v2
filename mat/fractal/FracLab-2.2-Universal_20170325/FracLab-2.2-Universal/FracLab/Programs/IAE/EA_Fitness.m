function EAStruct = EA_Fitness(EAStruct)
% calculate EAStruct.Individuals.Fitness from EAStruct.Fitness
% variants for EAStruct.Config.evol_fitness_method: 'interpolation', 'nearest'

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if (isempty(EAStruct.Fitness.map) == 1)
	%disp('Query to empty Fitnessmap.');
	for i=1:1:length(EAStruct.Individuals)
		EAStruct.Individuals(i).fitness = 0;
		EAStruct.Individuals(i).genes_fitness = zeros(1,7);
	end
	
	return;
end

done_exact_measure = cell(1,7);
polynoms = cell(1,7);

% iterate through all individuals
for i=1:1:length(EAStruct.Individuals)
	
	if (strcmp(EAStruct.Config.evol_fitness_method,'interpolation') == 1)
		
				if (EAStruct.Individuals(i).genotype.amin <= max(EAStruct.Fitness.map(1,:)) && EAStruct.Individuals(i).genotype.amin >= min(EAStruct.Fitness.map(1,:)))
					if (done_exact_measure{1} == 1)
						[points_amin, 	curve_amin, 	polynom_amin] 	= calc_fitness(EAStruct.Individuals(i).genotype.amin		, EAStruct.Fitness.map(1,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_amin_min,EAStruct.Config.evol_amin_max]			, [0,1], 10, polynoms{1});
					else
						[points_amin, 	curve_amin, 	polynom_amin] 	= calc_fitness(EAStruct.Individuals(i).genotype.amin		, EAStruct.Fitness.map(1,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_amin_min,EAStruct.Config.evol_amin_max]			, [0,1], 10, []);			
						polynoms{1} = polynom_amin;
						done_exact_measure{1} = 1;
					end
				else
					[points_amin, 	curve_amin, 	polynom_amin] 	= calc_fitness(EAStruct.Individuals(i).genotype.amin		, EAStruct.Fitness.map(1,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_amin_min,EAStruct.Config.evol_amin_max]			, [0,1], 10, []);			
				end
					
		
				if (EAStruct.Individuals(i).genotype.gmin <= max(EAStruct.Fitness.map(2,:)) && EAStruct.Individuals(i).genotype.gmin >= min(EAStruct.Fitness.map(2,:)))
					if (done_exact_measure{2} == 1)
						[points_gmin, 	curve_gmin, 	polynom_gmin] 	= calc_fitness(EAStruct.Individuals(i).genotype.gmin		, EAStruct.Fitness.map(2,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_gmin_min,EAStruct.Config.evol_gmin_max]			, [0,1], 10, polynoms{2});
					else
						[points_gmin, 	curve_gmin, 	polynom_gmin] 	= calc_fitness(EAStruct.Individuals(i).genotype.gmin		, EAStruct.Fitness.map(2,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_gmin_min,EAStruct.Config.evol_gmin_max]			, [0,1], 10, []);			
						polynoms{2} = polynom_gmin;
						done_exact_measure{2} = 1;
					end
				else
					[points_gmin, 	curve_gmin, 	polynom_gmin] 	= calc_fitness(EAStruct.Individuals(i).genotype.gmin		, EAStruct.Fitness.map(2,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_gmin_min,EAStruct.Config.evol_gmin_max]			, [0,1], 10, []);			
				end
				
			
				if (EAStruct.Individuals(i).genotype.amax <= max(EAStruct.Fitness.map(3,:)) && EAStruct.Individuals(i).genotype.amax >= min(EAStruct.Fitness.map(3,:)))
					if (done_exact_measure{3} == 1)
						[points_amax, 	curve_amax, 	polynom_amax] 	= calc_fitness(EAStruct.Individuals(i).genotype.amax		, EAStruct.Fitness.map(3,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_amax_min,EAStruct.Config.evol_amax_max]			, [0,1], 10, polynoms{3});
					else
						[points_amax, 	curve_amax, 	polynom_amax] 	= calc_fitness(EAStruct.Individuals(i).genotype.amax		, EAStruct.Fitness.map(3,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_amax_min,EAStruct.Config.evol_amax_max]			, [0,1], 10, []);			
						polynoms{3} = polynom_amax;
						done_exact_measure{3} = 1;
					end
				else
					[points_amax, 	curve_amax, 	polynom_amax] 	= calc_fitness(EAStruct.Individuals(i).genotype.amax		, EAStruct.Fitness.map(3,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_amax_min,EAStruct.Config.evol_amax_max]			, [0,1], 10, []);			
				end	
				
			
				if (EAStruct.Individuals(i).genotype.gmax <= max(EAStruct.Fitness.map(4,:)) && EAStruct.Individuals(i).genotype.gmax >= min(EAStruct.Fitness.map(4,:)))
					if (done_exact_measure{4} == 1)
						[points_gmax, 	curve_gmax, 	polynom_gmax] 	= calc_fitness(EAStruct.Individuals(i).genotype.gmax		, EAStruct.Fitness.map(4,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_gmax_min,EAStruct.Config.evol_gmax_max]			, [0,1], 10, polynoms{4});
					else
						[points_gmax, 	curve_gmax, 	polynom_gmax] 	= calc_fitness(EAStruct.Individuals(i).genotype.gmax		, EAStruct.Fitness.map(4,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_gmax_min,EAStruct.Config.evol_gmax_max]			, [0,1], 10, []);			
						polynoms{4} = polynom_gmax;
						done_exact_measure{4} = 1;
					end
				else
					[points_gmax, 	curve_gmax, 	polynom_gmax] 	= calc_fitness(EAStruct.Individuals(i).genotype.gmax		, EAStruct.Fitness.map(4,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_gmax_min,EAStruct.Config.evol_gmax_max]			, [0,1], 10, []);			
				end
				
				
				if (EAStruct.Individuals(i).genotype.anod <= max(EAStruct.Fitness.map(5,:)) && EAStruct.Individuals(i).genotype.anod >= min(EAStruct.Fitness.map(5,:)))
					if (done_exact_measure{5} == 1)
						[points_anod, 	curve_anod, 	polynom_anod] 	= calc_fitness(EAStruct.Individuals(i).genotype.anod		, EAStruct.Fitness.map(5,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_anod_min,EAStruct.Config.evol_anod_max]			, [0,1], 10, polynoms{5});
					else
						[points_anod, 	curve_anod, 	polynom_anod] 	= calc_fitness(EAStruct.Individuals(i).genotype.anod		, EAStruct.Fitness.map(5,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_anod_min,EAStruct.Config.evol_anod_max]			, [0,1], 10, []);			
						polynoms{5} = polynom_anod;
						done_exact_measure{5} = 1;
					end
				else
					[points_anod, 	curve_anod, 	polynom_anod] 	= calc_fitness(EAStruct.Individuals(i).genotype.anod		, EAStruct.Fitness.map(5,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_anod_min,EAStruct.Config.evol_anod_max]			, [0,1], 10, []);			
				end
				
				
				if (EAStruct.Individuals(i).genotype.sigma <= max(EAStruct.Fitness.map(6,:)) && EAStruct.Individuals(i).genotype.sigma >= min(EAStruct.Fitness.map(6,:)))
					if (done_exact_measure{6} == 1)
						[points_sigma, 	curve_sigma, 	polynom_sigma] 	= calc_fitness(EAStruct.Individuals(i).genotype.sigma		, EAStruct.Fitness.map(6,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_sigma_min,EAStruct.Config.evol_sigma_max]			, [0,1], 10, polynoms{6});
					else
						[points_sigma, 	curve_sigma, 	polynom_sigma] 	= calc_fitness(EAStruct.Individuals(i).genotype.sigma		, EAStruct.Fitness.map(6,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_sigma_min,EAStruct.Config.evol_sigma_max]			, [0,1], 10, []);			
						polynoms{6} = polynom_sigma;
						done_exact_measure{6} = 1;
					end
				else
					[points_sigma, 	curve_sigma, 	polynom_sigma] 	= calc_fitness(EAStruct.Individuals(i).genotype.sigma		, EAStruct.Fitness.map(6,:), EAStruct.Fitness.map(8,:), [EAStruct.Config.evol_sigma_min,EAStruct.Config.evol_sigma_max]			, [0,1], 10, []);			
				end
				
			
				if (EAStruct.Individuals(i).genotype.filter <= max(EAStruct.Fitness.map(7,:)) && EAStruct.Individuals(i).genotype.filter >= min(EAStruct.Fitness.map(7,:)))
					if (done_exact_measure{7} == 1)
						[points_filter, 	curve_filter, 	polynom_filter] 	= calc_fitness(EAStruct.Individuals(i).genotype.filter		, EAStruct.Fitness.map(7,:), EAStruct.Fitness.map(8,:), [min(EAStruct.Config.evol_filters),max(EAStruct.Config.evol_filters)]			, [0,1], 10, polynoms{7});
					else
						[points_filter, 	curve_filter, 	polynom_filter] 	= calc_fitness(EAStruct.Individuals(i).genotype.filter		, EAStruct.Fitness.map(7,:), EAStruct.Fitness.map(8,:), [min(EAStruct.Config.evol_filters),max(EAStruct.Config.evol_filters)]			, [0,1], 10, []);			
						polynoms{7} = polynom_filter;
						done_exact_measure{7} = 1;
					end
				else
					[points_filter, 	curve_filter, 	polynom_filter] 	= calc_fitness(EAStruct.Individuals(i).genotype.filter		, EAStruct.Fitness.map(7,:), EAStruct.Fitness.map(8,:), [min(EAStruct.Config.evol_filters),max(EAStruct.Config.evol_filters)]			, [0,1], 10, []);			
				end
				
				
				% Calculate overall fitness
				EAStruct.Individuals(i).fitness = mean([curve_amin,curve_gmin,curve_amax,curve_gmax,curve_anod,curve_sigma,curve_filter]);
				EAStruct.Individuals(i).genes_fitness = [curve_amin,curve_gmin,curve_amax,curve_gmax,curve_anod,curve_sigma,curve_filter];
				
	elseif (strcmp(EAStruct.Config.evol_fitness_method,'nearest') == 1)
		
		distances = [];
		genes_distance = [];
		for j=1:1:size(EAStruct.Fitness.map,2)
			individual_genotype = [EAStruct.Individuals(i).genotype.amin, EAStruct.Individuals(i).genotype.gmin, EAStruct.Individuals(i).genotype.amax, EAStruct.Individuals(i).genotype.gmax, EAStruct.Individuals(i).genotype.anod, EAStruct.Individuals(i).genotype.sigma, EAStruct.Individuals(i).genotype.filter];
			distances = [distances, calc_genom_distance(individual_genotype', EAStruct.Fitness.map(:,j))	];
			genes_distance = [genes_distance ,abs(individual_genotype'-EAStruct.Fitness.map(1:7,j))];
		end
			
		[vals,idx] = sort(distances);
		[gene_vals, gene_idx] = sort(genes_distance,2);
				
		% get the fitness value of the nearest genom saved in the fitness map	
		EAStruct.Individuals(i).fitness = EAStruct.Fitness.map(8,idx(1));
		EAStruct.Individuals(i).genes_fitness = EAStruct.Fitness.map(8,gene_idx(:,1)');
		
		%EAStruct.Individuals(i).genes_fitness = [curve_amin,curve_gmin,curve_amax,curve_gmax,curve_anod,curve_sigma,curve_filter];
		
	else
		error('Wrong method in function call to fitness measurement');	
	end
		
end


