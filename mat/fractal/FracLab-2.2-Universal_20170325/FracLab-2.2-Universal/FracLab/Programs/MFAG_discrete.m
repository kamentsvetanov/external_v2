function [a,f]=MFAG_discrete(n,p)
% function [a,f]=MFAG_discrete(n,p)           
% Discrete Large Deviation spectrum computation on measure: test function

% Author Christophe Canus, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% display initialization
figure(1);
clf;

% computation of pre-multifractal besicovitch measure: mu_n
% resolution of the pre-multifractal measure
% n=16;
% parameter of the besicovitch measure
% p=.4;
% synthesis of the pre-multifractal beiscovitch 1d measure
[mu_n,I_n]=bm1d(n,p);
% plot the pre-multifractal besicovitch 1d measure
subplot(2,2,1);
plot(I_n,mu_n);
title(['Besicovith measure (p=',num2str(p),', n=',num2str(n),')']);
xlabel('I_n');
ylabel('\mu_n');

% computation of coarse Hoelder exponents: ch
% discretization of the unit interval
m=1;
% scale factor
s=1;
ch=mch(mu_n,m,s);
% plot of the coarse Hoelder exponents
subplot(2,2,2);
plot(I_n,ch);
grid on;
title('coarse Hoelder exponents');
xlabel('I_n');
ylabel('\alpha_n');

% computation of the Discrete Large Deviation spectrum: f
% # of hoelder exponents
N=200; 
% computation of the Discrete Large Deviation spectrum
[a,f,pdf]=mdfg(mu_n,N,1);
% plot the Probability Density function
subplot(2,2,3);
plot(a,pdf,'r');
grid on;
title('Probability Density function');
xlabel('\alpha');
ylabel('p_n(\alpha)');

% computation of the theoric Hausdorff spectrum
[ta,tf]=bm1ds(N,p);
% plot the theoric Hausdorff spectrum
subplot(2,2,4);
plot(ta,tf,'b');
hold on;
% plot the Discrete Large Deviation spectrum
plot(a,f,'m');
hold off;
grid on;
title('Discrete Large Deviation spectrum');
xlabel('\alpha');
ylabel('f_{g,n}(\alpha)');
