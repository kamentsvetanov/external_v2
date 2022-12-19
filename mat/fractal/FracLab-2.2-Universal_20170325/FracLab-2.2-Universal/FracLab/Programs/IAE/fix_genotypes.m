function fix_genotypes(imag_num)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;


if (exist('imag_num') == 0)

for i=2:1:7

	mydata.images.image(i).genotype.amin 	 = max(mydata.images.image(i).genotype.amin , mydata.config.evol_amin_min);	
	mydata.images.image(i).genotype.amin 	 = min(mydata.images.image(i).genotype.amin , mydata.config.evol_amin_max);
	
	mydata.images.image(i).genotype.gmin 	 = max(mydata.images.image(i).genotype.gmin , mydata.config.evol_gmin_min);
	mydata.images.image(i).genotype.gmin 	 = min(mydata.images.image(i).genotype.gmin , mydata.config.evol_gmin_max);
	
	mydata.images.image(i).genotype.amax 	 = max([mydata.images.image(i).genotype.amax , mydata.config.evol_amax_min , mydata.images.image(i).genotype.amin+0.00004]);
	mydata.images.image(i).genotype.amax 	 = min(mydata.images.image(i).genotype.amax , mydata.config.evol_amax_max);
	
	mydata.images.image(i).genotype.gmax 	 = max(mydata.images.image(i).genotype.gmax , mydata.config.evol_gmax_min);
	mydata.images.image(i).genotype.gmax 	 = min(mydata.images.image(i).genotype.gmax , mydata.config.evol_gmax_max);
	
	mydata.images.image(i).genotype.anod 	 = max([mydata.images.image(i).genotype.anod , mydata.config.evol_anod_min , mydata.images.image(i).genotype.amin+0.00001]);
	mydata.images.image(i).genotype.anod 	 = min([mydata.images.image(i).genotype.anod , mydata.config.evol_anod_max , mydata.images.image(i).genotype.amax-0.00001]);
	
	mydata.images.image(i).genotype.sigma 	 = max(mydata.images.image(i).genotype.sigma , mydata.config.evol_sigma_min);
	mydata.images.image(i).genotype.sigma 	 = min(mydata.images.image(i).genotype.sigma , mydata.config.evol_sigma_max);	
	
	if (max(size(intersect(mydata.config.evol_filters,mydata.images.image(i).genotype.filter)))==0)
		mydata.images.image(i).genotype.filter = mydata.config.evol_filters( round(rand*(size(mydata.config.evol_filters,2)-1))+1 );
	end
	
end

else
	i=imag_num;
	
	mydata.images.image(i).genotype.amin 	 = max(mydata.images.image(i).genotype.amin , mydata.config.evol_amin_min);	
	mydata.images.image(i).genotype.amin 	 = min(mydata.images.image(i).genotype.amin , mydata.config.evol_amin_max);
	
	mydata.images.image(i).genotype.gmin 	 = max(mydata.images.image(i).genotype.gmin , mydata.config.evol_gmin_min);
	mydata.images.image(i).genotype.gmin 	 = min(mydata.images.image(i).genotype.gmin , mydata.config.evol_gmin_max);
	
	mydata.images.image(i).genotype.amax 	 = max([mydata.images.image(i).genotype.amax , mydata.config.evol_amax_min , mydata.images.image(i).genotype.amin+0.00004]);
	mydata.images.image(i).genotype.amax 	 = min(mydata.images.image(i).genotype.amax , mydata.config.evol_amax_max);
	
	mydata.images.image(i).genotype.gmax 	 = max(mydata.images.image(i).genotype.gmax , mydata.config.evol_gmax_min);
	mydata.images.image(i).genotype.gmax 	 = min(mydata.images.image(i).genotype.gmax , mydata.config.evol_gmax_max);
	
	
	mydata.images.image(i).genotype.anod 	 = max([mydata.images.image(i).genotype.anod , mydata.config.evol_anod_min , mydata.images.image(i).genotype.amin+0.00001]);
	mydata.images.image(i).genotype.anod 	 = min([mydata.images.image(i).genotype.anod , mydata.config.evol_anod_max , mydata.images.image(i).genotype.amax-0.00001]);

	
	mydata.images.image(i).genotype.sigma 	 = max(mydata.images.image(i).genotype.sigma , mydata.config.evol_sigma_min);
	mydata.images.image(i).genotype.sigma 	 = min(mydata.images.image(i).genotype.sigma , mydata.config.evol_sigma_max);	
	
	if (max(size(intersect(mydata.config.evol_filters,mydata.images.image(i).genotype.filter)))==0)
		mydata.images.image(i).genotype.filter = mydata.config.evol_filters( round(rand*(size(mydata.config.evol_filters,2)-1))+1 );
	end
	
end
