function [w1, w2, ecorr] = s2cca(X, Y, group_info, paras)
% --------------------------------------------------------------------
% S2CCA algorithm with direct iterative
% 2-norm loss with general 21-norm regularization
% --------------------------------------------------------------------
% Input:
%       - X1, geno matrix
%       - X2, pheno matrix
%       - paras, parameters: r1, r2, beta1, beta2 (unknown, get from other functions)
% Output:
%       - w1, weight of geno
%       - w2, weight of pheno.
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: Feb-06-2014.
% Copyright (C) 2013-2015 Li Shen (shenli@iu.edu) and Lei Du
% -----------------------------------------

%% Problem
%
%  max  w1' X 'Y w2 - 1/2*r1*||w1 X||^2 - 1/2*r2*||w2 Y||^2 -
%  beta1*||w1||_21group - beta2*||w2||_21group
% --------------------------------------------------------------------

% set parameters
r1 = paras.r1;
r2 = paras.r2;
beta1 = paras.beta1;
beta2 = paras.beta2;

[~, p] = size(X);
q = size(Y,2);

% set group information
X_group_idx = group_info.X_group;
X_group_set = unique(X_group_idx);
X_group_num = length(X_group_set);

Y_group_idx = group_info.Y_group;
Y_group_set = unique(Y_group_idx);
Y_group_num = length(Y_group_set);

% Calculate coverance within X and Y
XX = X'*X;
YY = Y'*Y;

% Calculate coverance between X and Y
XY = X'*Y;
YX = Y'*X;

d1 = ones(p, 1);
d2 = ones(q, 1);

w10 = ones(p, 1) ./p; % initialize w1 here
w20 = ones(q, 1)./q; % initialize w2 here
w1 = w10;
w2 = w20;
% 
max_iter = 50;
i = 0;
err = 1e-5;
diff_w1 = err*10;
diff_w2 = err*10;
while ((i < max_iter)) && ((diff_w1 > err) || (diff_w2 > err))) % default 50 times of iteration
    i = i+1;
    % get w1, given w2
    D1 = diag(d1);
    w1_new = (r1*XX + beta1*D1) \ (XY*w2);
    scale1 = sqrt(w1_new'*XX*w1_new);
    w1_new = w1_new./scale1;
    if sum(isnan(w1_new))
        continue;
    end
    diff_w1 = max(abs(w1_new - w1));
    w1 = w1_new;
    % update D1
    for X_c = 1:X_group_num
        X_idx = find(X_group_idx == X_group_set(X_c));
        wc1 = w1(X_idx, :);
        X_di = sqrt(sum(sum(wc1.*wc1))+eps);
        X_wi(X_idx) = X_di;
    end
    d1 = 0.5 ./ X_wi;
    
    % get w2, given w1
    D2 = diag(d2);
    w2_new = (r2*YY + beta2*D2) \ (YX*w1);
    scale2 = sqrt(w2_new'*YY*w2_new);
    w2_new = w2_new./scale2;
    if sum(isnan(w2_new))
        continue;
    end
    diff_w2 = max(abs(w2_new - w2));
    w2 = w2_new;
    % update D2
    for Y_c = 1:Y_group_num
        Y_idx = find(Y_group_idx == Y_group_set(Y_c));
        wc2 = w2(Y_idx, :);
        Y_di = sqrt(sum(sum(wc2.*wc2))+eps);
        Y_wi(Y_idx) = Y_di;
    end
    d2 = 0.5 ./ Y_wi;
end

% estimated correlation coefficient
ecorr = corr(X*w1, Y*w2);