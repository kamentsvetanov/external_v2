function value = interpolate2(samples, vectors)
% interpolates the given samples to find a good value for the missing dimension of vector
% dim(samples)= NxM , dim(vectors)= (N-1)xL

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

dim = size(samples,1);
num_samples = size(samples,2);
num_vectors = size(vectors,2);
value = [];

for k=1:1:num_vectors
	vector = vectors(:,k);
	
	dist = [];
	for i=1:1:num_samples
		val = calc_genom_distance(samples(:,i), vector);
		dist = [dist, val];
	end
	
	if (min(dist) == 0)
		value = [value,samples(dim, find(dist == 0) )];	
	else
		dist = 1 ./ dist;
	  dist = dist ./ sum(dist);
		weights = samples(dim,:) .* dist(i);
		value = [value,sum(weights)];
	end
	
end