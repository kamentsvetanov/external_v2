function x = UpDyad_SBS(beta,alpha,qmf,dqmf)
% UpDyad_SBS -- Symmetric Upsampling operator
%  Usage
%    x = UpDyad_SBS(beta,alpha,qmf,dqmf)
%  Inputs
%    beta  coarse coefficients
%    alpha fine coefficients
%    qmf   quadrature mirror filter
%    dqmf  dual quadrature mirror filter
%  Outputs
%    x     1-d signal at fine scale
%  See Also
%    DownDyad_SBS, IWT_SBS

% Author Thomas P.Y. Yu, 1996
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

        % oddf = (rem(length(qmf),2)==1);
	oddf = ~(qmf(1)==0 & qmf(length(qmf))~=0);
	oddx = (length(beta) ~= length(alpha));
	
	L = length(beta)+length(alpha);

	if oddf,
	  if oddx,
	    ebeta = extend(beta,1,1);
	    ealpha = extend(alpha,2,2);
	  else
	    ebeta = extend(beta,2,1);
	    ealpha = extend(alpha,1,2);
	  end
	else
	  if oddx,
	    ebeta = extend(beta,1,2);
	    ealpha = [alpha 0 -reverse(alpha)];
	  else
	     ebeta = extend(beta,2,2);
	     ealpha = [alpha -reverse(alpha)];
	  end
	end

	coarse = UpDyadLo_PBS(ebeta,dqmf);
	fine = UpDyadHi_PBS(ealpha,qmf);
	x = coarse + fine;
	x = x(1:L);
    
