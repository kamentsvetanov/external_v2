function erg = calc_variance()
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;
conf = mydata.config;

range_amin 		= mydata.config.evol_amin_max - mydata.config.evol_amin_min;
range_gmin 		= mydata.config.evol_gmin_max - mydata.config.evol_gmin_min;
range_amax 		= mydata.config.evol_amax_max - mydata.config.evol_amax_min;
range_gmax 		= mydata.config.evol_gmax_max - mydata.config.evol_gmax_min;
range_anod 		= mydata.config.evol_anod_max - mydata.config.evol_anod_min;
range_sigma	  = mydata.config.evol_sigma_max - mydata.config.evol_sigma_min;
range_filter = max(mydata.config.evol_filters) - min(mydata.config.evol_filters);


distances = [];

for i=2:1:6

	for j=i+1:1:7
		geno1 = mydata.images.image(i).genotype;
		geno2 = mydata.images.image(j).genotype;
	
		data = [((geno1.amin-geno2.amin)/range_amin)^2, ((geno1.gmin-geno2.gmin)/range_gmin)^2, ((geno1.amax-geno2.amax)/range_amax)^2, ((geno1.gmax-geno2.gmax)/range_gmax)^2, ((geno1.anod-geno2.anod)/range_anod)^2, ((geno1.sigma-geno2.sigma)/range_sigma)^2, ((geno1.filter-geno2.filter)/range_filter)^2];
		%data = [(conf.evol_amin_evidence*(geno1.amin-geno2.amin)/range_amin)^2, (conf.evol_gmin_evidence*(geno1.gmin-geno2.gmin)/range_gmin)^2, (conf.evol_amax_evidence*(geno1.amax-geno2.amax)/range_amax)^2, (conf.evol_gmax_evidence*(geno1.gmax-geno2.gmax)/range_gmax)^2, (conf.evol_anod_evidence*(geno1.anod-geno2.anod)/range_anod)^2, (conf.evol_sigma_evidence*(geno1.sigma-geno2.sigma)/range_sigma)^2, (conf.evol_filter_evidence*(geno1.filter-geno2.filter)/range_filter)^2];
		distances = [distances, sqrt(sum(data)/7)];
	end
	
end

erg = var(distances,1);