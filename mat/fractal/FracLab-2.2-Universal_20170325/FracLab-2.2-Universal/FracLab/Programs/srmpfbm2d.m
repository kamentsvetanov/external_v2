function srmp = srmpfbm2d(N,gz,varargin)
% SRMPFBM2D Generates a 2D Self-Regulating Multifractional Process from a field of
%           fractional brownian motions using an iterative method.
%
%   SRMP = SRMPFBM2D(N,GZ) Generates the self-regulating multifractional process, SRMP,
%   using a sample size, [N,N], and a function of z, GZ. The parameter N is a positive
%   integer and the parameter GZ is a vector whose values correspond to a function
%   from (0,1) to (0,1) linking the pointwise Holder exponent to the amplitude.
%
%   SRMP = SRMPFBM2D(...,'shape',{FXY,M}) Generates SRMP with a specific deterministic
%   "shape", given by the function, FXY and a mixing parameter, M. FXY defines the shape
%   of low frequencies and M rules the mixing of FXY and the texture. The higher M is,
%   the closer the obtained SRMP will be to the function FXY. If M is not specified, 
%   the default value is M = 1.
%
%   SRMP = SRMPFBM2D(...,'seed',SEED) Generates SRMP with a specific random seed, SEED. 
%   This is useful to generate the same path several times or to compare the paths
%   of different SRMPs
%
%   Example
%
%       % Synthesis of 2D self-regulating multifractional process
%       N=32; z=linspace(0,1,N); gz = eval('1./(1+5*z.^2)');
%       x2D = srmpfbm2d(N,gz);
%       figure; imagesc(x2D)
%
%   References
%
%      [1] Barrière, O. Synthèse et estimation de mouvements Browniens multifractionnaires
%          et autres processus à régularité prescrite. Définition du processus
%          autorégulé multifractionnaire et applications.
%          PhD Thesis (2007)
%
% Reference page in Help browser
%     <a href="matlab:fl_doc srmpfbm2d ">srmpfbm2d</a>

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
        try fxy = shape{1}; end  %#ok<TRYNC>
        try M = shape{2}; catch, M = 2; end %#ok<NOCOM,CTCH>
        if ~isnumeric(fxy) || size(fxy,1) ~= N || size(fxy,2) ~= N, error('Invalid use of shape property'); end
        if ~isnumeric(M), error('Invalid use of melange property'); end
    end
    [seed, arguments] = checkforargument(arguments,'seed',rand(1)*1e6);
    if ~isnumeric(seed), error('Invalid use of seed property'); end
    if ~isempty(arguments), error('Too many input arguments'); end
else
    shape = [];
    seed = rand(1) * 1e6;
end

%--------------------------------------------------------------------------
B = zeros(N,N,N);
Niter = 100; 

randn('state',seed);
gu = (fix(log(2*[N,N]-1)/log(2)+1)); m = 2.^gu;
W_xy = fft2(randn(m)); 
W_x = fft(randn(m(1),1))/sqrt(m(1)); W_y = fft(randn(1,m(2))).'/sqrt(m(2));

h_waitbar = fl_waitbar('init'); NN = 10;

% Pre calculating Gaussian field of the fBms
a = min(gz); b = max(gz); H = linspace(a,b,N)';
for i = 1:N
    fl_waitbar('view',h_waitbar,i,N+NN);
    B(i,:,:) = fastfBm2D([N,N],H(i),W_xy,W_x,W_y,1);
end

if ~isempty(shape)
    for i = 1:N
        Bi = recadrageAuto(B(i,:),min(min(fxy)),max(max(fxy)));
        B(i,:) = Bi - M*reshape(fxy,size(Bi));
    end
end

% Cropping
A_= max(max(max(B))); B_= min(min(min(B)));
alpha = min(gz); beta = max(gz);
Z1 = ones(N,N)*mean(gz); Z2 = zeros(size(Z1));
normediff(1) = 0; stable = 0; 
i = 0; 
 
while i<=Niter && ~stable
    i = i+1;
    fl_waitbar('view',h_waitbar,N+i,N+NN);
    for x = 1:N
        for y = 1:N
            Bab = alpha + (beta-alpha)*(B(:,x,y)-A_)/(B_-A_);
            Z2(x,y) = Bab(trouve(Z1(x,y),gz));
        end
    end
    normediff(i+1) = norm(Z2-Z1); %#ok<AGROW>
    Z1 = Z2;
    if i == NN, NN = 2*NN; end
    if abs(normediff(i+1)-normediff(i))<eps, stable = 1; end
end
fl_waitbar('close',h_waitbar);
if i > Niter, error('The algorithm didn''t converge'); end

srmp = Z2;
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
