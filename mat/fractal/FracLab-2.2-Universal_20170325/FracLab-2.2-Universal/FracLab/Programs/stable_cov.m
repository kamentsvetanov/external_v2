%   Covariation of two jointly symmetric Alpha-Stable random
%   variables
%
%   This routine estimates the covariation of two jointly symmetric alpha-
%   stable random variables.
%
%   1.  Usage
%
%   [cov]=stable_cov(data1,data2)
%
%   1.1.  Input parameters
%
%   o  data1 : real vector [size,1]
%      corresponding to the the first data sample.
%
%   o  data2 : real vector [size,1]
%      corresponding to the second data sample.
%
%   1.2.  Output parameters
%
%   o  sm : real scalar
%      corresponding to the estimation  the covariation of data1 on data2.

% Author Lotfi Belkacem, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------