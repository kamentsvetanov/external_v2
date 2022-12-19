function value = DistMap_Tool_get_value_from_cell(structure, indexvector)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

pos_str = '';
for h=1:1:size(indexvector,2)
	pos_str = [pos_str num2str(indexvector(h))];
	if (h < size(indexvector,2))
		pos_str = [pos_str ','];
	end
end

value = eval(['structure{' pos_str '}']);