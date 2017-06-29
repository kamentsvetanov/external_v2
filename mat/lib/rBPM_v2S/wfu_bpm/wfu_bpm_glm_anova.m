function [BETA,X,dof,sig2, Es] = wfu_bpm_glm_anova(data,brain_mask,no_subj,nr,BPM)
%--------------------------------------------------------------------- 
%                            GLM anova
%-------------------------------------------------------------------

[n,ng] = size(data); % ng - number of groups
Data = [];

% reorganizaing volumes into matrices of subjs by voxels
for k = 1:ng
    [M,N,s1] = size( data{k} );
%     no_subj(k) = s1;
    data1 = reshape(data{k},M*N,s1)';
    Data = [Data;data1];
end
Tsubj = sum(no_subj);
% finding out which are the voxels (columns) corresponding to the brain
% region

mask1 = reshape(brain_mask,M*N,1)';
indx  = find(mask1 == 1);
Data  = Data(:,indx);
X     = wfu_bpm_design_mat(no_subj);
if isfield(BPM,'ancova_ROI_reg')
    X = [X BPM.ancova_ROI_reg];
end

beta = X\Data;
% nc   = size(beta,1);
% BETA = cell(1,nc);
BETA = zeros(M,N,nr);
for k = 1:nr
    beta1 = zeros(M*N,1);
    beta1(indx) = beta(k,:);
    BETA(:,:,k) = reshape(beta1,M,N);
end

Es = zeros(M,N,Tsubj);
E = Data - X*beta ;
for k1 = 1:size(E,1)
    e = zeros(M*N,1);
    e(indx) = E(k1,:);    
    Es(:,:,k1) = reshape(e,M,N) ;
end

p = rank(X);
% T - total number of subjects in all the groups
dof = Tsubj - p;       %   dof - degrees of freedom
sig2a = sum(E.*E)/(dof);
sig2 = zeros(M*N,1);
sig2(indx) = sig2a;
sig2 =  reshape(sig2,M,N);


