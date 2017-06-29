function [IX0,SigmaX0,deltaMuX0,suffStat] = VBA_IX0(...
    X0,y,posterior,suffStat,dim,u,options)
% Gauss-Newton update of initial conditions



if options.DisplayWin % Display progress
    set(options.display.hm(1),'string',...
        'VB Gauss-Newton on initial conditions... ');
    set(options.display.hm(2),'string',' ');
    drawnow
end

% check infinite precision transition pdf
indIn = options.params2update.x0;
iQx0 = VB_inv(options.priors.iQx{1},indIn,'replace');
IN = diag(~~diag(iQx0));

% Get precision parameters
alphaHat = posterior.a_alpha./posterior.b_alpha;

% Preallocate intermediate variables
muX0 = options.priors.muX0;
x0 = muX0;
x0(indIn) = X0;

% Evaluate evolution function at current mode
[fx0,dF_dX0,dF_dTheta0,d2F_dXdTheta0] =...
    VBA_evalFun('f',x0,posterior.muTheta,u(:,1),options,dim);

% error terms
dx = IN*(posterior.muX(:,1)- fx0);
dx2 = dx'*iQx0*dx;
dx0 = muX0-x0;

% posterior covariance matrix terms
Q = options.priors.SigmaX0(indIn,indIn);
iQ = VB_inv(Q,[]);
iSigmaX0 = alphaHat.*dF_dX0(indIn,indIn)*iQx0*dF_dX0(indIn,indIn)' +iQ;
if ~options.ignoreMF
    A1f = reshape(permute(d2F_dXdTheta0,[2,3,1]),dim.n*dim.n_theta,dim.n)';
    A2f = A1f*kron(iQx0,posterior.SigmaTheta);
    tmp = A2f*A1f';
    iSigmaX0 = iSigmaX0 + alphaHat.*tmp(indIn,indIn);
end

% posterior covariance matrix
SigmaX0 = VB_inv(iSigmaX0,[]);

% mode
tmp = iQ*dx0(indIn) + ...
    alphaHat.*dF_dX0(indIn,indIn)*iQx0(indIn,indIn)*dx(indIn);
if ~options.ignoreMF
    tmp2 = A2f*vec(dF_dTheta0);
    tmp = tmp -alphaHat.*tmp2(indIn);
end
deltaMuX0 = SigmaX0*tmp;

% variational energy
IX0 = -0.5.*dx0'*iQ*dx0 - 0.5*alphaHat.*dx2;
if isweird(IX0)
    IX0 = -Inf;
end

% update sufficient statistics
suffStat.SX0 = 0.5*length(indIn)*log(2*pi*exp(1)) ...
    + 0.5*VBA_logDet(posterior.SigmaX0,indIn);
dx20 = suffStat.dx(:,1)'*iQx0*suffStat.dx(:,1);
suffStat.dx2 = suffStat.dx2 - dx20 + dx2; % correct states squared error
suffStat.dx(:,1) = dx;
suffStat.dx0 = dx0;




