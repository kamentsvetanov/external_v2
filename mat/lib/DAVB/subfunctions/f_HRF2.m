function [fx,dfdx,dfdp] = f_HRF2(Xt,P,ut,in)
% Balloon (HRF) model evolution function in log-space
% function [fx,dfdx,dfdp] = f_HRF2(Xt,P,ut,in)
% This function evaluates the evolution function derived from the balloon
% model for the hemodynamic response function. It can be called in two
% ways: (i) as a "stand-alone" evolution function, whereby the system's
% states are hemodynamic states of the balloon model, or (ii) as a
% generalized observation function, where the real system's states are the
% neuronal states of a DCM for fMRI model. Note that the hemodynamic states
% are in log-space, for positivity constrints.


deltat = in.deltat;
n = size(Xt,1);

% Get parameters
[E0,V0,tau0,kaf,kas,epsilon,alpha] = BOLD_parameters;
if isfield(in,'fullDCM') && in.fullDCM
    nreg = n./5;
    ind1 = in.ind1;
    ind2 = in.ind2;
    ind3 = in.ind3;
    ind4 = in.ind4;
    n1 = in.n1;
    n2 = in.n2;
    n3 = in.n3;
    n4 = in.n4;
    try, n5=in.n5; catch, n5=[];end
    epsilon = 1;
    alpha = alpha.*exp(P(in.ind5));
else
    nreg = n./4;
    ind1 = 1;
    ind2 = 2;
    ind3 = 3;
    ind4 = 4;
    n1 = 1;
    n2 = 2;
    n3 = 3;
    n4 = 4;
    epsilon = epsilon.*exp(P(5));
    alpha = alpha.*exp(P(6));
end
[E0,dsdp] = sigm(P(ind1)-0.6633,struct('beta',1,'G0',1,'INV',0));
E0 = E0(:);
tau0 = tau0.*exp(P(ind2));
kaf = kaf.*exp(P(ind3));
kas = kas.*exp(P(ind4));

% hemodynamic states ...
if isfield(in,'linearized') && in.linearized
    x1 = zeros(nreg,1);
    x2 = ones(nreg,1);
    x3 = ones(nreg,1);
    x4 = ones(nreg,1);
else
    x1 = Xt(n1,:);                               % vasodilatory signal s(t)
    x2 = exp(Xt(n2,:))+1e-3;                     % blood inflow f(t)
    x3 = exp(Xt(n3,:))+1e-3;                     % blood volume v(t)
    x4 = exp(Xt(n4,:))+1e-3;                     % dHb content q(t)
end
fv = x3.^(1./alpha);                            % blood outflow
dfvdx = (1./alpha).*fv;                         % d[blood flow]/dXt(3)
ff = (1-(1-E0).^(1./x2))./E0;                   % oxygen extraction
dffdx = log(1-E0).*(1-E0).^(1./x2)./(E0.*x2);   % d[O2 extraction]/dXt(2)
% ... and flow field, derivatives, etc...
f = zeros(n,1);
J = zeros(n,n);
dfdp = zeros(size(P,1),n);

% Evaluate flow field
f(n1) = (epsilon.*ut - kas.*x1 - kaf.*(x2 - 1));
f(n2) = x1./x2;
f(n3) = (x2 - fv)./(tau0.*x3);
f(n4) = (x2.*ff./x4 - fv./x3)./tau0;

% Evaluate jacobian and gradients wrt parameters
for i=1:nreg
    
    J(n1(i),n1(i):n1(i)+3) = [ -kas(i) , 1./x2(i), 0, 0 ];
    J(n2(i),n1(i):n1(i)+3) = [ -kaf(i).*x2(i), -x1(i)./x2(i), ...
        x2(i)./(tau0(i).*x3(i)), ...
        x2(i).*(ff(i)+dffdx(i))./(tau0(i).*x4(i))];
    J(n3(i),n1(i):n1(i)+3) = [ 0, 0,...
        -f(n3(i)) - dfvdx(i)./(tau0(i).*x3(i)) , ...
        (fv(i)-dfvdx(i))./(tau0(i).*x3(i))];
    J(n4(i),n1(i):n1(i)+3) = [ 0, 0, 0, ...
        -(x2(i).*ff(i))./(tau0(i).*x4(i)) ];
    
    % gradient wrt parameters
    dfdp(ind1(i),n1(i):n1(i)+3) = [0,0,0,...
        x2(i).*(((1-E0(i)).^(-1+1./x2(i)))./x2(i)-ff(i))...
        .*dsdp(i)./(tau0(i).*x4(i).*E0(i))];
    dfdp(ind2(i),n1(i):n1(i)+3) = [0,0,...
        -(x2(i) - fv(i))./(tau0(i).*x3(i)),...
        -(x2(i).*ff(i)./x4(i) - fv(i)./x3(i))./tau0(i)];
    dfdp(ind3(i),n1(i):n1(i)+3) = kaf(i).*[-x2(i)+1,0,0,0];
    dfdp(ind4(i),n1(i):n1(i)+3) = kas(i).*[-x1(i),0,0,0];
    
    % complement gradients if used for full DCM model
    if isfield(in,'fullDCM') && in.fullDCM
        if  ~isempty(n5)
            J(n5(i),n1(i)) = epsilon;
        end
        dfdp(in.ind5(i),n1(i):n1(i)+3) = [0,0,...
            log(x3(i)).*fv(i)./(tau0(i).*x3(i).*alpha(i)),...
             log(x3(i)).*fv(i)./(tau0(i).*x3(i).*alpha(i))];
    else
        dfdp(5,:) = epsilon.*[ut,0,0,0];
        dfdp(6,:) = [0,0,...
            log(x3).*fv./(tau0.*x3.*alpha),...
             log(x3).*fv./(tau0.*x3.*alpha)];
    end
    
end

% Apply Euler discretization
if isfield(in,'linearized') && in.linearized
    Cu = zeros(n,1);
    Cu(n1) = epsilon.*ut;
    fx = Xt + deltat.*(J'*Xt + Cu);
    dfdp = [];
else
    fx = Xt + deltat.*f;
    dfdp = deltat.*dfdp;
end
dfdx = eye(n) + deltat.*J;


