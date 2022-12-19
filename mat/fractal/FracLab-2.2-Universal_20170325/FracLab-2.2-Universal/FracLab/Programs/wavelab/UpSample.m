function y = UpSample(x,s)
% UpSample -- Upsampling operator
%  Usage
%    u = UpSample(d[,s]) 
%  Inputs
%    d   1-d signal, of length n
%    s   upsampling scale, default = 2
%  Outputs
%    u   1-d signal, of length s*n with zeros
%        interpolating alternate samples
%        u(s*i-1) = d(i), i=1,...,n

% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	if nargin == 1, s = 2; end
	n = length(x)*s;
	y = zeros(1,n);
	y(1:s:(n-s+1) )=x;