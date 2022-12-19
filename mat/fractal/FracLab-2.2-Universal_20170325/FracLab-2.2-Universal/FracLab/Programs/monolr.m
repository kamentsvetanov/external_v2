%   monovariate linear regression
%
%   This C_LAB routine provides six different algorithms to proceed linear
%   regression on monovariate data:  least square, weighted  least square,
%   penalized least square, multiple least square, maximum likelyhood and
%   Lepskii's adaptive procedure least square, in one sole routine.
%
%   1.  Usage
%
%   [a_hat,[b_hat,y_hat,e_hat,sigma2_e_hat,optvarargout]=
%   monolr(x,y,[lrstr,optvarargin])
%
%   1.1.  Input parameters
%
%   o  x : real vector [1,J] or [J,1]
%      Contains the abscissa.
%
%   o  y : real vector [1,J] or [J,1]
%      Contains the ordinates to be regressed.
%
%   o  lrstr : string
%      Contains the  string which specifies  the type of linear regression
%      to be used.
%
%   o  optvarargin :
%      Contains optional variable input arguments. Depending on the choice
%      of linear regression, the fourth parameter can be
%
%   o  w : strictly positive real vector [1,J] or [J,1]
%      If weighted least square is chosen, contains the weights.
%
%   o  I : strictly positive real (integer) scalar
%      If penalized least square is chosen, contains the number of
%      iterations.
%
%   o  sigma2_j : strictly positive real vector [1,J] or [J,1]
%      If Lepskii's  adaptive procedure least square  is chosen, contains
%      the sequence of variances.
%
%      The fifth parameter can be
%
%   o  m : real scalar
%      If penalized least square is chosen, contains the mean of the
%      normal weights.
%
%   o  K : strictly positive real scalar
%      If Lepskii's adaptive procedure least square is chosen, contains
%      the confidence constant.
%
%      The sixth parameter can be
%
%   o  s : strictly positive real scalar
%      If penalized  least  square is  chosen, contains  the variance  of
%      the normal weights.
%
%   1.2.  Output parameters
%
%   o  a_hat : real scalar or vector [1,J]
%      Contains the estimated slope.
%
%   o  b_hat : real scalar or vector [1,J]
%      Contains the estimated ordimate at the origin.
%
%   o  y_hat : real vector [1,J] or [1,(J+2)*(J-1)/2]
%      Contains the regressed ordinates.
%
%   o  e_hat : real vector [1,J] or [1,(J+2)*(J-1)/2]
%      Contains the residuals.
%
%   o  sigma2_e_hat : real scalar
%      Contains the residuals' variance (that is, the mean square error).
%
%   o  optvarargout :
%      Contains optional  variable output  arguments.  If  Lepskii's
%      adaptive procedure least square is chosen, the parameters are
%
%   o  K_star : strictly positive real scalar
%      Contains the optimal confidence constant.
%
%   o  j_hat : strictly positive real (integer) scalar
%      Contains the selected index.
%
%   o  I_c_j_min : real vector [1,J]
%      Contains the minimum bounds of the confidence intervals.
%
%   o  I_c_j_max : real vector [1,J]
%      Contains the maximum bounds of the confidence intervals.
%
%   o  E_c_j_hat_min : real scalar
%      Contains the minimum bound of the selected intersection interval.
%
%   o  E_c_j_hat_max : real scalar
%      Contains the maximum bound of the selected intersection interval.
%
%   2.  Description
%
%   2.1.  Parameters
%
%   The abscissa x and the ordinate y  to be regressed with must be of the
%   same size [1,J] or [J,1].
%
%   The linear regression string lrstr  specifies the type of  linear
%   regression used.  It can be 'ls' for least square, 'wls' for weighted
%   least square, 'pls' for penalized least square,   'mls' for multiple
%   least square  (that is for  j varying from  1  to J),  'ml' for
%   maximum likelyhood,  'lapls'  for   Lepskii's adaptive   procedure
%   least square.  The default value for lrstr is 'ls'.
%
%   The weights w or the sequence  of variances sigma2_j must be strictly
%   positive and of size [1,J] or [J,1].
%
%   For   the   meaning  of  the     variable  optional input   parameters
%   sigma2_j  and  K,   see  lepskiiap (Lepskii's  Adaptive Procedure)
%   C_LAB routine's help.
%
%   The number of iterations I must be >=2.
%
%   The variance of the normal weights s must be strictly positive.
%
%   If multiple least square,   maximum likelyhood or Lepskii's   adaptive
%   procedure  least square is chosen,  the estimated slope a_hat and the
%   ordinate   at   the   origin  b_hat  are   vectors  of   size [1,J],
%   resp.  the  regressed  ordinates  y_hat  and the residuals e_hat
%   vectors  are  of size [1,(J+2)*(J-1)/2] (as they contains results for
%   multiple  linear regression, be aware of that  when vizualising  them
%   :-),  see examples),  otherwise there are scalars,   resp.  vectors
%   of size     [1,J].  For  maximum likelyhood, multiple least square
%   linear regressions are proceeded in order to obtain  variance
%   estimates.   Then maximum likelyhood  linear regression is
%   proceeded   (corresponding results   are    found in a_hat(1),
%   b_hat(1), y_hat(1:J),  e_hat(1:J)   and sigma2_e_hat(1), see
%   examples).
%
%   For  the  meaning   of   the   variable  optional   output  parameters
%   K_star,    j_hat,         I_c_j_min,    I_c_j_max, E_c_j_max, and
%   E_c_j_max,  see  lepskiiap  (Lepskii's Adaptive Procedure) C_LAB
%   routine's help.
%
%   2.2.  Algorithm details
%
%   For   the   details  of  the      Lepskii's  adaptive procedure,   see
%   lepskiiap (Lepskii's Adaptive Procedure) C_LAB routine's help.
%
%   3.  Examples
%
%   3.1.  Matlab
%
%   ______________________________________________________________________
%   J=32;
%   x=1+linspace(0,1,J);
%   % Wiener process
%   W=randn(1,J);
%   epsilon=.1;
%   y=x+epsilon*W;
%   % least square
%   [a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y);
%   plot(x);hold on;plot(y);plot(y_hat,'kd');
%   plot(epsilon.*W);hold on;plot(e_hat);
%   title('least square');
%   disp('type return');
%   pause;
%   clf;
%   % weighted least square
%   epsilon=linspace(.05,.5,J);
%   y=x+epsilon.*W;
%   [a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'wls',1./epsilon);
%   plot(x);hold on;plot(y);plot(y_hat,'kd');
%   plot(epsilon.*W);hold on;plot(e_hat);
%   title('weighted least square');
%   disp('type return');
%   pause;
%   clf;
%   % penalized least square
%   [a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'pls',30);
%   plot(x);hold on;plot(y);plot(y_hat);
%   title('penalized least square');
%   disp('type return');
%   pause;
%   clf;
%   % multiple least square
%   [a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'mls');
%   plot(x);hold on;plot(y)
%   start_j=0;
%   hold on;
%   for j=2:J
%     plot([1:j],y_hat(start_j+1:start_j+j),'k');
%     disp(['estimated slope a_hat =',num2str(a_hat(j))]);
%     disp('type return');
%     pause;
%     start_j=start_j+j;
%     j=j+1;
%   end
%   clf
%   % maximum likelyhood
%   [a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'ml');
%   plot(x);hold on;plot(y_hat(1:J),'kd');
%   plot(epsilon.*W);hold on;plot(e_hat(1:J));
%   clf;
%   % Lespkii's adaptive procedure
%   epsilon=.01;
%   y(1:16)=x(1:16)+epsilon*W(1:16);
%   y(16:32)=2*x(16:32)+epsilon*W(16:32);
%   [a_hat,b_hat,y_hat,e_hat,sigma2_e_hat,K_star,j_hat,I_c_j_min,I_c_j_max,E_c_j_hat_min,E_c_j_hat_max]=monolr(x,y,'lapls');
%   plot(a_hat);
%   hold on;
%   plot(I_c_j_max,'r^');
%   plot(I_c_j_min,'gV');
%   title('LAP: estimator vs. index');
%   xlabel('index: j');
%   ylabel('estimator: \theta_j');
%   plot(j_hat,E_c_j_hat_min,'ko');
%   plot(j_hat,E_c_j_hat_max,'ko');
%   ______________________________________________________________________
%   3.2.  Scilab
%
%   ______________________________________________________________________
%   //
%   ______________________________________________________________________
%
%   4.  References
%
%   To be published.
%
%   5.  See Also
%
%   lepskiiap (C_LAB routine).

% Author Christophe Canus, March 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------