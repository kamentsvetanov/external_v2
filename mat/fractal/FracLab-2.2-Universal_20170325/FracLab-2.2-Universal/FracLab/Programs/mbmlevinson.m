function mBm = mbmlevinson(N,H,varargin)
% MBMLEVINSON Generates a Multi-fractional Brownian Motion (mBm) using the 
%             Cholesky/Levinson factorization.
%
%   MBM = MBMLEVINSON(N,H) Generates the multi-fractional brownian motion, MBM,
%   using a sample size, N, and a Holder function, H. This allows to model a
%   process the pointwise regularity of which varies in time. The parameter
%   N is a positive integer. 
%
%   MBM = MBMLEVINSON(...,'support',TMAX) Generates MBM using a specific size
%   of time support, i.e. the time runs in [0,TMAX]. 
%   If SUPPORT is not specified, the default value is TMAX = 1.
%
%   MBM = MBMLEVINSON(...,'sigma',S) Generates MBM using a specific standard
%   deviation, S, at instant t = 1. 
%   If SIGMA is not specified, the default value is S = 1.
%
%   MBM = MBMLEVINSON(...,'seed',SEED) Generates MBM with a specific random 
%   seed, SEED. This useful to generate the same path several times or to compare
%   the paths of different MBMs
%
%   Example
%
%       % Synthesis of the Holder function H(t): 0 < t < 1
%       N = 512; t = linspace(0,1,N); Ht = eval('0.5+0.3*sin(4*pi*t)');
%       x = mbmlevinson(N,Ht);
%       figure; plot(t,x);
%       title ('Multi-fractional Brownian Motion with periodical holder exponent');
%       xlabel ('time');
%
%   See also mBmQuantifKrigeage, fbmwoodchan, fbmlevinson
%
%   References
%       [1] N. Levinson "The wiener rms error criterion in ?lter design and prediction", 
%           Journal of Mathematics and Physics, Vol 25 (1947) 261–278.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mbmlevinson ">mbmlevinson</a>

% Author Paulo Goncalves, June 1997
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
H = min(0.9999,H); H = max(eps,H);
t = linspace(0,tmax,N); shift = tmax/N;
s = eps; alpha = 2*H(:); 
r = (sigma^2*(exp(alpha(:)*log(abs(t+shift-s))) + ...
    exp(alpha(:)*log(abs(t-s-shift))) - 2*exp(alpha(:)*log(abs(t-s))))/2)';

randn('state',seed);
y = randn(N,1); mBm = zeros(N,N);
inter1 = r;
inter2 = [zeros(1,N) ; r(2:N,:) ; zeros(1,N)]; 
k = -inter2(2,:); aa = sqrt(r(1,:));

for j = 2:N
  aa = aa.*sqrt(1-k.^2);
  fl_waitbar('view',h_waitbar,j,N);
  inter = k(ones(N-j+1,1),:).*inter2(j:N,:) + inter1(j-1:N-1,:);
  inter2(j:N,:) = inter2(j:N,:) + k(ones(N-j+1,1),:).*inter1(j-1:N-1,:);	
  inter1(j:N,:) = inter; clear inter;					
  bb = y(j)*aa.^(-1);
  mBm(j:N,:) = mBm(j:N,:) + bb(ones(N-j+1,1),:).*inter1(j:N,:);
  k = -inter2(j+1,:)./(aa.^2);
end

mBm = diag(cumsum(mBm));
fl_waitbar('close',h_waitbar);