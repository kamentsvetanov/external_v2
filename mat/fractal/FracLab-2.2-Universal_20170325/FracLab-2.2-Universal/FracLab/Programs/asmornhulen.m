function asm = asmornhulen(N,alpha,lambda,M,m,varargin)
% ASMORNHULEN Generates an alpha-stable Ornstein-Uhlenbeck process.
%
%   ASM = ASMORNHULEN(N,ALPHA,LAMBDA,M,m) Generates the alpha-stable Ornstein-
%   Uhlenbeck process, ASM, using a sample size, N, a stability parameter, ALPHA,
%   an Ornstein-Uhlenbeck parameter, LAMBDA, a kernel cut-off parameter, M and
%   a number of discretization steps, m. The parameters N,M and m are positive
%   integers and this triplet should be chosen so that the value m*(N+M) is 
%   a power of 2. ALPHA is a real in (0,2) and LAMBDA is positive real.
%
%   ASM = ASMORNHULEN(...,SEED) Generates ASM with a specific random seed,
%   SEED. This is useful to generate the same path several times or to
%   compare the paths of different ASMs.
%
%   Example
%
%       N = 1000 ; A = 1.5 ; lambda = 1; t = linspace(0,1,N); M = 24; m = 32;
%       x = asmornhulen(N,A,lambda,M,m);
%       figure; plot(t,x);
%       title ('Ornstein-Uhlenbeck process with alpha = 1.5 and lambda = 1'); 
%       xlabel ('time');
%
%   See also asmlevy, asmlinfrac, msmornhulen
%
%   References
%       [1] K. Falconer, R. Le Guével, J. Lévy Véhel "Localisable moving 
%           average stable and multistable processes", Stochastic Models.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc asmornhulen ">asmornhulen</a>

% Author Ronan. Leguevel 2009.
% Modified by Christian Choque Cortez, May 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(5,6)
nargoutchk(1,1)

if ~(alpha >= 0 && alpha <= 2 ), error('alpha input argument mus be included in (0:2)'); end

seed = rand(1) * 1e6;
try %#ok<TRYNC>
    seed = varargin{1};
end

%--------------------------------------------------------------------------
mh = 1/m;
t = -M:mh:-mh;

A = mh^(1/alpha) * exp(lambda*t);
A = [A,zeros(1,m*N)];
Na = m*(M+N);
A  = fft(A,Na);

if alpha == 2
    randn('state',seed);
    Z = randn(1,Na)';
else
    [cumZ,Z] = asmlevy(Na,alpha,0,seed); 
end

Zhat = fft(Z',Na);
w = real(ifft(Zhat.*A,Na));
asm = w(1:m:N*m)';
end
