function val = image_lacunarity(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

matrix= 1-im2bw(mydata.images.image(imgnum).CData,0.5);

N1 = size(matrix,1);
N2 = size(matrix,2);
result = [];

matrix = sparse(matrix);

for i = 1:1:floor(log2(max(N1,N2)))
	dat = [];
	for x = 1:1:2^i
		for y = 1:1:2^i
			
			x1 = floor(N1/2^i * (x-1) +1);
			x2 = floor(N1/2^i * x);
			
			y1 = floor(N2/2^i * (y-1) +1);
			y2 = floor(N2/2^i * y);
			mat = matrix(x1:1:x2 , y1:1:y2);
			dat = [dat , size(find(mat),1)];
		end
	end
	
	%size(dat)
	result = [result ,log(var(dat)/mean(dat)^2)/log(2)];

end

fit_coeff = polyfit([1:1:size(result,2)] , result, 1);
val = fit_coeff(1);


function result = calc_lacunarity(data)

result = calc_variance(data) / calc_mean(data) ^2;


