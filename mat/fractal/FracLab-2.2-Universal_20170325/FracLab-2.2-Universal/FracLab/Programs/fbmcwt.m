function [x] = fbmcwt(N,H,fmin,fmax,nvoices,wl_length,randseed) ;
%   Continuous wavelet based synthesis of a fBm
%
%   Generates a 1/f Gaussian process from a continuous wavelet transform
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [x] = fbmcwt(N,H,[fmin,fmax,nvoices,wl_length,randseed]) ;
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o   N  : Positive integer
%      Sample size of the fBm
%
%   o   H  : Real in [0,1]
%      Holder exponent
%
%   o   fmin  : real in ]0,0.5[
%      Lower frequency bound for synthesis
%
%   o   fmax  : real in ]0,0.5]
%      Upper frequency bound for synthesis (fmax > fmin)
%
%   o   nvoices  : integer
%      Number of synthesized voices between  fmin  and  fmax
%
%   o   wl_length  : integer
%       wl_length  > 0 : real Morlet of length  2*wl_length+1  at fmax
%       wl_length  = 0 : real mexican hat wavelet
%
%   o   seed  : real scalar
%      Random seed generator
%
%   1.2.  Output parameters
%
%   o   x  : real vector  [1,N]
%      Time samples of the 1/f Gaussian process
%
%   2.  See also:
%
%   fbmfwt, fbmlevinson
%
%   3.  Examples
%
%   % Continuous Wavelet synthesis of a 1/f process
%     N = 1024 ; H = 0.8 ;
%     Smin = 2^(-8) ; Smax = 2^(-1) ; Nscale = 128 ; WaveLength = 8 ;
%     t = linspace(0,1,N) ;
%     [x] = fbmcwt(N,H,Smin,Smax,Nscale,WaveLength) ;
%     clf ;
%     plot(t,x) ; title ('Wavelet based 1/f process')
%     xlabel ('time')
%   % Regularized Dimension Estimation
%     [dim,H] = regdim(x,0,128,10,500,'gauss',0,1,1);
%
%   ______________________________________________________________________
%
%   [x] = fbmcwt(1024,0.8,2^(-8),2^(-1),64,8) ;
%   [wt,scale,f] = contwt(x,2^(-8),2^(-1),64,8) ;
%   [HofT] = cwttrack(wt,scale,0,1,1,8,1,1) ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch nargin
  
  case 2
    
    fmin = 2^(-round(log2(N))) ;
    fmax = 2^(-1) ;
    nvoices = 4 * round(log2(N)) ;
    wl_length = 8 ;
    
  case 3
    
    fmax = 2^(-1) ;
    nvoices = 4 * round(log2(N)) ;
    wl_length = 8 ;
    
  case 4
    
    nvoices = 4 * round(log2(N)) ;
    wl_length = 8 ;
    
  case 5
    
    wl_length = 8 ;
         
end

if exist('randseed') ;
  
  randn('seed',randseed) ;
  
end

xinit = randn(1,N) ;

[wtxinit,scale,freq] = contwt(xinit,fmin,fmax,nvoices,wl_length) ;

weigth = exp((H + 1/2) * log(freq./freq(nvoices))) ;
weigth = weigth(ones(1,N),:)' ;

wtx = wtxinit ./ weigth ;

[x] = icontwt(wtx,freq,wl_length) ;

x = x(:) ;
