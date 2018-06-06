function [k,p] = rrn_pca(data,e,d,n)

if ~isempty(data)
  [n,d] = size(data);
  m = mean(data);
  data0 = data - repmat(m, n, 1);
  e = svd(data0,0).^2/n;
end
e = e(:);

kmax = min([d-1 n-2]);
ks = 1:kmax;
p = zeros(size(ks));
for i = 1:length(ks)
  k = ks(i);
  e1 = e(1:k);
  e2 = e((k+1):length(e));
  v = sum(e2)/(d-k);
  
  p(i) = -k*log(sum(e1)/k) - (d-k)*log(v);
end
[pmax,i] = max(p);
k = ks(i);
