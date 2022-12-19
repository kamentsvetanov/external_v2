% This procedure estimates the 2-microlocal frontier of a signal on
% an interval. The algorithm uses an oscillation based characterization
% of 2-microlocal spaces.
%
% WARNING: it may take a couple of hours to compute the frontiers 
% if the signal, the interval or the discretization are high.
%
% The "starting point" and the "ending point" are the bounds of the
% studied interval.
% 
% The discretization of the frontier is the number of samples that are 
% computed to estimate the frontier. The bigger it is, the more precise
% the approximation is.
%
% An example of estimation is given if desired, i.e. an example of a
% regression which is done to compute a sample of the frontier.
%
% When desired, it also estimates the Pointwise Holder exponent (by 2
% methods) and the local Holder exponent, using the estimated frontier.
%