%No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Fractional Brownian motion synthesis
fbm=fbmlevinson(256,.6);

% partition function: z(a,q) estimation with default input arguments and
% all output arguments
[zaq,a,q]=fczq1d(fbm);
% plot outputs
plot(log(a),log(zaq));

% partition function: z(a,q) estimation with custom input arguments and 
% two output arguments
[zaq,a]=fczq1d(fbm,[-5:.1:+5],[10 1 128],'lin','l2');
% plot outputs
plot(log(a),log(zaq));