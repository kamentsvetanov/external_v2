function [maxmap] = findWTLM(wt,scale,depth)
%   Finds local maxima lines of a CWT
%
%   Finds the local maxima of a continuous wavelet transform
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [maxmap] = findWTLM(wt,scale[,depth])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  wt : Complex matrix  [N_scale,N]
%      Wavelet coefficients of a continuous wavelet transform (output of
%      FWT or contwt)
%
%   o  scale : real vector  [1,N_scale]
%      Analyzed scale vector
%
%   o  depth : real in [0,1]
%      maximum relative depth for the peaks search.  Default value is 1
%      (all peaks found)
%
%   1.2.  Output parameters
%
%   o  maxmap : 0/1 matrix  [N_scale,N]
%      If maxmap(m,n) = 0 : the coefficient wt(m,n) is not a local maximum
%      If maxmap(m,n) = 1 : the coefficient wt(m,n) is a local maximum
%
%   2.  See also:
%
%   contwt, cwt1D
%
%   3.  Examples
%
%   % signal synthesis
%   N = 256 ; H = 0.7 ;
%   [x] = fbmlevinson(N,H) ;
%   % Continuous Wavelet transform (L2 normalization)
%   wt = contwt(x,[2^(-6),2^(-1)],64,'morleta',12) ;
%   % Finding the local maxima lines of the wavelet transform
%   [maxmap] = findWTLM(wt.coeff,wt.scale) ;
%   % Vizualisation
%   viewWTLM(maxmap,scale,wt)
%   title('Wavelet coefficients and maxima lines')
%   xlabel('time') , ylablel('scale')

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin == 2
  depth = 1 ;
elseif nargin == 3
  depth = min(1,depth) ;
end

n = size(wt,2) ;
s = size(wt,1) ;

maxmap = zeros(s,n) ;

x = 1:n ;
xplus = [x(2:n) x(1)] ; 
xminus = [x(n) x(1:n-1)] ;

wt = abs(wt) ;
% wt = real(wt) ;

for k = 1:s
  maxdepth = (1-depth) * max(wt(k,:)) ;
  maxmap(k,x) = wt(k,x) > wt(k,xminus) & wt(k,x) > wt(k,xplus) & wt(k,x) >= maxdepth ;
end






