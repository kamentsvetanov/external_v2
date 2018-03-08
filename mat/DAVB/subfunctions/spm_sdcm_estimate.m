function [DCM] = spm_sdcm_estimate(P)
% Estimate parameters of a stochastic DCM for fMRI data
% FORMAT [DCM] = spm_sdcm_estimate(DCM)   
%
% DCM  - the DCM or its filename
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Jean Daunizeau



% load DCM structure
if ~nargin
    P = spm_select(1,'^DCM.*\.mat$','select DCM_???.mat');
    if isempty(P)
        return
    end
end
if isstruct(P)
    DCM = P;
    P   = ['DCM-' date];
else
    load(P)
end

% Get data and remove confounds
y = DCM.Y.y';
X0 = DCM.Y.X0;
iX0 = pinv(X0'*X0)*X0';
nreg = size(y,1);
for i=1:nreg
    beta = iX0*y(i,:)';
    yc = X0*beta;
    y(i,:) = y(i,:) - yc';
end


% Unpack DCM specification
dt = DCM.U.dt;
uu = DCM.U.u';
[nu,nt] = size(uu);
[p,ny] = size(y);
A = DCM.a - eye(nreg);
for i=1:nu
    B{i} = DCM.b(:,:,i);
end
C = DCM.c;
if isfield(DCM,'d')
    for i=1:nreg
        try
            D{i} = DCM.d(:,:,i);
        catch
            D{i} = zeros(nreg,nreg);
        end
    end
else
    for i=1:nreg
        D{i} = zeros(nreg,nreg);
    end
end

% Prepare optional input for inversion routine
TR = DCM.Y.dt;
f_fname = @f_DCMwHRF;       % evolution equation
g_fname = @g_HRF3;          % (static) observation equation
microDT = 1e-1;             % micro-time resolution (in sec)
[options] = prepare_fullDCM(A,B,C,D,TR,microDT);
options.microU = 1;
options.GnFigs = 1;
dim.n_theta         = options.inF.ind5(end);
dim.n_phi           = 2*nreg;
dim.n               = 5*nreg;

% Resampe inputs on microtime integration grid
[u] = resampleU(uu,dt,nt,nu,ny,options);
u = [zeros(nu,1),u];

% Build priors
priors.muX0 = kron(ones(nreg,1),[0;0;0;0;0]);
priors.SigmaX0 = 0e-1*speye(5*nreg);
priors.muTheta = 0*ones(dim.n_theta,1);
priors.muTheta(options.inF.indself) = 0;%-1;
priors.SigmaTheta = 1e-2*speye(dim.n_theta,dim.n_theta);
priors.muPhi = 0*ones(dim.n_phi,1);
priors.SigmaPhi = 1e-2*speye(dim.n_phi,dim.n_phi);
priors.a_alpha = Inf;%1e6;
priors.b_alpha = 0;%1e6;
priors.a_sigma = 1e5;
priors.b_sigma = 1e1;
% priors.AR = 1;
n_t = size(y,2);
for t = 1:n_t
    dq = Inf*ones(dim.n,1);
    dq(options.inF.n5) = 1;
    priors.iQx{t} = diag(dq);
end
% get Balloon model parameters for canonical hrf
disp(' ')
disp('-----------------------------')
disp('Initializing HRF parameter...')
[thetaHRF,phiHRF] = get_HRFparams(TR,microDT);
disp('Initializing HRF parameter... OK')
disp('-----------------------------')
disp(' ')
% fill in prior structure
priors.muTheta(options.inF.ind1) = thetaHRF(1);
priors.muTheta(options.inF.ind2) = thetaHRF(2);
priors.muTheta(options.inF.ind3) = thetaHRF(3);
priors.muTheta(options.inF.ind4) = thetaHRF(4);
priors.muTheta(options.inF.ind5) = thetaHRF(6);
indHemo = options.inF.indself+1:dim.n_theta;
priors.SigmaTheta(indHemo,indHemo) = 1e-1.*priors.SigmaTheta(indHemo,indHemo);
priors.muPhi(options.inG.ind1) = phiHRF(1);
priors.muPhi(options.inG.ind2) = phiHRF(2);
priors.SigmaPhi = 0e-1.*priors.SigmaPhi;
options.priors = priors;


% call inversion routine
% y0 = y;
% clear y;
% for i=1:size(y0,1)
%     D = floor(round(DCM.delays(i)./TR));
%     y(i,:) = y0(i,290-D:350-D);
% end
% u = u(:,290:350);

% y = [zeros(p,1),y(:,1:end-1)];

disp(' ')
disp('-----------------------------')
disp('Inverting stochastic DCM...')
% invert stochastic DCM using discrete-time VB routine:
[posterior,out] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);
% extract relevant info and fills in DCM structure
[DCM] = exportDCMfromVBNLSS(posterior,out,DCM);
disp('Inverting stochastic DCM... OK')
disp('-----------------------------')
disp(' ')

return

function [u] = resampleU(uu,dt,nt,nu,ny,options)
microDT = options.inF.deltat;
grid1 = 0:dt:dt*(nt-1);
grid2 = 0:microDT:microDT*options.decim*ny;
u = zeros(nu,ny);
for i=1:length(grid2)-1
    [tmp,ind1] = min(abs(grid2(i)-grid1));
    [tmp,ind2] = min(abs(grid2(i+1)-grid1));
    u(:,i) = mean(uu(:,ind1:ind2),2);
end
% [u,alpha] = spm_resample(full(uu),dt/microDT);



function [Y,alpha] = spm_resample(X,alpha)
% [Jean:] Basic resample function (when no Signal Proc. Toolbox)
% FORMAT Y = spm_resample(X,alpha)
% IN:
%   - X: a nXm matrix of n time series
%   - alpha: the ration of input versus output sampling frequencies. If
%   alpha>1, spm_resample(X,alpha) performs upsampling of the time series.
% OUT:
%   - Y: nX[alpha*m] matrix of resampled time series
%   - alpha: true alpha used (due to rational rounding)
% This function operates on rows of a signal matrix. This means it can be
% used on a block of channels.

N0     = size(X,2);
N      = floor(N0*alpha);
alpha  = N/N0;
Y      = fftshift(fft(X,[],2),2);
sy     = size(Y,2);
middle = floor(sy./2)+1;
if alpha>1 % upsample
    N2 = floor((N-N0)./2);
    if N0/2 == floor(N0/2)
        Y(:,1) = []; % throw away non symmetric DFT coef
    end
    Y  = [zeros(size(Y,1),N2),Y,zeros(size(Y,1),N2)];
else % downsample
    N2 = floor(N./2);
    Y  = Y(:,middle-N2:middle+N2);
end
Y      = alpha*ifft(ifftshift(Y,2),[],2);
% now rescale Y:
pX     = sqrt(sum(X(:).^2));
pY     = sqrt(sum(Y(:).^2));
Y      = Y.*(pX./pY);




