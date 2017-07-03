function obj = pca_density(h, v, m)
% PCA_DENSITY   Principal Components Analysis density.
%    PCA_DENSITY(h, v, m) returns a reduced-rank Gaussian density with 
%    subspace component defined by the columns of h and noise component
%    defined by v (a scalar).  m is the mean (the offset of the subspace).

s = struct('mean', m, 'v', v, 'h', h);
obj = class(s, 'pca_density');
