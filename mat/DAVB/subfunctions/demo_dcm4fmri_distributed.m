% Demo for DCM for fMRI (distributed responses) [broken]
% This demo inverts the DCM for fMRI model, which contains the ballon model
% as a generalized observation function (not affected by stochastic
% innovations).

close all
clear variables


%-----------------------------------------------------------
%-------------- DCM model specification --------------------


%--- Basic settings
n_t = .5e2;                      % number of time samples
TR = 3e0;                       % sampling period (in sec)
microDT = 5e-2;                 % micro-time resolution (in sec)
u       = zeros(2,n_t);         % inputs
u(1,1:2) = 1;
u(1,30:31) = 1;
u(1,50:51) = 1;
u(2,30:31) = 1;
u(2,60:61) = 1;

%--- DCM structure
% invariant effective connectivity
A = [0 1 1
     1 0 1
     0 1 0];
nreg = size(A,1);
% modulatory effects
B{1} = zeros(nreg,nreg);
B{2} = [0 0 0
        1 0 0
        0 0 0];
% input-state coupling
C = [1 0
     0 0
     0 0];
% gating effects
D{1} = [0 0 0
        0 0 0
        0 1 0];
D{2} = zeros(nreg,nreg);
D{3} = zeros(nreg,nreg);

%--- Build priors and options/dim structures for model inversion
f_fname = @f_DCMwHRF;
g_fname = @g_HRF_distributed;
[options] = prepare_fullDCM(A,B,C,D,TR,microDT);
options.inG.n_phi = 4; % number of spatial modes
options.inG.B = abs(randn(8,options.inG.n_phi)+1); % spatial modes
options.inG.ind_hrf = 1:2*nreg;
options.inG.n_reg = nreg;
for i=1:nreg
    options.inG.ind3{i} = options.inG.ind_hrf(end)+1+(i-1)*4:...
        options.inG.ind_hrf(end)+i*4;
end
options.GnFigs = 1;
options.MaxIter = 8; % to quicken inversion
dim.n_theta         = options.inF.ind5(end);
dim.n_phi           = (2+options.inG.n_phi).*nreg;
dim.n               = 5*nreg;

% Build priors for model inversion
indHemo = options.inF.indself+1:dim.n_theta;
priors.muX0 = kron(ones(nreg,1),[0;0;0;0;0]);
priors.SigmaX0 = 0e-1*speye(5*nreg);
priors.muTheta = 0*ones(dim.n_theta,1);
priors.muTheta(options.inF.indself) = -1;
priors.muTheta(options.inF.indC) = 1;
priors.SigmaTheta = 1e-3*speye(dim.n_theta);
priors.SigmaTheta(options.inF.ind1,options.inF.ind1) = 0;
priors.SigmaTheta(indHemo,indHemo) = 0;
priors.muPhi = 0*ones(dim.n_phi,1);
priors.SigmaPhi = 1e-3*speye(dim.n_phi);
priors.SigmaPhi(options.inG.ind_hrf,options.inG.ind_hrf) = 0;
priors.a_alpha = Inf;%1e4;
priors.b_alpha = 0;%1e0;
priors.a_sigma = 1e4;
priors.b_sigma = 1e0;
options.priors = priors;


%-----------------------------------------------------------
%----------- simulated times series specification ----------

%--- simulated evolution parameters: neuronal level
% A matrix
t_A = exp([ -1.5
            -1.5
            -0.5
            -2.5
            -1.5 ]);
% self-inhibition gain
t_Aself = -2;
% B matrices
t_B{1} = [];
t_B{2} = exp([ -0.5 ]);
% C matrix
t_C = exp([ +0.1 ]);
% D matrices
t_D{1} = exp([ -2.0 ]);
t_D{2} = [];
t_D{3} = [];

%--- simulated evolution parameters: hemodynamic level
t_E0 = zeros(nreg,1);               % HbO2 extraction fraction gain
t_tau0 = zeros(nreg,1);             % mean blood transit time gain
t_kas = zeros(nreg,1);              % vasodilatory signal decay gain
t_kaf = zeros(nreg,1);              % vasodilatory signal feedback
t_alpha = zeros(nreg,1);            % vessel stifness gain

%--- simulated observation parameters
p_V0 = zeros(nreg,1);               % blood volume gain
p_E0 = zeros(nreg,1);               % HbO2 extraction fraction gain
p_w = repmat([1;2;-1;-2],nreg,1);   % spatial pattern parameters

%--- Recollect paramters and i/o for model inversion
nu = size(u,1);
theta = zeros(dim.n_theta,1);
theta(options.inF.indA) = t_A;
for i=1:nu
    theta(options.inF.indB{i}) = t_B{i};
end
theta(options.inF.indC) = t_C;
for i=1:nreg
    theta(options.inF.indD{i}) = t_D{i};
end
theta(options.inF.indself) = t_Aself;
theta(options.inF.ind1) = t_E0;
theta(options.inF.ind2) = t_tau0;
theta(options.inF.ind3) = t_kaf;
theta(options.inF.ind4) = t_kas;
theta(options.inF.ind5) = t_alpha;
phi(options.inG.ind1) = p_E0;
phi(options.inG.ind2) = p_V0;
phi = [ phi(:) ; p_w ];
alpha   = Inf;%1e8;                 % state noise precision
sigma   = 1e3;                      % measurement noise precision

% Build time series of hidden states and observations
[y,x,x0,eta,e] = simulateNLSS(n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options);

% display time series of hidden states and observations
displaySimulations(y,x,eta,e)
% disp('--paused--')
% pause



%-----------------------------------------------------------
%------------------- model inversion -----------------------

% Call inversion routine
[posterior,out] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);

% Display results
displayResults(posterior,out,y,x,x0,theta,phi,alpha,sigma)

% Make predictions
try
    options = out.options;
    [xs,ys,xhat,vx,yhat,vy] = comparePredictions(...
        n_t,theta,phi,zeros(size(u)),alpha,sigma,options,posterior,dim);
catch
    disp('------!!Unable to form predictions!!------')
end


