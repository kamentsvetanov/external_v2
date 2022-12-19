
% Demo for Balloon model.
% This demo inverts a balloon model of the HRF.

close all
clear variables


% Choose basic settings for simulations
TR          = 3;                    % sampling time interval (in sec)
n_t         = 60/TR;                % number of time samples (over 40 sec)
deltat      = 5e-2;                 % micro-time resolution
decim       = max([1,round(TR./deltat)]);
u           = zeros(1,n_t*decim);         % input
u(1,1)      = 1e0;
f_fname     = @f_HRF2;               % Ballon model evolution function
g_fname     = @g_HRF3;               % Balloon model observation function
[theta,phi] = get_HRFparams(TR,deltat);
alpha       = 1e6;                  % simulated state noise precision
sigma       = 1e6;                  % simulated data noise precision

% Build priors for model inversion
priors.muX0         = [0;0;0;0];
priors.SigmaX0      = 0e-2*eye(4);
priors.muTheta      = 0.1*ones(6,1);
priors.SigmaTheta   = 1e-3*eye(6,6);
priors.muPhi        = 0*ones(2,1);
priors.SigmaPhi     = 1e-3*eye(2,2);
priors.a_alpha      = Inf;%1e6;
priors.b_alpha      = 0;%1e0;
priors.a_sigma      = 1e6;
priors.b_sigma      = 1e0;

% Build options and dim structures for model inversion
options.priors      = priors;
% options.checkGrads  = 1;
options.inF.deltat  = deltat;
options.inF.fullDCM = 0;
options.inF.linearized = 0;
options.inG.TE      = 0.04;
options.decim       = max([1,round(TR./options.inF.deltat)]);
options.microU      = 1;
dim.n_theta         = 6;
dim.n_phi           = 2;
dim.n               = 4;


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




