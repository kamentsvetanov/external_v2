% Demo for design efficiency of DCM for fMRI.


% close all
% clear variables

%--- Choose basic settings for simulations
n_t = 6e1;                      % number of time samples
TR = 1e0;                       % sampling period (in sec)
microDT = 5e-2;                 % micro-time resolution (in sec)
u       = zeros(2,n_t);         % inputs
u(1,1:10) = 1;
u(1,30:40) = 1;
% u(2,20:30) = 1;
% u(2,45:55) = 1;

%--- DCM structure
% invariant effective connectivity
% A = [0 1 1
%      1 0 1
%      0 1 0];
 A = [  0 1
        1 0 ];
nreg = size(A,1);
% modulatory effects
B{1} = zeros(nreg,nreg);
B{2} = zeros(nreg,nreg);
% B{2} = [0 0 0
%         1 0 0
%         0 0 0];
% input-state coupling
% C = [1 0
%      0 0
%      0 0];
C = [1 0
     0 1];
% gating effects
D{1} = zeros(nreg,nreg);
D{2} = zeros(nreg,nreg);
D{3} = zeros(nreg,nreg);



%--- Recollect paramters and i/o for model inversion
f_fname = @f_DCMwHRF;
g_fname = @g_HRF3;
[options] = prepare_fullDCM(A,B,C,D,TR,microDT);
dim.n_theta         = options.inF.ind5(end);
dim.n_phi           = 2*nreg;
dim.n               = 5*nreg;
dim.n_t             = n_t;
dim.p               = nreg;

% Build priors for model inversion
indHemo = options.inF.indself+1:dim.n_theta;
priors.muX0 = kron(ones(nreg,1),[1;1;1;1;1]);
priors.SigmaX0 = 0e-0*speye(5*nreg);
priors.muTheta = 0*ones(dim.n_theta,1);
priors.muTheta(options.inF.indC) = 1;
priors.muTheta(options.inF.indself) = -1;
priors.SigmaTheta = 1e-0*speye(dim.n_theta);
% priors.SigmaTheta(indHemo,indHemo) = 0;
priors.muPhi = 0*ones(dim.n_phi,1);
priors.SigmaPhi = 1e-0*speye(dim.n_phi);
priors.a_alpha = Inf;%1e4;
priors.b_alpha = 0;%1e0;
priors.a_sigma = 1e4;
priors.b_sigma = 1e0;
options.priors = priors;





