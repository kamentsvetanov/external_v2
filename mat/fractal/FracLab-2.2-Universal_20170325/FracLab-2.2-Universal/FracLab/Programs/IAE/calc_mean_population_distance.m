function [erg] = calc_mean_population_distance()
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;
conf = mydata.config;

range_amin 		= 2^-mydata.config.evol_amin_max - 2^-mydata.config.evol_amin_min;
range_gmin 		= mydata.config.evol_gmin_max - mydata.config.evol_gmin_min;
range_amax 		= 2^-mydata.config.evol_amax_max - 2^-mydata.config.evol_amax_min;
range_gmax 		= mydata.config.evol_gmax_max - mydata.config.evol_gmax_min;
range_anod 		= 2^-mydata.config.evol_anod_max - 2^-mydata.config.evol_anod_min;
range_sigma	  = mydata.config.evol_sigma_max - mydata.config.evol_sigma_min;
range_filter = max(mydata.config.evol_filters) - min(mydata.config.evol_filters);


distances = [];

for i=1:1:mydata.config.evol_population_size-1

	for j=i+1:1:mydata.config.evol_population_size
		
		geno1 = mydata.population.individuals(i).genotype;
		geno2 = mydata.population.individuals(j).genotype;
	
		data = [((2^-geno1.amin - 2^-geno2.amin)/range_amin)^2, ((geno1.gmin-geno2.gmin)/range_gmin)^2, ((2^-geno1.amax-2^-geno2.amax)/range_amax)^2, ((geno1.gmax-geno2.gmax)/range_gmax)^2, ((2^-geno1.anod-2^-geno2.anod)/range_anod)^2, ((geno1.sigma-geno2.sigma)/range_sigma)^2, ((geno1.filter-geno2.filter)/range_filter)^2];
		
		distances = [distances, sqrt(sum(data)/7)];
	end
	
end

erg = median(distances);