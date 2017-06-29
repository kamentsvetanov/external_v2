function X = wfu_bpm_design_mat(no_subj_grp,varargin)

no_grp = length(no_subj_grp);
if nargin == 1
    
    %%%%%% ANOVA %%%%%%%%%%%%
    tot_subj = sum(no_subj_grp);
    X = zeros(tot_subj,no_grp+1);
    X(:,1) = 1;
    indx = 1;
    for k = 2:no_grp + 1
        X(indx : indx + no_subj_grp(k-1)-1,k) = 1;
        indx = indx + no_subj_grp(k-1);
    end
elseif nargin == 2
    %%%%%% ANCOVA    
elseif nargin == 3
    %%%%% ANCOVA with additional confounds
end
