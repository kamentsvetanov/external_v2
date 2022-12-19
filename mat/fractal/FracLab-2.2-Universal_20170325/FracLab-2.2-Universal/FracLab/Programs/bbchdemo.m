% No help found

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

h=.3;beta=3;
N=1000;
% chirp singularity (h,beta)
x=linspace(0.,1.,N);
u_x=abs(x).^h.*sin(abs(x).^(-beta));
plot(x,u_x);
hold on;
[rx,ru_x]=bbch(x,u_x);
plot(rx,ru_x,'rd');
plot(x,abs(x).^h,'k');
