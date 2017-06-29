function [Cpc,T,E] = wfu_bpm_pc_SS(data,confound,col_conf, brain_mask, no_subj,Cpc,T,E)
%-------------------------------------------------------------------------
%   Computes the partial correlation coefficients for each slice using the
%   extra sum of squares principle and partial determination coefficients
%--------------------------------------------------------------------------

[n,ng] = size(data); % ng - number of groups
[n,nc] = size(confound); % nc - number of confounds
Tsubj  = sum(no_subj);
[M,N,s] = size( data{1} );
Data = [];

X = ones(no_subj,1);


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
    % ------------ creating the data vector ------------------------%
    y = [];
    for g  = 1:ng
        y1 = data{g}(m,n,:);
        y  = [y;y1(:)];
    end
    
    % ----- Computing the SS for the complete and reduced models ----%
    
    beta1     = X2\y                  ;
    e         = y - X2*beta1          ;
%   S1        = sum((X2*beta1 - y).^2);  
    S1        = sum((e).^2)           ;  
    X2(:,end) = []                    ;
    beta2     = X2\y                  ;
    S2        = sum((X2*beta2 - y).^2);  
    
    %--- Computing coefficients of partial determination and correlation---%
    
    Cpd       = (S2 - S1)/S2 ;   
    Cpcorr    = sign(beta1(end))*sqrt(abs(Cpd));  
    Cpc(m,n)  = Cpcorr ;
%     dof       = Tsubj - (size(col_conf,2) + 2);
    T(m,n)    = (sqrt(Tsubj-size(col_conf,2)-2)*Cpc(m,n))/sqrt(1-Cpc(m,n)^2);
    E(m,n,:)  = e  ;    
end
return



