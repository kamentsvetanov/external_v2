function dp = dyadpartition(n)
% dyadpartition -- determine dyadic partition in wavelet transform of 
%                  nondyadic signals

% Author Thomas P.Y. Yu, 1996
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

        J = ceil(log2(n));
	
	m = n;
	for j=J-1:-1:0;
	  if rem(m,2)==0,
	    dps(j+1) = m/2;
	    m = m/2;
	  else
	    dps(j+1) = (m-1)/2;
	    m = (m+1)/2;
	  end
	end
	
	dp = cumsum([1 dps]);   
    
