function [gg] = gg(h1,h2)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

gg = ii((h1+h2)/2)/sqrt(ii(h1)*ii(h2));

%%%%%%%%%%%%%%%%%%
function [ii]=ii(h);
if h<0.5
	q=1/h;
	ii=gamma(1-2*h)*q*sin(pi*(0.5-h));
elseif h==0.5;
	ii=pi;
else
	qq=1/(h*(2*h-1));
	ii=gamma(2-2*h)*qq*sin(pi*(h-0.5));
end;