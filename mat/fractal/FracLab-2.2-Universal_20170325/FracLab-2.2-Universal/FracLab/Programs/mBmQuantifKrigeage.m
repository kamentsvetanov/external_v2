function mBm = mBmQuantifKrigeage(N,H,k,varargin)
% MBMQUANTIFKRIGEAGE Generates a Multi-fractional Brownian Motion (mBm) using Wood&Chan
%                    circulant matrix, some krigging and a prequantification.
%
%   MBM = MBMQUANTIFKRIGEAGE(N,H,K) Generates the multi-fractional brownian motion, MBM,
%   using a sample size, N, a Holder function, H, and a number, K, of levels for the
%   prequantification. This allows to model a process the pointwise regularity of which
%   varies in time. The parameter N is a positive integer.
%
%   MBM = MBMQUANTIFKRIGEAGE(...,'support',TMAX) Generates MBM using a specific size
%   of time support, i.e. the time runs in [0,TMAX]. 
%   If SUPPORT is not specified, the default value is TMAX = 1.
%
%   MBM = MBMQUANTIFKRIGEAGE(...,'sigma',S) Generates MBM using a specific standard
%   deviation, S, at instant t = 1. 
%   If SIGMA is not specified, the default value is S = 1.
%
%   MBM = MBMQUANTIFKRIGEAGE(...,'seed',SEED) Generates MBM with a specific random 
%   seed, SEED. This useful to generate the same path several times or to compare
%   the paths of different MBMs
%
%   Example
%
%       % Synthesis of the Holder function H(t): 0 < t < 1
%       N = 1024; t = linspace(0,1,N); Ht = eval('0.5+0.3*sin(4*pi*t)');
%       x = mBmQuantifKrigeage(N,Ht,10);
%       figure; plot(t,x);
%       title ('Multi-fractional Brownian Motion with periodical holder exponent');
%       xlabel ('time');
%
%   See also mbmlevinson, fbmwoodchan, fbmlevinson
%
%   References
%
%      [1] O. Barrière,"Synthèse et estimation de mouvements Browniens multifractionnaires
%          et autres processus à régularité prescrite. Définition du processus
%          autorégulé multifractionnaire et applications", PhD Thesis (2007).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mBmQuantifKrigeage ">mBmQuantifKrigeage</a>

% Author Olivier Barrière, January 2006
% Modified by Christian Choque Cortez, March 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,9)
nargoutchk(1,1)

if nargin > 3
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
eps = 10^-3;
H = min(1-eps,H); H = max(eps,H) ;
h_waitbar = fl_waitbar('init');
mBm = zeros(N,1);

%k-moyennes
[moy, out, xmin, xmax] = k_means(H,k);

%Pour ne jamais être dans le cas de "3 voisins" on rajoute les valeurs min et max aux k moyennes
%avec une marge de "sécurité"
moymin = moy(1); moymax = moy(end);
if 2*xmin-moymin < 0
    moyinf = max(eps,xmin-10*eps);
else
    moyinf = 2*xmin-moymin;
end

if 2*xmax-moymax > 1
    moysup = min(1-eps,xmax+10*eps);
else
    moysup = 2*xmax-moymax;
end

moy = [ moyinf moy moysup ];

%Précalcul des k fBm 1D avec les entrées aléatoires.
basefBm1D = zeros(N,k+2);
for i = 1:k+2
    basefBm1D(:,i) = fbmwoodchan(N,moy(i),'support',tmax,'sigma',sigma,'seed',seed);
    fl_waitbar('view',h_waitbar,i,k+2+N-1);
end
Hu = zeros(N,1);

%Recherche du voisinage en H
for i = 1:N
    ind = out(i);
    if H(i) < moy(ind+1)
        Hu(i) = ind;
    else
        Hu(i) = ind+1;
    end
end
Hu1 = Hu+1;

%Krigeage: Calculating of some common coefficients for covariance matrices
q = zeros(1,k+2);
for i = 1:k+2
    q(i) = ii(moy(i));
end
f = zeros(1,k+2);
for i = 2:k+2
    f(i) = 0.5*ii((moy(i)+moy(i-1))/2)*(1/sqrt(q(i)*q(i-1)));
end

for i = 2:N-1
    hu = Hu(i);
    hu1 = Hu1(i);
    if abs(H(i)-moy(hu)) < eps
        mBm(i) = basefBm1D(i,hu);
    elseif abs(H(i)-moy(hu1)) < eps
        mBm(i) = basefBm1D(i,hu1);
    else
        v = coeff(i,hu,hu1,q(hu),q(hu1),f(hu1),H(i),N,moy);
        u = [basefBm1D(i-1,hu) basefBm1D(i,hu) basefBm1D(i+1,hu) ...
             basefBm1D(i-1,hu1) basefBm1D(i,hu1) basefBm1D(i+1,hu1)];
        mBm(i) = u*v;
    end
    fl_waitbar('view',h_waitbar,i+k+2,N-1+k+2);
end

mBm(N) = mBm(N-1);

fl_waitbar('close',h_waitbar);
end

%--------------------------------------------------------------------------
function[v, err] = coeff(index,hu,hu1,h1,h2,f,h,n,moy)
%calculates the covariance matrix of basic FBMs and coefficients
% for the calculating of MFBM in the case of 6 grid neighbours of (t,H(t))

t = index/n; tau = 1/n;
num1 = moy(hu); num2 = moy(hu1);
hh = ii(h);
f1 = 0.5*ii((num1+h)/2)*(1/sqrt(h1*hh)); 
f2 = 0.5*ii((num2+h)/2)*(1/sqrt(h2*hh));
b1 = f1*[t.^(num1+h)+(t-tau)^(num1+h)-tau.^(num1+h) 2*t.^(num1+h) t.^(num1+h)+(t+tau).^(num1+h)-...
    tau.^(num1+h)];
b2 = f2*[t.^(num2+h)+(t-tau)^(num2+h)-tau.^(num2+h) 2*t.^(num2+h) t.^(num2+h)+(t+tau).^(num2+h)-...
    tau.^(num2+h)];
b = [b1 b2]';
A = 0.5*[2*(t-tau).^(2*num1) (t-tau).^(2*num1)+(t).^(2*num1)-tau.^(2*num1)  (t-tau).^(2*num1)+...
    (t+tau).^(2*num1)-(2*tau).^(2*num1);
    0 2*(t).^(2*num1)  (t).^(2*num1)+(t+tau).^(2*num1)-tau.^(2*num1);
    0 0  2*(t+tau)^(2*num1)];
A = A + triu(A,1)';
B = 0.5*[2*(t-tau).^(2*num2) (t-tau).^(2*num2)+(t).^(2*num2)-tau.^(2*num2)  (t-tau).^(2*num2)+...
    (t+tau).^(2*num2)-(2*tau).^(2*num2);
    0  2*(t).^(2*num2)  (t).^(2*num2)+(t+tau).^(2*num2)-tau.^(2*num2);
    0 0  2*(t+tau)^(2*num2)];
B = B + triu(B,1)';
C = f*[2*(t-tau).^(num1+num2) (t-tau).^(num1+num2)+(t).^(num1+num2)-tau.^(num1+num2)...
    (t-tau).^(num1+num2)+(t+tau).^(num1+num2)-(2*tau).^(num1+num2);
    0  2*(t).^(num1+num2)  (t).^(num1+num2)+(t+tau).^(num1+num2)-tau.^(num1+num2);
    0  0  2*(t+tau)^(num1+num2)];
C = C+triu(C,1)';
D = [A C;C B];
covm = inv(D);
v = covm*b;
err = abs(t.^(2*h)-b'*v);
end

%--------------------------------------------------------------------------
function [ii]=ii(h)
if h<0.5
    q = 1/h;
    ii = newgamma(1-2*h)*q*sin(pi*(0.5-h));
elseif h == 0.5;
    ii = pi;
else
    qq = 1/(h*(2*h-1));
    ii = newgamma(2-2*h)*qq*sin(pi*(h-0.5));
end;
end

%--------------------------------------------------------------------------
function res = newgamma(z)
% MATLAB's function gamma(z) adjusted to the scalar z 0<z<1

%   Ref: Abramowitz & Stegun, Handbook of Mathemtical Functions, sec. 6.1.
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.10 $  $Date: 1997/11/21 23:45:34 $

%   This is based on a FORTRAN program by W. J. Cody,
%   Argonne National Laboratory, NETLIB/SPECFUN, October 12, 1989.
%
% References: "An Overview of Software Development for Special
%              Functions", W. J. Cody, Lecture Notes in Mathematics,
%              506, Numerical Analysis Dundee, 1975, G. A. Watson
%              (ed.), Springer Verlag, Berlin, 1976.
%
%              Computer Approximations, Hart, Et. Al., Wiley and
%              sons, New York, 1968.
%
ppp = [-1.71618513886549492533811e+0; 2.47656508055759199108314e+1;
    -3.79804256470945635097577e+2; 6.29331155312818442661052e+2;
    8.66966202790413211295064e+2; -3.14512729688483675254357e+4;
    -3.61444134186911729807069e+4; 6.64561438202405440627855e+4];
qqq = [-3.08402300119738975254353e+1; 3.15350626979604161529144e+2;
    -1.01515636749021914166146e+3; -3.10777167157231109440444e+3;
    2.25381184209801510330112e+4; 4.75584627752788110767815e+3;
    -1.34659959864969306392456e+5; -1.15132259675553483497211e+5];

xnum = 0; xden = 1;
for i = 1:8
    xnum = (xnum + ppp(i)) .* z;
    xden = xden .* z + qqq(i);
end
res = (xnum+xden)/(xden*z);
end