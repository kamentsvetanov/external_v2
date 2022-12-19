function imputsignal_normalized = frac_normalize (inputsignal, minval, maxval)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin <=2
	minval = 0;
	maxval = 1;
end
if minval > maxval
	tempval = minval;
	minval = maxval;
	maxval = tempval;
end
		
amplval = maxval - minval;

sizesignal = prod(size(inputsignal));
mininput = nanmin(reshape(inputsignal,[1 sizesignal]));
maxinput = nanmax(reshape(inputsignal,[1 sizesignal]));
amplinput = maxinput - mininput;

if amplinput*amplval~=0
    imputsignal_normalized = ((inputsignal-mininput)/amplinput*amplval)+minval;
else
    imputsignal_normalized = (maxval+minval)/2*ones(size(inputsignal));
end