function [F] = VBA_FreeEnergy2(posterior,suffStat,options)
% computes free energy of the sDCM generative model (at equilibrium)
% function [F] = VBA_FreeEnergy2(posterior,suffStat,options)
% This function evaluates the free energy associated with the nonlinear
% state-space model inverted by the main inversion routine
% VBA_NLStateSpaceModel.m.
% IN:
%   - posterior: a structure containing the natural parameters of the
%   marginal posterior pdf of the unknown variables of the model
%   - suffStat: a structure containing pre-calculated (sufficient
%   statistics) quantities associated required for the computation of the
%   free energy (such as derivatives of the evolution/observation functions
%   evaluated at the current mode)
%   - options: a structure variable containing optional parameters (such as
%   the priors structure)
% OUT:
%   - F: the free energy under the local Laplace approximation

if options.DisplayWin % Display progress
    try
        set(options.display.hm(1),'string',...
            'Calculating Free Energy... ');
        set(options.display.hm(2),'string','0%');
        drawnow
    end
end

priors = options.priors;
dim = options.dim;

% Get precision parameters
sigmaHat = posterior.a_sigma./posterior.b_sigma;
logSigmaHat = psi(posterior.a_sigma) - log(posterior.b_sigma);
if dim.n > 0
    alphaHat = posterior.a_alpha./posterior.b_alpha;
    logAlphaHat = psi(posterior.a_alpha) - log(posterior.b_alpha);
end

ldQ = 0;
nnt = 0;
for t=1:dim.n_t
    ldQ = ldQ + VBA_logDet(options.priors.iQy{t});
    if dim.n > 0
        ldQ = ldQ + ...
            VBA_logDet(options.priors.iQx{t},options.params2update.x{t});
        nnt = nnt + length(options.params2update.x{t});
    end
end


% Common terms in the free energy
F = - 0.5*sigmaHat*suffStat.dy2 ...
    - 0.5*dim.p*dim.n_t*(log(2*pi) - logSigmaHat) ...
    + priors.a_sigma*log(priors.b_sigma) - gammaln(priors.a_sigma) ...
    + (priors.a_sigma-1).*logSigmaHat - sigmaHat.*priors.b_sigma ...
    + suffStat.Ssigma ...
    + 0.5*ldQ;

% observation parameters
if dim.n_phi > 0
    indIn = options.params2update.phi;
    if ~isempty(indIn)
        Q = priors.SigmaPhi(indIn,indIn);
        iQ = VB_inv(Q,[]);
        F = F ...
            - 0.5*suffStat.dphi(indIn)'*iQ*suffStat.dphi(indIn) ...
            - 0.5*length(indIn)*log(2*pi) ...
            - 0.5*VBA_logDet(Q) ...
            + suffStat.Sphi - 0.5*length(indIn);
    end
end

% evolution parameters
if dim.n_theta > 0
    indIn = options.params2update.theta;
    if ~isempty(indIn)
        Q = priors.SigmaTheta(indIn,indIn);
        iQ = VB_inv(Q,[]);
        F = F ...
            - 0.5*suffStat.dtheta(indIn)'*iQ*suffStat.dtheta(indIn) ...
            - 0.5*length(indIn)*log(2*pi) ...
            - 0.5*VBA_logDet(Q) ...
            + suffStat.Stheta - 0.5*length(indIn);
    end
end

% hidden states
if dim.n > 0
    F = F ...
        - 0.5*alphaHat*suffStat.dx2 ...
        - 0.5*nnt*(log(2*pi) - logAlphaHat) ...
        + priors.a_alpha*log(priors.b_alpha) - gammaln(priors.a_alpha) ...
        + (priors.a_alpha-1).*logAlphaHat - alphaHat.*priors.b_alpha ...
        + suffStat.Salpha ...
        + suffStat.SX - 0.5*nnt;
    if options.updateX0
        indIn = options.params2update.x0;
        Q = priors.SigmaX0(indIn,indIn);
        iQ = VB_inv(Q,[]);
        F = F ...
            - 0.5*suffStat.dx0(indIn)'*iQ*suffStat.dx0(indIn) ...
            - 0.5*length(indIn)*log(2*pi) ...
            - 0.5*VBA_logDet(Q) ...
            + suffStat.SX0 - 0.5*length(indIn);
    end
end

if options.DisplayWin % Display progress
    try
        set(options.display.hm(2),'string','OK');
        drawnow
    end
end


function [f] = psi(z)
% psi(x) = d[log(gamma(x))]/dx
siz = size(z);
z=z(:);
zz=z;
f = 0.*z; % reserve space in advance
%reflection point
p=find(real(z)<0.5);
if ~isempty(p)
    z(p)=1-z(p);
end
%Lanczos approximation for the complex plane
g=607/128; % best results when 4<=g<=5
c = [  0.99999999999999709182;
    57.156235665862923517;
    -59.597960355475491248;
    14.136097974741747174;
    -0.49191381609762019978;
    .33994649984811888699e-4;
    .46523628927048575665e-4;
    -.98374475304879564677e-4;
    .15808870322491248884e-3;
    -.21026444172410488319e-3;
    .21743961811521264320e-3;
    -.16431810653676389022e-3;
    .84418223983852743293e-4;
    -.26190838401581408670e-4;
    .36899182659531622704e-5];
n=0;
d=0;
for k=size(c,1):-1:2
    dz=1./(z+k-2);
    dd=c(k).*dz;
    d=d+dd;
    n=n-dd.*dz;
end
d=d+c(1);
gg=z+g-0.5;
%log is accurate to about 13 digits...
f = log(gg) + (n./d - g./gg) ;
if ~isempty(p)
    f(p) = f(p)-pi*cot(pi*zz(p));
end
p=find(round(zz)==zz & real(zz)<=0 & imag(zz)==0);
if ~isempty(p)
    f(p) = Inf;
end
f=reshape(f,siz);
return



