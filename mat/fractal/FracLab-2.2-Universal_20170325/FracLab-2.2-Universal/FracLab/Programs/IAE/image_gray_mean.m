function result = image_gray_mean(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

data = double(rgb2gray(mydata.images.image(imgnum).CData));


result = mean2(data);
