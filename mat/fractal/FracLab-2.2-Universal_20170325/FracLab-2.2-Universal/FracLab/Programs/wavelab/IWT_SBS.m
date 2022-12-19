function x = IWT_SBS(wc,L,qmf,dqmf)
% iwt_po -- Inverse Wavelet Transform (symmetric extension, biorthogonal, symmetric)
%  Usage
%    x = IWT_SBS(wc,L,qmf,dqmf)
%  Inputs
%    wc     1-d wavelet transform: length(wc)= 2^J.
%    L      Coarsest scale (2^(-L) = scale of V_0); L << J;
%    qmf     quadrature mirror filter
%    dqmf    dual quadrature mirror filter (symmetric, dual of qmf)
%  Outputs
%    x      1-d signal reconstructed from wc
%  Description
%    Suppose wc = FWT_SBS(x,L,qmf,dqmf) where qmf and dqmf are orthonormal
%    quad. mirror filters made by MakeBioFilter.  Then x can be reconstructed
%    by
%      x = IWT_SBS(wc,L,qmf,dqmf)
%  See Also:
%    FWT_SBS, MakeBioFilter

% Author Thomas P.Y. Yu, 1996
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

        wcoef = ShapeAsRow(wc);
	[n,J] = dyadlength(wcoef);
	
	dp = dyadpartition(n);
	
	x = wcoef(1:dp(L+1));
	
	for j=L:J-1,
	  dyadj = (dp(j+1)+1):dp(j+2);
	  x = UpDyad_SBS(x, wcoef(dyadj), qmf, dqmf);
	end
	x = ShapeLike(x,wc);
	
