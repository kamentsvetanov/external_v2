% M = flica(Y, options...)
%
% Y = cell array of N(k) by L data matrices, ALREADY PREPROCESSED in
%   flica_load.
% options = 'optionName', value pairs, or a structure.
% M will return the important outputs.

% Ignore some MATLAB style messages...
%#ok<*AGROW>

function M = flica(Y, varargin)

tic; fprintf('Setup... ')
%% Parse options:
opts = flica_parseoptions(Y, varargin{:}); clear varargin

%% Initialize the model structure:
% Variables take the following form:
% Z = <Z>
% ZtZ = <Z'*Z>
% Z_someproperty = some property of Q(Z). e.g. variance, blockcov, etc.
% HlambdaHt = <H*diag(lambda)*H'> = a saved moment that we'll use later.
% Note that the "Z update" section should update ALL variables pertaining to Z.
% Unused values may be set to [] (or NaN, or 'Unused', etc. as appropriate).
%
% An optional suffix can be used to show shape: e.g. _NR is NxR, _1 is
% scalar.
%
% The M structure is output-only -- values saved there aren't re-used.
%
% Note: before an update for parameter Z, clear Z*; afterwards, clear tmp*.

K = length(Y);
L = opts.num_components;
R = size(Y{1},2);
DD = opts.dof_per_voxel; % the Virtual Decimation factor (often sqrt'd!)

F_history = [];
toc_history = [];

%% Initialize <X> and <H> using PCA:
for k=1:K
    N(k) = size(Y{k},1);
    tmpYcat{k} = Y{k} * sqrt(DD(k));
end
tmpYcat = vertcat(tmpYcat{:});

if isequal(opts.initH, 'PCA')
    % PCA -> but we want U to have an RMS of 1, and V absorbs the scaling.
    fprintf('doing PCA... '); [tmpU,tmpS,tmpV] = svd(tmpYcat,'econ'); clear tmpYcat
    fprintf('more setup... ');
    tmpU = tmpU(:,1:L)*tmpS(1:L, 1:L); clear tmpS
    tmpV = bsxfun(@rdivide, tmpV(:,1:L), 1./rms(tmpU,1));
    tmpU = bsxfun(@rdivide, tmpU, rms(tmpU,1));
else
    assert(isequal(size(opts.initH), [L R]))
    tmpV = opts.initH';
    tmpU = tmpYcat/tmpV';
end

tmpDDmean = mean(DD);  % moves most scaling to H, so W ~ 1, varying a bit by modality.

G = max(opts.Rgroups);
assertequal(size(opts.Rgroups,1), numel(opts.Rgroups), R)
assertequal(unique(opts.Rgroups), (1:G)') % All 1:G are used at least once.
Gmat = accumarray([(1:R)' opts.Rgroups], ones(R,1)); % [RxG] binary matrix

H = double(tmpV') / sqrt(tmpDDmean);
%H2_sumR = sum(H.^2,2);
H2Gmat = H.^2 * Gmat; % [LxG]
H_colcov = eye(L)*1e-12;
for k=1:K  % De-concatenate to get X{k} estimates:
    X{k} = tmpU(sum(N(1:k-1))+1:sum(N(1:k)), 1:L); % / sqrt(DD(k));
    W{k} = ones(1,L) * sqrt(tmpDDmean/DD(k)) ; % so Y = X*diag(W)*H + noise;
    
    W_rowcov{k} = eye(L)*1e-12;
    prior_W = 0; 
    prior_W_var = 1/DD(k);  % Fixed N(0,1) prior.
    
    WtW{k} = W{k}'*W{k} + W_rowcov{k};
    XtDX{k} = double(X{k}'*X{k})*DD(k);
    Y2D_sumN{k} = DD(k)*double(sum(Y{k}.^2,1)); % [1xR]
    X2{k} = X{k}.^2;
end
clear tmp*

%% Handy functions: 
% [NxLxM] -> [MxL] by summing over N, using decimation factor DD(k):
%NxLxM_to_MxL = @(Z,Dk) double(permute(sum(Z,1),[3 2 1])) * Dk;
NxLxM_to_MxL = @(Z,Dk) permute(sum(double(Z),1),[3 2 1]) * Dk;  % Slower, more accurate, might avoid F decreases
% [MxL] -> [NxLxM] with output dimension N(k).
MxL_to_NxLxM = @(Z,Nk) repmat(permute(Z,[3 2 1]),[Nk 1 1]);


%% Set up the models for P(X|params) and P(lambda):
for k=1:K
    
    %% Set up the model for P(X|params):
    if strfind(opts.X_model{k}, 'BayesianICA')==1
        % REST OF STRING IS CURRENTLY IGNORED
        
        % Initialize pi_mean{k} [3xL]:
        prior_pi_weights{k} = N(k)*0.1 * ones(3, L); %[3xL]
        pi_weights{k} = prior_pi_weights{k};
        pi_mean{k} = bsxfun(@rdivide, pi_weights{k}, sum(pi_weights{k},1)); % The variable "pi_mean" should be called "pi" for consistency, but that would cause other problems later ;)
        pi_log{k} = log(pi_mean{k});
        
        % Initialize beta{k} [3xL]:
        prior_beta_b{k} = repmat([1e3;1;1e3],[1 L]); % [3xL]
        prior_beta_c{k} = repmat([1e-6;1e6;1e-6], [1 L]); % [3xL]
        %beta_b, beta_c can be left undefined for now
        %beta{k} = repmat([.1;1;10].^-2, [1 L]); % An odd choice of initialization, not sure what I was thinking.  But too scared to change it now!
        beta{k} = repmat([.1;1000;1].^-2, [1 L]); % More sensible?  
% ABOVE LINE NEEDS TESTING!
        beta_log{k} = log(beta{k});
        beta_c{k} = ones(size(beta))*1e6;
        beta_binv{k} = 1e6./beta{k};
       
        % Initialize mu{k} [3xL]:
        prior_mu_mean = 0;
        prior_mu_var = 1e4;
        mu{k} = prior_mu_mean + zeros(3,L);
        mu2{k} = mu{k}.^2; % [3xL]
        mu_var{k} = mu{k}*0+1e-12;
        
        % Initialize q{k} [NxLx3]:
        q{k} = repmat(permute(pi_mean{k}, [3 2 1]), [N(k) 1 1]);
        if isequal(class(X{k}),'single'), q{k} = single(q{k}); end

        % Initialize X_q [NxLx3]:
        %Xq{k} = repmat(X{k}, [1 1 3]);
        Xq_var{k} = 1e-12 * ones(1,L,3);
       
    else
        error('Unimplemented X_model{%g} type %s.',k,opts.X_model{k})
    end
   
    %% Set up the model for lambda:
    if isequal(opts.lambda_dims{k},'R')
        prior_lambda_b{k} = 1e12 * ones(R,1);
        prior_lambda_c{k} = 1e-12 * ones(R,1);
        lambda{k} = double(rms(Y{k}, 1))' .^ -2;
        % Note that any "missing data" scans should use Ga(b=1e-18, c=1e12)
        lambda_log{k} = log(lambda{k});
        lambda_c{k} = 1e12;
        lambda_binv{k} = lambda_c{k}./lambda{k};
        lambda_R{k} = lambda{k};
    elseif isequal(opts.lambda_dims{k},'G')
        prior_lambda_b{k} = 1e12 * ones(G,1);
        prior_lambda_c{k} = 1e-12 * ones(G,1);
        %lambda{k} = double(rms(Y{k}, 1))' .^ -2;
        lambda{k} = (mean(Y{k}.^2,1)*desomething(Gmat,1,'scalesum'))'.^-1;
        % Note that any "missing data" scans should use Ga(b=1e-18, c=1e12)
        lambda_log{k} = log(lambda{k});
        lambda_c{k} = 1e12;
        lambda_binv{k} = lambda_c{k}./lambda{k};
        lambda_R{k} = Gmat*lambda{k};
    elseif isequal(opts.lambda_dims{k},'')
        prior_lambda_b{k} = 1e12;
        prior_lambda_c{k} = 1e-12;
        lambda{k} = double(rms(Y{k})) .^ -2;
        lambda_log{k} = log(lambda{k});
        lambda_c{k} = 1e12;
        lambda_binv{k} = lambda_c{k}./lambda{k};
        lambda_R{k} = repmat(lambda{k},[R 1]);
    else
        error('Unimplemented opts.lambda_dims{%g} = %s',k,opts.lambda_dims{k});
    end
end    

% Initialize eta [LxG]:
prior_eta_b = 1e3 * 1000;
prior_eta_c = 1e-3;
eta = prior_eta_b*prior_eta_c * ones(L,G); 
eta_log = log(eta); %#ok<NASGU>
eta_c = prior_eta_c; %#ok<NASGU>
eta_binv = 1./prior_eta_b; %#ok<NASGU>

% Initial updates: eta H {lambda X|q,q,X}*2

toc_setup = toc;
fprintf('done (%.2g sec)\n', toc_setup)

%% Run the iterations
for its = 1:opts.maxits
    tic; fprintf('Iteration %g... ', its)
    
    calcF = any(opts.calcFits == its); % Skip some calculations if false
    stopAfterEachUpdate = opts.subcalcF*(its>1);
    
    finalIteration = its==opts.maxits; % Set before returning!

    if stopAfterEachUpdate>0, keyboard, end
    %% Update eta
    % from vb2_update_eta(M, 'ARD')
    % inputs: H2_sum2, prior_eta_b, prior_eta_c
    % outputs: eta
    fprintf('eta ')
    clear eta*
    
    if its<10 && false
        warning 'eta lock hack'
        H2Gmat = sum(H2Gmat,2)*mean(Gmat,1);
    end
    
    eta_binv = 1./prior_eta_b + H2Gmat/2; % [LxG]; if G=1, H2Gmat = sum_r <H_ir^2>.
    eta_c = prior_eta_c + repmat( sum(Gmat,1)/2, [L 1]);
    eta = eta_c ./ eta_binv; % [LxG]
    eta_log = psi(eta_c)-log(eta_binv); % [LxG]
    
    if stopAfterEachUpdate>0, disp eta; keyboard, end % chance to run the "Free energy calculations" block after each update, then hit F5 to continue.
    %% Update H
    % from vb2_update_H(M,[],'NoFactorOverL')
    % inputs: eta, lambda, DD
    % NOTE that the following works for lambda [Rx1] OR lambda [1x1]!
    fprintf('H ')
    clear H* % Avoid leftovers
    
    % Here we use NH which is either {R,G} instead of R, to reduce the 
    % number of matrices inverses we need to do for H.  Note that usually
    % G==1.
    if any([opts.lambda_dims{:}]=='R')
        NH = R;
        tmpVinv_LxLxNH = apply3(@diag, permute(eta * Gmat', [1 3 2]));
        % Above: tmpVinv(i,j,r) = eta(i,opts.Rgroups(r)) for i=j, 0 otherwise.
        tmp_R_to_NH = 1:R;
    else
        NH = G; % Which may well be 1.
        tmpVinv_LxLxNH = apply3(@diag, permute(eta, [1 3 2]));
        % Above: tmpVinv(i,j,g) = eta(i,g) for i=j, 0 otherwise.
        tmp_R_to_NH = opts.Rgroups;
    end

    tmpM = zeros(L,R); % Always R, not Ror1
    H_PCs = [nan(K,L); eta']; % Precision contributions
    for k=1:K
         switch opts.lambda_dims{k}
             case 'G'
                 if NH==R
                     tmp_lambda_NH = lambda_R{k};
                 else
                     tmp_lambda_NH = lambda{k};
                 end
             case {'R',''}
                 assert(NH>=length(lambda{k}))
                 tmp_lambda_NH = lambda{k} + zeros(NH,1);
             otherwise
                 error 'Unimplemented!'
         end
        tmpVinv_LxLxNH = tmpVinv_LxLxNH + ...
            reshape(...
            WtW{k}(:) .* XtDX{k}(:) * tmp_lambda_NH',...
            [L L NH]);
        tmpM = tmpM + DD(k) * diag(W{k}) * double(X{k}' * Y{k}) * diag(lambda_R{k});
        H_PCs(k, :) = diag(WtW{k}) .* diag(XtDX{k}) * mean(lambda_R{k});
    end
    
    if G>1
        H_PCs = nan(K+1,L); 
        % H_PCs is Not useful for G>1, at least when K=1. Should probably make an X_PCs!
    end
    
    % Calculate H, H covariance, <H*Ht> and <H*lambda*Ht>
    H_colcov = apply3(@inv_prescale, tmpVinv_LxLxNH);
%     for r=Ror1:-1:1
%         %if rcond(tmpVinv_LxLxR(:,:,r))<1e-16, 
%         %    disp huh
%         %end
%         H_colcov(:,:,r) = inv_prescale(tmpVinv_LxLxR(:,:,r));
%         assert(all(diag(H_colcov(:,:,r))>0))
%     end
    for r=R:-1:1
        H(:,r) = H_colcov(:,:,tmp_R_to_NH(r)) * tmpM(:,r);
    end
    %HHt = H*H' + sum(H_colcov,3)*(R/Ror1); % Not needed
    %H2(i,r) = H(i,r).^2 + H_colcov(i,i,r); % Not needed
    %H2_sumR = sum(H.^2,2) + diag(sum(H_colcov,3))*(R/Ror1); % Replaced with H2Gmat
    if NH==R
        H2Gmat = H.^2*Gmat + makesize(squeeze(apply3(@diag, H_colcov)),[L,R])*Gmat; % [LxG]
    else
        H2Gmat = H.^2*Gmat + makesize(squeeze(apply3(@diag, H_colcov)),[L,G])*(Gmat'*Gmat); % [LxG]
    end
    clear tmp* NH
    
    %% Calculate <H*lambda{k}*H'>
    for k=1:K
        HlambdaHt{k} = H * diag(lambda_R{k}) * H';
        if size(H_colcov,3) == R
            for r=1:R
                HlambdaHt{k} = HlambdaHt{k} + H_colcov(:,:,r) * lambda_R{k}(r);
            end
        else % size(H_colcov,3) == G
            for g=1:G
                HlambdaHt{k} = HlambdaHt{k} + H_colcov(:,:,g) * (Gmat(:,g)'*lambda_R{k});
            end
        end
    end
    
    if stopAfterEachUpdate>0, disp 'H'; keyboard, end
    %% Update W
    % from vb2_update_W(M, 'NoFactorOverL') (also no hard elimination)
    % D_nn -> sqrt(DD(k))
    % XtDStSDX_ij
    fprintf('W ')
    %if stopAfterEachUpdate
    %    oldW=W;oldW_rowcov=W_rowcov;oldWtW=WtW;
    %else
    %    clear W*
    %end
    
    for k=1:K
        tmpL = XtDX{k}.*HlambdaHt{k} + diag(1./prior_W_var)*eye(L);
        tmpCov = inv_prescale(tmpL);
        W_rowcov{k} = 0.5*(tmpCov+tmpCov');
        assert(all(diag(W_rowcov{k})>0))
        assert(all(prior_W==0))
        tmpM = diag(double(X{k}' * Y{k}) * diag(lambda_R{k}) * H')' * DD(k);
        W{k} = tmpM * W_rowcov{k};
        WtW{k} = W{k}'*W{k} + W_rowcov{k};
        if stopAfterEachUpdate>0, fprintf('W{%g}\n',k); keyboard, end
        clear tmp*
    end
    
    %% Do the updates that depend on the form of X:
    fprintf('X')
    for k = 1:K
        if strfind(opts.X_model{k}, 'BayesianICA')==1
            if stopAfterEachUpdate <= 1
                %Xq{k} = nan(N(k),L,3, class(Y{k}));
                %q{k} = nan(N(k),L,3, class(Y{k}));
                Xq_var{k} = nan(1,L,3);
                XtDX{k} = nan;
            end
            
            %precalc_XWtWHlambdaH = X{k} * (WtW{k} .* HlambdaHt{k});
            
            for i=1:L
                
                %precalc_XWtWHlambdaH = precalc_XWtWHlambdaH - X{k}(:,i) * (WtW{k}(i,:) .* HlambdaHt{k}(i,:));
                
                X{k}(:,i) = 0;  % Will be overwritten soon, but setting it to zero temporarily lets us get rid of the slow "tmp_noti" referencing below
                X2{k}(:,i) = nan;
                                
                %% Update P'(X_i|q_i)
                % from vb2_update_X_given_q
                % inputs: beta, mu, lambda, H2
                
                tmpPriorPrec_M = beta{k}(:,i);
                tmpPriorMean_M = mu{k}(:,i);

                tmpL_1 = WtW{k}(i,i) .* HlambdaHt{k}(i,i);
                %tmp_noti = [1:i-1 i+1:L];
                
                %tmpM_N = Y{k}*(lambda{k}.*H(i,:)'*W{k}(:,i)) ...
                %    -X{k}(:,tmp_noti) * (WtW{k}(tmp_noti,i) .* HlambdaHt{k}(tmp_noti,i));
                if 1 % Split for profiling
                    if i==1,
                        precalc_YlambdaHTW_NxL = Y{k}*((lambda_R{k}*W{k}).*H');
                    end
                    
                    %tmp = WtW{k}(tmp_noti,i) .* HlambdaHt{k}(tmp_noti,i);
                    tmp = WtW{k}(:,i) .* HlambdaHt{k}(:,i);
                    %tmp = X{k}(:,tmp_noti) * tmp;
                    tmp = X{k} * tmp;
                    
                    %assertalmostequal(tmp, precalc_XWtWHlambdaH(:,i));
                    
                    tmp = precalc_YlambdaHTW_NxL(:,i) - tmp;
                    tmpM_N = tmp;
                end
                
                tmpM_MxN = bsxfun(@plus, tmpPriorPrec_M.*tmpPriorMean_M, tmpM_N'); % [3xN]
                tmpL_M = tmpL_1 + tmpPriorPrec_M;
                tmpVpost = 1./tmpL_M; % [3x1]
                tmpMpost = bsxfun(@rdivide, tmpM_MxN, tmpL_M); % [3xN]
                assert(all(isfinite([tmpMpost(:);tmpVpost(:)])))
                
                Xqki = permute(tmpMpost, [2 3 1]); % [NxLx3]
                %Xq{k}(:,i,:) = Xqki;
                Xq_var{k}(:,i,:) = permute(tmpVpost, [2 3 1]); % [1xLx3]
                Xq2ki = Xqki.^2 + repmat(Xq_var{k}(:,i,:), [N(k) 1 1]);
                
                assert(all(all(isfinite(Xqki))))
                assert(all(all(isfinite(Xq_var{k}(:,i,:)))))
                
                clear tmp*
                
                %% Update P'(q)  [q is NxLx3]
                % from vb2_update_q(M,'simultaneous')
                % inputs: beta, beta_log, mu, mu2, pi_log [all 3xL]
                % Annoyingly this has to be looped over i, because it
                % <X(:,i)> needs to be known before <Xq(:,i+1)> can be
                % calculated.
                %
                % Note that this update is rather complicated and should
                % actually be done jointly with the above; i.e., find
                % log P'(X,q) = sum_m(q_m*[C1 + C2*X + C3*X^2])
                % and then expand the LHS as a GMM to get the peculiar mix
                % of things that this has to match to. It's a very tricky
                % update to get right.
                tmpLogQ = ...
                	+ squeeze(log(Xq_var{k}(:,i,:)))/2 ... % Xq_var is [1xLx3]
                    + pi_log{k}(:,i) ...
                    + beta_log{k}(:,i)/2 ...
                    - beta{k}(:,i).*mu2{k}(:,i)/2;  % [3x1]
                tmpLogQ = ...
                    MxL_to_NxLxM(tmpLogQ, N(k)) ... % [Nx1x3]
                    + bsxfun(@rdivide,  Xqki.^2, Xq_var{k}(:,i,:)*2 );
                tmpLogQ = bsxfun(@minus, tmpLogQ, max(tmpLogQ,[],3)); % avoid overflow
                tmpQ = exp(tmpLogQ);
                qki = bsxfun(@rdivide, tmpQ, sum(tmpQ,3)); % [NxLx3]
                %q{k}(:,i,:) = qki;
                assert(all(all(isfinite(qki))))

                
                %% Update the various moments of X
                % from vb2_update_X_cache

               
                sumN_Dq{k}(:,i) = NxLxM_to_MxL(qki, DD(k)); % sum_N <q> * D
                sumN_DqXq{k}(:,i) = NxLxM_to_MxL(qki.*Xqki, DD(k)); % sum_N <X|q><q> * D
                sumN_DqXq2{k}(:,i) = NxLxM_to_MxL(qki.*(Xqki.^2 + Xq_var{k}(ones(N(k),1),i,:)), DD(k)); % sum_N <X^2|q><q> * D
                tmp_qlogq = qki.*log(qki);
                tmp_qlogq(qki==0) = 0;  % limit as q->0 of q*log(q) is 0.
                sumN_Dqlogq{k}(:,i) = NxLxM_to_MxL(tmp_qlogq, DD(k)); % sum_N <q>log<q> * D.  Not NOT <q><log q>!
                
                X{k}(:,i) = sum( Xqki .* qki, 3); % [NxL]
                X2{k}(:,i) = sum( Xq2ki .* qki, 3); % [NxL]

                %precalc_XWtWHlambdaH = precalc_XWtWHlambdaH + X{k}(:,i) * (WtW{k}(i,:) .* HlambdaHt{k}(i,:));
                
                % TODO: X2{k}(:,i) here as well!!!
                if stopAfterEachUpdate > 1 % DETAILED stopping after each update!
                    % from vb2_update_X_cache
                    %Xq2{k} = Xq{k}.^2 + repmat(Xq_var{k}, [N(k) 1 1]);
                    %X2{k} = sum( Xq2{k} .* q{k}, 3); % [NxL]
                    %assertalmostequal(X2{k}, X2_new{k})
                    XtDX{k} = double(X{k}' * X{k}) * DD(k); % [LxL]
                    XtDX{k}(1:L+1:L*L) = double(sum( X2{k}, 1)) * DD(k); % replace diagonal
                    fprintf('X{%g}(:,%g)\n',k,i)
                    keyboard
                end
                clear Xqki Xq2ki qki
            end
            clear precalc_YlambdaHTW_NxL

            % from vb2_update_X_cache
            %Xq2{k} = Xq{k}.^2 + repmat(Xq_var{k}, [N(k) 1 1]);
            %X2{k} = sum( Xq2{k} .* q{k}, 3); % [NxL]
            %assertalmostequal(X2{k}, X2_new{k})
            XtDX{k} = double(X{k}' * X{k}) * DD(k); % [LxL]
            XtDX{k}(1:L+1:L*L) = double(sum( X2{k}, 1)) * DD(k); % replace diagonal to include covariance
            
            if stopAfterEachUpdate==1, fprintf('X{%g}\n',k); keyboard, end
            %% Update P'(pi_mean)
            %clear pi_mean*
            pi_weights{k} = prior_pi_weights{k} + sumN_Dq{k}; % [3xL]
            pi_mean{k} = bsxfun(@rdivide,  pi_weights{k}, sum(pi_weights{k},1) );
            pi_log{k} = bsxfun(@minus,  psi(pi_weights{k}), psi(sum(pi_weights{k},1)) ); % [3xL]
            
            if stopAfterEachUpdate>0, disp pi; keyboard, end
            %% Update P'(beta)
            %clear beta*
            beta_c{k} = prior_beta_c{k} + 0.5*sumN_Dq{k}; % [3xL]
            tmp_mu2 = MxL_to_NxLxM(mu2{k}, N(k)); % [NxLx3]
            tmp_mu  = MxL_to_NxLxM(mu{k} , N(k)); % [NxLx3]
            tmp = sumN_Dq{k}.*mu2{k} + sumN_DqXq2{k} - 2.*mu{k}.*sumN_DqXq{k}; % [NxLx3]
            beta_binv{k} = 1./prior_beta_b{k} + tmp/2; % [3xL]
            beta{k} = beta_c{k} ./ beta_binv{k}; % [3xL]
            beta_log{k} = psi(beta_c{k}) - log(beta_binv{k});
            
            if ~(all(beta{k}(:) > 1e-10)), warning 'X getting awfully large', end %#ok<WNTAG>
            if ~mod(its,opts.keyboardEveryIterations), keyboard; end
            
            if stopAfterEachUpdate>0, disp beta; keyboard, end
            clear tmp*
            
            
            %% Update P'(mu)
            %clear mu*
            tmp_L = 1./prior_mu_var + beta{k} .* sumN_Dq{k}; % [3xL]
            tmp_M = prior_mu_mean./prior_mu_var + ...
                beta{k} .* sumN_DqXq{k}; % [3xL]
            mu{k} = tmp_M./tmp_L; % [3xL]
            mu_var{k} = 1./tmp_L; % [3xL]
            mu2{k} = mu{k}.^2 + mu_var{k};
            if stopAfterEachUpdate>0, disp mu; keyboard, end
            clear tmp*
        
        else
            error('Unimplemented X_model{%g} type %s.',k,opts.X_model{k})
        end
        
        fprintf('.')
    end

    
    %% Update P'(lambda)
    fprintf(' lambda')
    if ~stopAfterEachUpdate>0, clear lambda* HlambdaHt; end
    for k = 1:K    
        %% Update P'(lambda^(k))
        % from vb2_update_lambda(M,'TR')
        % diag( <H'*<diag(W)*<X'*D*X>*diag(W)>*H> ) =
        %   diag(<H>'*(<W'W>.*<X'*D*X>)*<H>) + sum(sum(H_colcov[r].*<WtW>.*<Xt*D*X>))
        %   The following should work for H_colcov [LxLxR] or [LxLx1]:
        tmp_diagHtWXtDXWH = ... % [1xR]
            sum( H .* (WtW{k}.*XtDX{k}*H), 1 );
        if size(H_colcov,3)==R
            tmp_diagHtWXtDXWH = tmp_diagHtWXtDXWH + ...
                (WtW{k}(:) .* XtDX{k}(:))' * reshape(H_colcov,L*L,[]);
        else % == G
            tmp_diagHtWXtDXWH = tmp_diagHtWXtDXWH + ...
                (WtW{k}(:) .* XtDX{k}(:))' * reshape(H_colcov,L*L,[]) * Gmat';
        end
            
        % Initial calculation based on the data only (no priors)
        lambda_c{k} = DD(k)*N(k)/2 * ones(R,1); % [Rx1]
        lambda_binv{k} = ...
            0.5*DD(k)*double(sum(Y{k}.^2,1))' + ...
            -(double(X{k}' * Y{k}) .* H)' * W{k}(:) * DD(k) + ...
            0.5*tmp_diagHtWXtDXWH'; % [Rx1]
            
        % Summarize these to get the right-dimensioned lambda{k}
        switch opts.lambda_dims{k}
            case 'R'
                % OK!  lambda_c and lambda_binv are already Rx1
            case 'G'
                lambda_c{k} = Gmat' * lambda_c{k};
                lambda_binv{k} = Gmat' * lambda_binv{k};
            case ''
                lambda_c{k} = sum(lambda_c{k});
                lambda_binv{k} = sum(lambda_binv{k});
            otherwise
                error 'Unimplemented'
        end
        
        % Add the priors in:
        lambda_c{k} = lambda_c{k} + prior_lambda_c{k};
        lambda_binv{k} = lambda_binv{k} + 1./prior_lambda_b{k};
        
        % Convert lambda_c and lambda_binv into various moments:
        lambda{k} = lambda_c{k}./lambda_binv{k}; % [Rx1 or Gx1 or 1x1]
        assert(all(lambda{k}>0))
        lambda_log{k} = psi(lambda_c{k}) - log(lambda_binv{k});
        switch opts.lambda_dims{k}
            case {'R',''}
                lambda_R{k} = lambda{k} + zeros(R,1);
                lambda_log_R{k} = lambda_log{k} + zeros(R,1);
            case 'G'
                lambda_R{k} = Gmat * lambda{k};
                lambda_log_R{k} = Gmat * lambda_log{k};
        end        
        clear tmp*
        
        %% Calculate <H*lambda{k}*H'>
        HlambdaHt{k} = H * diag(lambda_R{k}) * H';
        if size(H_colcov,3) == R
            for r=1:R
                HlambdaHt{k} = HlambdaHt{k} + H_colcov(:,:,r) * lambda_R{k}(r);
            end
        else % size(H_colcov,3) == G
            for g=1:G
                HlambdaHt{k} = HlambdaHt{k} + H_colcov(:,:,g) * (Gmat(:,g)'*lambda_R{k});
            end
        end
        
        fprintf('.')
        if stopAfterEachUpdate>0, fprintf('lambda{%g}\n',k); keyboard, end
        
    end
    
    %% Calculate F, if desired
    F = nan; Fpart = struct();
    toc_history(its,1) = toc;

    if calcF
        fprintf(' done updates (%.2g sec) F ',toc); tic
        %% Free energy calculations:
        % Note: in cases, where I'm not sure of a variable's dimension
        % (e.g. lambda could be [Rx1] or [1x1]), I use the construct
        % mean(lambda)*R instead of sum(makesize(lambda,[R 1])) to make
        % sure I sum the right number of elements.
        % Better yet... see sum_dims
        
        % <P(H)>_P'(H): uses sum_R(<H2>), <eta>, <log(eta)>.
        Fpart.Hprior = sum_dims(eta_log*Gmat',[L R])/2 -log(2*pi)*L*R/2 - sum_dims(eta.*H2Gmat,[L G])/2;
        % Note: above is sum over i=1:L and r=1:R of: 
        % <log(eta)_i,g(r)>/2 - log(2pi)/2 - <H_ir^2><eta_i,g(r)>
        
        % -<P'(H)>_P'(H): uses only H_colcov, <H> doesn't matter.
        tmp1 = apply3(@(x) logdet(x,'chol'), H_colcov); % log-determinant of each layer [1x1xR or 1x1xG]
        if size(H_colcov,3) == G
            Fpart.Hpost = 0.5*L*R*(1+2*pi) + 0.5*sum(Gmat)*squeeze(tmp1);
        else
            Fpart.Hpost = 0.5*L*R*(1+2*pi) + 0.5*sum_dims(tmp1,[1 1 R]);
        end
        % <P(eta)>_P'(eta): Noting that eta is LxG
        Fpart.etaPrior = ...
            -sum_dims(gammaln(prior_eta_c),[L G]) ...
            +sum_dims((prior_eta_c-1).*eta_log,[L G]) ...
            -sum_dims(prior_eta_c.*log(prior_eta_b),[L G]) ...
            -sum_dims(eta./prior_eta_b,[L G]);
        % -<P'(eta)>_P'(eta): Noting that eta is LxG
        Fpart.etaPost = ...
            +sum_dims(gammaln(eta_c),[L G]) ...
            -sum_dims((eta_c-1).*eta_log,[L G]) ...
            +sum_dims(-eta_c.*log(eta_binv),[L G]) ...
            +sum_dims(eta.*eta_binv,[L G]);         
            %+mean(-eta_c.*log(eta_binv))*L ...
            %+mean(eta.*eta_binv)*L;         
        for kk=1:K
            % <P(W)>_P'(W): W is [1xL].  Prior is N(0,prior_W_var).
            assert(all(prior_W(:)==0))
            Fpart.Wprior(kk) = sum_dims(log(1/prior_W_var),[1 L])/2 -log(2*pi)*1*L/2 - trace(WtW{kk})/2/prior_W_var;
            % -<P'(W)>_P'(W): uses only W_colcov, <H> doesn't matter.
            Fpart.Wpost(kk) = 0.5*1*L*(1+2*pi) + 0.5*logdet(W_rowcov{kk},'chol');
            % <P(mu)>_P'(mu): mu is [3xL]
            % uses prior_mu_var and mu2
            assert(prior_mu_mean==0 && numel(prior_mu_var)==1)
            Fpart.muPrior(kk) = ...
                -0.5/prior_mu_var.*sum_dims(mu2{kk},[3 L]) ...
                ...%+1./prior_mu_var.*mu{kk}.*prior_mu_mean ...
                ...%-0.5./prior_mu_var.*prior_mu_mean.^2 ...
                +0.5*log(2*pi*prior_mu_var) * 3*L;
            % -<P'(mu)>_P'(mu): 
            Fpart.muPost(kk) = ...
                +0.5*(1+log(2*pi))*3*L...
                +0.5*sum_dims(log(mu_var{kk}),[3 L]);
            % <P(beta)>_P'(beta)
            Fpart.betaPrior(kk) = ...
                -mean(mean(gammaln(prior_beta_c{kk})))*3*L ...
                +mean(mean((prior_beta_c{kk}-1).*beta_log{kk}))*3*L ...
                -mean(mean(prior_beta_c{kk}.*log(prior_beta_b{kk})))*3*L...
                -mean(mean(1./prior_beta_b{kk}.*beta{kk}))*3*L;
            % -<P'(beta)>_P'(beta)
            Fpart.betaPost(kk) = ...
                +sum_dims(gammaln(beta_c{kk}),[3 L]) ...
                -sum_dims((beta_c{kk}-1).*beta_log{kk},[3 L]) ...
                +sum_dims(beta_c{kk}.*-log(beta_binv{kk}),[3 L])...
                +sum_dims(beta_binv{kk}.*beta{kk},[3 L]);
            % <P(pi_mean)>_P'(pi_mean)
            Fpart.piPrior(kk) = ...
                +sum_dims( gammaln( sum_dims(prior_pi_weights{kk},[3 0]) ), [1 L] )...
                -sum_dims( gammaln( prior_pi_weights{kk} ), [3 L])...
                +sum_dims( (prior_pi_weights{kk}-1) .* pi_log{kk}, [3 L]);
%WTF?                +sum_dims( gammaln(prior_pi_weights{kk}), [3 L])...
%WTF?                -sum_dims( gammaln( sum_dims(prior_pi_weights{kk}, [3 0]) ),[1 L]) ...
%WTF?                +sum_dims( prior_pi_weights{kk} .* pi_mean{kk}, [3 L]);
            % -<P'(pi_mean)>_P'(pi_mean)
            Fpart.piPost(kk) = ...
                -sum_dims( gammaln( sum_dims(pi_weights{kk},[3 0]) ), [1 L])...
                +sum_dims( gammaln( pi_weights{kk} ), [3 L])...
                -sum_dims( (pi_weights{kk}-1) .* pi_log{kk}, [3 L]);
%WTF?                -sum_dims( gammaln(pi_weights{kk}), [3 L])...
%WTF?                +sum_dims( gammaln( sum_dims(pi_weights{kk}, [3 0]) ),[1 L]) ...
%WTF?                -sum_dims( pi_weights{kk} .* pi_mean{kk}, [3 L]);
            % <P(q)>_P'(q)
            Fpart.qPrior(kk) = ...
                sum_dims( sumN_Dq{kk} .* pi_log{kk}, [3 L]);
            %    sum_dims( q{kk} .* MxL_to_NxLxM(pi_log{kk}), [N L 3]) * DD(kk);
            % <P'(q)>_P'(q)
            Fpart.qPost(kk) = ...
                -sum_dims(sumN_Dqlogq{kk}, [3 L]);
                %-sum_dims( double(q{kk} .* log(q{kk})), [N(kk) L 3], 'nan->zero') * DD(kk);
            % <P(Y|X,H,lambda)>_P'(X)P'(H)P'(lambda)
            Fpart.Ylike1(kk) = ...
                N(kk)*DD(kk)/2 * sum_dims(lambda_log_R{kk}-log(2*pi),[R 1]);
            Fpart.Ylike2(kk) = ... % -1/2 DD*sum_N sum_R (Y_nr^2*lambda_r)
                -0.5*Y2D_sumN{kk}*lambda_R{kk};
            Fpart.Ylike3(kk) = ... % +sum_R [ DD*sum_N (Y .* XH) *lambda_r]
                DD(kk)*double(sum(Y{kk}.*(X{kk}*diag(W{kk})*H)))*lambda_R{kk};
            Fpart.Ylike4(kk) = ... % -1/2 sum_IJ <XtDX> .* <HlambdaHt>
                -0.5 * sum_dims(XtDX{kk} .* HlambdaHt{kk} .* WtW{kk}, [L L]);
                
            % <P(lambda)>_P'(lambda): here we don't know if lambda is R or
            % 1, but that's ok because the correct answer is just to sum
            % over however many lambda scalar variables there actually are!
            Fpart.lambdaPrior(kk) = ...
                -sum(gammaln(prior_lambda_c{kk})) ...
                +sum((prior_lambda_c{kk}-1).*lambda_log{kk}) ...
                -sum(prior_lambda_c{kk}.*log(prior_lambda_b{kk}))...
                -sum(1./prior_lambda_b{kk}.*lambda{kk});
            Fpart.lambdaPost(kk) = ...
                +sum(gammaln(lambda_c{kk})) ...
                -sum((lambda_c{kk}-1).*lambda_log{kk}) ...
                -sum(lambda_c{kk}.*log(lambda_binv{kk}))...
                +sum(lambda_binv{kk}.*lambda{kk});
            
            % <P'(X,q)>_P(X,q):
            
            Fpart.Xprior(kk) = ...
                sum_dims( ...
                    +0.5 .* (beta_log{kk}-log(2*pi)) .* sumN_Dq{kk} + ...
                    -0.5 * beta{kk}.*sumN_DqXq2{kk} + ...
                    beta{kk}.*mu{kk} .* sumN_DqXq{kk} + ...
                    -0.5*beta{kk}.*mu2{kk}.*sumN_Dq{kk} ...
                    , [3 L]);
                %sum_dims(q{kk} .* tmpXqPriorConj, [N(kk) L 3]) * DD(kk);
                
            Fpart.Xpost(kk) = ...
                -sum_dims( -0.5*sumN_Dq{kk}.*permute(1+log(2*pi)+log(Xq_var{kk}), [3 2 1]), [3 L]);
                
%             % Previous implementation:
%             tmpXqPriorConj = ...  % [NxLx3]
%                 +0.5 * MxL_to_NxLxM( beta_log{kk}-log(2*pi), N(kk)) + ...
%                 -0.5 * MxL_to_NxLxM( beta{kk}, N(kk)) .* (...
%                     +Xq2{kk} ...
%                     -2*Xq{kk}.*MxL_to_NxLxM( mu{kk}, N(kk))...
%                     +MxL_to_NxLxM( mu2{kk}, N(kk)));  % Or should this be mu{kk}.^2, as used before?
%                 
%             tmpXqPostConj = ... % [NxLx3]
%                 -0.5*repmat(1+log(2*pi)+log(Xq_var{kk}), [N(kk) 1 1]);
%             
%             Fpart.Xprior(kk) = ...
%                 sum_dims( NxLxM_to_MxL( q{kk} .* tmpXqPriorConj, DD(kk) ), [3 L]);
%                 %sum_dims(q{kk} .* tmpXqPriorConj, [N(kk) L 3]) * DD(kk);
%             Fpart.Xpost(kk) = ...
%                 -sum_dims( NxLxM_to_MxL( q{kk} .* tmpXqPostConj, DD(kk) ), [3 L]);
%                 %-sum_dims(q{kk} .* tmpXqPostConj, [N(kk) L 3]) * DD(kk);                
                
            clear tmp*
        end
        
        % Summarize:
        F = sum_carefully(Fpart); % add up all the bits
        if isequal(class(lambda), 'single')
            %% Find those pesky single values:
            % should only be X, X2, Xq, Xq2, Y, q.
            % (i.e. things with an "N" dimension!)
            clear aa aaa ans
            aaa = whos;
            for i=1:length(aaa);
                eval(sprintf('aa.%s = %s;', aaa(i).name, aaa(i).name));
            end;
            whos_deep(aa, '', inf, 'single'); 
            keyboard
        end
        toc_history(its,2) = toc;
        fprintf('(%.2g sec)',toc)
        
        try
            change_in_F = F - lastF;
            fprintf(', dF = %g', change_in_F);
            if change_in_F < 0
                diff_structs(Fpart, lastFpart, '', 'quiet'); 
                change_in_F %#ok<NOPRT>
                
                if ~any(opts.calcFits == its+1), 
                    warning 'F decreased -- now checking every iteration';
                    opts.calcFits = [opts.calcFits(opts.calcFits<its) its:opts.maxits];
                end
                if change_in_F < -0.1, 
                    warning 'F decreased significantly!', 
                    opts.subcalcF = true; warning 'NOW STOPPING AFTER EACH UPDATE!!!'
                end
            end
        catch err
            assertequal(err.identifier, 'MATLAB:UndefinedFunction')
            disp('No previous lastF')
            clear err
        end
        lastF = F;
        lastFpart = Fpart;
        fprintf('\n')
    else
        fprintf(' done updates (%.2g sec)\n',toc); tic
    end
    F_history(its) = F;
    tmpPrevIt = find(isfinite(F_history(1:end-1)),1,'last');
    dF = (F - F_history(tmpPrevIt))/(its-tmpPrevIt);
    if 0
        fprintf('Residual RMS:')
        for k=1:K
            fprintf(' %.4g', rms(Y{k}-X{k}*H)/rms(Y{k}))
        end
        fprintf('\n')
    end
    
    %fprintf('RMS of H: %g\n', rms(H))
    
    if opts.plotConvergence
        figure(opts.plotConvergence)
        clf
        [1:length(F_history);F_history];
        ans(:,isnan(ans(2,:))) = []; 
        loglog(ans(1,2:end), diff(ans(2,:))./diff(ans(1,:)), '.-')
    end
    %%
    if opts.plotEta %&& G>1
        figure(opts.plotEta)
        %clf; semilogy(eta.^-0.5)
        %title 'Eta ^ -0.5 (i.e. RMS scale of H)'
        clf
        bsxfun(@rdivide, eta, sum(eta,2));
        %desomething([bsxfun(@rdivide, H2Gmat, sum(Gmat,1)) (1./eta)],2,'scalesum');
        desomething(H2Gmat,2,'scalesum');
        ans( sum(H'.^2)/sum(H(:).^2) < 1e-20, :) = nan; % Some components are eliminated
        bar(ans, 'stacked','barwidth',1)
        axis ij
        axis([0.5 L+0.5 0 1])
        colormap(jet(100)*.8+.2)
        plot_drawdiag(0.5:L+0.5,'vertk')
        plot_drawdiag(cumsum(sum(Gmat))/R,'horzg')
        plot_annotate('Relative weight of each subject group')
                   
    end

    %% Save everything into M (keeping only the variables we care about)
    % M also serves as a "what was this value before?" variable, for
    % debugging.  The only drawback of this is doubles memory usage!
    % (Yes, MATLAB uses copy-on-write, by the time it gets to this comment
    % there will be two copies of everything: M.(var) and (var).
    
    if finalIteration || stopAfterEachUpdate || opts.subcalcF || any(opts.calcFits == its+1)
        
        % The main random variables that were inferred:
        M.H = H;
        M.lambda = lambda;
        M.W = W;
        M.beta = beta;
        M.mu = mu;
        M.pi = pi_mean;
        % We could include other moments, but they aren't very useful and
        % would just clutter up the structure.
        
        % These are by far the biggest variables, so make single:
        for k=1:K
            M.X{k} = single(X{k});
            %M.Xq{k} = single(Xq{k}); % Not needed
            %M.q{k} = single(q{k});   % Not needed
            %M.Y{k} = single(Y{k});   % Definitely not needed
        end

        % Auxilliary outputs:
        M.H_PCs = H_PCs;
        M.F = F;
        M.F_history = F_history;
        M.DD = DD;
        M.opts = opts;
        M.toc_setup = toc_setup;
        M.toc_history = toc_history;

    end
end

