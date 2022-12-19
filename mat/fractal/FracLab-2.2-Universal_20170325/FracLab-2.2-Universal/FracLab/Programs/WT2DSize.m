function [N] = WT2DSize(WT)
% Returns the size of the signal used for the decomposition 
%
% See also  WT2DStruct, WT2DNbScales, FWT2D, IWT2D

% Author Bertrand Guiheneuf, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	N = [ WT(1) , WT(2) ];
