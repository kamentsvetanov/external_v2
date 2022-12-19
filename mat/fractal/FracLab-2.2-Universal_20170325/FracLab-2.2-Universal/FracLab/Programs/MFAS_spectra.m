% script MFAS_spectra               
% Multifractal spectra synthesis: test script
%
% Inputs: 
%
% Outputs: plot spectra

% Author Christophe Canus, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N=200;
p0=.2; 
[alpha,f_alpha]=binom(p0,'spec',N);
plot(alpha,f_alpha);
grid on;
title(['Besicovith 1d measure Multifractal spectrum (p_0=',num2str(p0),')']);
xlabel('Hoelder exponents: \alpha');
ylabel('spectrum: f(\alpha)');
pause;
clf;

q0=.4;
[alpha,f_alpha]=binom(p0,'lumpspec',N,q0);
plot(alpha,f_alpha,'g');
grid on;
title(['lumping of 2 Besicovith 1d measures Multifractal spectrum (p_0=',num2str(p0),', q_0=',num2str(q0),')']);
xlabel('Hoelder exponents: \alpha');
ylabel('spectrum: f(\alpha)');
pause;
clf;

[alpha,f_alpha]=binom(p0,'sumspec',N,q0);
plot(alpha,f_alpha,'r');
grid on;
title(['sum of 2 Besicovith 1d measures Multifractal spectrum (p_0=',num2str(p0),', q_0=',num2str(q0),')']);
xlabel('Hoelder exponents: \alpha');
ylabel('spectrum: f(\alpha)');
pause;
clf;

[alpha,f_alpha]=sbinom('unifspec',N);
plot(alpha,f_alpha,'c');
grid on;
title('Uniform Law binomial measure Multifractal spectrum');
xlabel('Hoelder exponents: \alpha');
ylabel('spectrum: f(\alpha)');
pause;
clf;

b=3;
s=1.;
[alpha,f_alpha]=smultim1d(b,'lognspec',N,s);
plot(alpha,f_alpha,'m');
grid on;
title(['Limit Lognormal 1d measure Multifractal spectrum (\sigma= ',num2str(s),')']);
xlabel('Hoelder exponents: \alpha');
ylabel('spectrum: f(\alpha)');
pause;
clf;

p=[.1 .3 .6];
[alpha,f_alpha]=multim1d(b,p,'spec',N);
plot(alpha,f_alpha);
grid on;
title(['Multinomial 1d measure Multifractal spectrum (b=',num2str(b),', p=',num2str(p),')']);
xlabel('Hoelder exponents: \alpha');
ylabel('spectrum: f(\alpha)');
pause;
clf;

bx=3;
by=2;
p=[.1 .13 .17;.1 .1 .4];
[alpha,f_alpha]=multim2d(bx,by,p,'spec',N);
plot(alpha,f_alpha,'k');
grid on;
title(['Multinomial 2d measure Multifractal spectrum (b_x=',num2str(bx),', b_y=',num2str(by),', p= ',num2str([.1 .13 .17 .1 .1 .4]),')']);
xlabel('Hoelder exponents: \alpha');
ylabel('spectrum: f(\alpha)');
pause;
clf;
