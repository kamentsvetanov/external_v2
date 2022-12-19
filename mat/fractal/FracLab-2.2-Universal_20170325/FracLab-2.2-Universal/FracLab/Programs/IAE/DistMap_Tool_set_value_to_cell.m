function new_structure = DistMap_Tool_set_value_to_cell(structure, indexvector, value)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

new_structure = structure;

pos_str = '';
for h=1:1:size(indexvector,2)
	pos_str = [pos_str num2str(indexvector(h))];
	if (h < size(indexvector,2))
		pos_str = [pos_str ','];
	end
end

eval(['new_structure{' pos_str '}=value;']);