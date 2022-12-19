function val = image_euler_number(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

matrix= 1-im2bw(mydata.images.image(imgnum).CData,0.5);

val = bweuler(matrix,8);

