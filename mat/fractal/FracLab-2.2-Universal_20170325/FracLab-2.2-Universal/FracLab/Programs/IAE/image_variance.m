function result = image_variance(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

data1 = double(mydata.images.image(imgnum).CData(:,:,1));
data2 = double(mydata.images.image(imgnum).CData(:,:,2));
data3 = double(mydata.images.image(imgnum).CData(:,:,3));

data1 = reshape(data1,1,[]);
data2 = reshape(data2,1,[]);
data3 = reshape(data3,1,[]);

result = mean([var(data1,1),var(data2,1),var(data3,1)]);

