function [fx,dF_dX,dF_dTheta] = f_dcm4fmri_POS(Xt,Theta,ut,inF)
% nonlinear DCM evolution function (with positivity constraints)
% function [fx,dF_dX,dF_dTheta] = f_dcm4fmri_POS(Xt,Theta,ut,inF)
% This function evaluates the evolution function of the neuronal states of
% a nonlinear DCM for fMRI model. NB: there are positivity constraints on
% DCM evolution parameters.

deltat = inF.deltat;
n = size(Xt,1);

[dxdt,J,dfdp] = get_fx(Xt,Theta,ut,inF);
fx = Xt + deltat.*dxdt;

dF_dX = eye(n) + deltat.*J';
dF_dTheta = deltat.*dfdp;


function [dxdt,J,dfdp] = get_fx(Xt,Theta,ut,inF)

n = size(Xt,1);
nu = size(ut,1);

dfdp = zeros(size(Theta,1),n);
In = speye(n);
xI = kron(Xt',In);

A = inF.A;
indA = inF.indA;
if ~isempty(indA)
    A(A~=0) = exp(Theta(indA));
    A = A - eye(n);
    dfdp(indA,:) = exp(Theta(inF.indself)).*...
        [xI*inF.dA*diag(exp(Theta(indA)))]';
end

B = inF.B;
indB = inF.indB;
dxB = zeros(n,n);
for i=1:nu
    if ~isempty(indB{i})
        B{i}(B{i}~=0) = exp(Theta(indB{i}));
        dfdp(indB{i},:) = ...
            exp(Theta(inF.indself)).*...
            ut(i).*[xI*inF.dB{i}*diag(exp(Theta(indB{i})))]';
        dxB = dxB + ut(i).*B{i};
    end
end

C = inF.C;
indC = inF.indC;
if ~isempty(indC)
    C(C~=0) = exp(Theta(indC));
    dfdp(indC,:) = [kron(ut',In)*inF.dC*diag(exp(Theta(indC)))]';
end

D = inF.D;
indD = inF.indD;
dxD = zeros(n,n);
dxD2 = dxD;
for i=1:n
    if ~isempty(indD{i})
        D{i}(D{i}~=0) = Theta(indD{i});
        tmp = Xt(i)*D{i};
        dxD = dxD + tmp;
        tmp(:,i) = tmp(:,i)+D{i}*Xt;
        dxD2 = dxD2 +tmp;
        dfdp(indD{i},:) = ...
            exp(Theta(inF.indself)).*Xt(i)*...
            [xI*inF.dD{i}*diag(exp(Theta(indD{i})))]';
    end
end

% Unperturbed flow
tmp = exp(Theta(inF.indself)).*(A + dxB + dxD);

dxdt = tmp*Xt + C*ut;                           % vector field
J = exp(Theta(inF.indself)).*(A + dxB + dxD2);  % Jacobian
dfdp(inF.indself,:) = [tmp*Xt]';                % derivative wrt parameters



