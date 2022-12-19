function fBm = fbmwoodchan(N,H,varargin)
% FBMWOODCHAN Generates a Fractional Brownian Motion (fBm) using Wood and Chan circulant matrix
%
%   FBM = FBMWOODCHAN(N,H) Generates the fractional brownian motion, FBM, using
%   a sample size, N, and a Holder exponent, H. The parameter N is a positive integer
%   and the parameter H is a real value in (0:1) that governs both the pointwise
%   regularity and the shape around 0 of the power spectrum.
%
%   FBM = FBMWOODCHAN(...,'support',TMAX) Generates FBM using a specific size
%   of time support, i.e. the time runs in [0,TMAX]. 
%   If SUPPORT is not specified, the default value is TMAX = 1.
%
%   FBM = FBMWOODCHAN(...,'sigma',S) Generates FBM using a specific standard
%   deviation, S, at instant t = 1. 
%   If SIGMA is not specified, the default value is S = 1.
%
%   FBM = FBMWOODCHAN(...,'seed',SEED) Generates FBM with a specific random 
%   seed, SEED. This useful to generate the same path several times or to compare
%   the paths of different FBMs
%
%   Example
%
%       N = 1024 ; H = 0.8 ; t = linspace(0,1,N);
%       x = fbmwoodchan(N,H) ;
%       figure; plot(t,x) ;
%       title ('Fractional Brownian Motion with H = 0.8') ; xlabel ('time') ;
%
%   See also fbmlevinson, mBmQuantifKrigeage, mbmlevinson
%   
%   References
%       [1] A.T.A. Wood, G. Chan, "Simulation of stationary Gaussian process in [0,1]d", 
%           Journal of Computational and Graphical Statistics, Vol. 3 (1994) 409-432.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc fbmwoodchan ">fbmwoodchan</a>

% Author Olivier Barrière, January 2006
% Modified by Christian Choque Cortez, March 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,8)
nargoutchk(1,1)

if nargin > 2
    arguments = varargin;
    
    [tmax, arguments] = checkforargument(arguments,'support',1);
    if ~isnumeric(tmax) || tmax < 0, error('Invalid use of support property'); end
    [sigma, arguments] = checkforargument(arguments,'sigma',1);
    if ~isnumeric(sigma), error('Invalid use of sigma property'); end
    [seed, arguments] = checkforargument(arguments,'seed',rand(1)*1e6);
    if ~isnumeric(seed), error('Invalid use of seed property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    tmax = 1; sigma = 1;
    seed = rand(1) * 1e6;
end

%--------------------------------------------------------------------------

% Construction of the first line of the circulant matrix C
m = 2^(fix(log(N-1)/log(2)+1));
eigC = lineC(N,H,sigma,tmax,m);

% research of the power of two (<2^18) such that C is definite positive
eigC = fft(eigC);
while ((eigC <= 0) & (m < 2^17)) %#ok<AND2>
    m = 2*m;
    eigC = lineC(N,H,sigma,tmax,m);
    eigC = fft(eigC);
end

% simulation of W=(Q)^t Z, where Z leads N(0,I_m) and (Q)_{jk} = m^(-1/2) exp(-2i pi jk/m)
randn('state',seed);
ar = randn(m/2+1,1); ai = randn(m/2+1,1);
ar(1) = sqrt(2) * ar(1);
ar(m/2+1) = sqrt(2) * ar(m/2+1);
ai(1) = 0; ai(m/2+1) = 0;
ar = [ar(1:m/2+1); ar( m/2:-1:2 )];
aic = -ai;
ai = [ai(1:m/2+1); aic(m/2:-1:2)];
W = ar + i*ai;

% reconstruction of the fGn
W = sqrt(eigC').* W;
fGn = fft(W);
fGn = fGn/sqrt(2*m);
fGn = real(fGn);
fGn = fGn(1:N);

fBm = cumsum(fGn);