%   Stable law parameters estimation (McCulloch method)
%
%   This routine estimates parameters of a  stable law using the Mc-Cul-
%   loch (1985) method.
%
%   1.  Usage
%
%   [param,sd_param]=McCulloch(data)
%
%   1.1.  Input parameters
%
%   o  data : real vector [size,1]
%      corresponding to the data sample.
%
%   1.2.  Output parameters
%
%   o  param : real vector [4,1]
%      corresponding to the four estimated parameters  of the fited stable
%      law.
%      the order is respectively alpha (characteristic exponent),
%      beta (skewness parameter), mu (location parameter), gamma (scale
%      parameter)
%
%   o  sd_param : real vector [4,1]
%      corresponding to estimated standard deviation of the four previous
%      parameters.

% Auhtor Lotfi Belkacem, April 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------