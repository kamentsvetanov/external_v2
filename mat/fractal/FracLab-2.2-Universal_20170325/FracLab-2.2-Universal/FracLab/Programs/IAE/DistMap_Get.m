function output = DistMap_Get(DistMap, vector)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% normalize vectors
N_vector = (vector - DistMap.Config.RANGE_MIN_VECTOR) ./ (DistMap.Config.RANGE_MAX_VECTOR - DistMap.Config.RANGE_MIN_VECTOR);

% calculate cluster position ==> 1 or 2 for each dimension
Pos_Cluster = 1 + round(N_vector);

% test for recursive structure
if ( iscell(DistMap_Tool_get_value_from_cell(DistMap.map, Pos_Cluster)) == 1)
	
	%disp('RECURSION');
	
	% adapt parameters
	
	DistMap_Recursive = DistMap;
	DistMap_Recursive.map = DistMap_Tool_get_value_from_cell(DistMap.map, Pos_Cluster);
	
	for i=1:1:size(DistMap.Config.RANGE_MAX_VECTOR,2)
		
		Offset = (DistMap_Recursive.Config.RANGE_MAX_VECTOR(i) - DistMap_Recursive.Config.RANGE_MIN_VECTOR(i)) / 2;
		
		if (Pos_Cluster(i) == 1)
			DistMap_Recursive.Config.RANGE_MAX_VECTOR(i) = DistMap_Recursive.Config.RANGE_MIN_VECTOR(i) + Offset;
		elseif (Pos_Cluster(i) == 2)
			DistMap_Recursive.Config.RANGE_MIN_VECTOR(i) = DistMap_Recursive.Config.RANGE_MIN_VECTOR(i) + Offset;
		else
			error('Wrong index to distancemap [internal error]');
		end
		
	end

	
	% do recursive step
	
	output = DistMap_Get(DistMap_Recursive, vector);
	
	return;

	
	
else % we have reached a leaf	
	%disp('NO RECURSION');
	
	if (isempty(DistMap_Tool_get_value_from_cell(DistMap.map, Pos_Cluster)) == 1)
		disp('FIELD IS EMPTY, RETURNING DEFAULT_VALUE');
		output = DistMap.Config.DEFAULT_VALUE;
		return;

	else

		%disp('READ VALUE');
	
		output = DistMap_Tool_get_value_from_cell(DistMap.map, Pos_Cluster);
		return;
		
	end
	

end

