function x = checkGX_binomial(x)

% finesses 0/1 (inifinite precision) binomial probabilities

% function x = checkGX_binomial(x)
% IN:
%   - x: vector of binomial probabilities
% OUT:
%   - x: [id], corrected.

lim = 1e-8;
x(x<=lim) = lim;
x(x>=1-lim) = 1-lim;