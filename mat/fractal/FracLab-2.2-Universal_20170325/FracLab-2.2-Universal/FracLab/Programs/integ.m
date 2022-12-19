function som = integ(y,x) 
%   Approximate 1-D integral
%
%   Approximate 1-D integral. integ(y,x) approximates the integral of y
%   with respect to the variable x
%
%   1.  Usage
%
%   ______________________________________________________________________
%   SOM = integ(y[,x])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  y : real valued vector or matrix [ry,cy]
%      Vector or matrix to be integrated. For matrices, integ(Y) computes
%      the integral of each column of Y
%
%   o  x :  row-vector [ry,1]
%      Integration path of y. Default value is (1:cy)
%
%   1.2.  Output parameters
%
%   o  SOM : real valued vector [1,cy]
%      sum approximating the integral of y w.r.t the integration path x
%
%   2.  See also:
%
%   integ2d
%
%   3.  Examples
%
%   % Synthesis of a Normal p.d.f.
%     clf,
%     sigma = 1 ; N = 100 ;
%     x = logspace(log10(1e-4),log10(4),N/2) ;
%     x = [ -fliplr(x) x ] ;
%     y = 1/sqrt(2*pi) * exp( -(x.^2)./2 ) ;
%     subplot(211)
%     plot(x,y) , grid
%     title('Normal Probability Density Function f(x)')
%   % Calculus of the distribution function by integration of the p.d.f.
%     for n = 1:N
%       PartialSom(n) = integ( y(1:n),x(1:n) ) ;
%     end
%     subplot(212)
%     plot(x,PartialSom,x,PartialSom,'+r') , grid ,
%     title('Normal Distribution function : \int_{-\infty}^{x} f(u) du')

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if size(y,1) == 1 ;
  y = y(:) ;
end
[my,ny] = size(y) ;

if nargin == 1 
  x = (1:my) ;
end

if length(x) ~= my
  error('X and Y must have same size')
end
x = x(:).' ;

dy = y(1:my-1,:) + y(2:my,:) ;
dx = (x(2:my)-x(1:my-1))/2 ;
som = dx*dy ;




