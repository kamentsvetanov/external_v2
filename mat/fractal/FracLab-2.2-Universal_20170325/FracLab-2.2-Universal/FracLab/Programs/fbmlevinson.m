function fBm = fbmlevinson(N,H,varargin)
% FBMLEVINSON Generates a Fractional Brownian Motion (fBm) using Cholesky/Levinson factorization
%
%   FBM = FBMLEVINSON(N,H) Generates the fractional brownian motion, FBM, using
%   a sample size, N, and a Holder exponent, H. The parameter N is a positive
%   integer and the parameter H is a real value in (0:1) that governs both
%   the pointwise regularity and the shape around 0 of the power spectrum.
%
%   FBM = FBMLEVINSON(...,'support',TMAX) Generates FBM using a specific size
%   of time support, i.e. the time runs in [0,TMAX]. 
%   If SUPPORT is not specified, the default value is TMAX = 1.
%
%   FBM = FBMLEVINSON(...,'sigma',S) Generates FBM using a specific standard
%   deviation, S, at instant t = 1. 
%   If SIGMA is not specified, the default value is S = 1.
%
%   FBM = FBMLEVINSON(...,'seed',SEED) Generates FBM with a specific random 
%   seed, SEED. This useful to generate the same path several times or to compare
%   the paths of different FBMs
%
%   Example
%
%       N = 1024 ; H = 0.8 ; t = linspace(0,1,N);
%       x = fbmlevinson(N,H) ;
%       figure; plot(t,x) ;
%       title ('Fractional Brownian Motion with H = 0.8') ; xlabel ('time') ;
%
%   See also fbmwoodchan, mBmQuantifKrigeage, mbmlevinson
%
%   References
%       [1] N. Levinson "The wiener rms error criterion in ?lter design and prediction", 
%           Journal of Mathematics and Physics, Vol 25 (1947) 261–278.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc fbmlevinson ">fbmlevinson</a>

% Author Paulo Gonvalves, June 1997
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

h_waitbar = fl_waitbar('init');
t = linspace(0,tmax,N) ; shift = tmax/N;
alpha = 2*H; 
r = sigma^2*(abs(t+shift).^alpha + abs(t-shift).^alpha - 2*abs(t).^alpha)/2;

randn('state',seed);
y = randn(N,1);

fBm = zeros(1,N);

inter1 = r; inter2 = [0 r(2:N) 0];
k = -inter2(2); aa = sqrt(r(1));

for j = 2:N
  aa = aa * sqrt(1-k^2);
  fl_waitbar('view',h_waitbar,j,N);
  inter = k * inter2(j:N) + inter1(j-1:N-1);
  inter2(j:N) = inter2(j:N) + k*inter1(j-1:N-1);
  inter1(j:N) = inter;
  bb = y(j)/aa;
  fBm(j:N) = fBm(j:N) + bb*inter1(j:N);
  k = -inter2(j+1)/(aa^2);
end

fBm = cumsum(fBm(:));
fl_waitbar('close',h_waitbar);