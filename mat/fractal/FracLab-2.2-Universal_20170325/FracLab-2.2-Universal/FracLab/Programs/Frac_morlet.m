function  [h,alpha] = Frac_morlet(nu,N,analytic) ;
%   Morlet wavelet
%
%   Computes a Morlet wavelet.
%
%   1.  Usage
%
%   [wavelet,alpha] = Frac_morlet(nu,[N,analytic])
%
%   1.1.  Input parameters
%
%   o  nu :  real scalar between 0 and 1/2
%      Central (reduced) frequency of the wavelet
%
%   o  N : Positive integer
%      Half length of the wavelet transform. Default value corresponds to
%      a total length of 4.5 periods.
%
%   o  analytic : boolean (0/1) under Matalb or (%F/%T) under Scilab.
%      0 or %F : real Morlet wavelet
%      1 or %T : analytic Morlet wavelet
%
%   1.2.  Output parameters
%
%   o  wavelet : real or complex vector [1,2*N+1]
%      Morlet wavelet in time.
%
%   o  alpha : real scalar
%      Attenuation exponent of the Gaussian enveloppe of the Morlet
%      wavelet.
%
%   2.  See also:
%
%   mexhat, contwt
%
%   3.  Examples
%
%   % wavelet synthesis
%   x1 = Frac_morlet(0.1,128) ;
%   clf
%   plot(-128:128,x1) ;
%   title('a Morlet Wavelet')
%   xlabel ('time') ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narg = nargin ;
if narg ==1 
  n_periods = 2.25 ;
  N = ceil(n_periods * nu.^(-1)) ;
  narg = 2 ;
end
if narg == 2
  analytic = 0;
end

tol = 1e-3 ;
alpha = -log(tol)/N^2 ;

t = -N:N ;
h = sqrt(sqrt(2*alpha/pi))*exp(-alpha*t.^2).*exp(-i*2*pi*t*nu) ;
if ~analytic
  h = sqrt(2).*real(h) ;
end





