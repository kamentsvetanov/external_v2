function [sscaled,mellin,beta] = Frac_dilate(s,a,fmin,fmax,N) ;
%   Dilation of a signal
%
%   Computes dilated/compressed version of a signal using Fast Mellin
%   transform.
%
%   1.  Usage
%
%   [sscaled,mellin,beta] = Frac_dilate(s,a,[fmin,fmax,N])
%
%   1.1.  Input parameters
%
%   o  s : real vector [1,nt] or [nt,1]
%      Time samples of the signal to be scaled.
%
%   o  a : real strictly positive vector [1,N_scale]
%      Dilation/compression factors. a < 1 corresponds to compression in
%      time
%
%   o  fmin : real scalar in [0,0.5]
%      Lower frequency bound of the signal (necessary for the intermediate
%      computation of the Mellin transform)
%
%   o  fmax :  real scalar [0,0.5] and fmax >
%      Upper frequency bound of the  signal (necessary for the
%      intermediate computation of the Mellin transform)
%
%   o  N : positive integer.
%      number of Mellin samples.
%
%   1.2.  Output parameters
%
%   o  sscaled : Real matrix with N_scale columns
%      Each column j (for j = 1 .. N_scale) contains the
%      dilated/compressed version of s by scale a(j). First element of
%      each column gives the effective time support for each scaled
%      version of s.
%
%   o  mellin : complex vector [1,N]
%      Mellin transform of s.
%
%   o  beta : real vector [1,N]
%      Variable of the Mellin transform mellin.
%
%   2.  See also:
%
%   dmt, idmt
%
%   3.  Examples
%
%   % Signal synthesis
%   x = Frac_morlet(0.1,32) ;
%   % Dilation by factors 0.6 , 1.2 and 1.8
%   [sscaled,mellin,beta] = Frac_dilate(x,[0.6 1.2 1.8],2^(-8),2^(-1),256) ;
%   [Npts,Nscales] = size(sscaled) ; Npts = Npts-1 ;
%   T = ones(Npts,Nscales).*NaN ;
%   for j = 1 : Nscales
%    supT = (sscaled(1,j)-1)/2 ;
%    T(1:2*supT+1,j) = (-supT:supT)' ;
%   end
%   subplot(211) ;
%   plot([-32:32],x) ; title('Original signal (a = 1)') ;
%   subplot(212)
%   plot(T,sscaled(2:Npts+1,:)) ;
%   legend('a = 0.6','a = 1.2','a = 1.8') ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

M = length(s) ;
if rem(M,2) == 0
  figh = findobj('Tag','Fig_gui_fl_dilate') ;
  if isempty(figh)
    disp('--- WARNING --- length of signal to be scaled must be a odd number')
    disp('                S zero-padded to the nearest odd length') ;
  elseif ~isempty(figh)
    fl_error('--- WARNING --- length of signal to be scaled must be a odd number. S zero-padded to the nearest odd length') ;
  end
  s = [s(:);0] ;
  M = M+1 ;
end
T = M-1;
if nargin == 2
  
  s = fftshift(s) ; STF = fft(s) ; s = fftshift(s);
  sp = (abs(STF(1:round(M/2)))).^2;
  f = linspace(0,0.5,round(M/2)+1) ; f = f(1:round(M/2));
    figure('Tag','graph_spectrum') ;
    freq_lim = [0.01 ; 0.5] ; % Initialization
    loglog(f,sp) ;  grid ;
    xlabel('frequency');
    title('Analyzed Signal Spectrum');
    while ~isempty(freq_lim) 
      
      fmin = min(freq_lim(:,1)) ;
      fmax = min(0.5,max(freq_lim(:,1))) ;
      B = fmax-fmin ; R = B/((fmin+fmax)/2) ;
      Nmin = (B*T*(1+2/R)*log((1+R/2)/(1-R/2)));
      str = ['Number of frequency samples [ N > ',num2str(ceil(Nmin)),' ]'] ;
      title(str) ;
      freq_lim = fracginput(2) ;
      
    end;
    
    N = 2^(ceil(log2(Nmin))) ;
    fenh = findobj('Tag','graph_spectrum') ;
    close(fenh) ;
end

[mellin,beta] = dmt(s,fmin,fmax,N) ;

for na = 1 : length(a)
  phase =  exp((-i*2*pi*beta+1/2)*log(a(na))) ;
  mellin_a = phase.*mellin ;
  nta = 2*round((a(na)*M-1)/2) + 1 ;
  sscaled(1,na) = nta ;
  sscaled(2:nta+1,na) = idmt(mellin_a,beta,nta) ;
end




