% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

T=33;
% linear model
f_t=linspace(0,1,T);
% jump for t=floor(3/4*T)
f_t(floor(3/4*T):T)=2*f_t(floor(3/4*T):T);
% Wiener process
W_t=randn(1,T);
sigma=.1;
Y_t=f_t+sigma*W_t;
subplot(2,1,1);
plot(f_t);hold on;plot(Y_t);
title('White noise model Y(t)');
xlabel('index: t');
ylabel('Y(t)=f(t)+\sigma W(t)');
% estimation for t=t_0=floor(T/2)
t_0=floor(T/2)+1;
Y_t=f_t+sigma*W_t;
for t=1:floor(T/2)
  f_hat_t(t)=mean(Y_t(t_0-t:t_0+t));
end
% Lespkii's adaptive procedure
[K_star,t_hat,I_c_t_min,I_c_t_max,E_c_t_hat_min,E_c_t_hat_max]=lepskiiap(f_hat_t,.005*1./[1:floor(T/2)],2);
% plot and disp results
plot(t_0,Y_t(t_0),'k*');
plot(t_0-t_hat,Y_t(t_0-t_hat),'kd');
plot(t_0+t_hat,Y_t(t_0+t_hat),'kd');
subplot(2,1,2);
plot(f_hat_t);
hold on;
plot(I_c_t_max,'r^');
plot(I_c_t_min,'gV');
title(['estimator \theta_t(t_0) vs. index t with t_0=',num2str(floor(T/2)+1)]);
xlabel('index: t');
ylabel('estimator: \theta_t(t_0)');
plot(t_hat,E_c_t_hat_min,'ko');
plot(t_hat,E_c_t_hat_max,'ko');
disp(['linear estimation of f_t for t=t_0=',num2str(t_0)]);
disp(['selected index t=',num2str(t_hat)]);
disp(['estimated f_t_0 in [',num2str(E_c_t_hat_min),',',num2str(E_c_t_hat_min),']']);
