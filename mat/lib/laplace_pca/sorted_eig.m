function [v,e] = sorted_eig(a)
% returns eigenvectors and eigenvalues in descending order

[v,e] = eig(a);
d = diag(e);
[y,i] = sort(d);
d = d(i);
v = v(:,i);

e = diag(flipud(d));
v = fliplr(v);

if nargout < 2
  v = diag(e);
end
