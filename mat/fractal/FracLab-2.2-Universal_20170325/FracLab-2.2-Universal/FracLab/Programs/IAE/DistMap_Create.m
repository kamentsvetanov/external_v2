function DistMap = DistMap_Create(dimension, MIN_CLUSTER_SIZE, CLUSTER_CREATION_THRESHOLD, DEFAULT_VALUE, RANGE_MIN_VECTOR, RANGE_MAX_VECTOR )
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

dims = ones(1, dimension) * 2;

DistMap.map = cell(dims);
DistMap.Config.MIN_CLUSTER_SIZE = MIN_CLUSTER_SIZE;
DistMap.Config.CLUSTER_CREATION_THRESHOLD = CLUSTER_CREATION_THRESHOLD;
DistMap.Config.RANGE_MIN_VECTOR = RANGE_MIN_VECTOR;
DistMap.Config.RANGE_MAX_VECTOR = RANGE_MAX_VECTOR;
DistMap.Config.RANGE_MIN_VECTOR_BACKUP = RANGE_MIN_VECTOR;
DistMap.Config.RANGE_MAX_VECTOR_BACKUP = RANGE_MAX_VECTOR;
DistMap.Config.DEFAULT_VALUE = DEFAULT_VALUE;
