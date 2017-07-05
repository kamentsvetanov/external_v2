function [D] = getGroupInfo(idata, normtype)
% --------------------------------------------------------------------
% Set the group information according to different grouping structures
% --------------------------------------------------------------------
% Input:
%       - idata, dataset
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

switch normtype
    case 'lp'
        W2 = W.^2;
        diag_W2 = diag(diag(W2));
        W2 = W2-diag_W2;
        DD = diag(sum(W2,2));
        D = DD-W2;
end