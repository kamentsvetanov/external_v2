function srmp = srmpfbm(N,gz,varargin)
% SRMPFBM Generates a Self-Regulating Multifractional Process from a field of
%         fractional brownian motions using an iterative method.
%
%   SRMP = SRMPFBM(N,GZ) Generates the self-regulating multifractional process, SRMP,
%   using a sample size, N, and a function of z, GZ. The parameter N is a positive
%   integer and the parameter GZ is a vector whose values correspond to a function
%   from (0,1) to (0,1) linking the pointwise Holder exponent to the amplitude.
%
%   SRMP = SRMPFBM(...,'shape',{Ft,M}) Generates SRMP with a specific deterministic
%   "shape", given by the function Ft and a mixing parameter, M. Ft defines the shape
%   of low frequencies and M rules the mixing of Ft and the texture. The higher M is,
%   the closer the obtained SRMP will be to the function Ft. If M is not specified,
%   the default value is M = 2.
%
%   SRMP = SRMPFBM(...,'seed',SEED) Generates SRMP with a specific random seed, SEED. 
%   This is useful to generate the same path several times or to compare the paths
%   of different SRMPs.
%
%   Example
%
%       % Synthesis of self-regulating multifractional process
%       N = 1024; z = linspace(0,1,N); gz = eval('1./(1+5*z.^2)');
%       x = srmpfbm(N,gz);
%       figure; plot(x)
%
%   See also srmpmidpoint
%
%   References
%
%      [1] Barrière, O. Synthèse et estimation de mouvements Browniens multifractionnaires
%          et autres processus à régularité prescrite. Définition du processus
%          autorégulé multifractionnaire et applications.
%          PhD Thesis (2007)
%
% Reference page in Help browser
%     <a href="matlab:fl_doc srmpfbm ">srmpfbm</a>

% Author Olivier Barrière, 2008
% Modified by Antoine Echelard, November 2008
% Modified by Christian Choque Cortez, June 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,6)
nargoutchk(1,1)

if nargin >2
    arguments = varargin;
    [shape,arguments] = checkforargument(arguments,'shape',[],'wo');
    if ~isempty(shape)
        try ft = shape{1}; end  %#ok<TRYNC>
        try M = shape{2}; catch, M = 2; end %#ok<NOCOM,CTCH>
        if ~isnumeric(ft) || length(ft) ~= N, error('Invalid use of shape property'); end
        if ~isnumeric(M) || size(M,1) ~= 1 || size(M,2) ~= 1, error('Invalid use of melange property'); end
    end
    [seed, arguments] = checkforargument(arguments,'seed',rand(1)*1e6);
    if ~isnumeric(seed), error('Invalid use of seed property'); end
    if ~isempty(arguments), error('Too many input arguments'); end
else
    shape = [];
    seed = rand(1) * 1e6;
end

%--------------------------------------------------------------------------
B = zeros(N,N);
Niter = 100; 

h_waitbar = fl_waitbar('init');
% Pre calculating Gaussian field of the fBms
a = min(gz); b = max(gz); H = linspace(a,b,N)';
for i = 1:N
    B(i,:) = fbmwoodchan(N,H(i),'seed',seed);
end

if ~isempty(shape)
    for i = 1:N
        Bi = recadrageAuto(B(i,:),min(ft),max(ft));
        B(i,:) = Bi - M*ft;
    end
end

% Cropping
A_ = max(max(B)); B_ = min(min(B));
alpha = 0; beta = 1; Z_ = linspace(alpha,beta,N)';

Bab = alpha + (beta-alpha)*(B-A_)/(B_-A_);
srmp(1,:) = ones(1,N)*mean(Z_);
normediff(1) = 0; stable = 0; 
i = 0; 
 
while i<=Niter && ~stable
    i = i+1;
    fl_waitbar('view',h_waitbar,i,Niter);
    for t = 1:N
        iZ = trouve(srmp(i,t),Z_);
        igZ = trouve(gz(iZ),H);
        srmp(i+1,t) = Bab(igZ,t);
    end
    normediff(i+1) = norm(srmp(i+1,:)-srmp(i,:)); %#ok<AGROW>
    if normediff(i+1) == normediff(i), stable = 1; fl_waitbar('view',h_waitbar,Niter,Niter); end
end
fl_waitbar('close',h_waitbar);
if i > Niter, error('The algorithm didn''t converge'); end

srmp = srmp(end,:);
end
%--------------------------------------------------------------------------
function i = trouve(Xi,X)
% looks for the value where the sign changes

Z = X-Xi; signe = sign(Z(1)); i = 2;
while sign(Z(i)) == signe && i<length(Z), i=i+1; end
end
%--------------------------------------------------------------------------
function y=recadrageAuto(x,a,b)

xmin = min(min(x)); xmax = max(max(x));
y=a+(b-a)*(x-xmin)/(xmax-xmin);
end
