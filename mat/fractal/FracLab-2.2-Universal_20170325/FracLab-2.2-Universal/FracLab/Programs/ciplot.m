function pc = ciplot(Ci,j1,j2,cmax)
%   Plots the GIFS coefficients (troncated if desired) at different
%   scales.
%
%   1.  Usage
%
%   pc=ciplot(Ci,[M0,j1,j2,cmax])
%
%   1.1.  Input parameters
%
%   o  Ci : Real matrix
%      Contains the GIFS coefficients (obtained using wave2gifs)
%
%   o  j1 : Real scalar
%      Intger specifying the first scale you want in the plot (the finnest
%      scale is 1).  It must belong to {1,...,log2(lenght(signal))}
%
%   o  j1 : Real scalar
%      Intger specifying the last scale you want in the plot (the finnest
%      scale is 1).  It must belong to {1,...,log2(lenght(signal))}
%
%   o  cmax :  Real scalar
%      If specified, all the Ci's whose absolute value belong is greater
%      the cmax will be replaced by cmax (keeping their signe) in the
%      plot.
%
%   1.2.  Output parameters
%
%   o  pc : Real scalar
%      Percentage of clipped Ci's
%
%   2.  See also:
%
%   plot, wave2gifs.
%
%   3.  Example:

% Auhtor Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N = length(Ci) ;
J = Ci(N) ;
j0 = Ci(N-1)-1 ;
if  nargin == 1
	j1 = 1 ;
	j2 = j0 ;
end	
if  nargin == 2
	j2 = j0 ;
end

J1 = min(J-j1,J-j2) ;
J2 = max(J-j1,J-j2) ;
couleurs = 'ymcrgbk';
i = 1 ;
if nargin == 4
for j=J1:J2,
	p = 2^j;
	t=(1:2^(J2-j):2^J2);
	Ci_j = Ci(p-1:2*p-2) ;
	[C,pc] = clip(Ci_j,cmax) ;
	if i > 7
		i = 1 ;
	end 
	plot(t,C,couleurs(i))
	hold on
	i = i+1 ;
end
hold off
end

if nargin < 4
for j=J1:J2,
	p = 2^j;
	t=(1:2^(J2-j):2^J2);  
	Ci_j = Ci(p-1:2*p-2) ;
	if i > 7
		i = 1 ;
	end 
	plot(t,Ci_j,couleurs(i))
	hold on
	i = i+1 ;
end
hold off
pc = 0;
end
	
