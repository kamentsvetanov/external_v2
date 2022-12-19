function [x,y,z] = cihist(Ci,nbclas,cmax)
%   Plots the normalized histogram of GIFS coefficients (troncated if
%   desired) and the Gaussian distribution that fits at best the GIFS
%   coefficients one.
%
%   1.  Usage
%
%   [x,y,z] = cihist(Ci,[nbclass,cmax])
%
%   1.1.  Input parameters
%
%   o  Ci : Real matrix
%      Contains the GIFS coefficients (obtained using wave2gifs)
%
%   o  nbclass : Real scalar
%      Intger specifying the classes used in the samples values
%      subdivision (nbclass=100 by default)
%
%   o  cmax :  Real scalar
%      If specified, only the Ci's whose absolute values are samller the
%      cmax will be considered
%
%   1.2.  Output parameters
%
%   o  x : Real vector
%      Contains the bins centers
%
%   o  y : Real vector
%      Contains the the normalized number of Ci's elements in each
%      container
%
%   o  z : Real vector
%      Contains the the normalized number of Gaussian's elements in each
%      container
%
%   2.  See also:
%
%   hist, wave2gifs.
%
%   3.  Example:

% Auhtor Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

C=Ci;
if nargin == 1
	nbclas = 100;
end 
if nargin == 3
	I=find(abs(Ci)<cmax) ;
	C = Ci(I) ;
end

N=length(C);
moy=mean(C);
var=sum((C-moy).^2)./(N-1);
[n,x]=hist(C,nbclas);
y=n./(sum(n)*(x(2)-x(1)));
Gauss=exp(-((x-moy).^2)./(2*var))./sqrt((2*pi*var));
z=Gauss./(sum(Gauss)*(x(2)-x(1)));
bar(x,y);
hold on;
plot(x,z,'W-');
hold off;
%keyboard ;

