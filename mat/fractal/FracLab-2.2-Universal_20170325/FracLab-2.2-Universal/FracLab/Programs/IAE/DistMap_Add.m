function New_DistMap = DistMap_Add(DistMap, vector, value)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

New_DistMap = DistMap;

% Truncate vector
vector = min(vector, DistMap.Config.RANGE_MAX_VECTOR);
vector = max(vector, DistMap.Config.RANGE_MIN_VECTOR);

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

	
	
% RANGE_MIN_VECTOR = DistMap.Config.RANGE_MIN_VECTOR
% RANGE_MAX_VECTOR = DistMap.Config.RANGE_MAX_VECTOR
	
	% do recursive step
	% DistMap.map{Pos_Cluster} = DistMap_Add(DistMap_Recursive, vector1, vector2, value);
	
	rec = DistMap_Add(DistMap_Recursive, vector, value);
	DistMap.map = DistMap_Tool_set_value_to_cell(DistMap.map, Pos_Cluster, rec.map);
	
	New_DistMap = DistMap;
	return;

	
	
else % we have reached a leaf	
	%disp('NO RECURSION');
	
	% calculate present clustersize
	cluster_size = (DistMap.Config.RANGE_MIN_VECTOR - DistMap.Config.RANGE_MAX_VECTOR) / (DistMap.Config.RANGE_MIN_VECTOR_BACKUP - DistMap.Config.RANGE_MAX_VECTOR_BACKUP);
	
	assignin('base','M',DistMap.map);
	
	
	if (isempty(DistMap_Tool_get_value_from_cell(DistMap.map, Pos_Cluster)) == 1)
		%disp('DIRECT DROP');
		DistMap.map = DistMap_Tool_set_value_to_cell(DistMap.map, Pos_Cluster, value);
		New_DistMap = DistMap;
		return;

	elseif ( abs(DistMap_Tool_get_value_from_cell(DistMap.map, Pos_Cluster) - value) > DistMap.Config.CLUSTER_CREATION_THRESHOLD && cluster_size >= DistMap.Config.MIN_CLUSTER_SIZE)
	% Create and fill a new sub-cluster 

		%disp('CREATE CLUSTER');
	
		old_value = DistMap_Tool_get_value_from_cell(DistMap.map, Pos_Cluster);
		
		% calculate position in a new cluster
			% new ranges
				
			 RANGE_MIN_VECTOR = DistMap.Config.RANGE_MIN_VECTOR;
			 RANGE_MAX_VECTOR = DistMap.Config.RANGE_MAX_VECTOR;
				
				for i=1:1:size(Pos_Cluster,2)
		
					Offset = (DistMap.Config.RANGE_MAX_VECTOR(i) - DistMap.Config.RANGE_MIN_VECTOR(i)) / 2;
		
					if (Pos_Cluster(i) == 1)
						RANGE_MAX_VECTOR(i) = DistMap.Config.RANGE_MIN_VECTOR(i) + Offset;
					elseif (Pos_Cluster(i) == 2)
						RANGE_MIN_VECTOR(i) = DistMap.Config.RANGE_MIN_VECTOR(i) + Offset;
					else
						error('Wrong index to distancemap [internal error]');
					end
		
				end
				
			
			% new normalized vectors
		
				N_vector = (vector - RANGE_MIN_VECTOR) ./ (RANGE_MAX_VECTOR - RANGE_MIN_VECTOR);
				

			% calculate new cluster position
				Position = 1 + round(N_vector);
		
				
		cluster_dims = ones(1, size(Pos_Cluster,2)) * 2;
		new_cluster = cell(cluster_dims);
		

		injection_pos = DistMap_Tool_sub2ind(new_cluster, Position);
		
		
		for p=1:1:2^size(size(new_cluster),2)
						
			if (p ~= injection_pos)
				% fill with old value
				new_cluster{p} = old_value;
			else
				% inject new value
				new_cluster{p} = value;
			end
			
		end
		
		DistMap.map = DistMap_Tool_set_value_to_cell(DistMap.map, Pos_Cluster, new_cluster);
		New_DistMap = DistMap;
		return;
		
	end
	

end

if (cluster_size < DistMap.Config.MIN_CLUSTER_SIZE)
	%disp(['MINIMUM CLUSTERSIZE (' num2str(cluster_size) '<=' num2str(DistMap.Config.MIN_CLUSTER_SIZE) ') REACHED']);	
end

%disp('NOTHING CHANGED');

