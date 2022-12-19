function ResultStruct = EA_Crossover(EAStruct, IndividualStruct)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if (length(IndividualStruct) ~= 2)
	error('Can only mate 2 individuals at a time.');	
end

probability_sum = EAStruct.Config.evol_do_random_crossover + EAStruct.Config.evol_do_swapping_crossover + EAStruct.Config.evol_do_factory_crossover;
EAStruct.Config.evol_do_random_crossover 		= round(100 * EAStruct.Config.evol_do_random_crossover / probability_sum);
EAStruct.Config.evol_do_swapping_crossover 	= round(100 * EAStruct.Config.evol_do_swapping_crossover / probability_sum);
EAStruct.Config.evol_do_factory_crossover 	= round(100 * EAStruct.Config.evol_do_factory_crossover / probability_sum);


Roulette = [1*ones(1,EAStruct.Config.evol_do_random_crossover), 2*ones(1,EAStruct.Config.evol_do_swapping_crossover), 3*ones(1,EAStruct.Config.evol_do_factory_crossover)];

method = Roulette(round(rand*(length(Roulette)-1)) +1);

% initialize the ResultStruct
ResultStruct = IndividualStruct(1);
ResultStruct.is_locked=0;
ResultStruct.bound_image_number=0;
ResultStruct.fitness=0;
ResultStruct.sharing=0;

if (method == 1)
% random crossover between genes
	
	%disp('random crossover');
	a = rand;
	ResultStruct.genotype.amin = a * IndividualStruct(1).genotype.amin + (1-a) * IndividualStruct(2).genotype.amin;

	a = rand;
	ResultStruct.genotype.gmin = a * IndividualStruct(1).genotype.gmin + (1-a) * IndividualStruct(2).genotype.gmin;

	a = rand;
	ResultStruct.genotype.amax = a * IndividualStruct(1).genotype.amax + (1-a) * IndividualStruct(2).genotype.amax;

	a = rand;
	ResultStruct.genotype.gmax = a * IndividualStruct(1).genotype.gmax + (1-a) * IndividualStruct(2).genotype.gmax;

	a = rand;
	ResultStruct.genotype.anod = a * IndividualStruct(1).genotype.anod + (1-a) * IndividualStruct(2).genotype.anod;

	a = rand;
	ResultStruct.genotype.sigma = a * IndividualStruct(1).genotype.sigma + (1-a) * IndividualStruct(2).genotype.sigma;

	[val1,pos1]=intersect(EAStruct.Config.evol_filters,IndividualStruct(1).genotype.filter);
	[val2,pos2]=intersect(EAStruct.Config.evol_filters,IndividualStruct(2).genotype.filter);
	
	a = rand;
	ResultStruct.genotype.filter = EAStruct.Config.evol_filters(ceil( a * pos1 + 	(1-a) * pos2) );
	
	
elseif (method == 2)
% swapping crossover
% swap the genes of 2 individuals randomly

	%disp('swapping crossover');

	a = round(rand+1);
	ResultStruct.genotype.amin 		= (2-a) * IndividualStruct(1).genotype.amin 		+ (a-1) * IndividualStruct(2).genotype.amin;

	a = round(rand+1);
	ResultStruct.genotype.gmin 		= (2-a) * IndividualStruct(1).genotype.gmin 		+ (a-1) * IndividualStruct(2).genotype.gmin;

	a = round(rand+1);
	ResultStruct.genotype.amax 		= (2-a) * IndividualStruct(1).genotype.amax 		+ (a-1) * IndividualStruct(2).genotype.amax;

	a = round(rand+1);
	ResultStruct.genotype.gmax 		= (2-a) * IndividualStruct(1).genotype.gmax 		+ (a-1) * IndividualStruct(2).genotype.gmax;

	a = round(rand+1);
	ResultStruct.genotype.anod 		= (2-a) * IndividualStruct(1).genotype.anod			+ (a-1) * IndividualStruct(2).genotype.anod;

	a = round(rand+1);
	ResultStruct.genotype.sigma 	= (2-a) * IndividualStruct(1).genotype.sigma 		+ (a-1) * IndividualStruct(2).genotype.sigma;

	a = round(rand+1);
	ResultStruct.genotype.filter 	= (2-a) * IndividualStruct(1).genotype.filter 	+ (a-1) * IndividualStruct(2).genotype.filter ;

	
elseif (method == 3)
% factory crossover	
% build one individual with best genes from 2 individuals	
	
	%disp('factory crossover');
	a = (IndividualStruct(1).genes_fitness(1) < IndividualStruct(2).genes_fitness(1)) +1 ;
	ResultStruct.genotype.amin 		= (2-a) * IndividualStruct(1).genotype.amin 		+ (a-1) * IndividualStruct(2).genotype.amin;

	a = (IndividualStruct(1).genes_fitness(2) < IndividualStruct(2).genes_fitness(2)) +1 ;
	ResultStruct.genotype.gmin 		= (2-a) * IndividualStruct(1).genotype.gmin 		+ (a-1) * IndividualStruct(2).genotype.gmin;

	a = (IndividualStruct(1).genes_fitness(3) < IndividualStruct(2).genes_fitness(3)) +1 ;
	ResultStruct.genotype.amax 		= (2-a) * IndividualStruct(1).genotype.amax 		+ (a-1) * IndividualStruct(2).genotype.amax;

	a = (IndividualStruct(1).genes_fitness(4) < IndividualStruct(2).genes_fitness(4)) +1 ;
	ResultStruct.genotype.gmax 		= (2-a) * IndividualStruct(1).genotype.gmax 		+ (a-1) * IndividualStruct(2).genotype.gmax;

	a = (IndividualStruct(1).genes_fitness(5) < IndividualStruct(2).genes_fitness(5)) +1 ;
	ResultStruct.genotype.anod 		= (2-a) * IndividualStruct(1).genotype.anod			+ (a-1) * IndividualStruct(2).genotype.anod;

	a = (IndividualStruct(1).genes_fitness(6) < IndividualStruct(2).genes_fitness(6)) +1 ;
	ResultStruct.genotype.sigma 	= (2-a) * IndividualStruct(1).genotype.sigma 		+ (a-1) * IndividualStruct(2).genotype.sigma;

	a = (IndividualStruct(1).genes_fitness(7) < IndividualStruct(2).genes_fitness(7)) +1 ;
	ResultStruct.genotype.filter 	= (2-a) * IndividualStruct(1).genotype.filter 	+ (a-1) * IndividualStruct(2).genotype.filter ;


else
	error('Wrong crossover method.');	
end
	
	
	