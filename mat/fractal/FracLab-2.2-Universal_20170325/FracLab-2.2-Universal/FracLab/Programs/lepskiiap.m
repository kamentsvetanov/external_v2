%   lepskii adaptive procedure
%
%   This C_LAB  routine is an   implementation of  the Lepskii's  adaptive
%   procedure. This algorithm  selects the "best" estimator which balances
%   the  bias-variance tradeoff  in  a   sequence  of  noisy and    biased
%   estimators theta_hat_j of a  non-random parameter theta with the
%   assumption that when  j increases, bias b_j increases as variance
%   sigma2_j decreases.
%
%   1.  Usage
%
%   [K_star,j_hat,I_c_j_min,I_c_j_max,E_c_j_hat_min,E_c_j_hat_max]=
%   lepskiiap(theta_hat_j,[sigma2_j,K])
%
%   1.1.  Input parameters
%
%   o  theta_hat_j : real vector [1,J] or [J,1]
%      Contains the sequence of estimators.
%
%   o  sigma2_j : strictly positive real vector [1,J] or [J,1]
%      Contains the sequence of variances.
%
%   o  K : strictly positive real scalar
%      Contains the confidence constant.
%
%   1.2.  Output parameters
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
%   The sequence of  variances   sigma_j must be   stricly  positive,
%   decreasing  when     j increases and  of    the   same  size than
%   theta_hat_j.  When no sequence of variances  is given as input or when
%   it is uniformly equal to  0, the algorithm computes the sequence of
%   variances as sigma2_j=1./j.   The default value for epsilon is
%   1./[1:J].
%
%   The confidence constant K must be >=1.
%
%   For the meaning of the ouput parameters, see next section.
%
%   2.2.  Algorithm details
%
%   Define        the       sequence        of     confidence    intervals
%   I_c_j=[theta_hat_j-K*sigma_j,theta_hat_j+K*sigma_j], the  sequence  of
%   their   decreasing  intersections   E_c_j  and j_hat as the largest
%   index j such as  that E_c_j is non void.   The best  estimator  with
%   respect  to the Lepskii's  adaptive procedure is selected as
%   theta_hat_j_hat in E_c_j_hat.
%
%   The  two parameters  to be   handled are  the   sequence of  variances
%   sigma2_j and the confidence constant K. sigma2_j can be any sequence
%   dominating  the  estimator variance. Choosing  a  smaller K speeds up
%   the selection and results to smaller j_hat.
%
%   3.  Examples
%
%   3.1.  Matlab
%
%   ______________________________________________________________________
%   T=33;
%   % linear model
%   f_t=linspace(0,1,T);
%   % jump for t=floor(3/4*T)
%   f_t(floor(3/4*T):T)=2*f_t(floor(3/4*T):T);
%   % Wiener process
%   W_t=randn(1,T);
%   sigma=.1;
%   Y_t=f_t+sigma*W_t;
%   subplot(2,1,1);
%   plot(f_t);hold on;plot(Y_t);
%   title('White noise model Y(t)');
%   xlabel('index: t');
%   ylabel('Y(t)=f(t)+\sigma W(t)');
%   % estimation for t=t_0=floor(T/2)
%   t_0=floor(T/2)+1;
%   Y_t=f_t+sigma*W_t;
%   for t=1:floor(T/2)
%     f_hat_t(t)=mean(Y_t(t_0-t:t_0+t));
%   end
%   % Lespkii's adaptive procedure
%   [K_star,t_hat,I_c_t_min,I_c_t_max,E_c_t_hat_min,E_c_t_hat_max]=lepskiiap(f_hat_t,.005*1./[1:floor(T/2)],2);
%   % plot and disp results
%   plot(t_0,Y_t(t_0),'k*');
%   plot(t_0-t_hat,Y_t(t_0-t_hat),'kd');
%   plot(t_0+t_hat,Y_t(t_0+t_hat),'kd');
%   subplot(2,1,2);
%   plot(f_hat_t);
%   hold on;
%   plot(I_c_t_max,'r^');
%   plot(I_c_t_min,'gV');
%   title(['estimator \theta_t(t_0) vs. index t with t_0=',num2str(floor(T/2)+1)]);
%   xlabel('index: t');
%   ylabel('estimator: \theta_t(t_0)');
%   plot(t_hat,E_c_t_hat_min,'ko');
%   plot(t_hat,E_c_t_hat_max,'ko');
%   disp(['linear estimation of f_t for t=t_0=',num2str(t_0)]);
%   disp(['selected index t=',num2str(t_hat)]);
%   disp(['estimated f_t_0 in [',num2str(E_c_t_hat_min),',',num2str(E_c_t_hat_min),']']);
%   ______________________________________________________________________
%
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
%   monolr (C_LAB routine).

% Author Christophe Canus, March 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------