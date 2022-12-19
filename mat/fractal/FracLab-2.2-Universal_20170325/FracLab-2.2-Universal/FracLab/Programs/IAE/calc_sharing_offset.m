function results = calc_sharing_offset(EAStruct,Method)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

results = [];

sharing_weight = eval(['EAStruct.Config.evol_' lower(Method) '_selection_sharing_weight']); 

range_amin 		= 2^-EAStruct.Config.evol_amin_max  - 2^-EAStruct.Config.evol_amin_min;
range_gmin 		= EAStruct.Config.evol_gmin_max     - EAStruct.Config.evol_gmin_min;
range_amax 		= 2^-EAStruct.Config.evol_amax_max  - 2^-EAStruct.Config.evol_amax_min;
range_gmax 		= EAStruct.Config.evol_gmax_max     - EAStruct.Config.evol_gmax_min;
range_anod 		= 2^-EAStruct.Config.evol_anod_max  - 2^-EAStruct.Config.evol_anod_min;
range_sigma     = EAStruct.Config.evol_sigma_max    - EAStruct.Config.evol_sigma_min;
range_filter    = max(EAStruct.Config.evol_filters) - min(EAStruct.Config.evol_filters);


for i=1:1:length(EAStruct.Individuals)
    distances = [];
    
    for j=1:1:length(EAStruct.Individuals)
        
        if (i~=j)
            geno1 = EAStruct.Individuals(i).genotype;
            geno2 = EAStruct.Individuals(j).genotype;
	
            data = [((2^-geno1.amin - 2^-geno2.amin)/range_amin)^2, ((geno1.gmin-geno2.gmin)/range_gmin)^2, ((2^-geno1.amax - 2^-geno2.amax)/range_amax)^2, ((geno1.gmax - geno2.gmax)/range_gmax)^2, ((2^-geno1.anod - 2^-geno2.anod)/range_anod)^2, ((geno1.sigma-geno2.sigma)/range_sigma)^2, ((geno1.filter-geno2.filter)/range_filter)^2];
		
            distances = [distances, sqrt(sum(data)/(7))];
        end        
    end
    results = [results, mean(distances)*sharing_weight];
end

