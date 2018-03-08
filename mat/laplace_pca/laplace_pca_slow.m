function [k,p] = laplace_pca_slow(data, e, d, n)
% LAPLACE_PCA   Estimate latent dimensionality by Laplace approximation.
%
% k = LAPLACE_PCA([],e,d,n) returns an estimate of the latent dimensionality
% of a dataset with eigenvalues e, original dimensionality d, and size n.
% LAPLACE_PCA(data) computes (e,d,n) from the matrix data 
% (data points are rows)
% [k,p] = LAPLACE_PCA(...) also returns the log-probability of each 
% dimensionality, starting at 1.  k is the argmax of p.

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

n1 = n-1;
ehat = e*n/n1;
kmax = length(e)-1;
%kmax = min([kmax 15]);
ks = 1:kmax;
% normalizing constant for the prior (from James)
% the factor of 2 is cancelled when we integrate over the 2^k possible modes
z = log(2) + (d-ks+1)/2*log(pi) - gammaln((d-ks+1)/2);
for i = 1:length(ks)
  k = ks(i);
  e1 = ehat(1:k);
  e2 = ehat((k+1):length(e));
  v = sum(e2)/(d-k);
  p(i) = sum(log(e1)) + (d-k)*log(v);
  p(i) = p(i)*(-n1/2) - sum(z(1:k)) - k/2*log(n1);
  % compute logdet(H)
  invlambda_hat = 1./[e1; repmat(v, length(e2), 1)];
  h = 0;
  for j1 = 1:k
    for j2 = (j1+1):length(e)
      h = h + log(invlambda_hat(j2) - invlambda_hat(j1)) + log(e(j1) - e(j2));
    end
		% count the zero eigenvalues all at once
		h = h + (d-length(e))*(log(1/v - invlambda_hat(j1)) + log(e(j1)));
  end
  m = d*k-k*(k+1)/2;
  h = h + m*log(n);
  p(i) = p(i) + (m+k)/2*log(2*pi) - h/2;
  % missing terms added August 21 2008
  p(i) = p(i) + 1.5*k*log(2);
  p(i) = p(i) - 0.5*log(d-k);
end
[pmax,i] = max(p);
k = ks(i);

v0 = mean(ehat);
p0 = -n1*d/2*log(v0) - 0.5*log(d);
if p0 >= pmax
  k = 0;
end
p = [p0 p];
