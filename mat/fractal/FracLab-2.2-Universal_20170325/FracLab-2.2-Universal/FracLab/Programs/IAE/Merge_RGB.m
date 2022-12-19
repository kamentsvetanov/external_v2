function result = Merge_RGB(red, green, blue)
% --- Merge [NxM] color channels into one [NxMx3] image
% red	color channel red
% green	color channel green
% blue	color channel blue

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

RGB = [];
RGB(:,:,1) = red;
RGB(:,:,2) = green;
RGB(:,:,3) = blue;

result = uint8(RGB);