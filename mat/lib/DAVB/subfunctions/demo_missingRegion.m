function [y,simul,post,out,post12,out12] = demo_missingRegion2(lo,i,j,MR,TR)

% Demo for sDCM for fMRI (with 'missing region')


close all
tic

if nargin < 4
    MR = 1;
end
if nargin < 5
    TR = 1; % sampling period (in sec)
else
    TR
end

%-------------------------------------------------------
%-------------- 3 regions DCM model --------------------

%--- Basic settings
n_t = round(1.2e2/TR);            % number of time samples
dtU = round(20/TR)+1;           % input-on time interval
t0U = round(10/TR)+1;
microDT = 1e-1;                 % micro-time resolution (in sec)
u       = zeros(1,n_t);         % deterministic inputs
u(1,t0U:t0U+dtU) = 1;
u(1,5*t0U:5*t0U+dtU) = 1;
u = u(1:n_t);
% u(1,6:15) = 1;
% u(1,31:40) = 1;
disp(' ')
disp('--- Get HRF params ... ---')
[thetaHRF,phiHRF]   = get_HRFparams(TR,microDT);
thetaHRF = 0.*thetaHRF;
phiHRF = 0.*phiHRF;
disp('--- Get HRF params ... OK. ---')
homogeneous = 1; % params of g(x) homogeneous accross regions
reduced_f = 1; % only estimate kas and tau0 from Balloon model

%--- DCM structure
nreg = 3; % nb regions
if MR == 1
    disp('1 --> (2) --> 3')
    A = [0 0 0
        1 0 0
        0 1 0];
    C = [1;0;0];
elseif MR == 2
    disp('(2) --> 1 and 3')
    A = [0 1 0
        0 0 0
        0 1 0];
    C = [0;1;0];
%     u = [u;zeros(1,n_t)];
%     u(2,t0U:t0U+dtU) = 1;
%     u(2,6:15) = 1;
end

B = cell(size(u,1),1);
D = cell(nreg,1);
f_fname = @f_DCMwHRF;
g_fname = @g_HRF3;
[options] = prepare_fullDCM(A,B,C,D,TR,microDT,homogeneous);
dim.n_theta         = options.inF.ind5(end);
dim.n_phi           = 2;
dim.n               = 5*nreg;


% Simulate DCM with 4 regions
% A matrix
t_A = lo.theta(j).*ones(2,1);
% self-inhibition gain
t_Aself = -0;
% B matrices
for ii=1:size(u,1)
    t_B{ii} = [];
end
% C matrix
t_C = exp(+0.1);
% D matrices
t_D{1} = [];
t_D{2} = [];
t_D{3} = [];

%--- simulated evolution parameters: hemodynamic level
t_E0 = thetaHRF(1)*ones(nreg,1);       % HbO2 extraction fraction gain
t_tau0 = thetaHRF(2)*ones(nreg,1);     % mean blood transit time gain
t_kaf = thetaHRF(3)*ones(nreg,1);      % vasodilatory signal feedback regulation
t_kas = thetaHRF(4)*ones(nreg,1);      % vasodilatory signal decay gain
t_alpha = thetaHRF(6)*ones(nreg,1);    % vessel stifness gain

%--- simulated observation parameters
if ~homogeneous
    p_E0 = phiHRF(1)*ones(nreg,1);       % HbO2 extraction fraction gain
    p_epsilon = phiHRF(2)*ones(nreg,1);  % ratio of intra- and extravascular signal
else
    p_E0 = phiHRF(1);
    p_epsilon = phiHRF(2);
end

% precision hyperparameters
alpha   = 1e2/TR;
sigma   = lo.sigma(i)

%--- Recollect paramters for simulated data
nu = size(u,1);
theta = zeros(dim.n_theta,1);
theta(options.inF.indA) = t_A;
for ii=1:nu
    theta(options.inF.indB{ii}) = t_B{ii};
end
theta(options.inF.indC) = t_C;
for ii=1:nreg
    theta(options.inF.indD{ii}) = t_D{ii};
end
theta(options.inF.indself) = t_Aself;
theta(options.inF.ind1) = t_E0;
theta(options.inF.ind2) = t_tau0;
theta(options.inF.ind3) = t_kaf;
theta(options.inF.ind4) = t_kas;
theta(options.inF.ind5) = t_alpha;
phi = zeros(dim.n_phi,1);
phi(options.inG.ind1) = p_E0;
phi(options.inG.ind2) = p_epsilon;



% Build priors for model inversion
[priors] = getPriors(nreg,n_t,options,dim,reduced_f,thetaHRF,alpha,sigma);
options.priors = priors;

% Build time series of hidden states and observations
y = NaN;
x = NaN;
while isweird(x) || isweird(y)
    [y,x,x0,eta,e] = simulateNLSS(...
        n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options);
end
simul.x = x;
simul.x0 = x0;
simul.eta = eta;
simul.e = e;
simul.theta = lo.theta(j);
simul.sigma = lo.sigma(i);
simul.MR = MR;
simul.TR = TR;

% display time series of hidden states and observations
% displaySimulations(y,x,eta,e)
% disp('--paused--')
% pause

% Call inversion routine
options = getOptions(options,priors);
[post,out] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);
% pause
% post = [];
% out = [];

% Display results
% displayResults(post,out,y,x,x0,theta,phi,alpha,sigma)
% disp('--paused!--')
% pause


%-------------------------------------------------------
%-------------- 2 regions DCM models -------------------


%----- Now invert sub-DCMs and do model comparison.

% Select data from regions 1,2,3:
ys = y([1,3],:);

% Change model specification...
nreg = 2;
dim.n_phi = 2;
dim.n = 5*nreg;
B = cell(1,1);
clear C
C{1} = [1;0];
C{2} = [0;1];
C{3} = [1;1];
C{4} = [0;0];
D = cell(nreg,1);
clear priors;

post12 = cell(5,4);
out12 = cell(5,4);
for i=1:length(C)
    if length(C)>=i && ~isempty(C{i})
        [post12(:,i),out12(:,i)] = loopOverA(...
            ys,u(1,:),f_fname,g_fname,...
            B,C{i},D,dim,TR,microDT,...
            homogeneous,reduced_f,thetaHRF,...
            alpha,sigma);
    end
end
toc

function [priors] = getPriors(nreg,n_t,options,dim,reduced_f,thetaHRF,alpha,sigma)
priors.muX0 = kron(ones(nreg,1),[0;0;0;0;0]);
priors.SigmaX0 = 0e-3*eye(5*nreg);
priors.muTheta = 0*ones(dim.n_theta,1);
priors.muTheta(options.inF.indself) = 0;
priors.SigmaTheta = 1e-2*eye(dim.n_theta);
priors.SigmaTheta(options.inF.indself,options.inF.indself) = 0;
if reduced_f
    % fix some HRF params to their default values
    priors.muTheta(options.inF.ind1) = thetaHRF(1);
    priors.muTheta(options.inF.ind3) = thetaHRF(3);
    priors.muTheta(options.inF.ind5) = thetaHRF(6);
    priors.SigmaTheta(options.inF.ind1,options.inF.ind1) = 0;
    priors.SigmaTheta(options.inF.ind3,options.inF.ind3) = 0;
    priors.SigmaTheta(options.inF.ind5,options.inF.ind5) = 0;
%     priors.SigmaTheta(options.inF.ind2,options.inF.ind2) = 0;
%     priors.SigmaTheta(options.inF.ind4,options.inF.ind4) = 0;
end
priors.muPhi = 0*ones(dim.n_phi,1);
priors.SigmaPhi = 1e-2*eye(dim.n_phi);

% NB on hyperpriors:
%   - fix state noise precision using high scale param
%   - use non-informative priors on the residual precision, with high
%   expectation.
% This is because of the first iteration of the hidden states posterior
% update, which has to deviate from the its prior predictive density (as
% derived from the deterministic inversion).
% The following iterations will then work with a realistic (expected)
% residual precision, and adapt.
SC = 1e8;
priors.a_alpha = SC*alpha;
priors.b_alpha = SC;
priors.a_sigma = 1e0;
priors.b_sigma = 1e-4;

% Stat noise time-dependent covariance structure.
% NB: ratio of neural versus hemodynamic precision
for t = 1:n_t
    dq = 1e4*ones(dim.n,1);
    dq(options.inF.n5) = 1;
    priors.iQx{t} = diag(dq);
end

function options = getOptions(options,priors)
options.priors = priors;
options.DisplayWin = 0;
options.GnFigs = 0;
options.gradF = 0;
options.updateHP = 1;
options.backwardLag = 2;
% options.Laplace = 1;
% options.noSXi = 1;
options.init0 = 0;
% options.embed = 0;

function [post12,out12] = loopOverA(...
    ys,u,f_fname,g_fname,...
    B,C,D,dim,TR,microDT,...
    homogeneous,reduced_f,thetaHRF,...
    alpha,sigma)

post12 = cell(5,1);
out12 = cell(5,1);
nreg = 2;
n_t = size(ys,2);

% Sub-DCM #1:
A = [0 0
     1 0];
[options] = prepare_fullDCM(A,B,C,D,TR,microDT,homogeneous);
dim.n_theta         = options.inF.ind5(end);
[priors] = getPriors(nreg,n_t,options,dim,reduced_f,thetaHRF,alpha,sigma);
options = getOptions(options,priors);
displayAC(A,C)
[post12{1},out12{1}] = VBA_NLStateSpaceModel(...
    ys,u,f_fname,g_fname,dim,options);



% Sub-DCM #2:
A = [0 1
     0 0];
[options] = prepare_fullDCM(A,B,C,D,TR,microDT,homogeneous);
dim.n_theta         = options.inF.ind5(end);
[priors] = getPriors(nreg,n_t,options,dim,reduced_f,thetaHRF,alpha,sigma);
options = getOptions(options,priors);
displayAC(A,C)
[post12{2},out12{2}] = VBA_NLStateSpaceModel(...
    ys,u,f_fname,g_fname,dim,options);



% Sub-DCM #3:
A = [0 1
     1 0];
[options] = prepare_fullDCM(A,B,C,D,TR,microDT,homogeneous);
dim.n_theta         = options.inF.ind5(end);
[priors] = getPriors(nreg,n_t,options,dim,reduced_f,thetaHRF,alpha,sigma);
options = getOptions(options,priors);
displayAC(A,C)
[post12{3},out12{3}] = VBA_NLStateSpaceModel(...
    ys,u,f_fname,g_fname,dim,options);



% Sub-DCM #4:
A = [0 0
     0 0];
[options] = prepare_fullDCM(A,B,C,D,TR,microDT,homogeneous);
dim.n_theta         = options.inF.ind5(end);
[priors] = getPriors(nreg,n_t,options,dim,reduced_f,thetaHRF,alpha,sigma);
options = getOptions(options,priors);
displayAC(A,C)
[post12{4},out12{4}] = VBA_NLStateSpaceModel(...
    ys,u,f_fname,g_fname,dim,options);

% Sub-DCM #5:
A = [0 0
     0 0];
[options] = prepare_fullDCM(A,B,C,D,TR,microDT,homogeneous);
dim.n_theta         = options.inF.ind5(end);
[priors] = getPriors(nreg,n_t,options,dim,reduced_f,thetaHRF,alpha,sigma);
% add common source covariance component
nn = length(options.inF.n5);
Q0 = eye(nn) + ones(nn,nn);
iQ0 = pinv(Q0);
iQ = diag(1e4*ones(dim.n,1));
iQ(options.inF.n5,options.inF.n5) = iQ0;
for t = 1:n_t
    priors.iQx{t} = iQ;
end
options = getOptions(options,priors);
displayAC(A,C)
[post12{5},out12{5}] = VBA_NLStateSpaceModel(...
    ys,u,f_fname,g_fname,dim,options);


function displayAC(A,C)
A
C

