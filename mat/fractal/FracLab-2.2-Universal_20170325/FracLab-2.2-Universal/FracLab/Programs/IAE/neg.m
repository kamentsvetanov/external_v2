function erg = neg(vals, all_vals)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

erg = all_vals;
erg(vals) = [];
erg = sort(erg);