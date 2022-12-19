function [u,s,x,y] = flt(x,y,ccv) ;
%   Fast Legendre transform
%
%   Computes the Legendre transform of y  y^*(s) = sup_{x in X}[s.x -
%   y(x)]
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [u,s] = flt(x,y[,ccv])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  x : real valued vector [1,N]
%      samples support of the function y
%
%   o  y :  real valued vector [1,N]
%      samples of function y = y(x)
%
%   o  ccv : optional argument to choose between convex (ccv = 0) and
%      concave (ccv = 1) envelope.  Default value is ccv = 1 (concave)
%
%   1.2.  Output parameters
%
%   o  u : real valued vector [1,M]
%      transform of input y. Note that, since u stems from the envelope of
%      y, in general M <= N.
%
%   o  s : real valued vector [1,M]
%      Variable of the Legendre transform of y.
%
%   2.  See also:
%
%   3.  Examples
%
%   % Partition function synthesis (corresponding to binomial measures)
%     m0 = .55 ; m1 = 1 - m0 ;
%     m2 = .95 ; m3 = 1 - m2 ;
%     q = linspace(-20,20,201) ;
%     tau1 = - log2(exp(q.*log(m0)) + exp(q.*log(m1))) ;
%     tau2 = - log2(exp(q.*log(m2)) + exp(q.*log(m3))) ;
%     tau3 = min(tau1 , tau2) ;
%   % Legendre Transforms (yielding to Legendre spectra)
%     [u1,s1] = flt(q,tau1) ;
%     [u2,s2] = flt(q,tau2) ;
%     [u3,s3] = flt(q,tau3) ;
%   % Vizualisation
%     clf ,
%     subplot(211)
%     plot(q,tau1,'g',q,tau2,'b',q,tau3,'--r') ; grid ;
%     title('Partition functions') , xlabel('q') , ylabel('\tau(q)')
%     legend('\tau_1(q)','\tau_2(q)','\tau_3(q)') ;
%     subplot(212)
%     plot(s1,u1,'g',s2,u2,'b',s3,u3,'--r') ; grid ;
%     title('Legendre transforms of the Partition functions')
%     xlabel('\alpha') , ylabel('\tau^*(\alpha)')
%     legend('\tau_1^*(\alpha)','\tau_2^*(\alpha)','\tau_3^*(\alpha)') ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[x,I] = sort(x) ;
y = y(I) ;
x0 = x ; y0 = y ;

if exist('ccv') == 0
  ccv = 1 ;            % ccv = 1 : CONCAVE
end
y = (-2*ccv+1)*y ;

Pdiff = -1 ;
while ~all(Pdiff >= 0)
  P = [] ; O = [] ;
  Nx = length(x) ;
  for i = 1:Nx-1
    p = polyfit([x(i+1) x(i)],[y(i+1) y(i)],1) ; 
    P(i) = p(1) ;
    O(i) = p(2) ;
  end,
  Pdiff = diff(P) ;
  II = find(Pdiff >= 0) ;
  x = x([1 II+1 Nx]) ;
  y = y([1 II+1 Nx]) ;
end
y = (1 - 2*ccv)*y ;
u = (2*ccv - 1)*O ;
s = (1 - 2*ccv)*P ;








