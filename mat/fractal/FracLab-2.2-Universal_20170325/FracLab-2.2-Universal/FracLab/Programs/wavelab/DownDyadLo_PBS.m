function d = DownDyadLo_PBS(x,qmf)
% DownDyadLo_PBS -- Lo-Pass Downsampling operator (periodized,symmetric)
%  Usage
%    d = DownDyadLo_PBS(x,sf)
%  Inputs
%    x    1-d signal at fine scale
%    sf   symmetric filter
%  Outputs
%    y    1-d signal at coarse scale
%
%  See Also
%    DownDyadHi_PBS, UpDyadHi_PBS, UpDyadLo_PBS, FWT_PBSi, symm_aconv

% Author David L. Donoho, 1995

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	d = symm_aconv(qmf,x);
	n = length(d);
	d = d(1:2:(n-1));    
