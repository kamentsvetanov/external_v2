function [asm, rstab] = asmlevy(N,alpha,beta,varargin)
% ASMLEVY Generates an alpha-stable Levy motion.
%
%   ASM = ASMLEVY(N,ALPHA,BETA) Generates the alpha-stable Levy motion, ASM, using
%   a sample size, N, a stability parameter, ALPHA and a skewness parameter, BETA.
%   The parameter N is a positive integer, ALPHA is a real in (0,2) and 
%   BETA is a real in [-1,1]. The symmetric distribution corresponds to BETA = 0. 
%
%   ASM = ASMLEVY(...,SEED) Generates ASM with a specific random seed,
%   SEED. This is useful to generate the same path several times or to
%   compare the paths of different ASMs.
%
%   Example
%
%       N = 1000 ; A = 1.5 ; B = 0; t = linspace(0,1,N);
%       x = asmlevy(N,A,B);
%       figure; plot(t,x);
%       title ('Levy Motion with alpha = 1.5 and beta = 0'); 
%       xlabel ('time');
%
%   See also asmlinfrac, asmornhulen, msmlevy
%
%   References
%       [1] P. Bratley, B.L. Fox, and L.E. Schrage "A guide to simulation",
%           Springer-Verlag (1983).
%
%       [2] J.M. Chambers, C.L. Mallows, B.W. Stuck "A method for simulating
%           stable random variables", JASA,VOL.71, NO. 354, PP.340-344
%           (1976, correction in 1986).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc asmlevy ">asmlevy</a>

% Author Dimitar Vandev adapted from the original FORTAN code in [1].
% Modified by Jacques Lévy-Véhel, 2008
% Modified by Christian Choque Cortez, May 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,4)
nargoutchk(1,2)

seed = rand(1) * 1e6;

try %#ok<TRYNC>
    seed = varargin{1};
end

rand('state',seed)
pi2 = pi/2;
eps = 1 - alpha;

if (eps > -0.99)
    tau = beta / (pi2 * tan2(eps*pi2));
else
    tau = pi2 * alpha;
    tau = beta * eps * tau * tan2(tau);
end

% Compute some tangents.
a = rand(N,1);
phiby2 = (a - 0.5) * pi2;
a = phiby2.*tan2(phiby2);
b = phiby2 * eps; b = b.*tan2(b);

% Compute some necessary subexpressions. If PHY near Pi/2, use double precision.
da = a.*a; a2 = 1 - da; a2p = 1 + da;
db = b.*b; b2 = 1 - db; b2p = 1 + db;

% Compute coefficient.
z = -log(rand(N,1));
z = z.*a2.*b2p;
z = log(a2p.*(b2 + phiby2.*tan2(b)*(2*tau))./z);
z = z/(1 - eps);
d = z.*d2(z*eps);

% Compute stable.
asm = a.*b; asm = 1 + asm;
rstab = 1 + d*eps;
rstab = (rstab*2).*((a-b).*asm - (phiby2*tau).*tan2(b).*(b.*a2-a*2))./(a2.*b2p)+d*tau;
asm = cumsum(rstab);
end

%--------------------------------------------------------------------------
function y = tan2(x)
% Returns tan(xarg)/xarg only for abs(xarg)<= (Pi/4) and tan(x)/x for other
% arguments. Adapted from the original FORTAN code in [2].

p =[0.129221035e+3, -0.887662377e+1, 0.528644456e-1];
q =[0.164529332e+3, -0.451320561e+2, 1];
pi4 = pi/4;
xx = abs(x);
y = zeros(size(x));

I = find(xx > pi4);
if ~isempty(I), y(I) = tan(x(I))./x(I); end

I = find(xx <= pi4);
if ~isempty(I)
    xx = xx(I)./pi4; xx = xx.*xx;
    y(I) = (p(1) + xx.*(p(2) + xx*p(3)))./(pi4 * (q(1) + xx.*(q(2) + xx*q(3))));
end
end

%--------------------------------------------------------------------------
function y = d2(z)
% Returns (exp(x) - 1)/exp(x). Adapted from the original FORTAN code in [2]
% The correction in Chambers, Mallows & Stuck JASA (1987) was incorporated.

p = [840.066852536483239 20.0011141589964569];
q = [1680.13370507296648 180.0133704073900023 0.1];
y = zeros(size(z));

I = find(abs(z) > 0.1);
if ~isempty(I), y(I) = (exp(z(I))-1)./z(I); end

I=find(abs(z) <= 0.1);
if ~isempty(I)
    zz = z(I).*z(I); pv = p(1) + zz*p(2);
    y(I) = 2 * pv./(q(1) + zz.*(q(2) + zz*q(3)) - z(I).*pv);
end
end
