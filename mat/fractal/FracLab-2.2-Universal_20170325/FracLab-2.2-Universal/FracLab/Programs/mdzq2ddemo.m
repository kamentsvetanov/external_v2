% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Pre-multifractal multinomial 2d measure synthesis
mu_n=multim2d(2,2,[.1 .3; .2 .4],'meas',6);

% Partition function: z(a,q) on 2d measure with default input arguments and
% all output arguments
[zaq,a,q]=mdzq2d(mu_n);
plot(log(a),log(zaq));


