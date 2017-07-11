function [group_info] = getGroupInfo(idata, type)
% --------------------------------------------------------------------
% Set the group information according to different grouping structures
% --------------------------------------------------------------------
% Input:
%       - idata, dataset
%       - type, get different group structure based on the 'type'
% Output:
%       - group_info
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: Jan-03-2015
% Updated: Jan-18-2015
% @Indiana University School of Medicine.
% -----------------------------------------

W = corr(idata);
idx = isnan(W);
W(idx) = 0;

switch type
    case 'lp' % graph laplacian
        W2 = W.^2;
        diag_W2 = diag(diag(W2));
        W2 = W2-diag_W2;
        DD = diag(sum(W2,2));
        D = DD-W2;
end
group_info = D;