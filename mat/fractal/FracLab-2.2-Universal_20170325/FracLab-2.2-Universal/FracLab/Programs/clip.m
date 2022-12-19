function [Cn,pc] = clip(C,cmax)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N = length(C) ;
Cn = C ;
count = 0 ;
for n=1:N,
	c = C(n) ;
	if abs(c) > cmax
		Cn(n) = sign(c)*cmax ;
		count = count+1 ;
	end
end
pc = (count/N) *100 ;