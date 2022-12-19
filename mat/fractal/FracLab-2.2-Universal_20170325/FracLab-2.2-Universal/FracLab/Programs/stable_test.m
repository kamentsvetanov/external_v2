%   stable law conformicy test
%
%   This routine tests the stability property of a signal.
%
%   1.  Usage
%
%   [param,sd_param]=stable_test(maxr,data)
%
%   1.1.  Input parameters
%
%   o  maxr : integer positive scalar.
%      maximum resolution witch depend on the size of the sample.
%
%   o  data : real vector [size,1]
%      corresponding to the data sample (increments of the signal).
%
%   1.2.  Output parameters
%
%   o  param : real matrix [maxr,4]
%      corresponding to the four estimated parameters  of the fited stable
%      law at each level of resolution.
%      param(i,:), for i=1, ...maxr, gives respectively
%      alpha(characteristic exponent), beta (skewness parameter), mu
%      (location parameter), gamma (scale parameter) estimated at the
%      resolution i.
%
%   o  sd_param : real matrix [maxr,4]
%      corresponding to the estimated standard deviations of the four
%      previous parameters at each level of resolution.
%      sd_param(i,:), for i=1, ...maxr, gives respectively standard
%      deviation of alpha, beta, mu and gamma estimated at the resolution
%      i.

% Author Lotfi Belkacem, April 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------