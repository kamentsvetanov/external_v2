% No help found

% Author Christophe Canus, May 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% pre-multifractal binomial 1d measure synthesis
mu_n=binom(.1,'meas',10);

% Discrete Legendre spectrum: f(alpha) on 1d measure with default input arguments and
% all output arguments
[alpha,f_alpha,zaq,a,tq,q]=mdfl1d(mu_n);
% plot outputs
plot(log(a),log(zaq));
plot(q,tq);
plot(alpha,f_alpha,'o');

% Discrete Legendre spectrum: f(alpha) on 1d function with custom input arguments and
% two output arguments
[alpha,f_alpha]=mdfl1d(mu_n,[-5:.1:+5],[10 1 512],'linpart','pls');
% plot outputs
plot(alpha,f_alpha,'r');

