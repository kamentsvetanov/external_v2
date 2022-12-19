%   Stable Law parameters estimation (Koutrouvelis method)
%
%   This routine estimates parameters of a  stable law using the Koutrou-
%   velis (1985) method.
%
%   1.  Usage
%
%   [alpha,beta,mu,gamma]=Koutrouvelis(data)
%
%   1.1.  Input parameters
%
%   o  proc : real vector [size,1]
%      corresponding to the data sample.
%
%   1.2.  Output parameters
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

% Auhtor Lotfi Belkacem, April 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------