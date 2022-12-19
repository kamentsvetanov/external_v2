function [x,t] = idmt(y,beta,M);
%   Inverse Discrete Mellin transform
%
%   Computes the Inverse Fast Fourier-Mellin transform of a signal.
%
%   1.  Usage
%
%   [x,t] = idmt(mellin,beta,[M])
%
%   1.1.  Input parameters
%
%   o  mellin :  complex vector [1,N]
%      Fourier-Mellin transform to be inverted. For a correct inversion of
%      the Fourier-Mellin transform, the direct Fourier-Mellin transform
%      mellin must have been computed from fmin to 0.5 cycles per sec.
%
%   o  beta : real vector [1,N]
%      Variable of the Mellin transform mellin.
%
%   o  M : positive integer.
%      Number of time samples to be recovered from mellin.
%
%   1.2.  Output parameters
%
%   o  x : complex vector [1,M]
%      Inverse Fourier-Mellin transform of mellin.
%
%   o  t : time variable of the Inverse Fourier-Mellin transform x.
%
%   2.  See also:
%
%   dmt, Frac_dilate
%
%   3.  Examples
%
%   % Signal synthesis
%   x = Frac_morlet(0.1,32) ;
%   % Computation of the Mellin transform
%   [mellin,beta] = dmt(x,0.01,0.5,128) ;
%   [y,t] = idmt(mellin,beta,65) ;
%   subplot(211) ;
%   plot(t,x,t,y) ; title('Signals in time') ; xlabel('time')
%   legend('Original','Inverse Mellin transformed') ;
%   subplot(212)
%   plot(beta,abs(mellin))
%   title('Mellin Spectrum'), xlabel('\beta') ;

% IDMT       [x,t] = idmt(y,beta,M) computes the inverse fast 
%		Fourier-Mellin transform of signal y.
%            !!! WARNING : the inverse F-Mellin of the F-Mellin transform y 
%			   is correct only if the direct F-Mellin transform 
%                          has been computed from FMIN to 0.5 cycles/sec.
%
% Input:     -y  F-Mellin transform to be inverted. Mellin must have
%             been obtained from DMT with frequency running from FMIN
%             to 0.5
%            -beta  Mellin variable issued from DMT
%            -[M] number of point of the inverse Mellin transform. Its
%             default value is the length of Mellin
%
% Output:    -x inverse Mellin transform with M points in time
%            -[t] time vector with M points.
%
% Example:   S = amaltes(128,0.1,0.4) ; 
%            [MELLIN,BETA] = dmt(S,0.05,0.5,256) ;
%            [X,T] = idmt(MELLIN,BETA,128) ; plot(T,X) ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[yy,xy]=size(y) ; 
if yy>xy , y = y.' ; else, end;
N = length(y) ;
if nargin==2
  M = N ;
end
q = exp(1/(N*(beta(2)-beta(1)))) ;
fmin = 0.5/(q^(N/2-1)) ;

k = 1:N/2 ;
geo_f(k) = fmin*(exp((k-1).*log(q))) ;
itfmatx=[];

itfmatx = exp(2*i*(0:M-1)'*geo_f(1:N/2)*pi);

t = [0:M-1] ;   	

% Inverse Mellin transform computation 

S = fft(fftshift(y)) ;  S=S(1:N/2) ;  
for kk=1:M
   x(kk)=real(2*integ(itfmatx(kk,:).*S,geo_f)) ;
end;

x = x(:) ;






