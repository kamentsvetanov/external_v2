% demo for split-Laplace (MoG approx to a Gaussian density)

% Choose basic settings for simulations
% sigma = 1e10;            % precision 
g_fname = @MoG; % observation function
inG.gri = -20:2e-2:20;  % grid on which the gbf is evaluated
% Build simulated observations
gx = exp(-0.5*(inG.gri).^2);
gx = (1./sqrt(2*pi)).*gx;
% gx = gx./sum(gx);
% y = gx + sqrt(sigma.^-1)*randn(size(gx));
y = gx(:);
% display time series of hidden states and observations
figure,
% plot(y','ro')
% hold on;
plot(inG.gri,gx')
disp('--paused--')
% pause


%---- Invert gbf on simulated data ----%

% Build priors structure
priors.muPhi = [0;0;0];             % prior mean on observation params
priors.SigmaPhi = 1e-0*speye(3);    % prior covariance on observation params
priors.a_sigma = 1e5;               % Jeffrey's prior
priors.b_sigma = 1;                 % Jeffrey's prior
% Build options structure
options.ObsEval = 'plot_MoG(posterior.muPhi)';
options.priors = priors;            % include priors in options structure
options.inG = inG;                  % input structure (grid)
options.GnFigs = 0;                 % disable annoying figures
options.GnTolFun = 1e-10;
dim.n_phi = 3;                      % nb of observation parameters
dim.n_theta = 0;                    % nb of evolution parameters
dim.n=0;                            % nb of hidden states
% Call inversion routine
[posterior,out] = VBA_NLStateSpaceModel(y,[],[],g_fname,dim,options);


%---- Display results ----%
% displayResults(posterior,out,y,[],[],[],phi,[],sigma)