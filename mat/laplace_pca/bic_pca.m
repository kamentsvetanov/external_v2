function [k,p,like] = bic_pca(data, e, d, n)
% BIC_PCA   Estimate latent dimensionality by BIC approximation.
%
% BIC_PCA([],e,d,n) returns an estimate of the latent dimensionality
% of a dataset with eigenvalues e, original dimensionality d, and size n.
% BIC_PCA(data) computes (e,d,n) from the matrix data 
% (data points are rows).
% [k,p] = BIC_PCA(...) also returns the log-probability of each 
% dimensionality, starting at 1.  k is the argmax of p.

% Written by Tom Minka

if ~isempty(data)
  [n,d] = size(data);
  m = mean(data);
  data0 = data - repmat(m, n, 1);
  e = svd(data0,0).^2/n;
end
e = e(:);
% break off the eigenvalues which are identically zero
i = find(e < eps);
e(i) = [];

kmax = min([d-1 n-2 length(e)]);
%kmax = min([kmax n/2]);
ks = 1:kmax;
for i = 1:length(ks)
  k = ks(i);
  e1 = e(1:k);
  e2 = e((k+1):length(e));
  v = sum(e2)/(d-k);
  % we can equivalently use e2 in this formula (except it has zeros)
  like(i) = -sum(log(e1)) - (d-k)*log(v);
  m = d*k - k*(k+1)/2;
  % params = the number of well-determined params
  params = m+k;
  % this is irrelevant, comes from exp(-nd/2) |A_L|^(-1/2)
  params = params + d+1;  
  % p(i) omits an irrelevant factor of 1/2
  p(i) = like(i)*n - params*log(n);
end
[pmax,i] = max(p);
k = ks(i);

