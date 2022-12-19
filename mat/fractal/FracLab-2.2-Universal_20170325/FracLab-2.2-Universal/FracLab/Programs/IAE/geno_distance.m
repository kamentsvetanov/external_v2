function val = geno_distance(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

conf = mydata.config;

range_amin 		= conf.evol_amin_max - conf.evol_amin_min;
range_gmin 		= conf.evol_gmin_max - conf.evol_gmin_min;
range_amax 		= conf.evol_amax_max - conf.evol_amax_min;
range_gmax 		= conf.evol_gmax_max - conf.evol_gmax_min;
range_anod 		= conf.evol_anod_max - conf.evol_anod_min;
range_sigma	  = conf.evol_sigma_max - conf.evol_sigma_min;
range_filter = max(conf.evol_filters) - min(conf.evol_filters);

geno1 = mydata.images.image(imgnum).genotype;

distances = [];

for j=2:1:7
		
	if (j~=imgnum)
		geno2 = mydata.images.image(j).genotype;
	
		data = [((geno1.amin-geno2.amin)/range_amin)^2, ((geno1.gmin-geno2.gmin)/range_gmin)^2, ((geno1.amax-geno2.amax)/range_amax)^2, ((geno1.gmax-geno2.gmax)/range_gmax)^2, ((geno1.anod-geno2.anod)/range_anod)^2, ((geno1.sigma-geno2.sigma)/range_sigma)^2, ((geno1.filter-geno2.filter)/range_filter)^2];
		distances = [distances, sqrt(sum(data)/7)];
		
	end
end
	


val = mean(distances);

