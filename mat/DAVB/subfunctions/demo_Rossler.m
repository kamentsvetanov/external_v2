% Demo for Double Well system.
% This demo inverts a model of chaotic double-Well system, which is
% observed through a nonlinear sigmoid observation function.

clear variables
close all

% Choose basic settings for simulations
f_fname = @f_Rossler;
g_fname = @g_sigmoid;
u       = [];
n_t = 2e3;
deltat = 4e-2;
alpha   = Inf;%1e3;
sigma   = Inf;
theta   = [0.2;0.2;2.791];
phi     = [];


% Build options structure for temporal integration of SDE
inF.deltat = deltat;
options.inF     = inF;
options.backwardLag = 0;

% Build priors for model inversion
priors.muX0 = [0;0;0];
priors.SigmaX0 = 1e-1*eye(3);
priors.muTheta = 0.*ones(length(theta),1);
priors.SigmaTheta = 1e-1*eye(3);
priors.a_alpha = 6e5;
priors.b_alpha = 1e4;
priors.a_sigma = 1e8;
priors.b_sigma = 1e4;

% Build options and dim structures for model inversion
options.priors = priors;
dim.n_theta = 3;
dim.n_phi   = 0;
dim.n       = 3;



% Build time series of hidden states and observations
stop = 0;
it = 1;
itmax = 10;
while ~stop
    [y,x,x0,eta,e] = simulateNLSS(...
        n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options);
    if (~isweird(y) && ~isweird(x)) || it >= itmax
        stop = 1;
    else
        it = it+1;
    end
end

% display time series of hidden states and observations
displaySimulations(y,x,eta,e)
getSubplots
% disp('--paused--')
% pause


% Call inversion routine
if (~isweird(y) && ~isweird(x))
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
end




