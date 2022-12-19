function y = UpDyadLo_PBS(x,qmf)
% UpDyadLo_PBS -- Lo-Pass Upsampling operator; periodized
%  Usage
%    u = UpDyadLo_PBS(d,sf)
%  Inputs
%    d    1-d signal at coarser scale
%    sf   symmetric filter
%  Outputs
%    u    1-d signal at finer scale
%
%  See Also
%    DownDyadLo_PBS , DownDyadHi_PBS , UpDyadHi_PBS, IWT_PBS, symm_iconv

% Author David L. Donoho, 1995
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	y =  symm_iconv(qmf, UpSample(x) );
