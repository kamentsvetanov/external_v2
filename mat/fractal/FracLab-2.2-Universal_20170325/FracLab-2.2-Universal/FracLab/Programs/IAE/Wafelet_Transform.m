function result = Wafelet_Transform(mat2D,scales,filter)
% --- Do DWT Transformation
% mat2D 	2dim.Image Data
% scales 	number of scales to calculate
% filter 	Wafelet which should be used

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[wt,wti,wtl] = FWT2D(double(mat2D), scales, filter);

result = struct('wt',wt, 'size_x',size(mat2D,1), 'size_y',size(mat2D,2), 'wti',wti, 'wtl',wtl, 'scales', size(wti,1), 'filter',filter);
