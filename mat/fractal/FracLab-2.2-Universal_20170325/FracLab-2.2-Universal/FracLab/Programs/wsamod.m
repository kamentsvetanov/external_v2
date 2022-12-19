function [f,count] = wsamod(x,QMF,varargin)
% WSAMOD Computes a model of a 1D signal. This model is a Weakly Self-Affine function
%        i.e. a function which has a weak form of scale invariance. Based on
%        this model, a segmentation of the original signal is then proposed.
%
%   F = WSAMOD(X,QMF) Computes the WSA model, F, of the input signal, X, using a 
%   quadrature mirror filter, QMF. A figure is displayed plotting X (in blue),the 
%   synthetic signal F (in green) and the segmentation marks (as red crosses).
%   The size of the signal X must be a power of 2.
%
%   F = WSAMOD(...,'scale',S) Computes F with a specific scale depth parameter, S,
%   which is a positive integer strictly greater than 2 and smaller than log2(N)-1.
%   The parameter S tunes the number of scales in the input signal which are taken
%   into account in the WSA modelling. Scales larger than S are ignored.
%   If SCALE is not specified, the default value is S = log2(N) - 1.
%
%   F = WSAMOD(...,'threshold',ERR) Computes F with a specific maximum error, ERR,
%   which is a postive real. The parameter ERR tunes the maximum pointwise 
%   discrepancy allowed between the input signal and the model. If discrepancies
%   larger than ERR occur, the signal is segmented to reduce this error.
%   If THRESHOLD is not specified, the default value is ERR = 10.
%
%   F = WSAMOD(...,'limits',[LOWER,UPPER]) Computes F with specific lower and upper scaling 
%   coefficients for the WSA model. These values are positive reals and the upper value
%   can be greater than 1 but the continuity of F is no longer guaranteed in this case.
%   Coefficients which are large or close to 0 tend to produce large variations,
%   and should most of the time be ignored in the modelling.
%   If LIMITS are not specified, the default vector is [LOWER,UPPER] = [0.1,1].
%
%   [F,COUNT] = WSAMOD(...) Computes F and retuns at the same time the percentage of
%   scaling coefficients which have been processed, COUNT, based on the [lower,upper]
%   couple. Tighter limits yield better behaved models, but at the price of a larger
%   percentage of non-processed (ignored) coefficients.
%
%   Example
%
%       N = 1024; H = 0.5;
%       x = fbmwoodchan(N,H);
%       QMF = MakeQMF('daubechies',4);
%       y = wsamod(x,QMF);
%
%   See also lacunary, MakeQMF, FWT, GIFSEG, WAVE2FIFS, GIFS2WAVE, IWT
%
% Reference page in Help browser
%     <a href="matlab:fl_doc wsamod ">wsamod</a>

% Author Khalid Daoudi, June 1997
% Modified by Christian Choque Cortez, April 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,8);
nargoutchk(1,2);

N = length(x) ;
if mod(log2(N),2) ~= 0 && mod(log2(N),2) ~= 1, error('The sample size must be a power of 2'); end
if nargin > 2
    arguments = varargin;
    [noctaves,arguments] = checkforargument(arguments,'scale',log2(N)-1);
    if ~isnumeric(noctaves) || noctaves < 3, error('Invalid use of scale property'); end
    [maxerr,arguments] = checkforargument(arguments,'threshold',10);
    if ~isnumeric(maxerr) || maxerr == 0, error('Invalid use of threshold property'); end
    [limits,arguments] = checkforargument(arguments,'limits',[0.1,1]);
    if ~isnumeric(limits) || size(limits,1) ~= 1 || size(limits,2) ~= 2, error('Invalid use of limits property'); end
    cmin = limits(1); cmax = limits(2);
    if ~isempty(arguments), error('Too many input arguments'); end
else
    noctaves = log2(N)-1; maxerr = 10;
    cmin = 0.1; cmax = 1;
end
%--------------------------------------------------------------------------

[wt,sc_idx,sc_lg] = FWT(x,noctaves,QMF);
Ci = wave2gifs(wt,sc_idx,sc_lg,2,0,2);
Ci_new1 = gifseg(Ci,.501,cmax,maxerr);
Ci_new2 = gifseg(Ci_new1,cmin,.5,maxerr);
[Cinew,marks,L3,count] = gifseg(Ci_new2,cmin,cmax,maxerr);
wt_new = gifs2wave(Cinew,wt,sc_idx,sc_lg);
f = IWT(wt_new);
visures(x,f,marks);
end
%--------------------------------------------------------------------------
function visures(sig,f,marks)
%Plots the the original signal and the synthetic one with the segmentation marks.

M = f(marks); 
N = length(sig);
t = (1:N);
figure('Tag','graph_segment');
plot(t,sig,'b',t,f,'g',marks,M,'r+');
legend('input signal','synthetic signal','segmentation marks','Location','NorthWest');
title ('Weakly self affine function analysis'); xlabel('time');
end
