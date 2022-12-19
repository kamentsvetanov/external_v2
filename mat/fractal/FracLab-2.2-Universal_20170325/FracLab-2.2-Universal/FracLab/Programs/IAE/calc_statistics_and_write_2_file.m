function stats = calc_statistics_and_write_2_file(images, stat_types, filename, write_2_file)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

stats = [];

for (n=1:1:max(size(images)))
	
	i = images(n);

%%% OUTPUT OF EVALUATIONS AND STATISTICS --->

f_eval = get(findobj('Tag',['text' num2str(i-1)]),'String');
output = [f_eval];

next_stats = [];


% Gray Variance
if (max(size(intersect(stat_types,1)))>0)
	f_stats1 = image_gray_variance(i);
	next_stats = [next_stats f_stats1];
end

if (max(size(intersect(stat_types,[2,3,4])))>0)
	f_stats = image_gray_deviation(i);
	
	% Deviation
	if (max(size(intersect(stat_types,2)))>0)
		f_stats2 = f_stats(1);
		next_stats = [next_stats f_stats2];
	end
	
	% Deviation Shift
	if (max(size(intersect(stat_types,3)))>0)
		f_stats3 = f_stats(2);
		next_stats = [next_stats f_stats3];
	end
	
	% Procentual Deviation
	if (max(size(intersect(stat_types,4)))>0)
		f_stats4 = f_stats(3);
		next_stats = [next_stats f_stats4];
	end
	
end
	
if (max(size(intersect(stat_types,5)))>0)
	f_stats5 = image_label_number(i);
	next_stats = [next_stats f_stats5];
end

if (max(size(intersect(stat_types,6)))>0)
	f_stats6 = image_euler_number(i); 
	next_stats = [next_stats f_stats6];
end

if (max(size(intersect(stat_types,7)))>0)
	f_stats7 = image_objects_area(i);
	next_stats = [next_stats f_stats7];
end

if (max(size(intersect(stat_types,[8,9,10,11])))>0)
	f_temp = image_spectral_measure(i);
end

if (max(size(intersect(stat_types,8)))>0)
	% MaxPos
	f_stats8 = f_temp(1); 
	next_stats = [next_stats f_stats8];
end

if (max(size(intersect(stat_types,9)))>0)
	% MaxPos Shift
	f_stats9 = f_temp(2); 
	next_stats = [next_stats f_stats9];
end

if (max(size(intersect(stat_types,10)))>0)
	% Weight
	f_stats10 = f_temp(3); 
	next_stats = [next_stats f_stats10];
end

if (max(size(intersect(stat_types,11)))>0)
	% Weight Shift
	f_stats11 = f_temp(4);
	next_stats = [next_stats f_stats11];
end

if (max(size(intersect(stat_types,[12,13,14,15])))>0)
	f_temp = image_spectral_measure2(i);

	if (max(size(intersect(stat_types,12)))>0)
		% Ascension
		f_stats12 = f_temp(1); 
		next_stats = [next_stats f_stats12];
	end

	if (max(size(intersect(stat_types,13)))>0)
		% Ascension Shift
		f_stats13 = f_temp(2); 
		next_stats = [next_stats f_stats13];
	end

	if (max(size(intersect(stat_types,14)))>0)
		% Descension
		f_stats14 = f_temp(3); 
		next_stats = [next_stats f_stats14];
	end

	if (max(size(intersect(stat_types,15)))>0)
		% Descension Shift
		f_stats15 = f_temp(4);
		next_stats = [next_stats f_stats15];
	end
	
end

if (max(size(intersect(stat_types,16)))>0)
	% Mean of Grayimage
	f_stats16 = image_gray_mean(i);
	next_stats = [next_stats f_stats16];
end

if (max(size(intersect(stat_types,17)))>0)
	% Correlation
	f_stats17 = image_gray_correlation(i);
	next_stats = [next_stats f_stats17];
end

if (max(size(intersect(stat_types,18)))>0)
	% Truecolor variance
	f_stats18 = image_variance(i);
	next_stats = [next_stats f_stats18];
end

if (max(size(intersect(stat_types,19)))>0)
	% Difference from image (the image to denoise)
	f_stats19 = image_difference(i);
	next_stats = [next_stats f_stats19];
end

	
	%Genotype:
if (max(size(intersect(stat_types,20)))>0)	
	f_stats20 = mydata.images.image(i).genotype.amin;
	next_stats = [next_stats f_stats20];
end

if (max(size(intersect(stat_types,21)))>0)	
	f_stats21 = mydata.images.image(i).genotype.gmin;
	next_stats = [next_stats f_stats21];
end

if (max(size(intersect(stat_types,22)))>0)
	f_stats22 = mydata.images.image(i).genotype.amax;
	next_stats = [next_stats f_stats22];
end

if (max(size(intersect(stat_types,23)))>0)	
	f_stats23 = mydata.images.image(i).genotype.gmax;
	next_stats = [next_stats f_stats23];
end

if (max(size(intersect(stat_types,24)))>0)	
	f_stats24 = mydata.images.image(i).genotype.anod;
	next_stats = [next_stats f_stats24];
end

if (max(size(intersect(stat_types,25)))>0)	
	f_stats25 = mydata.images.image(i).genotype.sigma;
	next_stats = [next_stats f_stats25];
end

if (max(size(intersect(stat_types,26)))>0)	
	f_stats26 = mydata.images.image(i).genotype.filter;
	next_stats = [next_stats f_stats26];
end

	stats = [stats; next_stats];
	
	
	for n=1:1:max(size(next_stats))
		output = [output '; ' num2str(next_stats(n))];
	end

if (write_2_file == 1)												 
	fp = fopen(filename,'a+');
	fprintf(fp,'%s\n',output);
	fclose(fp);
end

%%% <--- OUTPUT OF EVALUATIONS AND STATISTICS

end