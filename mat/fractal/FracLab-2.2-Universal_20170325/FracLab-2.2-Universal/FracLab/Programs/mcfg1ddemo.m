% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% synthesis of pre-multifractal binomial measure: mu_n
% resolution of the pre-multifractal measure
n=10; 
% parameter of the binomial measure
p_0=.4; 
% synthesis of the pre-multifractal beiscovitch 1d measure 
mu_n=binom(p_0,'meas',n);  
% continuous large deviation spectrum estimation: fgc_alpha  
%  minimum size, maximum size & # of scales
S_min=1;S_max=8;J=4;
% # of hoelder exponents, precision vector
N=200;epsilon=zeros(1,N); 
% estimate the continuous large deviation spectrum
[alpha,fgc_alpha,pc_alpha,epsilon_star]=mcfg1d(mu_n,[S_min,S_max,J],'dec','cent',N,epsilon,'hkern','maxdev','gau','suppdf'); 
% plot the continuous large deviation spectrum
plot(alpha,fgc_alpha); 
title('Continuous Large Deviation spectrum');  
xlabel('\alpha');
ylabel('f_{g,\eta}^{c,\epsilon}(\alpha)');
