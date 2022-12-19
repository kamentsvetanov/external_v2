%   Generation of stable random processes
%
%   This routine generates a stable random process and its increments
%   using the Chambers, Mallows and Stuck (1976) algorithm.
%
%   1.  Usage
%
%   [proc,inc]=sim_stable(alpha,beta,mu,gamma,size)
%
%   1.1.  Input parameters
%
%   o  alpha : real positive scalar between 0 and 2.
%      This parameter is often referred to as the characteristic exponent.
%
%   o  beta : real scalar between -1 and +1.
%      This parameter is often referred to as the skewness parameter.
%
%   o  mu : real scalar
%      This parameter is often referred to as the location parameter.
%      It is equal to the expectation when alpha is greater than 1.
%
%   o  gamma : real positive scalar.
%      This parameter is often referred to as the scale parameter.
%      It is equal to the standard deviation over two squared when alpha
%      equal 2.
%
%   o  size : integer positive scalar.
%      size of the simulated sample.
%
%   1.2.  Output parameters
%
%   o  proc : real vector [size,1]
%      corresponding to the stable random process.
%
%   o  inc : real vector [size,1]
%      corresponding to the increments of the simulated process.

% Author Lotfi Belkacem, April 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------