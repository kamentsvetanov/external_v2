%   Nearest integer power round
%
%   Rounds a number x to the up-nearest power of an integer Q
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [xup2Q,powQ] = nextpowQ(x[,Q])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  x : Real positive number
%
%   o  Q : Positive integer.
%      Default value is Q = 2
%
%   1.2.  Output parameters
%
%   o  xup2Q : Positive integer
%      x rounded to the closest power of Q
%
%   o  powQ :  Positive integer
%      xup2Q = powQ^Q.
%
%   2.  See also:
%
%   log, log2

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------