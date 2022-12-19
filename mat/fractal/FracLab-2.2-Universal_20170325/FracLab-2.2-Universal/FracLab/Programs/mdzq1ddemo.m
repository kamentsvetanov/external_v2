% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% pre-multifractal binomial 1d measure synthesis
mu_n=binom(.1,'meas',10);

% partition function: z(a,q) on 1d measure with default input arguments and
% all output arguments
[zaq,a,q]=mdzq1d(mu_n);
plot(log(a),log(zaq));
