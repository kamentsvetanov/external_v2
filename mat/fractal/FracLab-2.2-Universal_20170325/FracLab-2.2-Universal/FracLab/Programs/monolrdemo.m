% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

J=32;
x=1+linspace(0,1,J);
% Wiener process
W=randn(1,J); 
epsilon=.1;
y=10+x+epsilon*W;
% least square
[a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y);
plot(x);hold on;plot(y);plot(y_hat,'kd');
plot(epsilon.*W);hold on;plot(e_hat); 
title('least square');
disp('type return');
pause;
clf;
% weighted least square
epsilon=linspace(.05,.5,J);
y=x+epsilon.*W;
[a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'wls',1./epsilon);
plot(x);hold on;plot(y);plot(y_hat,'kd');
plot(epsilon.*W);hold on;plot(e_hat); 
title('weighted least square');
disp('type return');
pause;
clf;
% penalized least square
[a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'pls',30);
plot(x);hold on;plot(y);plot(y_hat);
title('penalized least square');
disp('type return');
pause;
clf;
% multiple least square
[a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'mls');
plot(x);hold on;plot(y)
start_j=0;
hold on;
for j=2:J
  plot([1:j],y_hat(start_j+1:start_j+j),'k');
  disp(['estimated slope a_hat =',num2str(a_hat(j))]);
  disp('type return');
  pause;
  start_j=start_j+j;
  j=j+1; 
end
clf
% maximum likelyhood
[a_hat,b_hat,y_hat,e_hat,sigma2_e_hat]=monolr(x,y,'ml');
plot(x);hold on;plot(y_hat(1:J),'kd');
plot(epsilon.*W);hold on;plot(e_hat(1:J));
clf;
% Lespkii's adaptive procedure
epsilon=.01;
y(1:16)=10+x(1:16)+epsilon*W(1:16);
y(16:32)=10+2*x(16:32)+epsilon*W(16:32);
[a_hat,b_hat,y_hat,e_hat,sigma2_e_hat,K_star,j_hat,I_c_j_min,I_c_j_max,E_c_j_hat_min,E_c_j_hat_max]=monolr(x,y,'lapls');
plot(a_hat);
hold on;
plot(I_c_j_max,'r^');
plot(I_c_j_min,'gV');
title('LAP: estimator vs. index');
xlabel('index: j');
ylabel('estimator: \theta_j');
plot(j_hat,E_c_j_hat_min,'ko');
plot(j_hat,E_c_j_hat_max,'ko');
