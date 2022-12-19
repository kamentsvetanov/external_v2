function result = image_genotype_fittness(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

minmax = [0.49839		0.98548		19.883		1				0.89871; ...
					0					0.014686	0.67977		0.20646	0.078831];


geno = mydata.images.image(imgnum).genotype;
erg = calculate_NN('D:\ProgramsXP\0Science\Pythia\Restrictions_041206.NN', minmax, {[geno.amin,geno.gmin,geno.amax,geno.gmax,geno.anod]});

result = erg{1};