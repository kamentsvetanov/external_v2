function [Wo, Do, Lo] = updateGraph(W, beta, flag)
% --------------------------------------------------------------------
% Update the weight matrix, degree matrix and the laplacian matrix
% --------------------------------------------------------------------
% Input:
%       - beta, coeffients
%       - W, original weight matrix
%       - flag, the tyoe of laplacian matrix L, e.g. +1 or -1
% Output:
%       - Wo, reweighted weight matrix W
%       - Do, reweighted degree matrix D
%       - Lo, reweighted laplacian matrix L
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: June-15-2015
% Date updated: June-15-2015
% Copyright (C) 2013-2015 Li Shen (shenli@iu.edu) and Lei Du
% -----------------------------------------

ncol = length(beta);
switch flag
    case '1' % ui - uj
        for i = 1:ncol
            for j = 1:ncol
                if i ~= j
                    temp = sqrt((beta(i)-beta(j))^2+eps);
                    Wo(i,j) = W(i,j)/temp; % reweight each edge
                end
            end
        end
        Do = diag(sum(Wo,2)); % sum of rows
        Lo = Do-Wo;
    case '-1' % ui + uj
        for i = 1:ncol
            for j = 1:ncol
                if i ~= j
                    temp = sqrt((beta(i)+beta(j))^2+eps);
                    Wo(i,j) = W(i,j)/temp; % reweight each edge
                end
            end
        end
        Do = diag(sum(Wo,2)); % sum of rows
        Lo = Do+Wo;
end