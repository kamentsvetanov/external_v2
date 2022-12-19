function [F,fs] = falphaimage(A,NA,varargin)
% FALPHAIMAGE Computes corresponding f(alpha) image from an input alpha image.
%             The function f(alpha) describes the global regularity.
%
%   F = falphaimage(A,NA) Estimates the f(alpha) image, F, of the input alpha 
%   image, A using a specific number of bins, NA. The parameter NA is a positve
%   integer which defines the discretization of A.
%
%   [F,fs] = falphaimage(A,NA) Estimates the f(alpha) image, F, and the f(alpha)
%   multifractal spectrum, fs. The output fs is a structure that contains
%   the spectrum, fs.spec, and the data corresponding to the alpha bins, fs.bins
%
%   [F,fs] = falphaimage(...,'ACTION') Estimates F and fs with 2 different actions.
%   The possible ACTION options that can be applied are 'norm', in order to normalize 
%   fs.spec within (0:2), or 'def' to avoid the normalization. 
%   If ACTION is not specified then the default value is ACTION = DEF.
%
%   Example
%
%       images_loc = which('alphaimage.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Segmentation','m213.pgm'));
%       x = ima2mat(x);
%       A = alphaimage(x,2,'neg');
%       [F,fs] = falphaimage(A,100);
%       figure; subplot(1,2,1); imagesc(F); title('f(alpha) image of A');
%       subplot(1,2,2); plot(fs.bins,fs.spec); title('multifractal spectrum');
%
%   See also alphaimage, spotted
%
%   References
%       [1] J. Lévy-Véhel, P. Mignot "Multifractal segmentation of images",
%           Fractals, Vol. 2, No. 3 (1994) 379-382.
%
%       [2] T. Stojic, I. Reljin, B. Reljin "Adaptation of multifractal analysis 
%           to segmentation of microcalcifications in digital mammograms", Physica A: 
%           Statistical Mechanics and its Applications, Vol. 367 (15), (2006) 494-508.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc falphaimage ">falphaimage</a>

% Author Tomislav Stojic, Irini Reljin, Branimir Reljin, University of Belgrade-Serbia, July 2004
% Modified by Christian Choque Cortez, September 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,3)
nargoutchk(1,3)

if nargin == 3
    if strcmp(varargin{1},'norm'), norm = 1; elseif strcmp(varargin{1},'def'), norm = 0; 
    else error('Invalid use of norm property'); end
else
    norm = 0;
end

%--------------------------------------------------------------------------
[m,n] = size(A);
Amin = min(A(:)); Amax = max(A(:));
bin_size = (NA - 1)/(Amax - Amin);

% Calculating alpha bins for f(alpha) spectrum
a = zeros(1,NA);
for i = 1:NA
  a(i) = (i-1)/bin_size + Amin;
end

nboxes = round(log2(min(m,n)))+2; % box dimensions
dimbp = ones(1,nboxes); % vector of box dimensions
bpovrp = ceil(m./dimbp); % vector of boxes of size 1 (pixel) per row
kon = 1; dimb(kon) = 1;

% covering boxes dimension calculation
for i = 2 : nboxes 
    dimbp(i) = 2*(i-1); % covering box dimension
    bpovrp(i) = ceil(m/dimbp(i)); % boxes of size dimbp(i) per row in image  
    if bpovrp(i) ~= bpovrp(i-1), kon = kon + 1; dimb(kon) = dimbp(i); end    
end 

nivo_rez = kon; % number of loops, i.e. resolution depth
bpovr = ones(1,nivo_rez); bpokol = bpovr; ukb = bpovr; Logdimb = bpovr;

for rez = 1 : nivo_rez 
    bpovr(rez) = ceil(m/dimb(rez)); % covering boxes per row, per resolution 
    bpokol(rez)= ceil(n/dimb(rez)); % covering boxes per column, per resolution
    ukb(rez) = bpovr(rez) * bpokol(rez); % covering boxes per image, per resolution
    Logdimb(rez) = log(1/dimb(rez)); % log(1/covering box dimension) for each resolution 
end 

Fp = zeros(NA,nivo_rez);
f = zeros (1,NA); % initialization of f(alpha) spectrum
F = zeros(m,n); % initialization of f(alpha) image

% matrix of alpha bins. At location (i,j) in this "image" corresponds to alpha bins,
% which alpha values at location (i,j) belongs to.   
ALFAind = floor(((A(1:m,1:n) - Amin)*bin_size) + 1);   

for rez = 1 : nivo_rez  
   Fpp = zeros(NA,ukb(rez)); % covering boxes per resolution 
   ii = ceil((1:m)/dimb(rez)) - 1; jj = ceil((1:n)/dimb(rez));
   for i = 1 : m
        for j = 1 : n
           rbb = ii(i) * bpovr(rez) + jj(j); % ordering number of current covering box 
           Fpp(ALFAind(i,j),rbb) = 1; % filling Fpp matrix  
        end
    end    
    for ALind = 1 : NA
        Fp(ALind,rez) = sum(Fpp(ALind,:)); % hit boxes per resolution
    end
end

% Y = zeros(1,nivo_rez);
for ALind = 1 : NA
    Y = Fp(ALind, :); % vector of covered boxes for given alpha bin
    Y(Y==0) = 1; % due logarithm
    LogY = log(Y);
    pom = my_polyfit(Logdimb,LogY); % linear regression, some speeded up
    f(ALind) = pom(1); % f =ln(hit boxes)/ln(1/box dimension)
end

d = find(abs(f) <= 0.00001); f(d) = 0; %#ok<FNDSB>

% optional normalization f(alpha) to [0 2]
if norm
    fmax = max(f); fmin = min(f);
    f = 2 * (f - fmin)/(fmax - fmin);
end

if nargout == 2, fs = struct('spec', f', 'bins', a'); end
% F(alpha) image forming
for i = 1 : m
     F(i,:) = f(ALFAind(i,1:n));
end

end
%--------------------------------------------------------------------------
function p = my_polyfit(x,y)
% Polynomial fitting, standard MatLab function accelerated by avoiding all unnecesary lines

x = x(:); y = y(:);

% Construct Vandermonde matrix.
V(:,1) = x; V(:,2) = ones(length(x),1);

% Solve least squares problem, and save the Cholesky factor.
[Q,R] = qr(V,0);
p = R\(Q'*y);    % Same as p = V\y;
p = p.';         % Polynomial coefficients are row vectors by convention.
end
