function Y = normalization(X)

[m,n] = size(X);
Y = X;
for j = 1 : n
    Xv = X(:,j);
    Xvn = (Xv-mean(Xv))/std(Xv);
    Y(:,j) = Xvn;
%     Y(:,j) = Xvn/sqrt(sum(Xvn.^2));
end