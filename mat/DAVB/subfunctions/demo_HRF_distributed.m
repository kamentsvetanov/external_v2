% Demo for distributed (locally multivariate) HRF


close all
clear variables


% Choose basic settings for simulations
TR          = 3;                  % sampling time interval (in sec)
n_t         = 40/TR;                % number of time samples (over 40 sec)
deltat      = 5e-2;                 % micro-time resolution
u           = zeros(1,n_t);         % input
u(1,1:2)    = 1e0;
f_fname     = @f_HRF2;               % Ballon model evolution function
g_fname     = @g_HRF_distributed;   % Balloon model observation function
theta       = zeros(6,1);           % simulated evolution parameters
theta(5)    = 1e0;
phi         = 0;                    % simulated observation parameter 
alpha       = Inf;%1e4;                  % simulated state noise precision
sigma       = 1e6;                  % simulated data noise precision

inG.ind_hrf = 1;
inG.ind_profile{1} = 2:5;
inG.n_reg = 1;
inG.n_phi = 4;
inG.B = randn(15,inG.n_phi);
phi = [ phi
        1
        2
        -1
        -2  ];



% Build priors for model inversion
% priors.AR = 1;
priors.muX0         = [0;0;0;0];
priors.SigmaX0      = 1e-2*eye(4);
priors.muTheta      = 0.1*ones(6,1);
priors.SigmaTheta   = 1e-1*eye(6,6);
priors.muPhi        = 0*ones(5,1);
priors.SigmaPhi     = 1e-1*eye(5);
priors.SigmaPhi(1)  = 0;
priors.a_alpha      = Inf;%1e6;
priors.b_alpha      = 0;%1e2;
priors.a_sigma      = 1e6;
priors.b_sigma      = 1e2;

% Build options and dim structures for model inversion
options.GnFigs = 1;
options.priors      = priors;
options.inF.deltat  = deltat;
options.decim       = max([1,round(TR./options.inF.deltat)]);
options.inG         = inG;
dim.n_theta         = 6;
dim.n_phi           = 5;
dim.n               = 4;
% options.checkGrads = 1;

% Simulate time series of hidden states and observations
[y,x,x0,eta,e]   = simulateNLSS(...
    n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options);

% Display simulated time series
displaySimulations(y,x,eta,e)
% disp('--paused--')
% pause




% Call inversion routine
% [posterior,out] = VBA_onlineWrapper(y,u,f_fname,g_fname,dim,options);
[posterior,out] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);

% Display inference results
displayResults(posterior,out,y,x,x0,theta,phi,alpha,sigma)

% Make predictions
try
    options = out.options;
    [xs,ys,xhat,vx,yhat,vy] = comparePredictions(...
        n_t,theta,phi,u,alpha,sigma,options,posterior,dim);
catch
    disp('------!!Unable to form predictions!!------')
end




