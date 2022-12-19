function MFAL_discrete(n,p_0)
% Discrete Legendre spectrum estimation on measure: test function
%
% Inputs: n  : # of levels of the pre-multifractal measure
%         p_0: weight of the binomial measure
%
% Outputs: plot measure, partition, Reyni functions 
%          and discrete Legendre spectrum on 4th part subplot

% Author Christophe Canus, January 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% pre-multifractal binomial measure: mu_n
p_0=.1;n=10;
[mu_n,I_n]=binom(p_0,'meas',n);

% 1st plot: pre-multifractal measure
subplot(2,2,1);
plot(I_n,mu_n);
title(['Binomial pre-multifractal measure (p_0=',num2str(p_0),', n=',num2str(n),')']);
xlabel('I_n');
ylabel('\mu_n');

% partition function: zaq 
q=[-5:.1:+5];
[zaq,a]=mdzq1d(mu_n,q);

% 2nd plot: partition function
subplot(2,2,2);
plot(log(a),log(zaq));
grid on;
title('Partition function');
xlabel('log a');
ylabel('log Z_a(q)');

% computation of Reyni function: tq 
tq=reynitq(zaq,q,a);

% 3rd plot: Reyni exponents function
subplot(2,2,3);
plot(q,tq,'r');
grid on;
title('Reyni exponents function');
xlabel('q');
ylabel('\tau(q)');

% discrete Legendre spectrum: fl_alpha
[alpha,fl_alpha]=linearlt(q,tq);
[t_alpha,tf_alpha]=binom(p_0,'spec',100);

% 4th plot: Discrete Legendre spectrum
subplot(2,2,4);
plot(alpha,fl_alpha,'yo');
hold on;
plot(t_alpha,tf_alpha,'g');
hold off;
grid on;
title('Discrete Legendre spectrum');
xlabel('\alpha');
ylabel('f_l(\alpha)');
