function result = image_label_number(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

data = 1-im2bw(mydata.images.image(imgnum).CData,0.5);

[L,result] = bwlabel(data,8);
result = result/(size(data,1)*size(data,2));
