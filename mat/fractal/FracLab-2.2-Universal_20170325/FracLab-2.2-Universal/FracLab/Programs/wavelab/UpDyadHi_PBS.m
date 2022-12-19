function y = UpDyadHi_PBS(x,qmf)
% UpDyadHi_PBS -- Hi-Pass Upsampling operator; periodized
%  Usage
%    u = UpDyadHi_PBS(d,f)
%  Inputs
%    d    1-d signal at coarser scale
%    sf   symmetric filter
%  Outputs
%    u    1-d signal at finer scale
%
%  See Also
%    DownDyadLo_PBS, DownDyadHi_PBS, UpDyadLo_PBS, IWT_PBS, symm_aconv

% Author David L. Donoho, 1995
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	
	y = symm_aconv( MirrorSymmFilt(qmf), rshift( UpSample(x) ) );
    
