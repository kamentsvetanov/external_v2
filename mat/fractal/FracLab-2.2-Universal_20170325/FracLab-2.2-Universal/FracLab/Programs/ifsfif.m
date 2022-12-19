function [ifs,y] = ifsfif(N,mi,vc,varargin)
% IFSFIF Generates a Fractal Interpolation Function based on Iterated Function System.
%
%   IFS = IFSFIF(N,MI,VC) Generates a fractal interpolation function, IFS, using
%   a sample size N, a k x 2 matrix of interpolation points, MI, and a (k-1) x 1
%   vector of contraction coefficients, VC. The parameter N is a positive integer
%   and the parameters MI and VC are reals.
%
%   IFS = IFSFIF(...,'SHAPE') Generates IFS using a specific type of interpolation.
%   The possbile SHAPE options that can be applied are 'affine' in order to use an
%   affine interpolation or 'sinusoidal' in order to use a sinusoidal interpolation.
%   If SHAPE is not specified, the default value is SHAPE = AFFINE.
%
%   [IFS,Y] = IFSFIF(...) Generates IFS and retuns at the same time the vector
%   Y containing the set of points corresponding to the abscissa of each
%   point of IFS.
%
%   Example
%
%       % Synthesis of a fractal interpomation function
%       N = 1024; t = linspace(0,1,N); 
%       interpoints = [0 0.5;0.7 -1;1 2;1.4 -2]; coefs = [0.5;-0.9;0.2];
%       x = ifsfif(N,interpoints,coefs);
%       figure; plot(t,x)
%       title ('Fractal Interpolation Function'); xlabel ('time');
%
%   See also ifsgfif, ifstfif
%
%   References
%
%       [1] K. Daoudi, J. Levy Vehel and Y. Meyer "Construction of continuous functions with 
%           prescribed local regularity", Constructive Approximation, Vol. 014(03) (1998), 349-385.
%
%       [2] J. Levy Vehel and K. Daoudi "Generalized IFS for Signal Processing",
%           IEEE DSP Workshop, Loen, Norway, September 1-4, 1996.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc ifsfif ">ifsfif</a>

% Author Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,4);
nargoutchk(1,2);

if size(mi,2)~=2, error('The interpolation points must be kx2 matrix'); end
k = length(mi);
if size(vc,2) ~= 1 || length(vc) ~= k-1, error('The contraction coefficients must be a (k-1)x2 vector'); end
if nargin > 3
    arguments = varargin;
    list = {'affine','sinusoidal'};
    
    [shape, arguments] = checkforargument(arguments,list,'affine');
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    shape = {'affine'};
end

%--------------------------------------------------------------------------
mi = sortrows(mi);

[z1,z2] = fif(mi,vc,N,shape{:}); % calling the mex-file
z = sortrows([z1 z2]);
ifs = z(:,2); y = z(:,1);

end