% scripts MFAS_dimensions               
% dimensions computation: test scripts
%
% Inputs: 
%
% Outputs: plot partition functions, mass exponent function, 
%          generalized dimensions

% Author Christophe Canus, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

vn=[1:1:16];
q=[-20:.1999:+10];

p0=.2; 
[znq]=binom(p0,'part',vn,q);
plot(-vn*log(2),log(znq));
title(['Besicovitch measure partition sum function (p_0=',num2str(p0),', n=',num2str(vn(1)),',...,',num2str(vn(16)),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('-n*log(2)');
ylabel('log(Z_n(q))');
grid on;
pause;
clf;

[tq,Dq]=binom(p0,'Reyni',q);
plot(q,tq);
title(['Besicovitch measure Reyni exponents function (p_0=',num2str(p0),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('measure exponents: q');
ylabel('Reyni exponents: \tau(q)');
grid on;
pause;
clf;

plot(q,Dq);
title(['Besicovitch measure generalized dimensions (p_0=',num2str(p0),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('measure exponents: q');
ylabel('generalized dimensions: D(q)');
grid on;
pause;
clf;

b=3;
p=[.1,.3,.6]; 
[znq]=multim1d(b,p,'part',vn,q);
plot(-vn*log(2),log(znq));
title(['Multinomial 1d measure partition sum function (b=',num2str(b),', p=',num2str(p),', n=',num2str(vn(1)),',...,',num2str(vn(16)),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('-n*log(2)');
ylabel('log(Z_n(q))');
grid on;
pause;
clf;

[tq,Dq]=multim1d(b,p,'Reyni',q);
plot(q,tq);
title(['Multinomial 1d measure Reyni exponents function (b=',num2str(b),', p=',num2str(p),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('measure exponents: q');
ylabel('Reyni exponents: \tau(q)');
grid on;
pause;
clf;

plot(q,Dq);
title(['Multinomial 1d measure generalized dimensions (b=',num2str(b),', p=',num2str(p),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('measure exponents: q');
ylabel('generalized dimensions: D(q)');
grid on;
pause;
clf;

bx=3;
by=2;
p=[.1 .13 .17;.1 .1 .4];
[znq]=multim2d(bx,by,p,'part',vn,q);
plot(-vn*log(2),log(znq));
title(['Multinomial 2d measure partition sum function (b_x=',num2str(bx),', b_y=',num2str(by),', p= ',num2str([.1 .13 .17 .1 .1 .4]),', n=',num2str(vn(1)),',...,',num2str(vn(16)),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('-n*log(2)');
ylabel('log(Z_n(q))');
grid on;
pause;
clf;

[tq,Dq]=multim2d(bx,by,p,'Reyni',q);
plot(q,tq);
title(['Multinomial 2d measure Reyni exponents function (b_x=',num2str(bx),', b_y=',num2str(by),', p= ',num2str([.1 .13 .17 .1 .1 .4]),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('measure exponents: q');
ylabel('Reyni exponents: \tau(q)');
grid on;
pause;
clf;

plot(q,Dq);
title(['Multinomial 2d measure generalized dimensions (b_x=',num2str(bx),', b_y=',num2str(by),', p= ',num2str([.1 .13 .17 .1 .1 .4]),', q=',num2str(q(1)),',...,',num2str(q(max(size(q)))),')']);
xlabel('measure exponents: q');
ylabel('generalized dimensions: D(q)');
grid on;
pause;
clf;
