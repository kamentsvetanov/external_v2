function distance = calc_genom_distance(genom1, genom2)
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


dim = min(length(genom1),length(genom2));

distance = [];

genom1 = genom1(1:dim);				
genom2 = genom2(1:dim);

genom1(1) = 2^-genom1(1);
genom1(3) = 2^-genom1(3);
genom1(5) = 2^-genom1(5);

genom2(1) = 2^-genom2(1);
genom2(3) = 2^-genom2(3);
genom2(5) = 2^-genom2(5);


data = [((genom1(1)-genom2(1))/range_amin)^2, ((genom1(2)-genom2(2))/range_gmin)^2, ((genom1(3)-genom2(3))/range_amax)^2, ((genom1(4)-genom2(4))/range_gmax)^2, ((genom1(5)-genom2(5))/range_anod)^2, ((genom1(6)-genom2(6))/range_sigma)^2, ((genom1(7)-genom2(7))/range_filter)^2];
distance = sqrt(sum(data)/7);

