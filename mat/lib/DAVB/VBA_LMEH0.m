function [LLH0] = VBA_LMEH0(y)
% evaluates the log-evidence of the null (H0) model
% [LLH0] = VBA_LMEH0(y)
% This function evaluates the exact log marginal likelihood of a null model
% H0, which basically assumes that the data only contain Gaussian noise of
% unknown variance, i.e. y ~ N(0,sigma^-1*I), where sigma is unknown, with
% Jeffrey's priors, i.e. sigma ~ Gamma(1,1). This is a trivial (null)
% model, to be compared with the model evidence of a non-trivial model as a
% diagnostic measure.
% IN:
%   - y: the data matrix;
% OUT:
%   - LLH0: the log evidence of the null model

y = y(:);
y2 = y'*y;
n = numel(y);
alpha = n/2 +1;
beta = y2./2 +1;
LLH0 = -0.5*n*log(2*pi) -alpha.*log(beta) + gammaln(alpha);

