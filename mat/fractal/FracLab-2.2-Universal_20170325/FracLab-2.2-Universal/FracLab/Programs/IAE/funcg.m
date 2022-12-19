function result = funcg(val,amin,gmin,amax,gmax,anod)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

for i=1:1:size(val,2)

	if (val(i)<=anod)
	
		m = (1-gmin)/(anod-amin);
	
	else
	
		m = (gmax-1)/(amax-anod);
	
	end
	
	n = 1-m*anod;	
	result(i) = m*val(i)+n;
end