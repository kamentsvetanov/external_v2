%   Computes the wavelet cefficients of  the synthetic 1-D real signal
%   from its new GIFS coefficients.
%
%   1.  Usage
%
%   [wt_new]=gifs2wave(Ci_new,wt,wt_idx,wt_lg)
%
%   1.1.  Input parameters
%
%   o  Ci_new : Real matrix
%      Contains the new GIFS coefficients
%
%   o  wt : Real matrix
%      contains the wavelet coefficients (obtained using FWT)
%
%   o  wt_idx : Real matrix [1,n]
%      contains the indexes (in wt) of the projection of the signal on the
%      multiresolution subspaces
%
%   o  wt_lg : Real matrix [1,n]
%      contains the dimension of each projection
%
%   1.2.  Output parameters
%
%   o  wi_new : Real matrix
%      Contains the new wavelet coefficients plus other informations.
%
%   2.  See also:
%
%   wave2gifs.
%
%   3.  Example:

% Auhtor Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------