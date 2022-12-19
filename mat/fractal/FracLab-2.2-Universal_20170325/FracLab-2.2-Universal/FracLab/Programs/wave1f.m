function wgp = wave1f(N,H,QMF,varargin)
% WAVE1F Generates a 1/f Gaussian Process using a discret Wavelet transform
%
%   WGP = WAVE1F(N,H,Q) Generates the 1/f Gaussian process, WGP, using a sample
%   size, N, a Holder exponent, H, and quadrature mirror filter QMF. The parameter 
%   N is a positive integer, the parameter H is a real value in (0,1), and the 
%   parameter QMF is a real vector.
%
%   WGP = WAVE1F(...,'scale',S) Generates WGP with a specific scale depth
%   parameter, S, which is a positive integer that should not exceed S = log2(N).
%   If SCALE is not specified the default value S = log2(N).
%
%   WGP = WAVE1F(...,'seed',SEED) Generates WGP with a specific random seed, SEED. 
%   This useful to generate the same path several times or to compare the paths
%   of different WGPs.
%
%   Example
%
%       N = 1024 ; H = 0.5 ; t = linspace(0,1,N);
%       QMF = MakeQMF('daubechies',4);
%       x = wave1f(N,H,QMF);
%       figure; plot(t,x);
%       title ('1/f Gaussian Process with H = 0.5 and 4-daubechies filter'); 
%       xlabel ('time');
%
%   See also lacunary, MakeQMF, FWT, IWT
%
% Reference page in Help browser
%     <a href="matlab:fl_doc wave1f ">wave1f</a>

% Author Paulo Goncalves, June 1997
% Modified by Christian Choque Cortez, June 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,7);
nargoutchk(1,1);

if nargin > 3
    arguments = varargin;
    [noctaves,arguments] = checkforargument(arguments,'scale',floor(log2(N)));
    if ~isnumeric(noctaves) || noctaves == 0, error('Invalid use of scale property'); end
    [seed, arguments] = checkforargument(arguments,'seed',rand(1)*1e6);
    if ~isnumeric(seed), error('Invalid use of seed property'); end
    if ~isempty(arguments), error('Too many input arguments'); end
else
    noctaves = floor(log2(N));
    seed = rand(1) * 1e6;
end

%--------------------------------------------------------------------------

randn('state',seed);
xinit = randn(1,N);

[wtxinit,wti,wtl] = FWT(xinit,noctaves,QMF);
scale = exp((0:noctaves-1)*log(2));
wtx = wtxinit;

for j = 1:noctaves
  wtx(wti(j):wti(j)+wtl(j)-1) = wtx(wti(j):wti(j)+wtl(j)-1).*(scale(j).^(H+1/2));
end

wgp = IWT(wtx)';
wgp = wgp(1:N);
