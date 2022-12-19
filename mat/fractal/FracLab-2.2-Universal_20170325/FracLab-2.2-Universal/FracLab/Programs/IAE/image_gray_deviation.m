function result = image_gray_deviation(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

data1 = double(rgb2gray(mydata.images.image(1).CData));
data2 = double(rgb2gray(mydata.images.image(imgnum).CData));

std_1 = std2(data1);
std_2 = round(1000*std2(data2))/1000;

std_diff = round(1000* (std_2 - std_1) )/1000;
std_proc = round(1000* std_2*100/std_1 )/1000;

result = [std_2, std_diff, std_proc];

