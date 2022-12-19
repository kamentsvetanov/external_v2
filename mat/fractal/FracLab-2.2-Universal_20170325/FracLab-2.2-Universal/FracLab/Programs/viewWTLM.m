function viewWTLM(maxmap,scale,wt) ;
%   Vizualises the local maxima lines of a CWT
%
%   Displays the local maxima of a continuous wavelet transform
%
%   1.  Usage
%
%   ______________________________________________________________________
%   viewWTLM(maxmap[,scale,wt])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  maxmap : 0/1 matrix  [N_scale,N]
%      Indicator matrix of the local wavelet coefficients maxima
%
%   o  scale : real vector  [1,N_scale]
%      Analyzed scale vector
%
%   o  wt : Complex matrix  [N_scale,N]
%      Wavelet coefficients of a continuous wavelet transform (output of
%      FWT or contwt)
%
%   2.  See also:
%
%   findWTLM, viewmat, contwt, cwt1D
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

[y,x] = find(maxmap) ;

if exist('scale') == 1
  logscale = log2(scale(y)) ;
else
  logscale = 1:size(maxmap,1) ;
end
if exist('wt') == 1
  viewmat(abs(wt),1:size(wt,2),log2(scale),[1 1 24]) ; hold on ;
end

plot(x,logscale,'.k','MarkerSize',8) ; hold off ;
