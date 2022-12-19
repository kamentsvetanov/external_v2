% flica_upsample(outdir, YfilesHR, Ylowres)
%   outdir -> the output directory (where to load H, etc. from!)
%   YfilesHR -> filenames of highres versions of data
%   Ylowres -> OPTIONAL!! Only used for error-checking (validates that the
%      transformations are pretty similar to the ones used on the lowres
%      data)
%   output -> saves a bunch of _HR files to outdir.
function flica_upsample(outdir, YfilesHR, Ylowres)

if nargin<3, Ylowres = []; end

indir=outdir; suffix='_HR';
%assert(~isequal(indir,outdir)) % would overwrite files!

% Re-load priors {pi,beta,mu}
priors = load([indir '/spatialPriors']); 
pi_mean = priors.pi;
beta = priors.beta;
mu = priors.mu;
transforms = priors.transforms;


% Re-load W, H, lambda
H = read_vest([indir '/subjectCoursesOut.txt'])';
L = size(H, 1);
R = size(H, 2);
K = length(beta);
W = []; % Assuming it's "standardized", i.e. all W==1.

lambda_rk = read_vest([indir '/noiseStdevOut.txt']);
for k=1:K
    lambda{k} = (lambda_rk(:,k) .* transforms{k,3}).^-2;
    HlambdaHt{k} = H*diag(lambda{k})*H';
    W{k} = ones(1,L);
    WtW{k} = ones(L,L);
    pi_log{k} = log(pi_mean{k});
    beta_log{k} = log(beta{k});
    mu2{k} = mu{k}.^2;
end
clear lambda_rk

MxL_to_NxLxM = @(in_ML, N) repmat(permute(in_ML,[3 2 1]),[N 1 1]);

for k=1:length(YfilesHR)

    %% Load highres data and apply the same transformations to it
    if isnumeric(transforms{k,2}) && size(transforms{k,2},1)>1
        if size(transforms{k,2},2)>1
            transforms{k,2} = 'auto12';
        else
            transforms{k,2} = 'auto2';
        end
    end
    [Y,tmp] = flica_load(YfilesHR(k), transforms(k,:));
    Y = single(Y{:});
    N(k) = size(Y,1);
    fileinfoHR.masks{k} = tmp.masks{:};
    fileinfoHR.transforms(k,:) = tmp.transforms;
    fileinfoHR.filetype{k} = tmp.filetype{:};
    clear tmp
    
    fprintf('\nChecking histogram match...');
    % Check for a decent match between high-res and low-res files
    if ~isempty(Ylowres) && ~isempty(Ylowres{k})
        % Compare histograms:
        list1 = sort(Y(:));
        list2 = sort(Ylowres{k}(:));
        list1 = list1(floor(linspace(1,length(list1),length(list2))));
        diffFrac = rms(list1-list2)/(rms(list1)+rms(list2))*2;
        fprintf(' diffFrac = %g', diffFrac)
        
        clf
        qqplot(Y, Ylowres{k});
        % or overall: qqplot(Y(:), Ylowres{k}(:));
        plot_drawdiag
        plot_annotate(['Modality ' num2str(k) ', plotted by subject'], 'Highres voxels', 'Lowres voxels')
        
        if ( diffFrac > 0.80 )  % Might need to up this a bit, if processing is different at all
            error 'Severe histogram mismatch -- there must be a mistake!'
        elseif ( diffFrac > 0.20 )  % Might need to up this a bit, if processing is different at all
            warning 'Histograms don''t match very well -- check preprocessing matches.'
        end
        clear list1 list2
        %Ylowres{k} = 'Used!'; % No longer needed -- but read-only and 
        % therefore shares RAM with calling workspace.
    end
    fprintf('\nRe-fitting...');
    %% Re-fit the X matrices using the new Y and existing W, H, lambda, pi, beta, mu.
    % i.e. fit {Xq, q, X moments} (GMM prior) or {X,beta} (for VBFPT)
    %start with X, Xq, q, all set to zero??
    if ~isempty(mu) && ~isempty(mu{k})
        oldX = 0;
        X = zeros(size(Y,1),L,'single'); % not Y/H?
        X2 = X.^2;
        Xqi = nan(N(k),1,3, 'single');  % Don't need to keep all L!
        Xq_var = nan(1,L,3);
        qi = nan(N(k),1,3, 'single');
        
        for its=1:30
            fprintf('\nIteration %g: ',its)
            for i=1:L
                fprintf('i=% 3g',i)
                                
                %% Update P'(X_i|q_i)
                fprintf .
                tmpPriorPrec_M = beta{k}(:,i);
                tmpPriorMean_M = mu{k}(:,i);
                tmpL_1 = WtW{k}(i,i) .* HlambdaHt{k}(i,i);
                tmp_noti = [1:i-1 i+1:L];
                if 1 % Split for profiling
                    if i==1,
                        precalc_YlambdaHTW_NxL = Y*((makesize(lambda{k},[R 1])*W{k}).*H');
                    end
                    tmp2 = WtW{k}(tmp_noti,i) .* HlambdaHt{k}(tmp_noti,i);
                    tmp2 = X(:,tmp_noti) * tmp2;
                    tmp1 = precalc_YlambdaHTW_NxL(:,i) - tmp2;
                    tmpM_N = tmp1;
                end
                
                tmpM_MxN = bsxfun(@plus, tmpPriorPrec_M.*tmpPriorMean_M, tmpM_N'); % [3xN]
                tmpL_M = tmpL_1 + tmpPriorPrec_M;
                tmpVpost = 1./tmpL_M; % [3x1]
                tmpMpost = bsxfun(@rdivide, tmpM_MxN, tmpL_M); % [3xMN]
                assert(all(isfinite([tmpMpost(:);tmpVpost(:)])))
                
                Xqi(:,1,:) = permute(tmpMpost, [2 3 1]); % [NxLx3]
                Xq_var(:,i,:) = permute(tmpVpost, [2 3 1]); % [1xLx3]
                
                assert(all(all(isfinite(Xqi(:,1,:)))))
                assert(all(all(isfinite(Xq_var(:,i,:)))))
                
                clear tmp*
                
                %% Update P'(q)  [q is NxLx3]
                fprintf .
                tmpLogQ = ...
                	+ squeeze(log(Xq_var(:,i,:)))/2 ... % Xq_var is [1xLx3]
                    + pi_log{k}(:,i) ...
                    + beta_log{k}(:,i)/2 ...
                    - beta{k}(:,i).*mu2{k}(:,i)/2;  % [3x1]
                tmpLogQ = ...
                    MxL_to_NxLxM(tmpLogQ, N(k)) ... % [Nx1x3]
                    + bsxfun(@rdivide, Xqi(:,1,:).^2, Xq_var(:,i,:)*2 );
                tmpLogQ = bsxfun(@minus, tmpLogQ, max(tmpLogQ,[],3)); % avoid overflow
                tmpQ = exp(tmpLogQ);
                qi(:,1,:) = bsxfun(@rdivide, tmpQ, sum(tmpQ,3)); % [NxLx3]
                assert(all(all(isfinite(qi(:,1,:)))))
                clear tmp*
                
                %% Update the various moments of X
                % from vb2_update_X_cache
                fprintf .
                X(:,i) = sum( Xqi(:,1,:) .* qi(:,1,:), 3); % [NxL]
                fprintf '\b\b\b\b\b\b\b\b'
                clear Xqi qi
            end
            fprintf('Fraction change X = %g', rms(X-oldX)/rms(X))
            if rms(X-oldX)/rms(X) < 0.001*its, break; end  % Gradually loosening threshold as we get more impatient!
            oldX = X;
      
            clear precalc_YlambdaHTW_NxL
        end
        
        M.X{k} = X;
        M.H = H;
        M.lambda = lambda;
        M.W = [];
        fprintf('\nDone fitting this modality.\n')
        
        clear oldX X
    else
        error 'Unimplemented!'
    end    
    
end


flica_save(flica_Zmaps(M), fileinfoHR, outdir, suffix)
