%   1D Inverse Discrete Wavelet Transform
%
%   This routine computes inverse discrete wavelet transforms of a  real
%   signal. Two inverse transforms are possible : Orthogonal and Biorthog-
%   onal
%
%   1.  Usage
%
%   [result]=IWT(wt,[f])
%
%   1.1.  Input parameters
%
%   o  wt : real unidimensional matrix [m,n]
%      Contains the wavelet transform (obtained with FWT).
%
%   o  f : real unidimensional matrix [m,n]
%      Synthesis filter.
%
%   1.2.  Output parameters
%
%   o  result : real unidimensional matrix
%      Result of the reconstruction.
%
%   2.  See Also
%
%   FWT, MakeQMF, MakeCQF, WTMultires, WTStruct

% Author Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------