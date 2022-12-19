% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

x=linspace(-5.,5.,1024);
u_x=-1+log(6+x);
plot(x,u_x);
% looks like a Reyni exponents function, isn't it ?
[s,u_star_s]=linearlt(x,u_x);
plot(s,u_star_s);
