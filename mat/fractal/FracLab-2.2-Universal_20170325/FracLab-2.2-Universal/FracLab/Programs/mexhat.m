function  [h,alpha] = mexhat(nu) ;
%   Mexican hat wavelet
%
%   Computes a Mexican Hat wavelet (seconde derivative of the gaussian).
%
%   1.  Usage
%
%   [wavelet,alpha] = mexhat(nu)
%
%   1.1.  Input parameters
%
%   o  nu :  real scalar between 0 and 1/2
%      Central (reduced) frequency of the wavelet.
%
%   1.2.  Output parameters
%
%   o  wavelet : real vector [1,2*N+1]
%      Mexican Hat wavelet in time.
%
%   o  alpha : real scalar
%      Attenuation exponent of the Gaussian enveloppe of the Mexican Hat
%      wavelet.
%
%   2.  See also:
%
%   Frac_morlet, contwt
%
%   3.  Examples
%
%   % wavelet synthesis
%   wavelet = mexhat(0.1) ;
%   N = length(wavelet) ;
%   clf
%   plot(-(N-1)/2:(N-1)/2,wavelet) ;
%   title('a Mexican hat Wavelet')
%   xlabel ('time') ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N = 1.5 ;
alpha = pi^2*nu^2 ;
n = ceil(N/nu) ; 
t = -n:n ;
h = sqrt(sqrt(32*alpha/pi)/3)*exp(-alpha*t.^2);%.*(1-2*alpha*t.^2) ;
h=h.*(1-2*alpha*t.^2) ; 










