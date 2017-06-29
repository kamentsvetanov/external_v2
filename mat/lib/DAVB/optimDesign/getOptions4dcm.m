function [options,dim] = getOptions4dcm(A,B,C,D,TR,microDT,n_t)
% builds the options structure from basic DCM info
%
% function [options,dim] = getOptions4dcm(A,B,C,D,TR,microDT,n_t)
% IN:
%   - A,B,C,D: the binary DCM neural connectivity matrices
%   - TR: the fMRI sampling rate
%   - microDT: the desired (micro-time) sampling rate
%   - n_t: the number of time samples in the fMRI time series
% OUT:
%   - options: the options input structure for VBA_NLStateSpaceModel.m
%   - dim: [id]

nreg = size(A,1);

[options] = prepare_fullDCM(A,B,C,D,TR,microDT);

dim.n_theta         = options.inF.ind5(end);
dim.n_phi           = 2*nreg;
dim.n               = 5*nreg;
dim.p               = nreg;
dim.n_t             = n_t;

priors.muX0 = kron(ones(nreg,1),[0;0;0;0;0]);
priors.SigmaX0 = 0e-1*speye(5*nreg);
priors.muTheta = 1e-3*ones(dim.n_theta,1);
priors.muTheta(options.inF.indself) = -1;
priors.SigmaTheta = 1e-3*speye(dim.n_theta);
% priors.SigmaTheta(options.inF.ind1,options.inF.ind1) = 0;
priors.muPhi = 0*ones(dim.n_phi,1);
priors.SigmaPhi = 1e-3*speye(dim.n_phi);
priors.a_alpha = Inf;%1e6;
priors.b_alpha = 0;%1e4;
priors.a_sigma = 1e0;
priors.b_sigma = 1e0;

options.priors = priors;