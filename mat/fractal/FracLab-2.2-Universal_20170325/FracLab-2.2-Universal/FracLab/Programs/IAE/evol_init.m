function erg = evol_init(params)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;


erg.amin = rand(1)*mydata.config.evol_amin_max;
erg.gmin = mydata.config.evol_gmin_min + rand(1)*(mydata.config.evol_gmin_max - mydata.config.evol_gmin_min);
erg.anod = erg.amin+0.0001 + rand(1)*(mydata.config.evol_anod_max - (erg.amin+0.0001));
erg.amax = erg.anod+0.0001 + rand(1)*(mydata.config.evol_amax_max - (erg.anod+0.0001));
erg.gmax = mydata.config.evol_gmax_min + rand(1)*(mydata.config.evol_gmax_max - mydata.config.evol_gmax_min);
erg.sigma = mydata.config.evol_sigma_min + rand(1)*(mydata.config.evol_sigma_max - mydata.config.evol_sigma_min);
erg.filter = mydata.config.evol_filters( round(rand*(size(mydata.config.evol_filters,2)-1))+1 );
