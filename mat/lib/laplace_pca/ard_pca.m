function [k,e] = ard_pca(data)
% ARD_PCA  Estimate latent dimensionality by automatic relevance determination.
%
% ARD_PCA(data) returns an estimate of the latent dimensionality from data
% (data points are rows).

% Written by Tom Minka

data = data';
[d,n] = size(data);
k = min([d-1 n-2]);
k = min([k 10]);

m = mean(data,2);
s = moment2(data,m);
tr_s = trace(s);

% initialize with ML
[v,e] = sorted_eig(s);
h = v(:,1:k);
e = diag(e);
e1 = e(1:k);
e2 = e((k+1):length(s));
v = sum(e2)/(length(e)-k);
h = h*diag(sqrt(e1 - repmat(v, k, 1)));

alpha = ones(1,k);
e = [];
for iter = 1:1000
  old_h = h;
  old_v = v;
  
  c = h'*h+v*eye(cols(h));
  ic = inv(c);
  % xw = 1/n sum_n (t_n - mu) x_n'
  xw = s*h*ic;
  % ww = 1/n sum_n x_n x_n'
  % note that (11) in Bishop's paper is wrong --- should be sigma^2*inv(M)
  ww = ic*h'*s*h*ic + v*ic;
  h = xw*inv(ww + v*diag(alpha/n));
  %v = tr_s - 2*trace(xw*h') + trace(ww*(h'*h));
  v = tr_s - trace(xw*h');
  v = v/d;
  
  e(iter) = sum(normpdfln(data, m, [], h*h'+v*eye(d)));
  hmag = col_sum(h.^2);
  e(iter) = e(iter) + d/2*sum(log(alpha)) - 1/2*sum(alpha .* hmag);
  
  if max(abs(h - old_h)) < 1e-4 & max(abs(v - old_v)) < 1e-4
    %break
    old_alpha = alpha;
    alpha = d./hmag;
    if max(abs(alpha - old_alpha)) < 1e-4
      break
    end
    i = find(alpha > 1e+12);
    alpha(i) = [];
    h(:,i) = [];
    k = cols(h);
  end
end
