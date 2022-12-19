function     [mellin,beta] = dmt(s,fmin,fmax,N);
%   Discrete Mellin transform of a vector
%
%   Computes the Fast Mellin transform of a signal.
%
%   1.  Usage
%
%   [mellin,beta] = dmt(s,[fmin,fmax,N])
%
%   1.1.  Input parameters
%
%   o  s : real vector [1,nt] or [nt,1]
%      Time samples of the signal to be transformed.
%
%   o  fmin : real scalar in [0,0.5]
%      Lower frequency bound of the signal
%
%   o  fmax :  real scalar [0,0.5] and fmax >
%      Upper frequency bound of the  signal
%
%   o  N : positive integer.
%      number of Mellin samples.
%
%   1.2.  Output parameters
%
%   o  mellin : complex vector [1,N]
%      Mellin transform of s.
%
%   o  beta : real vector [1,N]
%      Variable of the Mellin transform mellin.
%
%   2.  See also:
%
%   idmt, Frac_dilate
%
%   3.  Examples
%
%   % Signal synthesis
%   x = Frac_morlet(0.1,32) ;
%   % Computation of the Mellin transform
%   [mellin,beta] = dmt(x,0.01,0.5,128) ;
%   subplot(211) ;
%   plot(x) ; title('Signal un time') ; xlabel('time')
%   subplot(212)
%   plot(beta,abs(mellin))
%   title('Mellin Spectrum'), xlabel('\beta') ;

%	     [mellin,beta] = dmt(s,fmin,fmax,N) computes the Fast 
%		Fourier-Mellin Transform of signal S.
%
% Input:     -s signal in time 
%            -[fmin],[fmax] respectively lower and upper frequency bounds of
%             the analyzed signal. When specified, these parameters fix the
%             equivalent frequency bandwidth (both are expressed in
%             cycles/sec).
%            -[N] number of Mellin points. This number is needed when FMIN
%             and FMAX are forced.
%
%
% Output:    -MELLIN the N-points Fourier-Mellin transform of signal S
%            -[BETA] the N-points Mellin variable
%
% Example:   S = amaltes(128,0.05,0.45) ;
%            [MELLIN,BETA] = dmt(S,0.05,0.5,128) ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[ys,xs]=size(s) ; 
if ys>xs , s = s.' ; else, end;
M = length(s);
Tmin = 1;
Tmax = M;
T = Tmax-Tmin;
if nargin==1 			% fmin,fmax,N unspecified
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
    
elseif nargin==4 

  B = fmax-fmin ; R = B/((fmin+fmax)/2) ; 

end
if fmax ~= 0.5 
  figh = findobj('Tag','Fig_gui_fl') ;
  if isempty(figh)
    disp('--- WARNING --- Inverse Mellin transform requires that fmax = 1/2')
  elseif ~isempty(figh)
    fl_error('--- WARNING --- Inverse Mellin transform requires that fmax = 1/2')
  end
end

% Geometric sampling of the analyzed spectrum

k = 1:N/2;
q = (fmax/fmin)^(1/(N/2-1)) ;

t = [0:M-1]; 

flog(k) = fmin*(exp((k-1).*log(q))) ; 

tfmatx = zeros(M,N/2);
tfmatx = exp(-2*i*(t(1:M))'*flog*pi);
S = s*tfmatx ; 
S(N/2+1:N) = zeros(1,N/2);
 
% Mellin transform computation of the analyzed signal

mellin = fftshift(ifft(S)).';
k = 1:N ;
beta(k) = -1/(2*log(q))+(k-1)./(N*log(q));
beta = beta(:) ;





