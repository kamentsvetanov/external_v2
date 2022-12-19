%   This routine computes holder exponents of a measures defined on 2D
%   real signal. Several measures and capacities are available.
%
%   1.  Usage
%
%   [holder]=holder2d(Input,[Meas],[Res],[Ref],[RefMeas])
%
%   1.1.  Input parameters
%
%   o  Input : real matrix [m,n]
%      Contains the signal to be analysed.
%
%   o  Meas : string
%      Analysing measure. Must choosen be in
%      {"sum", "var", "ecart", "min", "max", "iso", "riso",
%      "asym", "aplat", "contrast", "lognorm", "varlog", "rho",
%      "pow", "logpow", "frontmax", "frontmin", "diffh", "diffv",
%      "diffmin", "diffmax"}
%      (default : "sum")
%
%   o  res : Number of resolutions used for the computation. (default : 1)
%
%   o  Ref : real matrix [m,n]
%      Contains the reference signal i.e. the signal on which the
%      reference measure will be computed.
%      Input and Ref must have the same dimensions.
%
%   o  RefMeas : string
%      Reference measure. (default : "sum")
%
%   1.2.  Output parameters
%
%   o  holder : real matrix [m,n]
%      Contains the Holder exponents.
%
%   2.  See Also

% Author Pascal Mignot & Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------