%   Discrete Legendre spectrum estimation on 2d measure
%
%   This routine estimates the discrete Legendre spectrum on a pre-multi-
%   fractal 2d measure.
%
%   1.  Usage
%
%   [alpha,fl_alpha]=mdfl2d(mu_n,N,n)
%
%   1.1.  Input parameters
%
%   o  mu_n : strictly positive real matrix [nux_n,nuy_n]
%      Contains the pre-multifractal measure.
%
%   o  N : strictly positive real (integer) scalar
%      Contains the number of Hoelder exponents.
%
%   o  n : strictly positive real (integer) scalar
%      Contains the final resolution.
%
%   1.2.  Output parameters
%
%   o  alpha : real vector [1,N]
%      Contains the Hoelder exponents.
%
%   o  fl_alpha : real vector [1,N]
%      Contains the dimensions.
%
%   2.  See also
%
%   mdznq1d,mdznq2d,reynitq,linearlt,mdfl1d.

% Author Christophe Canus, March 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------