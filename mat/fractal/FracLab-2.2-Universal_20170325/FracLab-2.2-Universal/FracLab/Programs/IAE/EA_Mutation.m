function IndividualStruct = EA_Mutation(EAStruct, IndividualStruct)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if (length(IndividualStruct) < 1)
	error('Empty list of individuals!');	
end

probability_sum = EAStruct.Config.evol_do_prefered_area_directed_mutation + EAStruct.Config.evol_do_random_mutation;
EAStruct.Config.evol_do_prefered_area_directed_mutation 		= round(100 * EAStruct.Config.evol_do_prefered_area_directed_mutation / probability_sum);
EAStruct.Config.evol_do_random_mutation 										= round(100 * EAStruct.Config.evol_do_random_mutation / probability_sum);

Roulette = [1*ones(1,EAStruct.Config.evol_do_prefered_area_directed_mutation), 2*ones(1,EAStruct.Config.evol_do_random_mutation), 3*ones(1,EAStruct.Config.evol_do_prefered_area_directed_mutation_plus_random_mutation)];

method = Roulette(round(rand*(length(Roulette)-1)) +1);

if (method == 1)
% mutate towards prefered areas
	%disp('prefered area mutation');
	IndividualStruct = prefered_mutation(EAStruct, IndividualStruct);	

	
elseif (method == 2)
% random mutation
	%disp('random mutation');
	IndividualStruct = random_mutation(EAStruct, IndividualStruct);
	
elseif (method == 3)
% do random plus directed mutation
	%disp('random+directed mutation');
	IndividualStruct = prefered_mutation(EAStruct, IndividualStruct);	
	IndividualStruct = random_mutation(EAStruct, IndividualStruct);

else
	error('Wrong mutation method.');	
end
	
	

function IndividualStruct = prefered_mutation(EAStruct, IndividualStruct)


	for i=1:1:length(IndividualStruct)

		IndividualStruct(i).is_locked=0;
		IndividualStruct(i).bound_image_number=0;
		IndividualStruct(i).fitness=0;
		
		is_outside = (IndividualStruct(i).genotype.amin < EAStruct.Config.user_prefered_regions(1,1)) || (IndividualStruct(i).genotype.amin > EAStruct.Config.user_prefered_regions(2,1));
		distance = IndividualStruct(i).genotype.amin - (EAStruct.Config.user_prefered_regions(2,1) + EAStruct.Config.user_prefered_regions(1,1))/2;
		IndividualStruct(i).genotype.amin 	= IndividualStruct(i).genotype.amin			- is_outside * (distance * rand);
		IndividualStruct(i).genotype.amin 	= min(max(EAStruct.Config.evol_amin_min, IndividualStruct(i).genotype.amin), EAStruct.Config.evol_amin_max);

		is_outside = (IndividualStruct(i).genotype.gmin < EAStruct.Config.user_prefered_regions(1,2)) || (IndividualStruct(i).genotype.gmin > EAStruct.Config.user_prefered_regions(2,2));
		distance = IndividualStruct(i).genotype.gmin - (EAStruct.Config.user_prefered_regions(2,2) + EAStruct.Config.user_prefered_regions(1,2))/2;
		IndividualStruct(i).genotype.gmin 	= IndividualStruct(i).genotype.gmin			- is_outside * (distance * rand);
		IndividualStruct(i).genotype.gmin 	= min(max(EAStruct.Config.evol_gmin_min, IndividualStruct(i).genotype.gmin), EAStruct.Config.evol_gmin_max);
		
		is_outside = (IndividualStruct(i).genotype.amax < EAStruct.Config.user_prefered_regions(1,3)) || (IndividualStruct(i).genotype.amax > EAStruct.Config.user_prefered_regions(2,3));
		distance = IndividualStruct(i).genotype.amax - (EAStruct.Config.user_prefered_regions(2,3) + EAStruct.Config.user_prefered_regions(1,3))/2;
		IndividualStruct(i).genotype.amax 	= IndividualStruct(i).genotype.amax			- is_outside * (distance * rand);
		IndividualStruct(i).genotype.amax 	= min(max(EAStruct.Config.evol_amax_min, IndividualStruct(i).genotype.amax), EAStruct.Config.evol_amax_max);
		
		is_outside = (IndividualStruct(i).genotype.gmax < EAStruct.Config.user_prefered_regions(1,4)) || (IndividualStruct(i).genotype.gmax > EAStruct.Config.user_prefered_regions(2,4));
		distance = IndividualStruct(i).genotype.gmax - (EAStruct.Config.user_prefered_regions(2,4) + EAStruct.Config.user_prefered_regions(1,4))/2;
		IndividualStruct(i).genotype.gmax 	= IndividualStruct(i).genotype.gmax			- is_outside * (distance * rand);
		IndividualStruct(i).genotype.gmax 	= min(max(EAStruct.Config.evol_gmax_min, IndividualStruct(i).genotype.gmax), EAStruct.Config.evol_gmax_max);
		
		is_outside = (IndividualStruct(i).genotype.anod < EAStruct.Config.user_prefered_regions(1,5)) || (IndividualStruct(i).genotype.anod > EAStruct.Config.user_prefered_regions(2,5));
		distance = IndividualStruct(i).genotype.anod - (EAStruct.Config.user_prefered_regions(2,5) + EAStruct.Config.user_prefered_regions(1,5))/2;
		IndividualStruct(i).genotype.anod 	= IndividualStruct(i).genotype.anod			- is_outside * (distance * rand);
		IndividualStruct(i).genotype.anod 	= min(max(EAStruct.Config.evol_anod_min, IndividualStruct(i).genotype.anod), EAStruct.Config.evol_anod_max);
		
		is_outside = (IndividualStruct(i).genotype.sigma < EAStruct.Config.user_prefered_regions(1,6)) || (IndividualStruct(i).genotype.sigma > EAStruct.Config.user_prefered_regions(2,6));
		distance = IndividualStruct(i).genotype.sigma - (EAStruct.Config.user_prefered_regions(2,6) + EAStruct.Config.user_prefered_regions(1,6))/2;
		IndividualStruct(i).genotype.sigma 	= IndividualStruct(i).genotype.sigma			- is_outside * (distance * rand);
		IndividualStruct(i).genotype.sigma 	= min(max(EAStruct.Config.evol_sigma_min, IndividualStruct(i).genotype.sigma), EAStruct.Config.evol_sigma_max);
		
		is_outside = (IndividualStruct(i).genotype.filter < EAStruct.Config.user_prefered_regions(1,7)) || (IndividualStruct(i).genotype.filter > EAStruct.Config.user_prefered_regions(2,7));
		distance = IndividualStruct(i).genotype.filter - (EAStruct.Config.user_prefered_regions(2,7) + EAStruct.Config.user_prefered_regions(1,7))/2;
		IndividualStruct(i).genotype.filter 	= IndividualStruct(i).genotype.filter			- is_outside * (distance * rand);
		
		[val,pos]=min(abs(EAStruct.Config.evol_filters - IndividualStruct(i).genotype.filter));
		IndividualStruct(i).genotype.filter = EAStruct.Config.evol_filters(pos);
		
		
	end
	
	
function IndividualStruct = random_mutation(EAStruct, IndividualStruct)


	range_amin 		= EAStruct.Config.evol_amin_max 	- EAStruct.Config.evol_amin_min;
	range_gmin 		= EAStruct.Config.evol_gmin_max 	- EAStruct.Config.evol_gmin_min;
	range_amax 		= EAStruct.Config.evol_amax_max 	- EAStruct.Config.evol_amax_min;
	range_gmax 		= EAStruct.Config.evol_gmax_max 	- EAStruct.Config.evol_gmax_min;
	range_anod 		= EAStruct.Config.evol_anod_max 	- EAStruct.Config.evol_anod_min;
	range_sigma	  = EAStruct.Config.evol_sigma_max 	- EAStruct.Config.evol_sigma_min;
	range_filter	= length(EAStruct.Config.evol_filters);
	
	for i=1:1:length(IndividualStruct)
		
		IndividualStruct(i).is_locked=0;
		IndividualStruct(i).bound_image_number=0;
		IndividualStruct(i).fitness=0;
		
		IndividualStruct(i).genotype.amin 	= IndividualStruct(i).genotype.amin			+ range_amin 	* EAStruct.Config.evol_amin_mutation * (2*rand-1);	
		IndividualStruct(i).genotype.gmin 	= IndividualStruct(i).genotype.gmin			+ range_gmin 	* EAStruct.Config.evol_gmin_mutation * (2*rand-1); 	
		IndividualStruct(i).genotype.amax 	= IndividualStruct(i).genotype.amax			+ range_amax 	* EAStruct.Config.evol_amax_mutation * (2*rand-1);	
		IndividualStruct(i).genotype.gmax 	= IndividualStruct(i).genotype.gmax			+ range_gmax 	* EAStruct.Config.evol_gmax_mutation * (2*rand-1);	
		IndividualStruct(i).genotype.anod 	= IndividualStruct(i).genotype.anod			+ range_anod 	* EAStruct.Config.evol_anod_mutation * (2*rand-1);	
		IndividualStruct(i).genotype.sigma	= IndividualStruct(i).genotype.sigma		+ range_sigma * EAStruct.Config.evol_sigma_mutation * (2*rand-1);	
		
		IndividualStruct(i).genotype.amin 	= min(max(EAStruct.Config.evol_amin_min, IndividualStruct(i).genotype.amin), EAStruct.Config.evol_amin_max);
		IndividualStruct(i).genotype.gmin 	= min(max(EAStruct.Config.evol_gmin_min, IndividualStruct(i).genotype.gmin), EAStruct.Config.evol_gmin_max);
		IndividualStruct(i).genotype.amax 	= min(max([EAStruct.Config.evol_amax_min, IndividualStruct(i).genotype.amax, IndividualStruct(i).genotype.amin+0.00004]), EAStruct.Config.evol_amax_max);
		IndividualStruct(i).genotype.gmax 	= min(max(EAStruct.Config.evol_gmax_min, IndividualStruct(i).genotype.gmax), EAStruct.Config.evol_gmax_max);
		IndividualStruct(i).genotype.anod 	= min([max([EAStruct.Config.evol_anod_min, IndividualStruct(i).genotype.anod, IndividualStruct(i).genotype.amin+0.00001]), EAStruct.Config.evol_anod_max, IndividualStruct(i).genotype.amax-0.00001]);
		IndividualStruct(i).genotype.sigma 	= min(max(EAStruct.Config.evol_sigma_min, IndividualStruct(i).genotype.sigma), EAStruct.Config.evol_sigma_max);
		
		[val,pos]=intersect(EAStruct.Config.evol_filters, IndividualStruct(i).genotype.filter);
		
		
		pos = pos + EAStruct.Config.evol_filter_mutation * range_filter * (2*rand-1);
		pos = mod(pos-1,range_filter)+1;
		
		pos = max(round(pos),1);
		pos = min(round(pos),range_filter);
		
		IndividualStruct(i).genotype.filter 	= EAStruct.Config.evol_filters(pos);	
	end