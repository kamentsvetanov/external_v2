function [DCM] = exportDCMfromVBNLSS0(posterior,out,DCM,TR)

% This function fills in a DCM structure with the output of VBNLLS
% (i.e. stochastic DCM) inversion

nu = size(out.options.inF.C,2);
nreg = size(out.options.inF.C,1);
y = out.y;
if isempty(DCM) % fill in default info
    try
        DCM.Y.dt = TR;
    catch
        DCM.Y.dt = 1;
    end
    try
        DCM.TE = out.options.inG.TE;
    catch
        DCM.TE = 0.04;
    end
    DCM.Y.y = y';
    DCM.U.dt = 1;
    DCM.U.u = out.u';
    for i=1:nreg
        DCM.Y.name{i} = ['region #',num2str(i)];
    end
    for i=1:nu
        DCM.U.name{i} = ['factor #',num2str(i)];
    end
    DCM.M.m = nu; % number of inputs
    DCM.M.n = out.dim.n; % number of hidden states
    DCM.M.l = nreg; % number of regions
    DCM.a = out.options.inF.A;
    for i=1:nu
        if ~isempty(out.options.inF.indB{i})
            DCM.b(:,:,i) = out.options.inF.B{i};
        else
            DCM.b(:,:,i) = zeros(nreg,nreg);
        end
    end
    DCM.c = out.options.inF.C;
    for i=1:nreg
        if ~isempty(out.options.inF.indD{i})
            DCM.d(:,:,i) = out.options.inF.D{i};
        else
            DCM.d(:,:,i) = zeros(nreg,nreg);
        end
    end
end
DCM.M.IS = '[in built Euler integration scheme]';
if isa(out.options.g_fname,'function_handle')
    DCM.M.g = func2str(out.options.g_fname);
else
    DCM.M.g = out.options.g_fname;
end
if isa(out.options.f_fname,'function_handle')
    DCM.M.f = func2str(out.options.f_fname);
else
    DCM.M.f = out.options.f_fname;
end
DCM.options.two_state = 0;
if isinf(out.options.priors.a_alpha) && ...
        isequal(out.options.priors.b_alpha,0)
    sdcm = 0;
else
    sdcm = 1;
end
DCM.options.stochastic = sdcm;
DCM.Cp = out.suffStat.ODE_posterior.SigmaPhi;
DCM.y = out.suffStat.gx'; % predicted data
DCM.R = y' - DCM.y; % residuals of the model
DCM.F = out.F;

% gets A, B, C and D expectations and PPMs
[A,B0,C,D0,pA,pB0,pC,pD0] = getABCD(posterior,out,0);
for i=1:nu
    B(:,:,i) = B0{i};
    pB(:,:,i) = pB0{i};
end
for i=1:nreg
    D(:,:,i) = D0{i};
    pD(:,:,i) = pD0{i};
end

DCM.Ep.A = A;
DCM.Ep.B = B;
DCM.Ep.C = C;
DCM.Ep.D = D;

DCM.Pp.A = pA;
DCM.Pp.B = pB;
DCM.Pp.C = pC;
DCM.Pp.D = pD;

[DCM.H1,DCM.K1] = getKernels(posterior,out,1);
DCM.M.N = size(DCM.H1,2);
DCM.M.dt = out.options.inF.deltat;

% finally store out structure in DCM
DCM.out = out;


function [A,B,C,D,pA,pB,pC,pD] = getABCD(posterior,out,t)
inF = out.options.inF;
Theta = posterior.muTheta;
V = posterior.SigmaTheta;
nreg = size(inF.A,1);
nu = size(inF.C,2);
esc = exp(Theta(inF.indself));
vsc = esc.^2.*V(inF.indself,inF.indself);

A = inF.A;
pA = NaN.*ones(nreg,nreg);
indA = inF.indA;
if ~isempty(indA)
    [ms,vs] = getVarProd(esc,vsc,inF.indself,Theta,V,indA);
    [ps] = getPPMS(ms,vs,t);
    [psc] = getPPMS(esc,vsc,t);
    A(A~=0) = ms;
    pA(A~=0) = ps;
    scI = esc.*eye(nreg);
    A = A - scI;
    pA(scI~=0) = psc;
end

B = inF.B;
pB = cell(nu,1);
indB = inF.indB;
for i=1:nu
    if ~isempty(indB{i})
        [ms,vs] = getVarProd(esc,vsc,inF.indself,Theta,V,indB{i});
        [ps] = getPPMS(ms,vs,t);
        B{i}(B{i}~=0) = ms;
        pB{i} = NaN.*ones(nreg,nreg);
        pB{i}(B{i}~=0) = ps;
    else
        B{i} = zeros(nreg,nreg);
        pB{i} = NaN.*ones(nreg,nreg);
    end
end

C = inF.C;
pC = NaN.*ones(nreg,nu);
indC = inF.indC;
if ~isempty(indC)
    C(C~=0) = Theta(indC);
    VC = V(indC,indC);
    pC(C~=0) = getPPMS( Theta(indC),diag(VC),t);
end

D = inF.D;
pD = cell(nreg,1);
indD = inF.indD;
for i=1:nreg
    if ~isempty(indD{i})
        [ms,vs] = getVarProd(esc,vsc,inF.indself,Theta,V,indD{i});
        [ps] = getPPMS(ms,vs,t);
        D{i}(D{i}~=0) = ms;
        pD{i} = NaN.*ones(nreg,nreg);
        pD{i}(D{i}~=0) = ps;
    else
        D{i} = zeros(nreg,nreg);
        pD{i} = NaN.*ones(nreg,nreg);
    end
end


function [ms,vs] = getVarProd(esc,vsc,ind0,mu,V,ind)
m = mu(ind); % expectations of the non-scaled parameters
S = diag(full(V));
S = S(ind); % variances of the non-scaled parameters
C = V(ind,ind0); % covariances of the non-scaled params with the scaling
n = length(m);
ms = zeros(n,1);
vs = zeros(n,1);
for i=1:n
    Sigma = [ vsc        esc.*C(i)
              esc.*C(i)  vsc       ];
    Mu = [ esc
           m(i) ];
    [ms(i),vs(i)] = EVprodX(Mu,Sigma);
end

function [ps] = getPPMS(m,v,t)
n = length(m);
ps = zeros(n,1);
for i=1:n
    [ps(i)] = VB_PPM(m(i),v(i),t,0);
end
