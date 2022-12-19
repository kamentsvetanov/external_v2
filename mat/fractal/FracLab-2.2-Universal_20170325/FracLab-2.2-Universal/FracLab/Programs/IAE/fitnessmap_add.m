function new_fitnessmap = fitnessmap_add(fitnessmap, append);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if (size(append,1)<size(append,2))
	append = append';
end

new_fitnessmap = [fitnessmap, append];