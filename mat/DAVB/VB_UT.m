function [muU,SU,CU] = VB_UT(m,P,fname,args,argn,alpha,beta,k)
% Unscented transform
% function [muU,SU,CU] = VB_UT(m,P,fname,args,argn,L,alpha,beta,k)
% This function computes the unscented transform of a gaussian variable X
% mapped through a nonlinear function f. This solves the problem of
% matching the first two moments of f(X), knowing that X ~ N(m,P).
% IN:
%   - m: nx1 mean vector of the Gaussian distribution
%   - V: nxn covariance matrix of the Gaussian distribution
%   - fname: the name or handle of the mapping function
%   - args: a cell containing the arguments of the mapping function
%   - argn: the index of the argument X of the mapping function {1}
%   - alpha/beta/k: internal parameters of the unsented transform {1,1,1}
% OUT:
%   - muU: mean of the Gaussian approximation of the distribution of f(X)
%   - SU: covariance matrix of the Gaussian approximation of the
%   distribution of f(X)
%   - CU: covariance matrix between X and f(X).


try argn; catch argn = 1; end
try alpha; catch alpha = 1; end
try beta; catch beta = 1; end
try k; catch k = 1; end
    
L = size(m,1);
c = alpha.^2.*(L+k);
lambda = alpha.^2.*(L+k) - L;

% form weight matrices
Wm0 = lambda./(lambda+L);
Wc0 = Wm0 + 1-alpha.^2 + beta;
Wm = [Wm0;(1./(2*(L+lambda))).*ones(2*L,1)];
Wc = [Wc0;(1./(2*(L+lambda))).*ones(2*L,1)];

tmp = eye(2*L+1) - repmat(Wm,1,2*L+1);
W = tmp*diag(Wc)*tmp';

% form sigma points
[u,s,v] = svd(full(P));
sP = u*sqrt(s)*v';
X = repmat(m,1,2*L+1) + sqrt(c).*[zeros(L,1),sP,-sP];

% get mode (and dimensions of the function image)
args{argn} = X(:,1);
Y1 = feval(fname,args{:});
Y = zeros(size(Y1,1),2*L+1);
Y(:,1) = Y1;

% loop through sigma points
for i=1:2*L
    args{argn} = X(:,i+1);
    Y(:,i+1) = feval(fname,args{:});  
end

% form first and second order moments
muU = Y*Wm;
SU = Y*W*Y';
CU = X*W*Y';


