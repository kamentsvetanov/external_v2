function [k,p] = rru_pca(data)
% RRU_PCA(data)

[n,d] = size(data);
m = mean(data);
data0 = data - repmat(m, n, 1);
[v,s,u] = svd(data0,0);
e = diag(s).^2/n;
all_z = v*s;

kmax = min([d-1 n-2]);
kmax = min([kmax 10]);
ks = 1:kmax;
for i = 1:length(ks)
  k = ks(i);
  e1 = e(1:k);
  e2 = e((k+1):length(e));
  v = sum(e2)/(d-k);
  
  %z = (data*u(:,1:k))';
  % same as above
  z = all_z(:,1:k)';
  beta = max(max(abs(z)));
  p(i) = -n*d/2*log(v) -n*k*log(2*beta) - n*(d-k)/2;
  b = sqrt(2*v);
	if 0
		% slow
		for i1 = 1:n
			for j = 1:k
				p(i) = p(i) + 1/2*log(pi/2*v) + log(erf((beta - z(j,i1))/b) - ...
						erf((-beta - z(j,i1))/b));
			end
		end
	else
		% fast
		p(i) = p(i) + n*k/2*log(pi/2*v);
		%q = normcdf((beta-z)/b) - normcdf((-beta-z)/b);
		p(i) = p(i) + sum(sum(log(erf((beta - z)/b) - erf((-beta - z)/b))));
	end
  % don't use the improper prior
  %p(i) = p(i) - log(v);
end
[pmax,i] = max(p);
k = ks(i);
