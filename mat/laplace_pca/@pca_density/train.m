function obj = train(obj, data)

obj.mean = mean(data,2);
s = moment2(data, obj.mean);

k = cols(obj.h);
[v,e] = sorted_eig(s);
obj.h = v(:,1:k);
e = diag(e);
e1 = e(1:k);
e2 = e((k+1):length(s));
obj.v = sum(e2)/(length(e)-k);
if obj.v < eps
  obj.v = eps;
end
obj.h = obj.h*diag(sqrt(e1 - repmat(obj.v, k, 1)));
