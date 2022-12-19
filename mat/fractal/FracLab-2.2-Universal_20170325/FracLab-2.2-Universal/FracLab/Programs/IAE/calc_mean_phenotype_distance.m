function erg = calc_mean_phenotype_distance()
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

range_amin 		= mydata.config.evol_amin_max - mydata.config.evol_amin_min;
range_gmin 		= mydata.config.evol_gmin_max - mydata.config.evol_gmin_min;
range_amax 		= mydata.config.evol_amax_max - mydata.config.evol_amax_min;
range_gmax 		= mydata.config.evol_gmax_max - mydata.config.evol_gmax_min;
range_anod 		= mydata.config.evol_anod_max - mydata.config.evol_anod_min;
range_sigma	  = mydata.config.evol_sigma_max - mydata.config.evol_sigma_min;
range_filter = max(mydata.config.evol_filters) - min(mydata.config.evol_filters);

elements = size(mydata.images.image(1).CData,1)*size(mydata.images.image(1).CData,2);


distances = [];
for i=2:1:6
	err = [];
	for j=i+1:1:7
		
		pheno11 = double(mydata.images.image(i).CData(:,:,1));
		pheno12 = double(mydata.images.image(j).CData(:,:,1));
	
		
		pheno21 = double(mydata.images.image(i).CData(:,:,2));
		pheno22 = double(mydata.images.image(j).CData(:,:,2));
	
			
		pheno31 = double(mydata.images.image(i).CData(:,:,3));
		pheno32 = double(mydata.images.image(j).CData(:,:,3));
	
		
		data1 = sqrt(sum(sum(((pheno11-pheno12)/255).^2))./elements);
		data2 = sqrt(sum(sum(((pheno21-pheno22)/255).^2))./elements);
		data3 = sqrt(sum(sum(((pheno31-pheno32)/255).^2))./elements);
		
		distances = [distances, mean([data1, data2, data3])];
		
	end
	
end

erg = mean(distances);