function y = MirrorSymmFilt(x)
% MirrorSymmFilt -- apply (-1)^t modulation to symmetric filter
%  Usage
%    h = MirrorSymmFilt(l)
%  Inputs
%    l   symmetric filter
%  Outputs
%    h   symmetric filter with DC frequency content shifted
%        to Nyquist frequency
%
%  Description
%    h(t) = (-1)^t  * x(t),  -k <= t <= k ; length(x)=2k+1
%
%  See Also
%    DownDyadHi_PBS

% Author Iain M. Johnstone, 1993
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

    k = (length(x)-1)/2;
	y = ( (-1).^((-k):k) ) .*x;
    
