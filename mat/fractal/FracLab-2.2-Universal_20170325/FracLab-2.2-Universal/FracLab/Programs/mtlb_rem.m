%   remainder after division
%
%   Remainder after division. MTLB_REM(x,y) is x - y.*int(x./y) if y ~= 0.
%   The input x and y must be real arrays of the same size, or real
%   scalars.
%
%   1.  Usage
%
%   ______________________________________________________________________
%   leftover = mtlb_rem(x,q)
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  x : Real number
%
%   o  q : Real number
%      Divider of x
%
%   1.2.  Output parameters
%
%   o  leftover : Real number
%      Remainder of the division of x by q

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------