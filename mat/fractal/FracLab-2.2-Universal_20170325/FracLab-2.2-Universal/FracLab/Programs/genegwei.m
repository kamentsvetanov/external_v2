function wei = genegwei(N,Ht,varargin)
% GENEGWEI Generates a Generalized Weierstrass function
%
%   WEI = GENEGWEI(N,H) Generates the generalized Weierstrass function, WEI,
%   using a sample size, N, and a Holder function Ht. The parameter N is a 
%   positive integer and each element of the function Ht, which is in (0,1)
%   prescribes the local Holder regularity of the WEI.
%
%   WEI = GENEGWEI(...'METHOD') Generates WEI using a specific method. The 
%   possible METHOD options that can be applied are 'det' in order to generate
%   a deterministic WEI or 'stoc' in order to generate a stochastic WEI. 
%   If METHOD is not specified, the default value is METHOD = STOC.
%
%   WEI = GENEGWEI(...,'support',TMAX) Generates WEI using a specific size of
%   time support, TMAX. The parameter TMAX is a positive integer. 
%   If SUPPORT is not specified, the default value is TMAX = 1.
%
%   WEI = GENEGWEI(...,'frequency',L) Generates WEI using a specific frequency
%   term, L. The parameter L is a positive real superior to 1. 
%   If LAMBDA is not specified, the default value is L = 2.
%
%   WEI = GENEGWEI(...,'nterms',K) Generates WEI using a specific number of
%   terms in the sum, K. The parameter K is a positive integer, its value
%   should be greater than the Nyquist value, Nqv = log(N/2*TMAX)/log(L).
%   If Nterms is not specified the default value is K = 50. 
%
%   WEI = GENEGWEI(...,'seed',S) Generates a stochastic WEI with a specific
%   random seed, SEED. This is useful to generate the same path several times
%   or to compare the paths of different sotchastic WEIs.
%
%   Example
%
%       % Synthesis of the Holder function H(t): 0 < t < 1
%       N = 1024; t = linspace(0,1,N); Ht = eval('abs(sin(8*t))');
%       x = genegwei(N,Ht);
%       figure; plot(t,x);
%       title ('Stochastic Generalized Weierstrass function'); xlabel ('time');
%
%   See also genewei
%
% Reference page in Help browser
%     <a href="matlab:fl_doc genegwei ">genegwei</a>

% Author Paulo Goncalves, June 1997
% Modified by Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,11)
nargoutchk(1,1)

if nargin > 2
    arguments = varargin;
    
    [method, arguments] = checkforargument(arguments,{'det'},'stoc');
    if strcmp(method,'stoc')
        [method, arguments] = checkforargument(arguments,{'stoc'},'stoc');
    end
    [tmax, arguments] = checkforargument(arguments,'support',1);
    if ~isnumeric(tmax) || tmax < 0, error('Invalid use of support property'); end
    [lambda, arguments] = checkforargument(arguments,'frequency',2);
    if ~isnumeric(lambda) || lambda <= 1, error('Invalid use of lambda property'); end
    [kmax, arguments] = checkforargument(arguments,'nterms',50);
    if ~isnumeric(kmax), error('Invalid use of kmax property'); end
    [seed, arguments] = checkforargument(arguments,'seed',rand(1)*1e6);
    if ~isnumeric(seed), error('Invalid use of seed property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    method = {'stoc'};
    tmax = 1; lambda = 2; kmax = 50;
    seed = rand(1) * 1e6;
end

%--------------------------------------------------------------------------
wei = zeros(1,N);
randn('state',seed); rand('state',seed);

if strcmp(method,'stoc')
    C = randn(1,kmax+1); A = rand(1,kmax+1)*2*pi;
else
    C = ones(1,kmax+1); A = zeros(1,kmax+1);
end
s = 2 - Ht;

% WEIERSTRASS COMPUTATION
for k = 0:kmax
   y = C(k+1) * exp(log(lambda)*(s-2)*k).* sin(2*pi*lambda^k*tmax/N*(0:N-1)+A(k+1));
   wei(1:N) = wei(1:N) + y;
end

wei = wei';