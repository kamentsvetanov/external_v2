function [gsum] = getGraphNorm(W, beta)
% --------------------------------------------------------------------
% Get the objective function value for graph
% --------------------------------------------------------------------
% Input:
%       - beta, coeffients
%       - W, original weight matrix
% Output:
%       - Wo, reweighted weight matrix W
%       - Do, reweighted degree matrix D
%       - Lo, reweighted laplacian matrix L
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: June-15-2015
% Date updated: June-15-2015
% @Indiana University School of Medicine.
% -----------------------------------------

ncol = length(beta);
gsum = 0; % graph norm
for i = 1:ncol
    for j = 1:ncol
        if i ~= j
            gsum = W(i,j)*abs(beta(i)-beta(j))+gsum;
        end
    end
end