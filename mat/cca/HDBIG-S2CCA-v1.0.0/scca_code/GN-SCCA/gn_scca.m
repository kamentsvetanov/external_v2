function [u, v, ecorr] = gn_scca(X, Y, paras)
% --------------------------------------------------------------------
% GraphNet based SCCA (GN-SCCA)
% --------------------------------------------------------------------
% Input:
%       - X, X matrix
%       - Y, Y matrix
%       - paras, parameters
% Output:
%       - u, weight of X
%       - v, weight of Y
%       - ecorr, estimated correlation coefficient
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: DEC-19-2014
% Date updated: Jan-17-2015
% Copyright (C) 2013-2015 Li Shen (shenli@iu.edu) and Lei Du
% -----------------------------------------

%-------------------------
% set parameters
alpha1 = paras.alpha1;
alpha2 = paras.alpha2;
lambda1 = paras.lambda1;
lambda2 = paras.lambda2;
beta1 = paras.beta1;
beta2 = paras.beta2;
p = size(X,2);
q = size(Y,2);

%-------------------------
% Calculate coverance within X and Y
XX = X'*X;
YY = Y'*Y;

%-------------------------
% Calculate coverance between X and Y
XY = X'*Y;
YX = Y'*X;

%-------------------------
% Identify matrix
d11 = ones(p, 1);
d21 = ones(q, 1);

% set group information
G1 = getGroupInfo(X,'lp');
G2 = getGroupInfo(Y,'lp');

%-------------------------
% initialization
u = ones(p, 1) ./p; % initialize u here
v = ones(q, 1)./q; % initialize v here

max_iter = 50; % pre-set, default set to 50
i = 0; % counter
err = 1e-5; % 0.01 ~ 0.05
diff_u = err*10;
diff_v = err*10;
%-------------------------
while (i < max_iter && diff_u > err && diff_v > err) % default 50 times of iteration
    i = i+1;    
    % fix v, solve u
    D11 = diag(d11);
    T1 = XY*v;
    M1 = alpha1*XX+lambda1*G1+beta1*D11;
    u_new = M1 \ T1;
    if sum(isnan(u_new))
        u = u+eps;
        v = v+eps;
        continue;
    end
    diff_u = max(abs(u_new - u));
    u = u_new;
    d11 = 1 ./ sqrt(u.^2+eps);
    
    %**********************************************************************
    
    % fix u, solve v
    D21 = diag(d21);
    T2 = YX*u;
    M2 = alpha2*YY+lambda2*G2+beta2*D21;
    v_new = M2 \ T2;
    if sum(isnan(v_new))
        u = u+eps;
        v = v+eps;
        continue;
    end
    diff_v = max(abs(v_new - v));
    v = v_new;
    d21 = 1 ./ sqrt(v.^2+eps);
end

% scale u and v
scale1 = sqrt(u'*XX*u);
u = u./scale1;
scale2 = sqrt(v'*YY*v);
v = v./scale2;

% estimated correlation coefficient
ecorr = corr(X*u, Y*v);