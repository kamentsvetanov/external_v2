function result = image_gray_variance(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

data = double(rgb2gray(mydata.images.image(imgnum).CData));


data = reshape(data,1,[]);

result = var(data,1);

