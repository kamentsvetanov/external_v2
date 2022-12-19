%   Replaces at each scale the left (resp. right) nodes of the diadic
%   tree, associated to the GIFS coefficients, that belong to [cmin,cmax]
%   by a ceratin unique value.
%
%   1.  Usage
%
%   [Ci_new, marks, L]=gifseg(Ci,[cmin,cmax,epsilon])
%
%   1.1.  Input parameters
%
%   o  Ci : Real matrix
%      Contains the GIFS coefficients (obtained using FWT)
%
%   o  cmin : Real scalar [1,n]
%      Specifies the minimal value of the Ci's to be considered (cmin=0 by
%      default)
%
%   o  cmax : Real scalar [1,n]
%      Specifies the maximal value of the Ci's to be considered (cmin=0 by
%      default)
%
%   o  epsilon :  real scalar
%      Specifies the maximal error desied on the Ci's approximation.
%
%   1.2.  Output parameters
%
%   o  Ci_new : Real matrix
%      Contains the the new GIFS coefficients.
%
%   o  marks : Real vector
%      Contains the segmentation marques. length(marks)-1 is the number of
%      segmented parts.
%
%   o  L : Real matrix
%      A structure containing the left and right lambda_i's corresponding
%      to each segmented part.
%
%   2.  See also:
%
%   hist, wave2gifs.
%
%   3.  Example:

% Auhtor Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------