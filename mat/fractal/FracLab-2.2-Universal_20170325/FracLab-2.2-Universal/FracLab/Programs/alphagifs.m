%   Holder function estimation using IFS
%   Estimates the pointwise Holder exponents of a 1-D real signal using
%   the GIFS method.
%
%   1.  Usage
%
%   [Alpha, Ci]=alphagifs(sig, limtype)
%
%   1.1.  Input parameters
%
%   o  sig : Real vector [1,n] or [n,1]
%      Contains the signal to be analysed.
%
%   o  limtype : Character string
%      Specifies the type of limit you want to use. You have the choice
%      between "slope" and "cesaro".
%
%   1.2.  Output parameters
%
%   o  Alpha : Real vector
%      Contains the estimated Holder function of the signal.
%
%   o  Ci : Real matrix
%      Contains the GIFS coefficients obtained using the Schauder basis.
%
%   2.  See also:
%
%   gifs and prescalpha
%
%   3.  Example:
%
%    Synthesis of an fbm with exponent H=0.7 (of size 1024 samples) :
%
%   x = fmblevinson(1024,0.7) ;
%
%    Estimation of The Holder function :
%
%   Alpha = alphagifs(x,'slope');
%   plot(Alpha)

%   Author Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------