function [alpha,fgc_alpha]=MFAG_continuous(p,n)
% function [alpha,fgc_alpha]=MFAG_continuous(p,n)
% Continuous large deviation spectrum computation on measure: test script

% Author Christophe Canus, January 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% display initialization
figure(1);
clf;

% synthesis of the pre-multifractal binomial 1d measure: mu_n
[mu_n,I_n]=binom(p,'meas',n);
% plot the pre-multifractal binomial 1d measure
subplot(2,2,1);
plot(I_n,mu_n);
title(['Binomial measure (p=',num2str(p),', n=',num2str(n),')']);
xlabel('I_n');
ylabel('\mu_n');

% computation of coarse Hoelder exponents: alpha_eta_x
% minimum size, maximum size and # of scales
S_min=1;S_max=8;J=2;
[alpha_eta_x,eta,x]=mch1d(mu_n,[S_min,S_max,J],'dec','asym');
% plot of the coarse Hoelder exponents
subplot(2,2,2);
viewmat(alpha_eta_x,x,eta);colormap(hot);
title('coarse Hoelder exponents');
xlabel('x');
ylabel('\eta');

% computation of the continuous large deviation spectrum: fgc_alpha 
% # of hoelder exponents, precision vector
N=200;epsilon=zeros(1,N); 
% estimate the continuous large deviation spectrum
%[alpha,fgc_alpha,pc_alpha,epsilon_star]=cfg1d(alpha_eta_x,eta,x,N,epsilon,'hkern','maxdev','gau','suppdf'); 
[alpha,fgc_alpha,pc_alpha,epsilon_star]=mcfg1d(mu_n,[S_min,S_max,J],'dec','asym',N,epsilon,'hkern','maxdev','gau','suppdf'); 
% plot the pdf
subplot(2,2,3);
plot(alpha,pc_alpha);
grid on;
title('pdf');
xlabel('\alpha');
ylabel('p_\eta^{c,\epsilon}(\alpha)');

% computation of the theoric Hausdorff spectrum
[talpha,tf_alpha]=binom(p,'spec',N);
% plot the theoric Hausdorff spectrum
subplot(2,2,4);
plot(talpha,tf_alpha,'k');
hold on;
% plot the continuous large deviation spectrum
plot(alpha,fgc_alpha);
hold off;
grid on;
title('Continuous large deviation spectrum');
xlabel('\alpha');
ylabel('f_{g,\eta}^{c,\epsilon}(\alpha)');
