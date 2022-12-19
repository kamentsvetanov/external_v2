% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Fractional Brownian motion synthesis
fbm=fbmlevinson(256,.6);

% Continuous legendre spectrum: f(alpha) on 1d function with default input arguments and
% all output arguments
[alpha,f_alpha,zaq,a,tq,q]=fcfl1d(fbm);
% plot outputs
plot(log(a),log(zaq));
plot(q,tq);
plot(alpha,f_alpha);

% Continuous legendre spectrum: f(alpha) on 1d function with custom input arguments and
% two output arguments
[alpha,f_alpha]=fcfl1d(fbm,[-5:.1:+5],[10 1 128],'lin','l2','lapls');
% plot outputs
plot(alpha,f_alpha);
