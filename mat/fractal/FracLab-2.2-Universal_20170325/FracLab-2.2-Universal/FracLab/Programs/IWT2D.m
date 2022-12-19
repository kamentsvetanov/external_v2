%   2D Inverse Disrete Wavelet Transform
%
%   This routine computes inverse discrete wavelet transforms of a 2D real
%   signal. Two inverse transforms are possible : Orthogonal and Biorthog-
%   onal
%
%   1.  Usage
%
%   [result]=IWT2D(wt,[f])
%
%   1.1.  Input parameters
%
%   o  wt : real unidimensional matrix [m,n]
%      Contains the wavelet transform (obtained with FWT2D).
%
%   o  f : real unidimensional matrix [m,n]
%      Synthesis filter.
%
%   1.2.  Output parameters
%
%   o  result : real matrix
%      Result of the reconstruction.
%
%   2.  See Also
%
%   FWT2D, MakeQMF, MakeCQF, WT2Dext, WT2DVisu

% Author Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------