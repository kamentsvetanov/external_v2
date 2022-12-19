%   Discrete Legendre spectrum estimation on 1d measure
%
%   This routine estimates the discrete Legendre Spectrum on 1d measure.
%
%   1.  Usage
%
%   [alpha,f_alpha]=mdfl1d(mu_n,)
%
%   1.1.  Input parameters
%
%   o  mu_n : strictly positive real vector [1,nu_n]
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
%   o  f_alpha : real vector [1,N]
%      Contains the dimensions.
%
%   2.  Description
%
%   2.1.  Parameters
%
%   The discrete Legendre spectrum f_alpha is estimated on the finite
%   finer resolution of the pre-multifractal 1d measure mu_n. The three
%   steps of the estimatation are:
%
%   o  estimation of the partition function;
%
%   o  estimation of the Reyni exponents;
%
%   o  estimation of the Legendre transform.
%
%   2.2.  Algorithm details
%
%   The discrete partition function is estimated by coarse-graining masses
%   mu_n into non-overlapping boxes of increasing diameter (box method).
%   If nu_n is a power of 2, 2^n corresponds to the coarser scale.
%
%   The reyni exponents are estimated by least square linear regression.
%
%   The Legendre transform of the mass exponent function is estimated with
%   the linear-time Legendre transform.
%
%   3.  See also
%
%   mdzq1d,mdzq2d,reynitq,linearlt,mdfl2d.

% Author Christophe Canus, March 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------