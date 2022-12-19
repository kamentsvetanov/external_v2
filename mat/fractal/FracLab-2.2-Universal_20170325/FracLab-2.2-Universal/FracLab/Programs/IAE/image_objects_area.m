function val = image_objects_area(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

matrix= im2bw(mydata.images.image(imgnum).CData,0.5);

val = bwarea(matrix)/(size(matrix,1)*size(matrix,2));

