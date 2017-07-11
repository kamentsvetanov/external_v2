function [L, D, W] = getGroupStructure(idata, normtype)
% --------------------------------------------------------------------
% Set the group information according to different grouping structures
% --------------------------------------------------------------------
% Input:
%       - idata, dataset
% Output:
%       - graph structure, weight matrix, degree matrix and laplacian
%       matrix
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: Jan-03-2015
% Updated: Jan-18-2015
% Copyright (C) 2013-2015 Li Shen (shenli@iu.edu) and Lei Du
% -----------------------------------------

[~, ncol] = size(idata);
W0 = corr(idata);
% dd = eye(ncol);
% W = W-dd;
idx = isnan(W0);
W0(idx) = 0;
% % delete corr<0.2
% idx = M<0.2;
% M(idx) = 0;


switch normtype
    case 'lp1'
        W = W0.^2;
        diag_W = diag(diag(W));
        W = W-diag_W;
        D = diag(sum(W,2));
        L = D-W;
    case '-lp1'
        W = W0.^2;
        diag_W = diag(diag(W));
        W = W-diag_W;
        D = diag(sum(W,2));
        L = D+W;
    case 'l2'
        W = W0.^2;
        for i = 1:ncol
            for j = 1:ncol
                if j==i
                    L(i,j) = sum(W(i,:));
                else
                    L(i,j) = -sign(W0(i,j))*W(i,j);
                end
            end
        end
        D = diag(L);
    case 'l1'
        W = W0.^2;
        for i = 1:ncol
            for j = 1:ncol
                if j==i
                    L(i,j) = sum(W(i,:));
                else
                    L(i,j) = -sign(W0(i,j))*W(i,j)*tan(W(i,j)*pi/2);
                end
            end
        end
        D = diag(L);
    case 'lp'
        W = W0.^2;
        diag_W = diag(diag(W));
        W = W-diag_W;
        D = diag(sum(W,2));
        L = D-W;
    case 'lpn'
        W = W0.^2;
        diag_W = diag(diag(W));
        W = W-diag_W;
        D = diag(sum(W,2));
        L = (sqrt(D))^-1*(D-W)*(sqrt(D))^-1;
end
W = W;
D = D;
L = L;