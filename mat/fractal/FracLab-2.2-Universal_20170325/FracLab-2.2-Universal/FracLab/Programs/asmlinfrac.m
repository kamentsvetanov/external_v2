function asm = asmlinfrac(N,alpha,H,M,m,varargin)
% ASMLINFRAC Generates an alpha-stable Linear Fractional motion.
%
%   ASM = ASMLINFRAC(N,ALPHA,H,M,m) Generates the alpha-stable linear fractional
%   motion, ASM, using a sample size, N, a stability parameter, ALPHA, a self-similarity
%   parameter, H, a kernel cut-off parameter, M and a number of discretization steps, m.
%   The parameters N,M and m are positive integers and this triplet should be chosen 
%   so that the value m*(N+2*M) is a power of 2. ALPHA is a real in (0,2) and 
%   H must be a real in (0,1) different to (1/ALPHA).
%
%   ASM = ASMLINFRAC(...,SEED) Generates ASM with a specific random seed,
%   SEED. This is useful to generate the same path several times or to
%   compare the paths of different ASMs.
%
%   Example
%
%       N = 1000 ; A = 1.5 ; H = 0.5; M = 12; m = 32; t = linspace(0,1,N);
%       x = asmlinfrac(N,A,H,M,m);
%       figure; plot(t,x);
%       title ('Linear Fractional Motion with alpha = 1.5 and H = 0.5'); 
%       xlabel ('time');
%
%   See also asmlevy, asmornhulen, msmlinmfrac
%
%   References
%       [1] S. Stoev, M. Taqqu "Simulation methods for linear fractional 
%           stable motion and FARIMA using the Fast Fourier Transform", 
%           Fractals, Vol. 12, No. 1 (2004) 95-121.
%
%       [2] K. Falconer, R. Le Guével, J. Lévy Véhel "Localisable moving 
%           average stable and multistable processes", Stochastic Models.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc asmlinfrac ">asmlinfrac</a>

% Author Stilian Stoev, June 2002
% Modified by Jacques Lévy-Véhel, 2008
% Modified by Christian Choque Cortez, May 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(5,6)
nargoutchk(1,1)

if ~(alpha >= 0 && alpha <= 2 ), error('alpha input argument must be a real in (0,2)'); end
if H == 1/alpha, error('H input argument must be a real in (0,1) different of 1/alpha'); end

seed = rand(1) * 1e6;
try %#ok<TRYNC>
    seed = varargin{1};
end

%--------------------------------------------------------------------------
mh = 1/m;
d  = H-1/alpha;
t0 = -M:mh:-mh; t1 = mh:mh:M;

A  = mh^(1/alpha)*...
    [power(abs(t0+1),d)-power(abs(t0),d),power(abs(t1+1),d)-power(abs(t1),d)];
A(A==Inf) = power(10,10); A(A==-Inf) = -power(10,10);
CmM1 = sum(abs(A).^alpha)^(-1/alpha);
A  = CmM1*[A,zeros(1,m*N)];
Na = m*(2*M+N);
A  = fft(A,Na);

if alpha == 2
    randn('state',seed);
    Z = randn(1,Na)';
else
    [cumZ,Z] = asmlevy(Na,alpha,0,seed);
end

Zhat = fft(Z',Na);
w = real(ifft(Zhat.*A,Na));
asm = cumsum(w(1:m:N*m))';
end
