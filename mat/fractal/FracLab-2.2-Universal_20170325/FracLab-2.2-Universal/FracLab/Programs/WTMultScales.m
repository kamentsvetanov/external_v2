function [WTOut]=WTMultScales( WTIn, MultVect)
% Multiplies each scale of a Wavelet decomposition with a scalar
% The scale 1 of WTIn is multiplied by MultVect(1) and so on
%
% See also FWT, IWT
%
% Author Bertrand Guiheneuf, 1996

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	if (length(MultVect) ~= (WTNbScales(WTIn)+1)),
		error('The Multiplication Vector length must be the number of scales in WT + 1');
	end;

	WTOut=WTIn;
	[I,L]=WTStruct(WTIn);

	for Sc=1:WTNbScales(WTIn)+1;
		WTOut(I(Sc):I(Sc)+L(Sc)-1) = WTIn(I(Sc):I(Sc)+L(Sc)-1) * MultVect(Sc);
	end;

% END OF WTMultScales
