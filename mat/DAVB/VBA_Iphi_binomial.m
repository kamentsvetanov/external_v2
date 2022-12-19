function [Iphi,SigmaPhi,deltaMuPhi,suffStat] = VBA_Iphi_binomial(...
    phi,y,posterior,suffStat,dim,u,options)
% Gauss-Newton update of the observation parameters, for binomial data
% !! When the observation function is @VBA_odeLim, this Gauss-Newton update
% actually implements a gradient ascent on the variational energy of the
% equivalent deterministic DCM.

% check if called during initialization
if isequal(suffStat,VBA_getSuffStat(options))
    init = 1;
    if ~options.OnLine && options.verbose
        fprintf(1,'Deriving prior''s sufficient statistics ...')
        fprintf(1,'%6.2f %%',0)
    end
else
    init = 0;
end

if options.DisplayWin && ~init % Display progress
    if isequal(options.g_fname,@VBA_odeLim)
        STR = 'VB Gauss-Newton on observation/evolution parameters... ';
    else
        STR = 'VB Gauss-Newton on observation parameters... ';
    end
    set(options.display.hm(1),'string',STR);
    set(options.display.hm(2),'string','0%');
    drawnow
end

% Clear persistent variables if ODE mode
if isequal(options.g_fname,@VBA_odeLim) || ...
       isequal(options.g_fname,@VBA_smoothNLSS)
    clear VBA_odeLim
    clear VBA_smoothNLSS
end

%  Look-up which evolution parameter to update
indIn = options.params2update.phi;

% Preallocate intermediate variables
Q = options.priors.SigmaPhi(indIn,indIn);
iQ = VB_inv(Q,[]);
muPhi0 = options.priors.muPhi;
Phi = muPhi0;
Phi(indIn) = phi;
dphi0 = muPhi0-Phi;
ddydphi = 0;
dy = zeros(dim.p,dim.n_t);
vy = zeros(dim.p,dim.n_t);
gx = zeros(dim.p,dim.n_t);
d2gdx2 = zeros(dim.n_phi,dim.n_phi);
logL = 0;
if isequal(options.g_fname,@VBA_odeLim)
    muX = zeros(options.inG.old.dim.n,dim.n_t);
    SigmaX = cell(dim.n_t,1);
end
div = 0;

%--- Loop over time series ---%
for t=1:dim.n_t
       
    % evaluate observation function at current mode
    [gx(:,t),dG_dX,dG_dPhi,d2G_dXdPhi] =...
        VBA_evalFun('g',posterior.muX(:,t),Phi,u(:,t),options,dim);
    
    % fix numerical instabilities
    gx(:,t) = checkGX_binomial(gx(:,t));

    % store states dynamics if ODE mode
    if isequal(options.g_fname,@VBA_odeLim)
        % get sufficient statistics of the hidden states from unused i/o in
        % VBA_evalFun.
        muX(:,t) = dG_dX;
        SigmaX{t} = d2G_dXdPhi'*posterior.SigmaPhi*d2G_dXdPhi;
    end
    
    % accumulate log-likelihood
    logL = logL + y(:,t)'*log(gx(:,t)) + (1-y(:,t))'*log(1-gx(:,t));
    
    % prediction error
    dy(:,t) = y(:,t) - gx(:,t);
    
    % predicted variance over binomial data
    vy(:,t) = gx(:,t).*(1-gx(:,t));
    
    % gradient and Hessian
    ddydphi = ddydphi + dG_dPhi*(dy(:,t)./vy(:,t));
    tmp = y(:,t)./gx(:,t).^2 - (y(:,t)-1)./(1-gx(:,t)).^2;
    d2gdx2 = d2gdx2 + dG_dPhi*diag(tmp)*dG_dPhi';
    
    % Display progress
    if isequal(mod(t,dim.n_t./10),0)
        if ~init && options.DisplayWin
            set(options.display.hm(2),'string',[num2str(100*t/dim.n_t),'%']);
            drawnow
        end
        if init && ~options.OnLine && options.verbose
            fprintf(1,'\b\b\b\b\b\b\b\b')
            fprintf(1,'%6.2f %%',100*t/dim.n_t)
        end
    end
    
    % Accelerate divergent update
    if isweird(dy) || isweird(dG_dPhi) || isweird(dG_dX)
        div = 1;
        break
    end
    
end

% Display progress
if ~init && options.DisplayWin
    set(options.display.hm(2),'string','OK');
    drawnow
end
if init &&  ~options.OnLine  && options.verbose
    fprintf(1,'\b\b\b\b\b\b\b\b')
    fprintf(' OK.')
    fprintf('\n')
end

% posterior covariance matrix
iSigmaPhi = iQ + d2gdx2(indIn,indIn);
SigmaPhi = VB_inv(iSigmaPhi,[]);

% mode
tmp = iQ*dphi0(indIn) + ddydphi(indIn);
deltaMuPhi = SigmaPhi*tmp;

% variational energy
Iphi = -0.5.*dphi0(indIn)'*iQ*dphi0(indIn) + logL;
if isweird(Iphi) || isweird(SigmaPhi) || div
    Iphi = -Inf;
end

% update sufficient statistics
suffStat.Sphi = 0.5*length(indIn)*log(2*pi*exp(1)) ...
    + 0.5*VBA_logDet(posterior.SigmaPhi,indIn);
suffStat.gx = gx;
suffStat.dy = dy;
suffStat.logL = logL;
suffStat.vy = vy;
suffStat.dphi = dphi0;
if isequal(options.g_fname,@VBA_odeLim)
    suffStat.muX = muX;
    suffStat.SigmaX = SigmaX;
end



