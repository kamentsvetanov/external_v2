function [X] = sampleFromArbitraryP(p,gridX,N)
% inverse transform sampling scheme

% This function samples from an arbitrary 1D probability distribution
% function [X] = sampleFromArbitraryP(p,grid,N)
% IN:
%   - p: pX1 vector (the density evaluated along the grid)
%   - gridX: pX1 vector (the grid over which the density is evaluated)
%   - N: the number of smaples to be sampled
% OUT:
%   - X: NX1 vector of samples

try; N; catch, N=1; end 
pcdf = cumsum(p);
X = zeros(N,1);
for i=1:N
    tmp = (pcdf-rand).^2;
    [mc,ic] = min(tmp);
    lc = length(ic);
    if lc > 1
        ind = randperm(lc);
    else
        ind = 1;
    end
    X(i) = gridX(ic(ind));
end