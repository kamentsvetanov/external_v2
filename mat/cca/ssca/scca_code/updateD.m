function [d, struct_out] = updateD(beta, struct_in,lnorm)
% --------------------------------------------------------------------
% Update the diagnoal matrix
% --------------------------------------------------------------------
% Input:
%       - beta, coeffients
%       - group_in, matrxi regarding group structure
% Output:
%       - d, diagonal of matrix D
%       - group_out, found group structure
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: Jan-02-2015
% Date updated: Jan-09-2015
% @Indiana University School of Medicine.
% -----------------------------------------

% group = 0;
% if nargin == 1
%     d = 1 ./ sqrt(beta.^2+eps);
%     group = sum(abs(beta));
% else
%     [nrow,ncol] = size(group_in);
%     for g_i = 1:nrow
%         idx = group_in(g_i,:)~=0;
%         wc1 = beta(idx, :);
%         group = sqrt(sum(wc1.*wc1))+group; % for calculate objective function
%         d_gi = sqrt(sum(wc1.*wc1)+eps);
%         beta_i(idx) = d_gi;
%     end
%     d = 1 ./ beta_i;
% end
% group_out = group;

group = 0;
if nargin == 1
    d = 1 ./ sqrt(beta.^2+eps);
    group = sum(abs(beta));
elseif strcmpi(lnorm,'group')
    [nrow,ncol] = size(struct_in);
    for g_i = 1:nrow
        idx = struct_in(g_i,:)~=0;
        wc1 = beta(idx);
        group = sqrt(sum(wc1.*wc1))+group; % for calculate objective function
        d_gi = sqrt(sum(wc1.*wc1)+eps);
        beta_i(idx) = d_gi;
    end
    d = 1 ./ beta_i;
elseif strcmpi(lnorm,'graph')
    [nrow,ncol] = size(struct_in);
    coef = zeros(nrow,ncol);
    for g_i = 1:nrow
        idx0 = struct_in(g_i,:)==0;
        wc1 = beta;
        wc1(idx0)=0;
        group = sqrt(sum(wc1.*wc1))+group; % for calculate objective function
        d_gi = sqrt(sum(wc1.*wc1)+eps);
        coef(g_i,idx0) = d_gi;
%         beta_i(idx) = d_gi;
    end
    beta_i = sum(coef,1);
    d = 1 ./ beta_i;
end
struct_out = group;