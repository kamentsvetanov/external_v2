function [y,x,x0,eta,e] = simulateNLSS(n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options,x0)
% samples times series from sDCM generative model
% [y,x,x0,dTime,eta,eta0] =
% simulateNLSS(n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options,x0)
%
% This function creates the time series of hidden-states and measurements
% under the following nonlinear state-space model:
%   y_t   = g(x_t,Phi,u_t,t) + e_t
%   x_t+1 = f(x_t,Theta,u_t,t) + f_t
% where f and g are the evolution and observation, respectively.
% IN:
%   - n_t: the number of time bins for the time series of hidden-states and
%   observations, i.e. the time indices satisfy: 1<= t < n_t
%   - f_fname/g_fname: evolution/observation function names. The time entry
%   of these functions IS NOT the time index, it is defined as :
%   t0 + t*delta_t.
%   - theta/phi: evolution/observation parameters values.
%   - u: the mxt input matrix
%   - alpha: precision of the stochastic innovations
%   - sigma: precision of the measurement error
%   - options: structure variable containing the following fields:
%       .inF
%       .inG
%   - x0: the initial conditions
% OUT:
%   - y: the pxt (noisy) measurement time series
%   - x: the nxt (noisy) hidden-states time series
%   - x0: the nx1 initial conditions
%   - eta: the nxt stochastic innovations time series
%   - e: the pxt measurement errors

% 27/03/2007: JD.

% get system dimensions
dim.n_theta         = length(theta);
dim.n_phi           = length(phi);
dim.n_t             = n_t;
try
    dim.n           = size(x0,1);
catch
    dim.n           = size(options.priors.muX0,1);
end
try U=u(:,1);catch;U=[];end
try options.inG;catch;options.inG=[];end
p = size(feval(g_fname,zeros(dim.n,1),phi,U,options.inG),1);

% check input consistency
try
    if isinf(options.priors.a_alpha)
        options.priors.a_alpha = 1;
        options.priors.b_alpha = 1;
    end
end
try
    if options.embed > 0
        options.embed = 0;
    end
end
options.priors.AR   = 0;
[options,u,dim] = VBA_check(zeros(p,n_t),u,f_fname,g_fname,dim,options);

% Get covariance structure
iQy = options.priors.iQy;
iQx = options.priors.iQx;

% Get time
et0 = clock;

%-- initial hidden-states value
try
    x0;
catch
    x0 = options.priors.muX0;
    sQ0 = getISqrtCov(options.priors.SigmaX0,0);
    x0 = x0 + sQ0*randn(size(x0));
    clear sQ0
end

%-- First time point of the time series
n = size(x0,1);
x = zeros(n,n_t);
eta = zeros(n,n_t);
% Evaluate evolution function at initial conditions
x(:,1) = VBA_evalFun('f',x0,theta,u(:,1),options,dim);
C = getISqrtCov(iQx{1});
eta(:,1) = (1./sqrt(alpha))*C*randn(n,1);
x(:,1) = x(:,1) + eta(:,1);
% Evaluates observation function at x(:,1)
y1 = VBA_evalFun('g',x(:,1),phi,u(:,1),options,dim);
e = zeros(p,n_t);
y = zeros(p,n_t);
y(:,1) = y1;
C = getISqrtCov(iQy{1});
e(:,1) = (1./sqrt(sigma))*C*randn(p,1);
y(:,1) = y(:,1) + e(:,1);

%-- Loop over time points
% Display progress
fprintf(1,'Simulating SDE...')
fprintf(1,'%6.2f %%',0)
for t = 2:n_t

    % Evaluate evolution function at past hidden state
    Cx = getISqrtCov(iQx{t});
    eta(:,t) = (1./sqrt(alpha))*Cx*randn(n,1);
    x(:,t) = VBA_evalFun('f',x(:,t-1),theta,u(:,t),options,dim) ...
        + eta(:,t);
    % Evaluate observation function at current hidden state
    Cy = getISqrtCov(iQy{t});
    e(:,t) = (1./sqrt(sigma))*Cy*randn(p,1);
    y(:,t) = VBA_evalFun('g',x(:,t),phi,u(:,t),options,dim)+ e(:,t);
    % Display progress
    if mod(100*t/n_t,10) == 0
        fprintf(1,'\b\b\b\b\b\b\b\b')
        fprintf(1,'%6.2f %%',100*t/n_t)
    end
    if isweird(x) || isweird(y)
        break
    end
end
% Display progress
fprintf(1,'\b\b\b\b\b\b\b\b')
fprintf(1,[' OK (took ',num2str(etime(clock,et0)),' seconds).'])
fprintf(1,'\n')




function S = getISqrtCov(C,inv)
if nargin < 2
    inv = 1;
end
C(C==Inf) = 1e8;  % dirty fix for infinite precision matrices
if sum(C(:)) ~= 0
    if isequal(C,diag(diag(C)))
        if inv
            S = diag(sqrt(diag(C).^-1));
        else
            S = diag(sqrt(diag(C)));
        end
    else
        [U,s,V] = svd(full(C));
        if inv
            S = U*diag(sqrt(diag(s).^-1))*V';
        else
            S = U*diag(sqrt(diag(s)))*V';
        end
    end
else
    S = 0;
end


