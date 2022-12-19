function y = lshift(x)
% lshift -- Circular left shift of 1-d signal
%  Usage
%    l = lshift(x)
%  Inputs
%    x   1-d signal
%  Outputs
%    l   1-d signal 
%        l(i) = x(i+1) except l(n) = x(1)

% Author Iain M. Johnstone, 1993
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	y = [ x( 2:length(x) ) x(1) ];
    
