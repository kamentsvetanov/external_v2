%   Finite order difference of a matrix
%
%   Difference and approximate derivative. If x is a matrix, the differ-
%   ences are computed columnwise.
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [y] = mtlb_diff(x[,order])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  x : real valued vector or matrix [rx,cx]
%
%   o  order : positive integer specifying the difference order. Default
%      value is order = 1.
%
%   1.2.  Output parameters
%
%   o  y : real valued vector or matrix [rx-order,cx]
%      y = x(order+1:rx,:) - x(1:rx-order,:) ;
%
%   2.  See also:
%
%   3.  Examples

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------