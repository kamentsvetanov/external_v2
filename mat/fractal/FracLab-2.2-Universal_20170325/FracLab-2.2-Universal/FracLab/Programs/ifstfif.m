function ifs = ifstfif(N,mi,vc,varargin)
% IFSTFIF Generates a random Fractal Interpolation Function based on Stochastic
%         Iterated Function System.
%
%   IFS = IFSTFIF(N,MI,VC) Generates the random fractal interpolation function, IFS,
%   using a sample size, N, a 3x2 matrix of interpolation points, MI, and a 2x1 vector
%   of contraction coefficients, VC. The parameter N is a positive integer and 
%   the parameters MI and VC are reals.
%
%   IFS = IFSTFIF(...'LAW') Generates IFS using a specific law for the contraction
%   coefficients. The possible LAW options that can be applied are 'uniform' in order
%   to use a uniform random law or 'normal' in order to use a normal random law. 
%   If LAW is not specified, the default value is LAW = UNIFORM.
% 
%   IFS = IFSTFIF(...,'ratio',S) Generates IFS using a specific ratio, S, that 
%   rules the variance decrease across scales. This means that at at each scale j the
%   variance of the contraction coefficients is equal to 1/j^S.
%   If RATIO is not specified the default value is S = 1. 
%   
%   Example
%
%       %Synthesis of semi-generalized IFS
%       N = 1024; t = linspace(0,1,N);
%       x = ifstfif(N,[0 0;0.5 1;1 0],[0.5;0.9]);
%       figure; plot(t,x);
%       title ('Semi-Generalized IFS'); xlabel ('time');
%
%   See also ifsfif, ifsgfif
%
%   References
%
%       [1] J. Levy Vehel and K. Daoudi "Generalized IFS for Signal Processing",
%           IEEE DSP Workshop, Loen, Norway, September 1-4, 1996.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc ifstfif ">ifstfif</a>

% Author Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,6);
nargoutchk(1,1);

if mod(log2(N),2) ~= 0 && mod(log2(N),2) ~= 1, error('The sample size must be a power of 2'); end
if size(mi,1)~=3 || size(mi,2)~=2, error('The interpolation points must be 3x2 matrix'); end
if isequal(mi(1,:),mi(2,:)) || isequal(mi(1,:),mi(3,:)) || isequal(mi(2,:),mi(3,:))
    error('The interpolation points must be differents');
end
if size(vc,2) ~= 1 || length(vc) ~= 2, error('The contraction coefficients must be a 2x1 vector'); end
if nargin > 3
    arguments = varargin;
    list = {'normal','uniform'};
    
    [law, arguments] = checkforargument(arguments,list,'uniform');
    [ratio, arguments] = checkforargument(arguments,'ratio',1);
    if ~isnumeric(ratio) || ratio < 0, error('Invalid use of ratio property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    law = {'uniform'};
    ratio = 1;
end

%--------------------------------------------------------------------------
nn = log2(N);
mi = sortrows(mi);

[a,b,c] = sgifs(mi,vc,nn,law{:},ratio); %#ok<NASGU> % calling the mex-file
ifs = b(1:N);

end