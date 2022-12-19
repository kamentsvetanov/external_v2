function result = image_phenotype_fittness(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

	stats = calc_statistics_and_write_2_file(imgnum, [1,2,3,4,5,6,8,14,15,16], mydata.config.statistics_filename, 0);
	

		input = [	(stats(1, 1)-mydata.config.NN_Input_Min( 1))/(mydata.config.NN_Input_Max( 1)-mydata.config.NN_Input_Min( 1)) ...
								(stats(1, 2)-mydata.config.NN_Input_Min( 2))/(mydata.config.NN_Input_Max( 2)-mydata.config.NN_Input_Min( 2)) ...
								(stats(1, 3)-mydata.config.NN_Input_Min( 3))/(mydata.config.NN_Input_Max( 3)-mydata.config.NN_Input_Min( 3)) ...
								(stats(1, 4)-mydata.config.NN_Input_Min( 4))/(mydata.config.NN_Input_Max( 4)-mydata.config.NN_Input_Min( 4)) ...
								(stats(1, 5)-mydata.config.NN_Input_Min( 5))/(mydata.config.NN_Input_Max( 5)-mydata.config.NN_Input_Min( 5)) ...
								(stats(1, 6)-mydata.config.NN_Input_Min( 6))/(mydata.config.NN_Input_Max( 6)-mydata.config.NN_Input_Min( 6)) ...
								(stats(1, 7)-mydata.config.NN_Input_Min( 7))/(mydata.config.NN_Input_Max( 7)-mydata.config.NN_Input_Min( 7)) ...
								(stats(1,8)-mydata.config.NN_Input_Min( 8))/(mydata.config.NN_Input_Max( 8)-mydata.config.NN_Input_Min( 8)) ...
								(stats(1,9)-mydata.config.NN_Input_Min( 9))/(mydata.config.NN_Input_Max( 9)-mydata.config.NN_Input_Min( 9)) ...
								(stats(1,10)-mydata.config.NN_Input_Min(10))/(mydata.config.NN_Input_Max(10)-mydata.config.NN_Input_Min(10)) ...
							];


		
		layer1 = fermi(input * mydata.config.NN_layer01');
		layer2 = fermi(layer1 * mydata.config.NN_layer02');
		layer3 = fermi(layer2 * mydata.config.NN_layer03');
		result = fermi(layer3 * mydata.config.NN_layer04');
	
% --------------------------------------------------------------------
function result = fermi(n)
result = 1./(1+exp(-4*(n-0.5)));
