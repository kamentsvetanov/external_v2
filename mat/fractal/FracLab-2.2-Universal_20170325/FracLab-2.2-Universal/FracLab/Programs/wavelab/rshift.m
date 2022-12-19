function y = rshift(x)
% rshift -- Circular right shift of 1-d signal
%  Usage
%    r = rshift(x)
%  Inputs
%    x   1-d signal
%  Outputs
%    r   1-d signal 
%        r(i) = x(i-1) except r(1) = x(n)

% Author Iain M. JohnStone, 1993
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	n = length(x);
	y = [ x(n) x( 1: (n-1) )];

