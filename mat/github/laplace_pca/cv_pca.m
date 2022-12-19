function [k,e] = cv_pca(data)
% CV_PCA  Estimate latent dimensionality by 5-fold cross-validation.
%
% CV_PCA(data) returns an estimate of the latent dimensionality from data
% (data points are rows).
% [k,p] = CV_PCA(data) also returns the cross-validation score of each
% dimensionality, starting at 1.  k is the argmax of p.

% Written by Tom Minka

data = data';
[d,n] = size(data);
blocks = 5;
block_size = floor(n/blocks);
kmax = min([d-1 n-2-block_size]);
%kmax = min([kmax 15]);
ks = 1:kmax;
e = [];
for j = 1:length(ks)
  k = ks(j);
  e(j) = 0;
  % cross-validate this value of k
  for i = 1:blocks
    % break data into train and test
    t = data;
    r = (1:block_size) + (i-1)*block_size;
    test = t(:,r);
    t(:,r) = [];
    % train the model
    obj = pca_density(zeros(d,k), 1, zeros(d,1));
    obj = train(obj, t);
    % evaluate on test
    e(j) = e(j) + sum(logProb(obj, test))/cols(test)/blocks;
  end
end
[emax,j] = max(e);
k = ks(j);
