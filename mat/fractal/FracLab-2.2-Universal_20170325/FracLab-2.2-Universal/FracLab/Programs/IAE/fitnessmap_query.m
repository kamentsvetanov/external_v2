function fitness = fitnessmap_query(fitnessmap, genoms, mode, method)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;
fitness = [];

queries = [];

if (size(fitnessmap,2) == 0)
	%warning('Query to an empty fitnessmap.');
	fitness = zeros(1,size(genoms,2));
	return;
end


if (mode == 1)
% fetch genotypes from images	
	for i=1:1:size(genoms,2)
		geno = mydata.images.image(genoms(i)).genotype;
		append = [geno.amin, geno.gmin, geno.amax, geno.gmax, geno.anod, geno.sigma, geno.filter];
		queries = [queries, append'];
	end
elseif (mode == 2)
	% fetch genotypes from any individuals in the population	
	for i=1:1:size(genoms,2)
		geno = mydata.population.individuals(genoms(i)).genotype;
		append = [geno.amin, geno.gmin,geno.amax, geno.gmax, geno.anod, geno.sigma, geno.filter];
		queries = [queries, append'];
	end
elseif (mode == 3)
	% inputs are allready valid queries to the fitnessmap
	queries = genoms;
end

fitness_pos = size(fitnessmap,1);
dimension = size(fitnessmap,1);
map_size = size(fitnessmap,2);


switch method
	case 'components'
		%disp('>>components method');
		
		
	case 'nearest'
		% choose nearest sample from database
		%disp('>>nearest');
	
		for i=1:1:size(queries,2)
				
				distances = [];
				for j=1:1:size(fitnessmap,2)
					distances = [distances, calc_genom_distance(queries(:,i), fitnessmap(:,j))	];
				end
			
				[m,idx] = sort(distances);
	
				% get the fitness value of the nearest genom saved in the fitness map	
				fitness = [fitness, fitnessmap(fitness_pos,idx(1))];
		end


	case 'interpolation'
		%disp('>>interpolation');
	
		% do a linear interpolation	
		fitness = interpolate(fitnessmap, queries);
		
	otherwise
		error('Wrong method parameter in query to fitnessmap');
		
end

