%   Computation of IFS coef. with Discrete Wavelet coefficients
%
%   Computes the GIFS cefficients of a 1-D real signal as the ratio
%   between (synchrounous) wavelets coefficients at successive scales. You
%   have to compute the wavelet coefficients of the given signal (using
%   FWT) before using wave2gifs.
%
%   1.  Usage
%
%   [Ci, Ci_idx, Ci_lg, pc0, pc_ab]=wave2gifs(wt, wt_idx, wt_lg, [M0, a,
%   b])
%
%   1.1.  Input parameters
%
%   o  wt : Real matrix [1,n]
%      Contains the wavelet coefficients (obtained using FWT).
%
%   o  wt_idx : Real matrix [1,n]
%      Contains the indexes (in wt) of the projection of the signal on the
%      multiresolution subspaces (obtained also using FWT).
%
%   o  wt_lg : Real matrix [1,n]
%      Contains the dimension of each projection (obtained also using
%      FWT).
%
%   o  M0 :  Real positive scalar
%      If specified, each GIFS coefficient whose absolute value belong to
%      ]1,M0[ will be replaced by 0.99 (keeping its signe).
%
%   o  a,b : Real positive scalars
%      The routine gives the percentage of the Ci's whose absolute value
%      belong to ]a,b[ (if not specified, ]a,b[=]0,2[).
%
%   1.2.  Output parameters
%
%   o  Ci : Real matrix
%      Contains the GIFS coefficients plus other informations.
%
%   o  Ci_idx : Real matrix
%      Contains the the indexes of the first Ci at each scale (the finest
%      scale is 1).
%
%   o  Ci_lg : Real matrix
%      Contains the length of Ci's at each scale.
%
%   o  pc0 : Real scalar
%      Gives the percentage of vanishing Ci's
%
%   o  pc_ab : Real scalar
%      Gives the percentage of Ci's which belong to ]a,b[
%
%   2.  See also:
%
%   FWT and MakeQMF.
%
%   3.  Example:

% Auhtor Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------