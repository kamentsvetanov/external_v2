function [u, v, objFun, U, V] = gosc_scca(X, Y, paras)
% --------------------------------------------------------------------
% Structured SCCA vis Graph OSCAR (GOSC-SCCA)
% --------------------------------------------------------------------
% Input:
%       - X, geno matrix
%       - Y, pheno matrix
%       - paras, parameters: gamma1, gamma2, beta1, beta2 (unknown, tuned from other functions)
% Output:
%       - u, weight of X
%       - v, weight of Y
%       - corrs, all corr of every iteration
%       - U, all u of every iteration
%       - V, all v of every iteration.
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: DEC-19-2014
% Updated: June-02-2015
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
X_number_feature = size(X,2);
Y_number_feature = size(Y,2);

%-------------------------
% Calculate coverance within Geno and Pheno
% XX = X'*X;
% YY = Y'*Y;
XX = cov(X);
YY = cov(Y);

%-------------------------
% Calculate coverance between Geno and Pheno
% XY = X'*Y;
% YX = Y'*X;
XY = bsxfun(@minus,X,mean(X))'*bsxfun(@minus,Y,mean(Y))/(size(X,1)-1);
YX = bsxfun(@minus,Y,mean(Y))'*bsxfun(@minus,X,mean(X))/(size(Y,1)-1);

%-------------------------
% Identify matrix
d10 = ones(X_number_feature, 1);
d20 = ones(Y_number_feature, 1);
d11 = ones(X_number_feature, 1);
d12 = ones(X_number_feature, 1);
d21 = ones(Y_number_feature, 1);
d22 = ones(Y_number_feature, 1);

% pre calculate for loop
% % set structure information
[HH1,D11,W11] = getGroupStructure(X, 'lp1');
[HH2,D12,W12] = getGroupStructure(X, '-lp1');
[TT1,D21,W21] = getGroupStructure(Y, 'lp1');
[TT2,D22,W22] = getGroupStructure(Y, '-lp1');

%-------------------------
% initialization
u0 = ones(X_number_feature, 1);
v0 = ones(Y_number_feature, 1);
scale1 = sqrt(u0'*XX*u0);
u = u0./scale1;
scale2 = sqrt(v0'*YY*v0);
v = v0./scale2;

U = [];
V = [];
objFun = [];

max_iter = 50; % pre-set, default set to 50
i = 0; % counter
err = 1e-6; % 0.01 ~ 0.05
diff_u = err*10;
diff_v = err*10;
diff_obj = err*10;
%-------------------------
% while (i < max_iter && diff_obj > err) % default 50 times of iteration
while (i < max_iter && diff_u > err && diff_v > err) % default 50 times of iteration
    i = i+1;
    
    % fix v, solve u
    iter1 = 0;
    while ((iter1 < max_iter) && (diff_u > err))
        iter1 = iter1+1;
        D11 = diag(d11);
        M1 = alpha1*XX+lambda1*(HH1+HH2)+beta1*D11;
        u_new = M1 \ (XY*v);
%         scale1 = sqrt(u_new'*XX*u_new);
%         u_new = u_new./scale1;
        if sum(isnan(u_new))
            u = u+eps;
            v = v+eps;
            continue;
        end
        diff_u = max(abs(u_new - u));
        u = u_new;
        [d11, u_group1] = updateD(u);
        [W11, D11, HH1] = updateGraph(W11, u, '1');
        [W12, D12, HH2] = updateGraph(W12, u, '-1');
    end
    
    %**********************************************************************
    % fix u, solve v
    iter2 = 0;
    while ((iter2 < max_iter) && (diff_v > err))
        iter2 = iter2+1;
        D21 = diag(d21);
        M2 = alpha2*YY+lambda2*(TT1+TT2)+beta2*D21;
        v_new = M2 \ (YX*u);
%         scale2 = sqrt(v_new'*YY*v_new);
%         v_new = v_new./scale2;
        if sum(isnan(v_new))
            u = u+eps;
            v = v+eps;
            continue;
        end
        diff_v = max(abs(v_new - v));
        v = v_new;
        [d21, v_group1] = updateD(v);
        [W21, D21, TT1] = updateGraph(W21, v, '1');
        [W22, D22, TT2] = updateGraph(W22, v, '-1');
    end
    
    %-------------------------
    % save results for every iteration
    U(:,i) = u;
    V(:,i) = v;
    obj11 = getGraphNorm(W11, u);
    obj12 = getGraphNorm(W12, u);
    obj21 = getGraphNorm(W21, v);
    obj22 = getGraphNorm(W22, v);
    objFun(i) = -u'*XY*v+lambda1*(obj11+obj12)+lambda2*(obj21+obj22)+beta1*u_group1+beta2*v_group1+alpha1*u'*XX*u+alpha2*v'*YY*v; % objective function
%     
    if i ~= 1
        diff_obj = abs((objFun(i)-objFun(i-1))/objFun(i-1)); % relative prediction error
    end
end
scale1 = sqrt(u'*XX*u);
u = u./scale1;
scale2 = sqrt(v'*YY*v);
v = v/scale2;