function [BETA_COEF,XX,dof,sig2,E] = wfu_bpm_glm(data,confound,col_conf, brain_mask, type,no_subj,nr,BETA_COEF,E,sig2,dof,XX,flag,Rwfun,PMaxOut)
%-----------------------------------------------------------------------%
%                         BPM GLM                                       %                         
%                                                                       %
%  It fits a GLM voxel-wise including imaging covariates for one slice  %
%  Non-imaging covariates  can be included in the analysis.             %
%                                                                       %
%-----------------------------------------------------------------------%

[n,ng] = size(data); % ng - number of groups
[n,nc] = size(confound); % nc - number of confounds
Tsubj  = sum(no_subj);
[M,N,s] = size( data{1} );
Data = [];
err = 1e-4;

if strcmp(type,'ANCOVA')
    X = wfu_bpm_design_mat(no_subj); 
end

if strcmp(type,'REGRESSION')
    X = ones(no_subj,1);
end

%----- Append non-imaging confounds -----------%
if ~isempty(col_conf)      
    X = [X col_conf];
end

% ----------- The analysis is performed on voxel by voxel basis --------- %

[I,J]          = find(brain_mask > 0);
for kmv = 1:length(I)
    
    m = I(kmv);
    n = J(kmv);   
    if ~isempty(confound)
        X1 = [];   % for confounds
        for c = 1:nc
            x1 = [];
            for g = 1:ng
                x11 = confound{c}{g}(m,n,:);
                x1 = [x1;x11(:)];
            end 
            X1 = [X1 x1];
        end
        X2 = [X X1];     % complete Design Matrix
    else
        X2 = X;
    end
    % ------- creating the data vector ---------- %
    y = [];
    for g  = 1:ng
        y1 = data{g}(m,n,:);
        y  = [y;y1(:)];
    end
    
    p                = rank(X2)          ;
    
    if flag == 0
        beta             = X2\y          ;
        e                = y - X2*beta   ;
        sig2(m,n)        = e'*e/(Tsubj-p);
        Xmat             = X2'*X2        ;        
    else
        X3               = X2            ;
        X3(:,1)          = []            ;
        [beta, stats]    = robustfit(X3,y,Rwfun); % robust, use bisqure function
        e                = y - X2*beta   ;
        sig2(m,n)        = stats.robust_s^2 ; % use robust_s as estimated covariance        
        W                = stats.w;
        wei              = diag(W);
        Xmat             = X2'*wei*X2/(sum(W)/Tsubj);
        
        % Check how many outliers
        if (length(find(stats.w<err)) > Tsubj*PMaxOut)
            % too much outliers
            beta = X2\y;
            e = y - X2*beta;
            sig2(m,n) = e'*e/(Tsubj-p);
            Xmat = X2'*X2        ; 
        end
    end

    BETA_COEF(m,n,:) = beta          ;
    E(m,n,:)         = e             ;
    XX(m,n,:)        = Xmat(:)       ;            
    dof(m,n)         = Tsubj-p       ;

end





