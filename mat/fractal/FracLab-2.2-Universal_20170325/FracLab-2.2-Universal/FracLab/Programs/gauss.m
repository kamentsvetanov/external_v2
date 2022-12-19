function g = gauss(n,a,k)
%   Gaussian window
%
%   Returns a Gaussian window
%
%   1.  Usage
%
%   ______________________________________________________________________
%   Win = gauss(N[,A])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  N :  Positive integer
%      Number of points defining the time support of the window
%
%   o  A : Real positive scalar
%      Attenuation in dB at the end of the window (10^(-A)). Default value
%      is A = 2.
%
%   1.2.  Output parameters
%
%   o  Win : real vector [1,N]
%      Gaussian window in time.
%
%   2.  See also:
%
%   mexhat, Frac_morlet
%
%   3.  Examples
%
%   % Gaussian windows synthesis
%   t = linspace(-1,1,128) ;
%   ExpDecay = logspace(log10(0.1),log10(100),10)
%   Win = [] ;
%   for s = ExpDecay
%     Win = [Win gauss(128,s)'] ;
%   end
%   % Vizualisation - Matlab
%   StD = sqrt((2*ExpDecay*log(10)).^(-1)) ;
%   plot(t,Win) ; title('Gaussian windows with different Standard Deviations')
%   legend(num2str(StD(:)))
%
%   ______________________________________________________________________
%   t = linspace(-1,1,128) ;
%   Win1 = gauss(128,2) ;
%   Win2 = gauss(128,5) ;
%   ______________________________________________________________________
%
%    Vizualisation - Matlab
%
%   ______________________________________________________________________
%   plot(t,win1,'b',t,win2,'r') ;
%   legend('Gaussian window 1','Gaussian window 2')
%   ______________________________________________________________________
%
%    Vizualisation - Scilab
%
%   ______________________________________________________________________
%   plot2d([t(:) t(:)],[Win1(:) Win2(:)],[17 19])

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin == 1
  a = 2 ;
  k = 0 ;
end

if nargin == 2
  k = 0 ;
end

t=-(n-1)/2:(n-1)/2;
c=(a*log(10)/((n-1)/2)^2);
if k==0
  g =exp(-c*t.^2);
else
  g = polyval(polyGauss(k,c),t).* exp(-c*t.^2);
end

function p=polyGauss(k,c)

if k==1
  p=[-2*c,0];
  return;
end

p=[0,0,polyder(polyGauss(k-1,c))]-2*c*[polyGauss(k-1,c),0];




