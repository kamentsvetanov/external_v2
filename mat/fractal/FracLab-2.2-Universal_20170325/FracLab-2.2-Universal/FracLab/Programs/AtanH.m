function Ht=AtanH(N,h1,h2,shape);
%   Arctangent variation
%
%   Generates an arc-tangent trajectory
%
%   1.  Usage
%
%   ______________________________________________________________________
%   Ht=AtanH(N,h1,h2,shape);
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o   N  : Positive integer
%      Sample size of the trajectory
%
%   o   h1  : Real scalar
%      First value of the arc-tangent trajectory
%
%   o   h2  : Real scalar
%      Last value of the arc-tangent trajectory
%
%   o   shape  : real in [0,1]
%      smoothness of the trajectory
%      shape = 0 : constant piecewise (step function)
%      shape = 1 : linear
%
%   1.2.  Output parameters
%
%   o   Ht  : real vector  [1,N]
%      Time samples of the arc-tangent trajectory
%
%   2.  See also:
%
%   3.  Examples
%
%   % Synthesis of the Holder function H(t): 0 < t < 1
%   % variation between H(0) = 0 and H(1) = 1
%     N = 256 ; H0 = 0 ; H1 = 1 ;
%     t = linspace(0,1,N) ;
%     clf ;
%   % Constant piecewise function
%     SmoothParam = 0 ;
%     H = AtanH(N,H0,H1,SmoothParam) ;
%     [x] = GeneWei(N,H,1.2,1,0) ;
%     subplot(2,2,1)
%     plot(t,H) ;
%     title ('Holder trajectory (constant piecewise)')
%     subplot(2,2,3)
%     plot(t,x) ;
%     title ('Generalized Weierstrass function')
%     xlabel('time') ;
%   % Linear function
%     SmoothParam = 1 ;
%     H = AtanH(N,H0,H1,SmoothParam) ;
%     [x] = GeneWei(N,H,1.2,1,0) ;
%     subplot(2,2,2) ;
%     plot(t,H) ;
%     title ('Holder trajectory (linear)')
%     subplot(2,2,4)
%     plot(t,x) ;
%     title ('Generalized Weierstrass function')
%     xlabel('time') ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
	
if (shape<0 | shape>1)
  error('0 (piecewise) < smoothness < 1 (linear) ! Try again');
elseif (shape>=0 & shape <=1)
  if shape ==1 
    Ht = linspace(pi/2,-pi/2,N) ;
  elseif shape < 1
    shape=shape*1000+eps;
    Ht(1:N)=atan([N/2:-1:-N/2+1]./shape);
  end
  a=(h1-h2)/(Ht(1)-Ht(N));
  b=(h1+h2-a*(Ht(1)+Ht(N)))/2;
  Ht=a*Ht+b;
end
