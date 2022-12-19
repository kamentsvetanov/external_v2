% Demo for partially observable oscillatory system.
% This demo inverts a model of a linear oscillatory system, which is
% observed through a nonlinear sigmoid function.

clear variables
close all

% Choose basic settings for simulations
n_t = 5e2;
delta_t = 1e-1;         % integration time step (Euler method)
f_fname = @f_lin2D;
g_fname = @g_sqrtSig;

u       = [];

% Build options structure for temporal integration of SDE
inF.deltat = delta_t;
inF.a           = 0.1;
inF.b           = 0.9e-2;
inG.G0          = 2;
inG.beta        = 1;
inG.y0          = -1;
inG.ind         = 1;
options.inF     = inF;
options.inG     = inG;


% Parameters of the simulation
alpha   = 1e8;
sigma   = 1e8;
theta   = 1;
phi     = [];

% Build priors for model inversion
priors.muX0 = [-2;-2];
priors.SigmaX0 = 1e-0*eye(2);
priors.muTheta = 0*ones(1,1);
priors.SigmaTheta = 1e-1*eye(1);
priors.a_alpha = 1e4;
priors.b_alpha = 1e1;
priors.a_sigma = 1e6;
priors.b_sigma = 1e1;

% Build options and dim structures for model inversion
options.priors      = priors;
dim.n_theta         = 1;
dim.n_phi           = 0;
dim.n               = 2;

% options.checkGrads = 1;

% Build time series of hidden states and observations
[y,x,x0,eta,e] = simulateNLSS(n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options);

% display time series of hidden states and observations
displaySimulations(y,x,eta,e)
% disp('--paused--')
% pause


% Call inversion routine
% [posterior,out] = VBA_onlineWrapper(y,u,f_fname,g_fname,dim,options);
[posterior,out] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);

% Display results
displayResults(posterior,out,y,x,x0,theta,phi,alpha,sigma)

% Make predictions
try
    options = out.options;
    [xs,ys,xhat,vx,yhat,vy] = comparePredictions(...
        n_t,theta,phi,u,alpha,sigma,options,posterior,dim);
catch
    disp('------!!Unable to form predictions!!------')
end


