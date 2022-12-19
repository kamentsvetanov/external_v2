function [x,Fj,Fs] = oscillsing(alpha,beta,sing_pos,N,show) ;
%   Oscillating Singularity synthesis
%
%   Generates oscillating singularities located in the interval [0 .. 1]
%
%   1.  Usage
%
%   [x,Fj,Fs] = oscillsing(alpha,beta,sing_pos,N,show) ;
%
%   1.1.  Input parameters
%
%   o   alpha  : Real positive vector [1,n_sing] or [n_sing,1]
%      Holder strenghts of the singularities
%
%   o   beta  : Real positive vector [1,n_sing] or [n_sing,1]
%      Chirp exponents of the singularities
%
%   o   sing_pos  : Real vector [1,n_sing] or [n_sing,1]
%      Location of the singularities in the interval  [0 .. 1]
%
%   o   N  : Integer
%      Sample size for the synthesized signal
%
%   o   show  : flag 0/1
%       flag  = 0 : no display
%       flag  = 1 : displays the instantaneous frequencies and the
%      synthesized signal
%
%   1.2.  Output parameters
%
%   o   x  : real vector  [1,N]
%      Time samples of the synthesized signal
%
%   o   Fj  : real matrix [N,n_sing]
%      instantaneous frequencies (each column of Fj contains the frequency
%      chirp of each singularity)
%
%   o   Fs  : real
%      sampling frequency
%
%   2.  See also:
%
%   3.  Example:
%
%   4.  Examples
%
%   % Synthesis of a signal with three oscillating singularity
%   % o Holder regularities : a1 = 0.5 ; a2 = 1 ; a3 = 2 ;
%   % o Chirp rates : b1 = -1 ; b2 = -2 ; b3 = -4 ;
%   % o Locations : t1 = -0.5 ; t2 = 0 ; t3 = 0.5 ;
%   % o signal length : N = 256
%
%   [x,Fj,Fs] = oscillsing([1/2 1 2],[1 2 4],[-0.5 0 0.5],256,1) ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

nsing = length(alpha) ;

if ~all(sing_pos <= 1) | ~all(sing_pos >= -1)
  error('sing_pos must be in the interval [-1,1]') ;
end
x = zeros(1,N) ;
Fj = zeros(N,nsing) ;
t = linspace(-1,1,N) ;
Fs = N/2 ;
for j = 1:nsing
  xj = (abs(t-sing_pos(j)).^alpha(j)).*sin(2*pi*abs(t-sing_pos(j)).^(-beta(j))) ;
  f = beta(j).*abs(t-sing_pos(j)).^(-beta(j)-1) ;
  Fj(:,j) = f(:) ;
  x = x + xj ;
end

if exist('show')

  if show == 1

    clf ,
    subplot(211) ; semilogy(t,Fj,t,Fj,'+',t,Fs*ones(1,N)) ; grid
    title('log(Instantaneous frequency)') ;
    subplot(212) ; plot(t,x) 
    title('signal')

  end

end







