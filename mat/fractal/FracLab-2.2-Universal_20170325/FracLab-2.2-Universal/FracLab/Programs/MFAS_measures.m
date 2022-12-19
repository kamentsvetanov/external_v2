% script MFAS_measures               
% Pre-multifractal measures synthesis: test script %
% Inputs: 
%
% Outputs: plot measures

% Author Christophe Canus, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

n=8;
p0=.2; 
[mu_n,I_n]=binom(p0,'meas',n);
plot(I_n,mu_n);
title(['Besicovitch measure (p_0= ',num2str(p0),', n= ',num2str(n),')']);
xlabel('dyadic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

e=.1;
mu_n=binom(p0,'pertmeas',n,e);
plot(I_n,mu_n,'r');
title(['Pertubated Besicovitch measure (p_0= ',num2str(p0),', n= ',num2str(n),', \epsilon= ',num2str(e),')']);
xlabel('dyadic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

q0=.4;
mu_n=binom(p0,'lumpmeas',n,q0);
plot(I_n,mu_n,'m');
title(['lumping of 2 Besicovitch measures (p_0= ',num2str(p0),', q_0= ',num2str(q0),', n= ',num2str(n),')']); 
xlabel('dyadic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

mu_n=binom(p0,'summeas',n,q0);
plot(I_n,mu_n,'c');
title(['sum of 2 Besicovitch measures (p_0= ',num2str(p0),', q_0= ',num2str(q0),', n= ',num2str(n),')']);
xlabel('dyadic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

mu_n=binom(p0,'lumppertmeas',n,q0,e);
plot(I_n,mu_n,'y');
title(['lumping of 2 pertubated Besicovitch measures (p_0= ',num2str(p0),', q_0= ',num2str(q0),', n= ',num2str(n),', \epsilon= ',num2str(e),')']);
xlabel('dyadic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

mu_n=binom(p0,'sumpertmeas',n,q0,e);
plot(I_n,mu_n,'k');
title(['sum of 2 pertubated Besicovitch measures (p_0= ',num2str(p0),', q_0= ',num2str(q0),', n= ',num2str(n),', \epsilon= ',num2str(e),')']);
xlabel('dyadic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

e=.05;
mu_n=sbinom('unifmeas',n,e);
plot(I_n,mu_n,'g');
title(['Uniform Law binomial measure (n= ',num2str(n),', \epsilon= ',num2str(e),')']);
xlabel('dyadic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

b=3;
p=[.1 .3 .6];
[mu_n,I_n]=multim1d(b,p,'meas',n);
plot(I_n,mu_n);
title(['Multinomial 1d measure (b= ',num2str(b),', p= ',num2str(p),', n= ',num2str(n),')']);
xlabel('b-adic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

e=.099;
mu_n=multim1d(b,p,'pertmeas',n,e);
plot(I_n,mu_n,'r');
title(['Pertubated Multinomial 1d  measure (b= ',num2str(b),', p= ',num2str(p),', n= ',num2str(n),', \epsilon= ',num2str(e),')']);
xlabel('b-adic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

e=.05;
mu_n=smultim1d(b,'unifmeas',n,e);
plot(I_n,mu_n,'g');
title(['Uniform Law multinomial 1d measure (b= ',num2str(b),', n= ',num2str(n),', \epsilon= ',num2str(e),')']);
xlabel('b-adic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

b=3;
s=.1;
mu_n=smultim1d(b,'lognmeas',n,s);
plot(I_n,mu_n,'y');
title(['Limit Lognormal 1d measure (b= ',num2str(b),', n= ',num2str(n),', \sigma= ',num2str(s),')']);
xlabel('b-adic intervals: I_n');
ylabel('measures: \mu_n');
pause;
clf;

n=5;
bx=3;
by=2;
p=[.1 .13 .17;.1 .1 .4];
[mu_n,I_nx,I_ny]=multim2d(bx,by,p,'meas',n);
mesh(I_nx,I_ny,mu_n);
title(['Multinomial 2d measure (b_x= ',num2str(bx),', b_y=',num2str(by),', p= ',num2str([.1 .13 .17 .1 .1 .4]),', n= ',num2str(n),')']);
xlabel('b_x-adic intervals: I_n(x)');
ylabel('b_y-adic intervals: I_n(y)');
zlabel('measures: \mu_n');
pause;
clf;

e=.05;
mu_n=multim2d(bx,by,p,'pertmeas',n,e);
mesh(I_nx,I_ny,mu_n);
title(['Pertubated multinomial 2d measure (b_x= ',num2str(bx),', b_y=',num2str(by),', p= ',num2str([.1 .13 .17 .1 .1 .4]),', n= ',num2str(n),', e=',num2str(e),')']);
xlabel('b_x-adic intervals: I_n(x)');
ylabel('b_y-adic intervals: I_n(y)');
zlabel('measures: \mu_n');
pause;
clf;

mu_n=smultim2d(bx,by,'unifmeas',n,e);
mesh(I_nx,I_ny,mu_n);
title(['Uniform Law multinomial 2d measure (b_x= ',num2str(bx),', b_y=',num2str(by),' , n= ',num2str(n),', \epsilon= ',num2str(e),')']);
xlabel('b_x-adic intervals: I_n(x)');
ylabel('b_y-adic intervals: I_n(y)');
zlabel('measures: \mu_n');
pause;
clf;

mu_n=smultim2d(bx,by,'lognmeas',n,s);
mesh(I_nx,I_ny,mu_n);
title(['Limit Lognormal 2d measure (b_x= ',num2str(bx),', b_y= ',num2str(by),', n= ',num2str(n),', \sigma= ',num2str(s),')']);
xlabel('b_x-adic intervals: I_n(x)');
ylabel('b_y-adic intervals: I_n(y)');
zlabel('measures: \mu_n');
pause;
clf;
