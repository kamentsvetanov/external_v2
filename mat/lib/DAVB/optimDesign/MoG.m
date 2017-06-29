function [mgp] = MoG(xt,Phi,ut,in)
% observation function for mixture of gaussian (MoG) densities
%
% function [mgp] = MoG(xt,Phi,ut,in)
% This functions serves when evaluating the best MoG approximation to a 1D
% arbitrary density. This function uses a MoG with 3 components, one
% centered at 0, and two symmetric components (with means -mu and mu). All
% of these have the same variance.
% NB: the code has been optimized to best approximate a Gaussian density
% (for split-Laplace approximation).
% IN:
%   - xt: [useless]
%   - Phi: parameters of the MoG.
%   - ut: [useless]
%   - in: optinal input. This is used to pass the grid over which the MoG
%   density is evaluated.
% OUT:
%   - mgp: the MoG evaluated over the 1D grid.

try
    gri = in.gri;
catch
    gri = -10:1e-2:10;
end
gri = gri(:);

mu = 2*sigm(Phi(2));%-1.4131205233; %2*sigm(Phi(1));
s = exp(Phi(3));%0.51751260421;

p1 = exp(-0.5*(gri-mu).^2./s);
p1 = (1./sqrt(2*pi))*(1./sqrt(s)).*p1;

p2 = exp(-0.5*(gri+mu).^2./s);
p2 = (1./sqrt(2*pi))*(1./sqrt(s)).*p2;

p3 = exp(-0.5*(gri).^2./s);
p3 = (1./sqrt(2*pi))*(1./sqrt(s)).*p3;

q = 0.5*sigm(Phi(1));

mgp = q.*p1 + q.*p2 + (1-2*q).*p3;
