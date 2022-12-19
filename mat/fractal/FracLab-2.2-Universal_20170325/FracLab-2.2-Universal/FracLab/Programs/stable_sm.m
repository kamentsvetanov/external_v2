%   Spectral measure of a bivariate Stable random vector
%
%   This routine estimates a normalized spectral measure of a bivariate
%   stable random vector.
%
%   1.  Usage
%
%   [theta,sm]=stable_sm(data1,data2)
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
%   o  theta : real vector
%      corresponding to the the input argument of the estimated spectral
%      measure.
%      Components of the vector theta are varying between 0 and 2*PI.
%
%   o  sm : real vector
%      corresponding to the estimation of the normalized spectral measure
%      of the bivariate vector (data1,data2).

% Author Lotfi Belkacem, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------