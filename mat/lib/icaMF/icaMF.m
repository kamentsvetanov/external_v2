function [S,A,loglikelihood,Sigma,chi]=icaMF(X,par);

% ICAMF  Mean field independent component analysis (ICA)
%    [S,A,LOGLIKELIHOOD,SIGMA,CHI]=ICAMF(X) performs linear 
%    instanteneous mixing ICA with additive noise X = A S + eta.  
%    Empirical Bayes (maximum Likelihood) is used to estimate the mixing 
%    matrix A and the noise covariance SIGMA [1]. The sufficient statistics 
%    (mean and covarinces of the sources) are estimated using either 
%    variational with linear response correction for covariances [1] or
%    with the expectation consistent framework (formerly known as adaptive
%    TAP) [1-4].
%   
%    Input and output arguments: 
%      
%    X        : Mixed signal
%    A        : Estimated mixing matrix
%    S        : Estimated source mean values                                   
%    SIGMA    : Estimated noise covariance
%    LL       : Normalized marginal log likelihood, log P(X|A,SIGMA) / N 
%    CHI      : Estimated source covariances
%
%    Outputs are sorted in descending order according to 'energy'
%    sum(A.^2,1))'.*sum(S.^2,2).
%
%    [S,A,LL,SIGMA,CHI]=ICA_ADATAP(X,PAR) allows for specification of 
%    parameters to specify priors on A, S and SIGMA, the method to be used
%    and additional parameters. PAR.method overrides other choices of 
%    priors. PAR.Aprior, PAR.Sprior, PAR.Sigmaprior and PAR.method are 
%    character strings that can take the following values
%    
%    PAR.Aprior :         constant      constant mixing matrix 
%                         free          unconstrained optimization
%                         positive      positively constrained optimization 
%                                       (uses QUADPROG if negative data or
%                                       sources occur)
%
%    PAR.Sprior :         bigauss       sum of two Gaussians, default
%                                       variance 1 centered at +/-1.  
%                         binary        binary +/-1 
%                         binary_01     binary 0/1             
%                         combi         combinations of priors
%                                       E.g. 2 binary_01's and 1
%                                       exponential are specified by
%                                       PAR.S(1).prior='binary_01';
%                                       PAR.S(2).prior='binary_01';
%                                       PAR.S(3).prior='exponential'; 
%                                       Parameters to the priors can also
%                                       be specified, see mog prior below.
%                         exponential   exponential (positive)
%                         Gauss         Gaussian for factor analysis and 
%                                       probabilistic PCA, see below.
%                         heavy_tail    heavy_tailed (non-analytic 
%  				                        power law tail)
%                         Laplace       Laplace (double exponential)
%                         mog           mixture of Gaussians. Parameters 
%                                       for mixing proportions, mean and 
%                                       variances are specified with 
%                                       PAR.S.pi, PAR.S.mu and PAR.S.Sigma. 
%                                       Parameters can also be specific to
%                                       the source using PAR.S(source).pi
%                                       etc. Default is shared and heavy-
%                                       tailed: PAR.S.pi = [ 0.5 0.5 ]', 
%                                       PAR.S.mu = [ 0 0 ]' and
%                                       PAR.S.Sigma = [ 1 0.01 ]'.
%
%    PAR.Sigmaprior :     constant      constant noise covariance
%                         free          full noise covariance matrix  
%                         isotropic     white noise, with same (scalar) 
%                                       noise variance on all sensors
%                         diagonal      white noise, different noise 
%                                       variance for each sensor.
%
%
%    PRIOR.method :       constant      constant A and Sigma 
%                                       for test sets. A and Sigma
%                                       should initialized, see 
%                                       below. Sets PAR.Aprior='constant'
%                                       and PAR.Sigmaprior='constant'.
%                         fa            factor analysis (FA) sets
%                                       PAR.Aprior='free', 
%                                       PAR.Sprior='Gauss' and
%                                       PAR.Sigmaprior='diagonal'.
%                         neg_kurtosis  negative kurtosis set
%                                       PAR.Sprior='bigauss'.
%                         pos_kurtosis  positive kurtosis sets
%                                       PAR.Sprior='mog'. 
%                         positive      positive ICA sets
%                                       PAR.Sprior='exponential' and
%                                       PAR.Aprior='positive'.
%                         ppca          probabilistic PCA (pPCA)
%                                       sets PAR.Aprior='free', 
%                                       PAR.Sprior='Gauss' and 
%                                       PAR.Sigmaprior='isotropic'.
%                         default       PAR.Aprior='free', 
%                                       PAR.Sprior='mog', and 
%                                       PAR.Sigmaprior='isotropic'
%
%    Additional fields that can be set in PAR (e.g. PAR.sources) are
%   
%       sources           Number of sources (default is quadratic 
%                         size(X,1)). This parameter is overridden 
%                         by size(PAR.A_init,2) if PAR.A_init is defined.
%       optimizer         optimization method for A and SIGMA
%
%                         aem           adaptive overrelaxed em by
%                                       Salakhutdinov and Roweis, default.
%                         em            expectation maximization
%                         bfgs          bfgs quasi-Newton with line search.
%                         conjgrad      conjugated gradient.
%
%       solver            method for estimating the statistics of the 
%                         sources
%
%                         ec            expectation consistent framework,
%                                       default.
%                         variational   variational (Bayes) with linear 
%                                       response correction for source
%                                       covariances and likelihood 
%                                       ( = - free energy).
%                         
%       A_init            Initial mixing matrix, default is small random 
%                         values.        
%       S_init            Initial source values, default is zero only used
%                         for estimating initial noise covariance.
%       Sigma_init        Initial noise covariance (scalar for isotropic). 
%                         Default is empirical variance.
%       max_ite           Number of A and SIGMA updates, default is 50.
%       S_max_ite         Maximum number of source mean iteration steps, 
%                         default 100.
%       S_tol             Required squared deviation of solution of mean
%                         field equations, default 1e-10.
%       draw              toggle whether to plot run-time information,
%                         defualt is 1.
%
%
%    The memory requirements are O(M^2*N+D*N), where D is the 
%    number of sensors, N the number of samples (X is D*N) and M is 
%    the number of sources. The computational complexity is typically
%    dominated by estimation of sources covariances O(M^3*N). Additional 
%    complexity can come when D is large for positive mixing matrix and/or
%    full noise covariances.  Use of QUADPROG (see above) also tends to 
%    slow down the program.
%
%    It is recommended as a preprocessing step to normalize the 
%    data, e.g. by dividing by the largest absolute element of the data: 
%    X=X/max(max(abs(X))).
%
%    See also icaMF_bic

%
% References [1-4]:
%
%    Mean Field Approaches to Independent Component Analysis
%    Pedro A.d.F.R. Højen-Sørensen, Ole Winther and Lars Kai Hansen
%    Neural Computation 14, 889-918 (2002).
%
%    Expectation Consistent Approximate Inference
%    Manfred Opper and Ole Winther
%    Journal of Machine Learning Research (2005).
%  
%    Tractable Approximations for Probabilistic Models: The Adaptive 
%    Thouless-Anderson-Palmer Mean Field Approach
%    M. Opper and O. Winther
%    Phys. Rev. Lett. 86, 3695-3699 (2001).
%
%    Adaptive and Self-averaging Thouless-Anderson-Palmer Mean Field 
%    Theory for Probabilistic Modeling
%    M. Opper and O. Winther
%    Physical Review E 64, 056131 (2001). 
% 

% Program uses notation of reference [2].

% - by Ole Winther 2002, 2005 - IMM, Technical University of Denmark
% - http://isp.imm.dtu.dk/staff/winther/
% - version 3.0

[A,Sigma,par] = initializeMF(X,par) ;

fprintf(' Mean Field ICA empirical Bayes algorithm\n')
fprintf(' %s mean field solver, %s source prior\n',par.solver,par.Sprior);  
if strcmp(par.Sprior,'combi')
    for i=1:par.sources
        fprintf('   %s source prior\n',par.S(i).prior); 
    end
end
fprintf(' %s parameter optimizer for %s A and %s noise\n',...
    par.optimizer,par.Aprior,par.Sigmaprior);
fprintf(' sensors: D = %i\n sources: M = %i\n samples: N = %i\n\n',par.D,par.M,par.N); 

if par.draw 
  if size(Sigma,1) * size(Sigma,2) == par.D
    fprintf(' initial noise variance = %g \n\n',sum(Sigma)/par.D);
  else       
    fprintf(' initial noise variance = %g \n\n',trace(Sigma)/size(Sigma,1));
  end  
end

% run mean field ICA empirical Bayes algorithm

% choose optimization method for parameters
switch lower(par.optimizer)

    case 'constant'
    
    case 'conjgrad'
         
        if par.draw
            h = waitbar(1,'Mean Field ICA - conjugated gradient optimization...') ;
        end
        
        popt = ASigma2popt(A,Sigma,par) ;
        
        popt = minimize(popt,'icaMFconjgrad',par.max_ite,X,par) ; % conjugated gradients
    
        [A,Sigma] = popt2ASigma(popt,par) ;
        
        if par.draw close(h), end

    case 'bfgs'
 
        if par.draw
            h = waitbar(1,'Mean Field ICA - BFGS optimization...') ;
        end
        
        popt = ASigma2popt(A,Sigma,par) ;
      
        par.X = X ;
        ucminf_opt = [10  1e-8  1e-12  par.max_ite];
        [popt,info] = ucminf( 'icaMFbfgs' , par , popt , ucminf_opt ); % BFGS
   
        [A,Sigma] = popt2ASigma(popt,par) ;

        if par.draw close(h), end
        
    case 'em'
    
        [A,Sigma] = icaMFem(A,Sigma,X,par) ;
    
    case 'aem' % adaptive overrelaxed em by R Salakhutdinov + S Roweis

        [A,Sigma] = icaMFaem(A,Sigma,X,par) ;
        
end

% solve mean field equations and exit!
[theta,J,par] = XASigma2thetaJ(X,A,Sigma,par) ;

[S,chi,f,ite,dSdS] = par.mf_solver(theta,J,par) ; 

loglikelihood = - f  ;

% return variables sorted according to 'energy'  
[Y,I]=sort((sum(A.^2,1))'.*sum(S.^2,2)) ;
I=flipud(I);
S=S(I,:); A=A(:,I); 
for i=1:par.N
  chi(:,:,i)=squeeze(chi(I,I,i));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                        end of main program                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          help functions                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              free energy (minus log likelihood) and derivative wrt parameters                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,df] = icaMFconjgrad(popt,X,par) % for minimize

[A,Sigma] = popt2ASigma(popt,par);

[theta,J,par] = XASigma2thetaJ(X,A,Sigma,par) ;

[S,chi,f] = par.mf_solver(theta,J,par) ;

df = dpoptf(X,A,Sigma,S,chi,par) ;



function [f,df] = icaMFbfgs(popt,par) % for ucminf

[A,Sigma] = popt2ASigma(popt,par);

[theta,J,par] = XASigma2thetaJ(par.X,A,Sigma,par) ;

[S,chi,f] = par.mf_solver(theta,J,par) ;

df = dpoptf(par.X,A,Sigma,S,chi,par) ;



function [A,Sigma] = icaMFem(A,Sigma,X,par) % em

EM_step=0;

if par.draw
    h = waitbar(0,'Mean Field ICA - running EM optimization...') ;
end

while EM_step<par.max_ite %& (dA_rel>tol | dSigma_rel>tol) 

    EM_step=EM_step+1;
    
    if par.draw waitbar(EM_step/par.max_ite,h), end
    
    [theta,J,par] = XASigma2thetaJ(X,A,Sigma,par) ;

    if par.draw
        [S,chi,f,S_ite,dSdS]=par.mf_solver(theta,J,par) ;
    else
        [S,chi] = par.mf_solver(theta,J,par) ;
    end
    
    [Anew,Sigmanew] = dASigmaf(X,A,Sigma,S,chi,par) ;

    dpoptrel = sum(abs([ (Anew(:) - A(:))'  (Sigmanew(:) - Sigma(:))' ])) / ...
               ( sum(abs([A(:)' Sigma(:)'])) + eps ) ;
   
    % em update
    A = Anew ;
    Sigma = Sigmanew ;
               
    if par.draw
        fprintf(' Iteration %d\n S_ite = %d   dSdS = %g dpar/|par| = %g\n',...
            EM_step,S_ite,dSdS,dpoptrel);
        fprintf(' loglikelihood = %6.3f  ',-f);
        if size(Sigma,1)*size(Sigma,2)==par.D 
            fprintf(' noise variance = %g \n\n',sum(Sigma)/D);
        else       
            fprintf(' noise variance = %g \n\n',trace(Sigma)/size(Sigma,1));
        end
    end

end % EM_step

if par.draw close(h), end


function [A,Sigma] = icaMFaem(A,Sigma,X,par) % aem

EM_step=0; 
fold = inf ; 
alpha = 1.05 ; % increase factor for overrelaxed
eta = 1 / alpha ;

if par.draw
    h = waitbar(0,'Mean Field ICA - running AEM optimization...') ;
end

while EM_step<par.max_ite %& (dA_rel>tol | dSigma_rel>tol) 

    EM_step=EM_step+1;
    
    if par.draw waitbar(EM_step/par.max_ite,h), end
    
    [theta,J,par] = XASigma2thetaJ(X,A,Sigma,par) ;
    
    [S,chi,f,S_ite,dSdS] = par.mf_solver(theta,J,par) ;
    
    [Aem,Sigmaem] = dASigmaf(X,A,Sigma,S,chi,par) ;
   
    if f > fold & eta > 1
        % we took a step that decreased the likelihood
        % backtrack and take regular em step instead
        eta = 1;
        A = Aold ; Sigma = Sigmaold ; f = fold ;
        Aem = Aemold ; Sigmaem = Sigmaemold ;
    else
        % increase step size
        eta = alpha * eta ;
        Aemold = Aem ; Sigmaemold = Sigmaem ;
    end 
  
    % aem update
    Aold = A ; Sigmaold = Sigma ;  fold = f ; 
    switch par.Aprior
        case 'free'
            A = A + eta * ( Aem - A ) ;
        case 'positive'
            A = A .* ( Aem ./ A ).^eta ;
            maxratio = 2; minratio = 0.5 ; % maximim increase/decrease factors
            A = min(A,maxratio*Aold); A = max(A,minratio*Aold);
    end 
      
    switch par.Sigmaprior 
        case 'free'
            logSigma = logm(Sigma) ; 
            Sigma = expm( logSigma + eta * ( logm(Sigmaem) - logSigma) ) ;
        case {'isotropic','diagonal'}
            Sigma = Sigma .* ( Sigmaem ./ Sigma ).^eta ;
    end
  
    dpoptrel = sum(abs([ (A(:) - Aold(:))'  (Sigma(:) - Sigmaold(:))' ])) / ...
                ( sum(abs([Aold(:)' Sigmaold(:)'])) + eps ) ;
    
    if par.draw
        fprintf(' Iteration %d\n S_ite = %d   dSdS = %g  eta  = %g  dpar/|par| = %g\n',...
            EM_step,S_ite,dSdS,eta,dpoptrel);
        fprintf(' loglikelihood = %6.3f  ',-f);
        if size(Sigma,1)*size(Sigma,2)==par.D 
            fprintf(' noise variance = %g \n\n',sum(Sigma)/par.D);
        else       
            fprintf(' noise variance = %g \n\n',trace(Sigma)/size(Sigma,1));
        end
    end

end % EM_step

if par.draw close(h), end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                        mean field solvers                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    expectation consistent solver                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,chi,G,ite,dmdm]=ec_solver(theta,J,par) % ,debug_draw)
% ec_solver formerly known as ec_fac_ep.m 
% expectation consistent factorized inference
% optimized using ep-style updates 

% Ole Winther, IMM, February 2005
  
% initialize variables
M = par.M ;
N = par.N ; 

% initialize constants specific for ec_solver 
try minchi=par.minchi; catch minchi = 1e-7; end
try m=par.m; catch m=zeros(M,N); end
% initial value of m=<S>=mean values of sources - called S in outer
% routines
try minLam_q=par.minLam_q; catch minLam_q = 1e-5; end
try eta=par.eta; catch eta=1; end % set learning rate for lam_r update

dm = zeros(M,N); m_r = zeros(M,N); v_r = zeros(M,N);

eigJ=eig(J); mineigJ = min(eigJ); maxeigJ = max(eigJ);
Lam_r = 1 * ( maxeigJ - mineigJ ) * ones(M,1) ;
chi = inv( diag(Lam_r) - J ) ; 
Lam_r = repmat(Lam_r,[1 N]) ;

% set mean value of r-distribution to be the same as m
gam_r = zeros(M,N) ;
m_r = m ;
v_r = diag(chi) ;

% make a covariance matrix for each sample
chi = repmat(chi,[1 1 N]) ; % could be made more effective with lightspeed.
%chiv = zeros(M,M,N) ; chivt = zeros(M,M,N) ;

ite=0;  
dmdm=Inf;
dmdmN=Inf*ones(N,1);
tolN = par.S_tol / N ;
I = 1:N;
while (~isempty(I) && dmdm>par.S_tol && ite<par.S_max_ite)     
    
  ite=ite+1;
  indx=randperm(M);
  for sindx=1:M
    cindx=indx(sindx); par.Sindx = cindx;
  
    %% find mean and variance of r
    m_r(cindx,I) = ...
        sum( shiftdim( chi(cindx,:,I) , 1 ) .* ( gam_r(:,I) + theta(:,I) ) , 1 ) ;
    v_r(cindx,I) = chi(cindx,cindx,I) ;
    
    % find Lagrange parameters of s 
    Lam_s1 = 1 ./ max( minchi , v_r(cindx,I) ) ;
    gam_s1 = Lam_s1 .* m_r(cindx,I); 
       
    % update lam_q
    gam_q = gam_s1 - gam_r(cindx,I) ; 
    Lam_q = Lam_s1 - Lam_r(cindx,I) ; 
    
    % update moments of q distribution
    [m(cindx,I),v_q] = par.Smeanf( gam_q , max( Lam_q , minLam_q ) , par ); %%% OBS hack here!!!!

    dm(cindx,I) = m(cindx,I) - m_r(cindx,I) ;

    % find Lagrange parameters of s 
    Lam_s2 = 1 ./ max( minchi , v_q ) ;
    gam_s2 = Lam_s2 .* m(cindx,I) ;

    % update lam_r
    dgam_r = eta * ( gam_s2 - gam_s1 ) ; gam_r(cindx,I) = dgam_r + gam_r(cindx,I) ;
    dLam_r = eta * ( Lam_s2 - Lam_s1 ) ; Lam_r(cindx,I) = dLam_r + Lam_r(cindx,I) ;
    
    % update chi using Sherman-Woodbury
    switch par.ecchiupdate 
        case 'parallel'
            oM = ones(M,1) ;
            kappa = dLam_r ./ ( 1 + dLam_r .* v_r(cindx,I) ) ; 
            kappa=reshape(kappa,1,1,length(I));
            chiv = chi(:,cindx,I) ; chiv =  kappa(oM,:,:) .* chiv ; chiv=chiv(:,oM,:);
            chivt = chi(cindx,:,I) ; chivt=chivt(oM,:,:);
            chi(:,:,I) = chi(:,:,I) - chiv .* chivt ; 
        case 'sequential'
            for j=1:length(I)
                i = I(j) ;
                chiv = chi(:,cindx,i) ; 
                chi(:,:,i) = chi(:,:,i) ... 
                    - dLam_r(j) / ( 1 + dLam_r(j) * v_r(cindx,i) ) * chiv * chiv' ;  
                % v_r(cindx,:) = chi(cindx,cindx,:)
            end
    end
        
  end % over variables - sindx 
 
  dmdmN=sum(dm.*dm,1) ;
  I=find(dmdmN > tolN);         
  dmdm=sum(dmdmN); 
  
end

if nargout > 2 % calculate free energy per sample
  
  Lam_s = 1 ./ max( minchi , v_r ) ; gam_s = Lam_s .* m_r ;   
  
  gam_q = gam_s - gam_r ; Lam_q = Lam_s - Lam_r ; 
  
  par.Sindx = (1:M)';
  logZ_q = par.logZ0f(gam_q, max( minLam_q , Lam_q ) , par ) ;
  logZ_r = 0.5 * ( N * log(2*pi) - N * par.logdet2piSigma - par.XinvSigmaX ) ;
  for i=1:N
    logZ_r = logZ_r + 0.5 * logdet( chi(:,:,i) ) ...
        + 0.5 * ( gam_r(:,i) + theta(:,i) )' * ...
                  chi(:,:,i) * ( gam_r(:,i) + theta(:,i) ) ;  
  end
  logZ_s = 0.5 * ( N * log(2*pi) + ...
        sum( sum(  - log( Lam_s ) + gam_s.^2 ./ Lam_s ) ) ) ;  
  G = ( - logZ_q - logZ_r + logZ_s ) / N ;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                         variational solver                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [m,chi,G,ite,dmdm]=variational_solver(theta,J,par)

M = par.M ;
N = par.N ; 

chi = zeros( M , M , N ) ;

% initialize constants
try minchi=par.minchi; catch minchi = 1e-7; end
try m=par.m; catch m=zeros(M,N); end
% initial value of m=<S>=mean values of sources - called S in outer
% routines

dm = m ;
Lam_q = - diag(J) ;  % variational result

ite=0;  
dmdm=Inf;
dmdmN=zeros(N,1);
tolN = par.S_tol / N ;
I=1:N;

while (~isempty(I) && dmdm>par.S_tol && ite<par.S_max_ite)     

    ite=ite+1 ;

    indx=randperm(M);

    for sindx=1:M

        cindx=indx(sindx); par.Sindx = cindx; % current index 
       
        % update hcav           
        gam_q = theta(cindx,I) + J(cindx,:) * m(:,I) + Lam_q(cindx) * m(cindx,I) ;
   
        % update m and derivative
        m_old=m(cindx,I);
        m(cindx,I)=par.Smeanf(gam_q,Lam_q(cindx,ones(size(I))),par) ;
        dm(cindx,I)=m(cindx,I)-m_old;        
 
    end   
 
    dmdmN=sum(dm.*dm,1);
    I=find(dmdmN > tolN);         
    dmdm=sum(dmdmN) ;
 
end      


if nargout > 1 % calculate chi
    gam_q = theta + ( J + diag(Lam_q) )* m ;
    par.Sindx = (1:M)';
    [m_q,v_q] = par.Smeanf( gam_q , Lam_q(:,ones(N,1)) , par);
    for i=1:N
        % Lam_s = 1 ./ v_q ;
        % chi = inv( diag( Lam_r ) - J ) = inv( diag( Lam_s -Lam_q ) - J )
        chi(:,:,i) = inv( eye(M) - diag( v_q(:,i) ) * ( J + diag( Lam_q ) ) ) * diag( v_q(:,i) ) ;
    end
end

if nargout > 2 % calculate free energy per sample
  
  Lam_s = 1 ./ max( minchi , v_q ) ; gam_s = Lam_s .* m_q ;   
  
  gam_r = gam_s - gam_q ; % Lam_r = Lam_s - Lam_q(:,ones(N,1)) ;  
  
  logZ_q = par.logZ0f(gam_q,Lam_q(:,ones(N,1)) , par ) ;
  logZ_r = 0.5 * ( N * log(2*pi) - N * par.logdet2piSigma - par.XinvSigmaX ) ;
  for i=1:N
    logZ_r = logZ_r + 0.5 * logdet( chi(:,:,i) ) ...
        + 0.5 * ( gam_r(:,i) + theta(:,i) )' * ...
                  chi(:,:,i) * ( gam_r(:,i) + theta(:,i) ) ;  
  end
  logZ_s = 0.5 * ( N * log(2*pi) + ...
        sum( sum(  - log( Lam_s ) + gam_s.^2 ./ Lam_s ) ) ) ;  
  G = ( - logZ_q - logZ_r + logZ_s ) / N ;

end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                        parameter conversion                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [theta,J,par] = XASigma2thetaJ(X,A,Sigma,par) 

% invert Sigma
switch size(Sigma,1)*size(Sigma,2)  
    case 1
        invSigma = 1 / Sigma; 
        par.logdet2piSigma = par.D * log( 2 * pi * Sigma ) ;
    case par.D
        invSigma = diag(1./Sigma); 
        par.logdet2piSigma = sum( log( 2 * pi * Sigma ) ) ;
    case par.D^2
        invSigma = inv(Sigma); 
        par.logdet2piSigma = logdet( 2 * pi * Sigma ) ;      
end

% calculate external field and coupling matrix
theta = A' * invSigma * X ;
J = - A' * invSigma * A ;
    
par.XinvSigmaX = sum( sum( X .* ( invSigma * X ) ) ) ;  


function [A,Sigma] = popt2ASigma(popt,par) ;

D = par.D ; M = par.M ;  

switch par.Aprior
    case 'free'
        A = reshape( popt(1:par.Asize) , D , M ) ;
    case 'positive'
        A = exp( reshape(popt(1:par.Asize), D , M ) ) ;
    case 'constant'
        A = par.A_init ;
end

switch par.Sigmaprior 
    case 'free' 
        par.sSigma = reshape(popt(par.Asize+1:end),par.D,par.D) ;
        Sigma = par.sSigma' * par.sSigma ;
    case {'isotropic','diagonal'}
        Sigma = exp( popt(par.Asize+1:end) ) ;
    case 'constant'
        Sigma = par.Sigma_init ;
end

function [popt] = ASigma2popt(A,Sigma,par) ;

D = par.D ; 

popt = zeros( par.Asize + par.Sigmasize , 1 ) ;

if strcmp(par.Aprior,'positive') & ...
        ( strcmp(par.optimizer,'bfgs') | strcmp(par.optimizer,'conjgrad') )
    popt(1:par.Asize) = log(A(:)) ;
else
    popt(1:par.Asize) = A(:) ;
end
 
switch par.Sigmaprior 
    case 'free' 
        popt(par.Asize+1:end) = par.sSigma(:) ; %R(par.triui) ;
    case {'isotropic','diagonal'}
        popt(par.Asize+1:end) = log(Sigma(:)) ;
    case 'constant'
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     parameter derivatives                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dpopt = dpoptf(X,A,Sigma,S,chi,par)
    
M = par.M ;

dpopt = zeros( par.Asize + par.Sigmasize , 1 ) ; 

for i=1:M  % set up matrices for finding derivatives
    for j=i:M
        tracechi(i,j)=sum(chi(i,j,:));
        tracechi(j,i)=tracechi(i,j);
        traceSS(i,j)=sum(chi(i,j,:))+sum(S(i,:)'.*S(j,:)');
        traceSS(j,i)=traceSS(i,j);
    end;
end;

if size(Sigma) == [par.D,1] 
    invSigma = diag(1 ./ Sigma ) ;
else
    invSigma = inv(Sigma) ;
end

dA = invSigma * ( A * traceSS - X * S' ) / par.N ;

switch par.Aprior
    case 'free'
        dpopt(1:par.Asize) = dA(:) ;
    case 'positive'
        dpopt(1:par.Asize) = A(:) .* dA(:) ;
    case 'constant'
end


switch par.Sigmaprior
    case 'isotropic'
        dSigma = 0.5 * invSigma * ( par.D  - ...
            ( sum(sum((X-A*S).^2)) + ... 
            sum(sum((A*tracechi).*A)) ) * invSigma / par.N ) ;
        dpopt(par.Asize+1) = Sigma * dSigma ;
    case 'diagonal'
        invSigma = diag( invSigma ) ;
        dSigma = 0.5 * invSigma .* ( ones(par.D,1) - ...
            ( sum((X-A*S).^2,2) + ... 
            sum((A*tracechi).*A,2) ) .* invSigma / par.N ) ;
        dpopt(par.Asize+1:end) =  Sigma .* dSigma ; 
    case 'free' 
        dSigma = 0.5 * invSigma * ( eye(par.D) - ...
            ( (X-A*S)*(X-A*S)' + A*tracechi*A' ) * invSigma / par.N ) ;  
        dSigma = 2 * dSigma - diag(diag(dSigma)) ; % take into account Sigma is symmetric
        dSigma = 2 * par.sSigma * dSigma ;
        dpopt(par.Asize+1:end) = dSigma(:) ;
    case 'constant'
end

function [A,Sigma] = dASigmaf(X,A,Sigma,S,chi,par)
    
M = par.M ;

for i=1:M  % set up matrices for finding derivatives
    for j=i:M
        tracechi(i,j)=sum(chi(i,j,:));
        tracechi(j,i)=tracechi(i,j);
        traceSS(i,j)=sum(chi(i,j,:))+sum(S(i,:)'.*S(j,:)');
        traceSS(j,i)=traceSS(i,j);
    end;
end;

if size(Sigma) == [par.D,1] 
    invSigma = diag(1 ./ Sigma ) ;
else
    invSigma = inv(Sigma) ;
end

switch par.Aprior
    case 'free'
        A = X * S' * inv(traceSS) ;
    case 'positive' % iterate eq. (2.13) in Ref. [3]
        A = A_positive_aem(traceSS,X * S',invSigma,A) ;
    case 'constant'
        A = par.A_init ;
end   

switch par.Sigmaprior
    case 'isotropic'
        Sigma = ( sum(sum((X-A*S).^2)) + ... 
            sum(sum((A*tracechi).*A)) ) / ( par.N * par.D ) ;
    case 'diagonal'
        Sigma = ( sum((X-A*S).^2,2) + ... 
                    sum((A*tracechi).*A,2) ) / par.N ;
    case 'free' 
        Sigma = ( (X-A*S)*(X-A*S)' + A*tracechi*A' ) / par.N ;  
    case 'constant'
        Sigma = par.Sigma_init ;
end


function [A] = A_positive(traceSS,XSt,invSigma,A) 

Atol = 1e-6;
KT_max_ite=100; 
A=A+10^-3*(A<eps);
sizeA = size(A,1) * size(A,2) ;
invSigmaXSt = invSigma * XSt ; 
amp=invSigmaXSt./max(eps,invSigma*A*traceSS);
Aneg=any(any(amp<0));
KT_ite=0; Aerror = inf ;
while ~Aneg & KT_ite<KT_max_ite & Aerror > Atol
  KT_ite=KT_ite+1;
  %dA = A - A.*amp ; dAerror = sum(sum(dA)) / (size(A,1)*size(A,2))
  Aold = A ;
  A=A.*amp ; 
  amp=invSigmaXSt./max(eps,invSigma*A*traceSS);
  Aneg=any(any(amp<0));
  Aerror = sum(sum(abs(A-Aold))) / sizeA ;
end
if Aneg % use quadratic programming instead - doesn't work for Sigma full
  M=size(traceSS,1);
  D=size(XSt,1);
  options=optimset('Display','off','TolX',10^5*eps,'TolFun',10^5*eps);
  for i=1:D
    B=quadprog(traceSS,-XSt(i,:)',[],[],[],[],zeros(M,1),[],A(i,:)',options);
    A(i,:)=B';
  end 
end

function [A] = A_positive_aem(traceSS,XSt,invSigma,A) 

Atol = 1e-6;
KT_max_ite=100; 
A=A+10^-3*(A<eps);
sizeA = size(A,1) * size(A,2) ;
invSigmaXSt = invSigma * XSt ; 
amp=invSigmaXSt./(invSigma*A*traceSS);
f = sum( sum( traceSS .* ( A' * invSigma * A ) ) ) ...
    - 2 * sum( sum( A .* ( invSigma * XSt ) ) ) ;
Aneg=any(any(amp<0));
KT_ite=0; Aerror = inf ;
alpha = 2; %1.1 ;
eta = 1 ;
%maxratio=4; minratio=0.25; % maximum increase/decrease factors
while ~Aneg & KT_ite<KT_max_ite & Aerror > Atol 
  KT_ite=KT_ite+1;
  Aold = A ;
  A=A.*amp.^eta;
  %A=min(A,maxratio*Aold); A=max(A,minratio*Aold);
  fnew = sum( sum( traceSS .* ( A' * invSigma * A ) ) ) ...
    - 2 * sum( sum( A .* ( invSigma * XSt ) ) ) ;
  if f < fnew 
      eta = 1 ;
      A = Aold .* amp ;
      %A=min(A,maxratio*Aold); A=max(A,minratio*Aold);
      f = sum( sum( traceSS .* ( A' * invSigma * A ) ) ) ...
        - 2 * sum( sum( A .* ( invSigma * XSt ) ) ) ;
  else
      eta = alpha * eta ;
      f = fnew ;
  end
  amp=invSigmaXSt./(invSigma*A*traceSS);
  Aneg=any(any(amp<0));
  Aerror = sum(sum(abs(A-Aold))) / sizeA ;
end
%KT_ite
if Aneg % use quadratic programming instead - doesn't work for Sigma full
  M=size(traceSS,1);
  D=size(XSt,1);
  options=optimset('Display','off','TolX',10^5*eps,'TolFun',10^5*eps);
  for i=1:D
    B=quadprog(traceSS,-XSt(i,:)',[],[],[],[],zeros(M,1),[],A(i,:)',options);
    A(i,:)=B';
  end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     initialization                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,Sigma,par] = initializeMF(X,par) 

% function handle to mean field solver
try 
    par.mf_solver = str2func( sprintf('%s_solver',par.solver) ) ;
catch
    par.mf_solver = str2func('ec_solver') ;
end
       

% method
try 
  switch par.method
    case 'constant'
      par.Aprior='constant'; par.Sigmaprior='constant';
    case 'fa' % factor analysis
      par.Aprior='free'; par.Sprior='Gauss'; par.Sigmaprior='diagonal';
    case 'neg_kurtosis'
      par.Sprior='bigauss';
    case 'pos_kurtosis'
      par.Sprior='mog'; 
    case 'positive'
      par.Sprior='exponential'; par.Aprior='positive';
    case 'ppca' % probabilistic PCA
      par.Aprior='free'; par.Sprior='Gauss'; par.Sigmaprior='isotropic';
  end
end   

% number of inputs, examples
[ par.D , par.N ] = size(X) ;

% A and number of sources
try par.Aprior; catch par.Aprior = 'free' ; end
try par.M = par.sources; catch par.M = par.D ; end  % default square mixing 
try 
    A = par.A_init;
    [ par.D , par.M ] = size( A ); 
catch
    Ascale = 0.1 / sqrt(par.M) ;
    A = Ascale * randn( par.D , par.M ); % use small random matrix  
    if strcmp(par.Aprior, 'positive' ) A = A .* sign(A) / sqrt( par.M) ; end
end
if strcmp( par.Aprior ,'constant' )
    par.Asize = 0 ;
    try par.A_init; 
    catch 
        error('par.A_init should be defined when par.Aprior = ''constant'''); 
    end
else
    par.Asize = par.D * par.M ;
end

% the sources
try % so far the initial value of S is only used to initialize Sigma!!!
    S = par.S_init ; 
    if size(S,1) ~= par.M
        error('size(S,1) must equal the number of sources'); 
    end
catch
    S=zeros(par.M,par.N); 
end
try % function handle to mean functions
    par.Smeanf = str2func(par.Sprior) ;
    par.logZ0f = str2func( sprintf('logZ0_%s',par.Sprior) ) ;
catch
    par.Smeanf = str2func('mog') ;
    par.logZ0f = str2func('logZ0_mog');
end
% parameters for prior distribution should be set here in field
% par.S(i).xxx
try par.Sprior; catch par.Sprior='mog'; end
switch lower(par.Sprior)
    case 'combi'
        for i=1:par.sources % maximum number of different priors
            try 
                par.S(i).meanf = str2func( par.S(i).prior ) ;
                par.S(i).logZ0f = str2func( sprintf('logZ0_%s',par.S(i).prior) ) ;
                switch par.S(i).prior
                    case 'mog'
                        try par.S(i).pi; catch par.S(i).pi = []; end 
                        try par.S(i).mu; catch par.S(i).mu = []; end 
                        try par.S(i).Sigma; catch par.S(i).Sigma = []; end
                        if isempty(par.S(i).pi) par.S(i).pi = [ 0.5 0.5 ]'; end
                        if isempty(par.S(i).mu) par.S(i).mu = [ 0 0 ]'; end
                        if isempty(par.S(i).Sigma) par.S(i).Sigma = [ 1 0.01 ]'; end
                end
                % parameter values for other priors should be added here!
            catch 
                error('Sprior is combi, but not all sources are specified in par.S(i).prior') ;
            end
        end
    case 'mog'
        try par.S.pi; catch par.S(1).pi = [0.5 0.5]'; end % mixing proportions
        try par.S.mu; catch par.S(1).mu = [0 0]'; end % means
        try par.S.Sigma; catch par.S(1).Sigma = [1 0.01]'; end % means
        Ssources = length(par.S) ;
        par.S(1).K = length(par.S(1).pi) ;
        if Ssources ~= par.sources % use same parameters for all sources 
            for indx=2:par.sources
                par.S(indx) = par.S(1) ;
            end
        end
end

% Sigma
try par.Sigmaprior; catch par.Sigmaprior = 'isotropic' ; end
switch par.Sigmaprior
    case 'isotropic'
        par.Sigmasize = 1 ;   
    case 'diagonal'
        par.Sigmasize = par.D ;
    case 'free'
        par.Sigmasize = par.D^2 ; 
    case 'constant'
        par.Sigmasize = 0 ; 
        try par.Sigma_init; catch 
            error('par.Sigma_init should be defined when par.Sigmaprior = ''constant'''); 
        end
end
try
  Sigma=par.Sigma_init;  
catch                
  Sigmascale = 1 ;
  switch par.Sigmaprior
    case {'isotropic','constant'}
      Sigma = Sigmascale * sum(sum( ( X - A * S ).^2 ) ) / (par.D*par.N) ;   
    case 'diagonal'
      Sigma = Sigmascale * sum( ( X - A * S ).^2 , 2 ) / par.N ; 
    case 'free'
      Sigma = Sigmascale * ( X - A * S ) * ( X - A * S )' / par.N ;
  end
end

% optimizer
try par.optimizer; catch par.optimizer = 'aem' ; end
if par.Asize + par.Sigmasize == 0 % no parameters to be optimized 
    par.optimizer = 'constant';
end

% more init of parameters...
if strcmp(par.Sigmaprior,'free') & ... 
        ( strcmp(par.optimizer,'bfgs') | strcmp(par.optimizer,'conjgrad') )
 % use par.sSigma as variable for unconstrained optimization in bfgs and
 % conjgrad
      par.sSigma = sqrtm(Sigma) ;  
end

% run time output
try par.draw ; catch par.draw = 1 ; end

% number of iterations and error tolerance
try par.max_ite; catch par.max_ite = 50 ; end
try par.S_tol; catch par.S_tol = 1e-10 ; end 
try par.S_max_ite; catch par.S_max_ite = 100 ; end

% chi update specific for ec_solver
try 
    par.ecchiupdate ;
catch
    if par.M > 10
        par.ecchiupdate = 'sequential' ;
    else
        par.ecchiupdate = 'parallel' ;
    end
end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                       mean (S) functions                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,df] = bigauss(gamma,lambda,par)
sigma2=1; mu=1;
lambda=1./(1+lambda*sigma2);
f=tanh(mu*gamma.*lambda);
if nargout > 1 
    df=lambda.*(sigma2+mu^2.*lambda.*(1-f.^2));
end
f=lambda.*(sigma2*gamma+mu*f);

function [f,df] = binary(gamma,lambda,par)
f=tanh(gamma);
if nargout > 1
    df=1-f.^2;
end

function [f,df] = binary_01(gamma,lambda,par)
tmp=exp(0.5*lambda+gamma);
f=1./(1+exp(0.5*lambda-gamma));
if nargout > 1 
    df=f.*(1-f);
end

function [f,df] = combi(gamma,lambda,par)
f = zeros(size(gamma)) ; df = zeros(size(gamma)) ;
Sindx = par.Sindx ;
for i=1:length(Sindx)
    par.Sindx = Sindx(i) ; % to pass information about current source
    [f(i,:),df(i,:)] = par.S(Sindx(i)).meanf(gamma(i,:),lambda(i,:),par) ;
end

function [f,df] = exponential(gamma,lambda,par)
eta=1;
erfclimit=-35;
%minlambda=10^-4;
%lambda=lambda.*(lambda>minlambda)+minlambda.*(lambda<=minlambda);
xi=(gamma-eta)./sqrt(lambda);
cc=(xi>erfclimit);
%i=find(cc==0);
%if ~isempty(i)
%    cc, pause
%end
xi1=xi.*cc;
epfrac=exp(-(xi1.^2)/2)./(Phi(xi1)*sqrt(2*pi));
f=cc.*(xi1+epfrac)./sqrt(lambda);            % need to go to higher order to get asymptotics right
if nargout > 1
    df=cc.*(1./lambda+f.*(xi1./sqrt(lambda)-f)); % need to go to higher order to get asymptotics right -fix at some point!!!
end

function [f,df] = Gauss(gamma,lambda,par)
f=gamma./(1+lambda);
if nargout > 1
    df=1./(1+lambda);
end

function [f,df] = heavy_tail(gamma,lambda,par)
alpha=1; % if changed change also in logZ0_heavy_tail
f=gamma./lambda-alpha*gamma./(2*alpha*lambda+gamma.^2);
if nargout > 1
    df=1./lambda+alpha*(gamma.^2-2*alpha*lambda)./(2*alpha*lambda+gamma.^2).^2;
end

function [f,df] = heavy_tail_plus_delta(gamma,lambda,par)
alpha=1; % if changed change also in logZ0_heavy_tail_plus_delta
beta=0.3; % proporation delta if changed change also in logZ0_heavy_tail_plus_delta
Z0ht=exp(0.5*gamma.^2./lambda).*(1+gamma.^2./(2*alpha*lambda)).^(-0.5*alpha);
f=(1-beta)*(gamma./lambda-alpha*gamma./(2*alpha*lambda+gamma.^2))./...
  (beta./Z0ht+(1-beta));
if nargout > 1 
    df=(1-beta)./(beta./Z0ht+(1-beta)).*...
        (1./lambda+alpha*(gamma.^2-2*alpha*lambda)./(2*alpha*lambda+gamma.^2).^2+...
        (gamma./lambda-alpha*gamma./(2*alpha*lambda+gamma.^2)).^2)-f.^2;
end
    
function [f,df] = Laplace(gamma,lambda,par)
erfclimit=-25;
eta=1;
%minlambda=10^-4;
%lambda=lambda.*(lambda>minlambda)+minlambda.*(lambda<=minlambda);
xip=(gamma-eta)./sqrt(lambda);
ccp=(xip>erfclimit);ccpc=not(ccp);
xip1=ccp.*xip;
xim=-(gamma+eta)./sqrt(lambda);
ccm=(xim>erfclimit);ccmc=not(ccm);
xim1=ccm.*xim;
Dp=exp(-(xip1.^2)/2)/sqrt(2*pi);
Dm=exp(-(xim1.^2)/2)/sqrt(2*pi);
kp=Phi(xip1).*Dm;  
km=Phi(xim1).*Dp; 
f=ccp.*ccm.*(xip.*kp-xim.*km)./(sqrt(lambda).*(kp+km))+(-ccpc.*xim+ccmc.*xip)./sqrt(lambda);
if nargout > 1 
    df=(ccp.*ccm.*(1+xim.*xip+Dp.*Dm.*(xip+xim)./(kp+km)+sqrt(lambda).*(xip.*km-xim.*kp)./(kp+km).*f)+ccpc+ccmc)./lambda;
end

function [f,df] = mog(gamma,lambda,par)
[M N ] = size(gamma);
oN = ones(N,1) ;
K = length(par.S(par.Sindx(1)).pi) ;
oK = ones(K,1) ; 
for i = 1:length(par.Sindx) % loop over sources
    cindx = par.Sindx(i) ;
    cgamma = gamma(i,:) ; clambda = lambda(i,:) ; % 1 * N
    logpi = log(par.S(cindx).pi) ; % K * N
    cmu = par.S(cindx).mu ;        % K * 1
    cSigma = par.S(cindx).Sigma ; % K * 1
    mu2dSigma = cmu.^2 ./ cSigma ; 
    musqrtSigma = cmu .* sqrt(cSigma) ; 
    opSigmalambda = 1 + cSigma * clambda ;
    resp = logpi(:,oN) - 0.5 * log( opSigmalambda ) ....
       + 0.5 * ( sqrt(cSigma) * cgamma + musqrtSigma(:,oN) ) .^2 ./ ...
       opSigmalambda - 0.5 * mu2dSigma(:,oN) ; % K * N
    maxresp = max( resp, [] , 1 ) ;
    resp = exp( resp - maxresp(oK,:) ) ;
    normalizer = sum( resp, 1 ) ;
    mconst = ( cgamma(oK,:) + cmu(:,oN) ) .* cSigma(:,oN) ./ opSigmalambda ;
    f(i,:) = sum(  mconst .* resp , 1 ) ./ normalizer ;
    if nargout > 1 
        df(i,:) = ...
            sum( ( cSigma(:,oN) ./ opSigmalambda + mconst.^2 ) .* resp , 1 ) ./ ...
            normalizer ;
    end
end
if nargout > 1 
    df = df - f.^2 ;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                       logZ0 functions                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [logZ0] = logZ0_bigauss(gamma,lambda,par)
sigma2=1; mu=1;
lambda=1./(1+lambda*sigma2);
logZ0terms=0.5*(log(lambda)-mu^2/sigma2+lambda.*(mu^2/sigma2+gamma.^2*sigma2))...
           -log(2)+abs(gamma*mu.*lambda)+log(1+exp(-2*abs(gamma*mu.*lambda))); % log(cosh(gamma*mu.*lambda))
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_binary(gamma,lambda,par)
logZ0terms=-0.5*lambda-log(2)+abs(gamma)+log(1+exp(-2*abs(gamma)));
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_binary_01(gamma,lambda,par)
gamma=0.5*(gamma-0.5*lambda);
logZ0terms=gamma-log(2)+abs(gamma)+log(1+exp(-2*abs(gamma)));
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_combi(gamma,lambda,par)
logZ0=0;
for i=1:par.M % assumes that run through all sources
    par.Sindx = i ; % to pass information about current source
    logZ0 = logZ0 + par.S(i).logZ0f(gamma(i,:),lambda(i,:),par) ;
end


function [logZ0] = logZ0_exponential(gamma,lambda,par)
eta=1;
erfclimit=-35;
%minlambda=10^-4;
%lambda=lambda.*(lambda>minlambda)+minlambda.*(lambda<=minlambda);
xi=(gamma-eta)./sqrt(lambda);
cc=(xi>erfclimit);
xi1=xi.*cc;
logZ0terms=cc.*(log(Phi(xi1))+0.5*log(2*pi)+0.5*xi1.^2)-(1-cc).*log(abs(xi)+cc)+log(eta)-0.5*log(lambda);
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_Gauss(gamma,lambda,par)
logZ0terms=0.5*gamma.^2./(1+lambda)-0.5*log(1+lambda);
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_heavy_tail(gamma,lambda,par)
alpha=1; % if changed change also in heavy_tail.m
logZ0terms=0.5*gamma.^2./lambda-0.5*alpha*log(1+gamma.^2./(2*lambda*alpha));
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_heavy_tail_plus_delta(gamma,lambda,par)
alpha=1; % if changed change also in heavy_tail_plus_delta
beta=0.3; % proporation delta if changed change also in heavy_tail_plus_delta
Z0ht=exp(0.5*gamma.^2./lambda).*(1+gamma.^2./(2*alpha*lambda)).^(-0.5*alpha);
logZ0terms=log(beta+(1-beta)*Z0ht);
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_Laplace(gamma,lambda,par)
erfclimit=-25;
eta=1;
%minlambda=10^-4;
%lambda=lambda.*(lambda>minlambda)+minlambda.*(lambda<=minlambda);
xip=(gamma-eta)./sqrt(lambda);
ccp=(xip>erfclimit);ccpc=not(ccp);
xip1=ccp.*xip;
xim=-(gamma+eta)./sqrt(lambda);
ccm=(xim>erfclimit);ccmc=not(ccm);
xim1=ccm.*xim;
Dp=exp(-(xip1.^2)/2)/sqrt(2*pi);
Dm=exp(-(xim1.^2)/2)/sqrt(2*pi);
Phip=Phi(xip1);  
Phim=Phi(xim1); 
logZ0terms=log(0.5*eta)+0.5*log(2*pi./lambda)+... 
ccp.*ccm.*(0.5*xip1.^2+0.5*xim1.^2+log(Dm.*Phip+Dp.*Phim)-0.5*log(2*pi))+...
ccp.*ccmc.*(0.5*xip1.^2+log(Phip+Dp./(abs(xim)+ccm)))+...
ccpc.*ccm.*(0.5*xim1.^2+log(Phim+Dm./(abs(xip)+ccp)))+...
ccpc.*ccmc.*(log(1./(abs(xip)+ccp)+1./(abs(xim)+ccm))-0.5*log(2*pi));
logZ0=sum(sum(logZ0terms));

function [logZ0] = logZ0_mog(gamma,lambda,par)
oN = ones(size(gamma,2),1) ;
K = length(par.S(par.Sindx(1)).pi) ;
oK = ones(K,1) ;
logZ0 = 0 ;
for i = 1:length(par.Sindx) % loop over sources
    cindx = par.Sindx(i) ;
    cgamma = gamma(i,:) ; clambda = lambda(i,:) ; % 1 * N
    logpi = log(par.S(cindx).pi) ; % K * 1
    cmu = par.S(cindx).mu ;       % K * 1
    cSigma = par.S(cindx).Sigma ; % K * 1
    mu2dSigma = cmu .^ 2 ./ cSigma ; 
    musqrtSigma = cmu .* sqrt(cSigma) ; 
    resp = logpi(:,oN) - 0.5 * log( 1 + cSigma * clambda ) ....
       + 0.5 * (sqrt(cSigma) * cgamma + musqrtSigma(:,oN) ) .^2 ./ ...
       ( 1 + cSigma * clambda ) - 0.5 * mu2dSigma(:,oN) ; % K * N
    maxresp = max( resp, [] , 1 ) ;
    logZ0 = logZ0 + sum ( maxresp + log( sum( exp( resp - maxresp(oK,:) ) , 1 ) ) ) ; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                different math help function                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = logdet(A)
% log(det(A)) where A is positive-definite.
% This is faster and more stable than using log(det(A)).

[U,p] = chol(A);
if p 
    y=0; % if not positive definite return 0 , could also be a log(eps)
else
    y = 2*sum(log(diag(U)));
end


% Phi (error) function
function y=Phi(x)
% Phi(x) = int_-infty^x Dz 
z=abs(x/sqrt(2));
t=1.0./(1.0+0.5*z);
y=0.5*t.*exp(-z.*z-1.26551223+t.*(1.00002368+...
    t.*(0.37409196+t.*(0.09678418+t.*(-0.18628806+t.*(0.27886807+...
    t.*(-1.13520398+t.*(1.48851587+t.*(-0.82215223+t.*0.17087277)))))))));
y=(x<=0.0).*y+(x>0).*(1.0-y);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           conjugated gradient minimizer by C Rasmussen                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, fX, i] = minimize(X, f, length, P1, P2, P3, P4, P5);

% Minimize a continuous differentialble multivariate function. Starting point
% is given by "X" (D by 1), and the function named in the string "f", must
% return a function value and a vector of partial derivatives. The Polack-
% Ribiere flavour of conjugate gradients is used to compute search directions,
% and a line search using quadratic and cubic polynomial approximations and the
% Wolfe-Powell stopping criteria is used together with the slope ratio method
% for guessing initial step sizes. Additionally a bunch of checks are made to
% make sure that exploration is taking place and that extrapolation will not
% be unboundedly large. The "length" gives the length of the run: if it is
% positive, it gives the maximum number of line searches, if negative its
% absolute gives the maximum allowed number of function evaluations. You can
% (optionally) give "length" a second component, which will indicate the
% reduction in function value to be expected in the first line-search (defaults
% to 1.0). The function returns when either its length is up, or if no further
% progress can be made (ie, we are at a minimum, or so close that due to
% numerical problems, we cannot get any closer). If the function terminates
% within a few iterations, it could be an indication that the function value
% and derivatives are not consistent (ie, there may be a bug in the
% implementation of your "f" function). The function returns the found
% solution "X", a vector of function values "fX" indicating the progress made
% and "i" the number of iterations (line searches or function evaluations,
% depending on the sign of "length") used.
%
% Usage: [X, fX, i] = minimize(X, f, length, P1, P2, P3, P4, P5)
%
% See also: checkgrad 
%
% Copyright (C) 2001 and 2002 by Carl Edward Rasmussen. Date 2002-02-13

RHO = 0.01;                            % a bunch of constants for line searches
SIG = 0.5;       % RHO and SIG are the constants in the Wolfe-Powell conditions
INT = 0.1;    % don't reevaluate within 0.1 of the limit of the current bracket
EXT = 3.0;                    % extrapolate maximum 3 times the current bracket
MAX = 20;                         % max 20 function evaluations per line search
RATIO = 100;                                      % maximum allowed slope ratio

argstr = [f, '(X'];                      % compose string used to call function
for i = 1:(nargin - 3)
  argstr = [argstr, ',P', int2str(i)];
end
argstr = [argstr, ')'];


if max(size(length)) == 2, red=length(2); length=length(1); else red=1; end
if length>0, S=['Linesearch']; else S=['Function evaluation']; end 

i = 0;                                            % zero the run length counter
ls_failed = 0;                             % no previous line search has failed
fX = [];
[f1 df1] = eval(argstr);                      % get function value and gradient
i = i + (length<0);                                            % count epochs?!
s = -df1;                                        % search direction is steepest
d1 = -s'*s;                                                 % this is the slope
z1 = red/(1-d1);                                  % initial step is red/(|s|+1)

while i < abs(length)                                      % while not finished
  i = i + (length>0);                                      % count iterations?!

  X0 = X; f0 = f1; df0 = df1;                   % make a copy of current values
  X = X + z1*s;                                             % begin line search
  [f2 df2] = eval(argstr);
  i = i + (length<0);                                          % count epochs?!
  d2 = df2'*s;
  f3 = f1; d3 = d1; z3 = -z1;             % initialize point 3 equal to point 1
  if length>0, M = MAX; else M = min(MAX, -length-i); end
  success = 0; limit = -1;                     % initialize quanteties
  while 1
    while ((f2 > f1+z1*RHO*d1) | (d2 > -SIG*d1)) & (M > 0) 
      limit = z1;                                         % tighten the bracket
      if f2 > f1
        z2 = z3 - (0.5*d3*z3*z3)/(d3*z3+f2-f3);                 % quadratic fit
      else
        A = 6*(f2-f3)/z3+3*(d2+d3);                                 % cubic fit
        B = 3*(f3-f2)-z3*(d3+2*d2);
        z2 = (sqrt(B*B-A*d2*z3*z3)-B)/A;       % numerical error possible - ok!
      end
      if isnan(z2) | isinf(z2)
        z2 = z3/2;                  % if we had a numerical problem then bisect
      end
      z2 = max(min(z2, INT*z3),(1-INT)*z3);  % don't accept too close to limits
      z1 = z1 + z2;                                           % update the step
      X = X + z2*s;
      [f2 df2] = eval(argstr);
      M = M - 1; i = i + (length<0);                           % count epochs?!
      d2 = df2'*s;
      z3 = z3-z2;                    % z3 is now relative to the location of z2
    end
    if f2 > f1+z1*RHO*d1 | d2 > -SIG*d1
      break;                                                % this is a failure
    elseif d2 > SIG*d1
      success = 1; break;                                             % success
    elseif M == 0
      break;                                                          % failure
    end
    A = 6*(f2-f3)/z3+3*(d2+d3);                      % make cubic extrapolation
    B = 3*(f3-f2)-z3*(d3+2*d2);
    z2 = -d2*z3*z3/(B+sqrt(B*B-A*d2*z3*z3));        % num. error possible - ok!
    if ~isreal(z2) | isnan(z2) | isinf(z2) | z2 < 0   % num prob or wrong sign?
      if limit < -0.5                               % if we have no upper limit
        z2 = z1 * (EXT-1);                 % the extrapolate the maximum amount
      else
        z2 = (limit-z1)/2;                                   % otherwise bisect
      end
    elseif (limit > -0.5) & (z2+z1 > limit)          % extraplation beyond max?
      z2 = (limit-z1)/2;                                               % bisect
    elseif (limit < -0.5) & (z2+z1 > z1*EXT)       % extrapolation beyond limit
      z2 = z1*(EXT-1.0);                           % set to extrapolation limit
    elseif z2 < -z3*INT
      z2 = -z3*INT;
    elseif (limit > -0.5) & (z2 < (limit-z1)*(1.0-INT))   % too close to limit?
      z2 = (limit-z1)*(1.0-INT);
    end
    f3 = f2; d3 = d2; z3 = -z2;                  % set point 3 equal to point 2
    z1 = z1 + z2; X = X + z2*s;                      % update current estimates
    [f2 df2] = eval(argstr);
    M = M - 1; i = i + (length<0);                             % count epochs?!
    d2 = df2'*s;
  end                                                      % end of line search

  if success                                         % if line search succeeded
    f1 = f2; fX = [fX' f1]';
    fprintf('%s %6i;  Value %4.6e\r', S, i, f1);
    s = (df2'*df2-df1'*df2)/(df1'*df1)*s - df2;      % Polack-Ribiere direction
    tmp = df1; df1 = df2; df2 = tmp;                         % swap derivatives
    d2 = df1'*s;
    if d2 > 0                                      % new slope must be negative
      s = -df1;                              % otherwise use steepest direction
      d2 = -s'*s;    
    end
    z1 = z1 * min(RATIO, d1/(d2-realmin));          % slope ratio but max RATIO
    d1 = d2;
    ls_failed = 0;                              % this line search did not fail
  else
    X = X0; f1 = f0; df1 = df0;  % restore point from before failed line search
    if ls_failed | i > abs(length)          % line search failed twice in a row
      break;                             % or we ran out of time, so we give up
    end
    tmp = df1; df1 = df2; df2 = tmp;                         % swap derivatives
    s = -df1;                                                    % try steepest
    d1 = -s'*s;
    z1 = 1/(1-d1);                     
    ls_failed = 1;                                    % this line search failed
  end
end
fprintf('\n');


function  [X, info, perf, D] = ucminf(fun,par, x0, opts, D0)
%UCMINF  BFGS method for unconstrained nonlinear optimization:
% Find  xm = argmin{f(x)} , where  x  is an n-vector and the scalar
% function  F  with gradient  g  (with elements  g(i) = DF/Dx_i )
% must be given by a MATLAB function with with declaration
%           function  [F, g] = fun(x, par)
% par  holds parameters of the function.  It may be dummy.  
% 
% Call:  [X, info {, perf {, D}}] = ucminf(fun,par, x0, opts {,D0})
%
% Input parameters
% fun  :  String with the name of the function.
% par  :  Parameters of the function.  May be empty.
% x0   :  Starting guess for  x .
% opts :  Vector with 4 elements:
%         opts(1) :  Expected length of initial step
%         opts(2:4)  used in stopping criteria:
%             ||g||_inf <= opts(2)                     or 
%             ||dx||_2 <= opts(3)*(opts(3) + ||x||_2)  or
%             no. of function evaluations exceeds  opts(4) . 
%         Any illegal element in  opts  is replaced by its
%         default value,  [1  1e-4*||g(x0)||_inf  1e-8  100]
% D0   :  (optional)  If present, then approximate inverse Hessian
%         at  x0 .  Otherwise, D0 := I 
% Output parameters
% X    :  If  perf  is present, then array, holding the iterates
%         columnwise.  Otherwise, computed solution vector.
% info :  Performance information, vector with 6 elements:
%         info(1:3) = final values of [f(x)  ||g||_inf  ||dx||_2] 
%         info(4:5) = no. of iteration steps and evaluations of (F,g)
%         info(6) = 1 :  Stopped by small gradient
%                   2 :  Stopped by small x-step
%                   3 :  Stopped by  opts(4) .
%                   4 :  Stopped by zero step.
% perf :  (optional). If present, then array, holding 
%          perf(1:2,:) = values of  f(x) and ||g||_inf
%          perf(3:5,:) = Line search info:  values of  
%                        alpha, phi'(alpha), no. fct. evals. 
%          perf(6,:)   = trust region radius.
% D    :  (optional). If present, then array holding the 
%         approximate inverse Hessian at  X(:,end) .

%  Hans Bruun Nielsen,  IMM, DTU.  00.12.18 / 02.01.22

  % Check call 
  [x n F g] = check(fun,par,x0,opts);
  if  nargin > 4,  D = checkD(n,D0);  fst = 0;
  else,            D = eye(n);  fst = 1;    end
  %  Finish initialization
  k = 1;   kmax = opts(4);   neval = 1;   ng = norm(g,inf);
  Delta = opts(1);
  Trace = nargout > 2;
  if  Trace
        X = x(:)*ones(1,kmax+1);
        perf = [F; ng; zeros(3,1); Delta]*ones(1,kmax+1);
      end
  found = ng <= opts(2);      
  h = zeros(size(x));  nh = 0;
  ngs = ng * ones(1,3);
   
  while  ~found
    %  Previous values
    xp = x;   gp = g;   Fp = F;   nx = norm(x);
    ngs = [ngs(2:3) ng];
    h = D*(-g(:));   nh = norm(h);   red = 0; 
    if  nh <= opts(3)*(opts(3) + nx),  found = 2;  
    else
      if  fst | nh > Delta  % Scale to ||h|| = Delta
        h = (Delta / nh) * h;   nh = Delta;   
        fst = 0;  red = 1;
      end
      k = k+1;
      %  Line search
      [al  F  g  dval  slrat] = softline(fun,par,x,F,g, h);
      if  al < 1  % Reduce Delta
        Delta = .35 * Delta;
      elseif   red & (slrat > .7)  % Increase Delta
        Delta = 3*Delta;      
      end 
      %  Update  x, neval and ||g||
      x = x + al*h;   neval = neval + dval;  ng = norm(g,inf);
      if  Trace
             X(:,k) = x(:); 
             perf(:,k) = [F; ng; al; dot(h,g); dval; Delta]; end
      h = x - xp;   nh = norm(h);
      if  nh == 0,
        found = 4; 
      else
        y = g - gp;   yh = dot(y,h);
        if  yh > sqrt(eps) * nh * norm(y)
          %  Update  D
          v = D*y(:);   yv = dot(y,v);
          a = (1 + yv/yh)/yh;   w = (a/2)*h(:) - v/yh;
          D = D + w*h' + h*w';
        end  % update D
        %  Check stopping criteria
        thrx = opts(3)*(opts(3) + norm(x));
        if      ng <= opts(2),              found = 1;
        elseif  nh <= thrx,                 found = 2;
        elseif  neval >= kmax,              found = 3; 
%        elseif  neval > 20 & ng > 1.1*max(ngs), found = 5;
        else,   Delta = max(Delta, 2*thrx);  end
      end  
    end  % Nonzero h
  end  % iteration

  %  Set return values
  if  Trace
    X = X(:,1:k);   perf = perf(:,1:k);
  else,  X = x;  end
  info = [F  ng  nh  k-1  neval  found];

% ==========  auxiliary functions  =================================

function  [x,n, F,g, opts] = check(fun,par,x0,opts0)
% Check function call
  x = x0(:);   sx = size(x);   n = max(sx);   
  if  (min(sx) > 1)
      error('x0  should be a vector'), end
  [F g] = feval(fun,x,par);
  sf = size(F);   sg = size(g);
  if  any(sf-1) | ~isreal(F)
      error('F  should be a real valued scalar'), end
  if  (min(sg) ~= 1) | (max(sg) ~= n)
      error('g  should be a vector of the same length as  x'), end
  so = size(opts0);
  if  (min(so) ~= 1) | (max(so) < 4) | any(~isreal(opts0(1:4)))
      error('opts  should be a real valued vector of length 4'), end
  opts = opts0(1:4);   opts = opts(:).';
  i = find(opts <= 0);
  if  length(i)    % Set default values
    d = [1  1e-4*norm(g, inf)  1e-8  100];
    opts(i) = d(i);
  end   
% ----------  end of  check  ---------------------------------------

function  D = checkD(n,D0)
% Check given inverse Hessian
  D = D0;   sD = size(D);
  if  any(sD - n)
      error(sprintf('D  should be a square matrix of size %g',n)), end
  % Check symmetry
  dD = D - D';   ndD = norm(dD(:),inf);
  if  ndD > 10*eps*norm(D(:),inf)
      error('The given D0 is not symmetric'), end
  if  ndD,  D = (D + D')/2; end  % Symmetrize      
  [R p] = chol(D);
  if  p
      error('The given D0 is not positive definite'), end
    
function  [alpha,fn,gn,neval,slrat] = ...
              softline(fun,fpar, x,f,g, h)
% Soft line search:  Find  alpha = argmin_a{f(x+a*h)}
  % Default return values 
  alpha = 0;   fn = f;   gn = g;   neval = 0;  slrat = 1;
  n = length(x);  
  
  % Initial values
  dfi0 = dot(h,gn);  if  dfi0 >= 0,  return, end
  fi0 = f;    slope0 = .05*dfi0;   slopethr = .995*dfi0;
  dfia = dfi0;   stop = 0;   ok = 0;   neval = 0;   b = 1;
  
  while   ~stop
    [fib g] = feval(fun,x+b*h,fpar);  neval = neval + 1;
    dfib = dot(g,h); 
    if  b == 1, slrat = dfib/dfi0; end
    if  fib <= fi0 + slope0*b    % New lower bound
      if  dfib > abs(slopethr),  stop = 1;
      else
        alpha = b;   fn = fib;   gn = g;   dfia = dfib;  
        ok = 1;   slrat = dfib/dfi0;
        if  (neval < 5) & (b < 2) & (dfib < slopethr)
          % Augment right hand end
          b = 2*b;
        else,  stop = 1; end
      end
    else,  stop = 1; end   
  end
  
  stop = ok;  xfd = [alpha fn dfia; b fib dfib; b fib dfib];
  while   ~stop
    c = interpolate(xfd,n);
    [fic g] = feval(fun, x+c*h, fpar);   neval = neval+1;
    xfd(3,:) = [c  fic  dot(g,h)];
    if fic < fi0 + slope0*c    % New lower bound
      xfd(1,:) = xfd(3,:);   ok = 1;
      alpha = c;   fn = fic;   gn = g;  slrat = xfd(3,3)/dfi0;
    else,  xfd(2,:) = xfd(3,:);  ok = 0; end
    % Check stopping criteria
    ok = ok & abs(xfd(3,3)) <= abs(slopethr);
    stop = ok | neval >= 5 | diff(xfd(1:2,1)) <= 0;
  end  % while   
%------------  end of  softline  ------------------------------
  
function  alpha = interpolate(xfd,n);
% Minimizer of parabola given by
% xfd(1:2,1:3) = [a fi(a) fi'(a); b fi(b) dummy]

  a = xfd(1,1);   b = xfd(2,1);   d = b - a;   dfia = xfd(1,3);
  C = diff(xfd(1:2,2)) - d*dfia;
  if C >= 5*n*eps*b    % Minimizer exists
    A = a - .5*dfia*(d^2/C);
    d = 0.1*d;   alpha = min(max(a+d, A), b-d);
  else
    alpha = (a+b)/2;
  end
%------------  end of  interpolate  --------------------------

