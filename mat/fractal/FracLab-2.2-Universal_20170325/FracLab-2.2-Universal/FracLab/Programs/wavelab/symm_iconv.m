function y = symm_iconv(sf,x)
% symm_iconv -- Symmetric Convolution Tool for Two-Scale Transform
%  Usage
%    y = iconv(sf,x)
%  Inputs
%    sf  symmetric filter
%    x   1-d signal
%  Output
%    y    filtered result
%
%  Description
%    Filtering by periodic convolution of x with sf
%
%  See Also
%    symm_aconv, UpDyadHi_PBS, UpDyadLo_PBS, DownDyadHi_PBS, DownDyadLo_PBS

% Author Shaobing Chen and David L. Donoho, 1995
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	n = length(x);
	p = length(sf);
	if p <= n,
	   xpadded = [x((n+1-p):n) x];
	else
	   z = zeros(1,p);
	   for i=1:p,
		   imod = 1 + rem(p*n -p + i-1,n);
		   z(i) = x(imod);
	   end
	   xpadded = [z x];
	end
	ypadded = filter(sf,1,xpadded);
	y = ypadded((p+1):(n+p));
	
	shift = (p+1)/2;
	shift = 1 + rem(shift-1, n);
	y = [y(shift:n) y(1:(shift-1))];

    
