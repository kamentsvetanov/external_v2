function result = image_gray_correlation(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

data1 = double(rgb2gray(mydata.images.image(imgnum).CData));
data2 = double(rgb2gray(mydata.images.image(1).CData));

result = corr2(data1,data2);

