function [u, v, obj] = A_KG_SCCA(X, Y, group, network, paras)

%% Problem
%  Solution with scaling and constraints in lagrangian form
%  max  u' X 'Y v - 1/2 *||u X1||^2 - 1/2 *||v Y||^2 -
%  - beta1*||v||_21group - beta2*||alpha*u||_2- theta1*||u||_1 - theta2*||v||_1
% -------------------------------------------------------------------------
% Input:
%       - X: n x c, geno matrix,
%       - Y, n x d, pheno matrix
%       - group: LD block information
%       - network: p x d, imaging connectivity matrix
%       - paras, parameters: beta1, beta2,theta1,theta2 (unknown, get from other functions)
% Output:
%       - u, c x 1, weight of geno
%       - v, d x 1, weight of pheno.
%       - obj: objective function value of each iteration
%--------------------------------------------------------------------------
% Citation:
%    Yan J, Du L, Kim S, Risacher SL, Huang H, Moore JH, Saykin AJ, Shen L, for the ADNI (2014) 
%    Transcriptome-guided amyloid imaging genetic analysis via a novel structured sparse learning algorithm. 
%    Bioinformatics, 2014, in press. 
%--------------------------------------------------------------------------
% Author: Jingwen Yan, jingyan@indiana.edu
% Date created: 07/12/2014.
% @Indiana University School of Medicine.
% -------------------------------------------------------------------------

% set parameters
b1 = paras.beta1;
b2 = paras.beta2;
t1 = paras.theta1;
t2 = paras.theta2;

% initialize canonical loadings
n_XVar = size(X,2);
n_YVar = size(Y,2);
u = ones(n_XVar, 1) ./n_XVar;
v = ones(n_YVar, 1)./n_YVar;

% stop criteria
stop_err = 10e-4;

max_iter = 100;
for iter = 1:max_iter
    
    % fix v, get u
    res = Y*v;
    
    XX = X'*X;
    XY = X'*res;

    [s_group,s_idx] = sort(group);
    s_u = u(s_idx);
    [tmp,reverse_idx] = sort(s_idx);
    Wi = cell2mat(accumarray(s_group,s_u,[],@(x){repmat(sqrt(sum(x.*x)+eps),length(x),1)}));
    Wi = Wi(reverse_idx);
    
    D1 = diag(1./Wi);
    Wi = sqrt(sum(u.*u,2)+eps);
    D2 = diag(1./Wi);
    u = (XX+b1*D1+t1*D2)\XY;
    scale1 = sqrt((X*u)' * X * u);
    u = u / scale1;
    
    % fix u, get v
    res = X*u;
    D1 = network' * network;
    XX = Y' * Y;
    XY = Y' * res;
    Wi = sqrt(sum(v.*v,2)+eps);
    D2 = diag(1./Wi);
    v = (XX+b2*D1+t2*D2)\XY;
    scale2 = sqrt((Y*v)' * Y * v);
    v = v / scale2;
    
    grp_obj = cell2mat(accumarray(group,u,[],@(x){sqrt(sum(x.*x))}));
    
    obj(iter) = u'* X' * Y * v - 0.5*norm(X*u,2) - 0.5*norm(Y*v,2)...
        - b1*sum(grp_obj) - 0.5*b2*norm(network*v,2) - t1*sum(abs(u)) - t2*sum(abs(v));
    
    if iter > 2 && abs(obj(iter) - obj(iter-1)) < stop_err
        break;
    end
    
end
