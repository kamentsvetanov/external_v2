function [gfx,dGF_dX] = getGFX(X,posterior,u,options,N)
% computes the N-lagged observation function
% [gfx] = getGFX(X,posterior,u,options,dim,N)
% IN:
%   - X: the states at time step t
%   - posterior: the posterior structure, which is used to evaluate the
%   evolution and observation functions at the posterior mode of evolution
%   and observation parameters
%   - u: the input at time step t
%   - options: the options structure
%   - N: the number of time samples ahead of the current hidden state
% OUT:
%   - gfx: the N-lagged prediction on observations, i.e. g(f(f(...f(x(t))))
%   - dGF_dX: the gradient of N-lagged observation function wrt X

fx = X;
dFdX = 1;
for i=1:N
    [fx,dF_dfx] = VBA_evalFun('f',fx,posterior.muTheta,u,options);
    dFdX = dFdX*dF_dfx;
end
[gfx,dG_dfx] = VBA_evalFun('g',fx,posterior.muPhi,u,options);
dGF_dX = dFdX*dG_dfx;
