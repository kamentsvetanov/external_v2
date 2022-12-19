function denx = mfdbayesian2d(x,QMF,varargin)
% MFDBAYESIAN2D Performs the Multifractal Denoising of a 2D signal using a 
%               Multifractal Bayesian method
%
%   DENX = MFDBAYESIAN2D(X,QMF) Computes the denoised signal, DENX, of the
%   input signal X using a quadrature mirror filter QMF.
%
%   DENX = MFDBAYESIAN2D(...,'increase',R) Computes DENX with a specific
%   minimal regularity increase, R, which is a positive real.
%   If INCREASE is not specified, the default value is R = 0.5.
%
%   DENX = MFDBAYESIAN2D(...,'level',L) Computes DENX with a specific start
%   level where the computation begins. The parameter L is positive integer
%   in (1,log2(max(size(X))).
%   If LEVEL is not specified, the default value is L = log2(max(size(X)))/2.
%
%   Example
%
%       images_loc = which('mfdbayesian2d.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Denoising','sar.tif'));
%       x = ima2mat(x);
%       QMF = MakeQMF('daubechies',4);
%       y = mfdbayesian2d(x,QMF,'increase',0.7);
%       figure; subplot(1,2,1); imagesc(x); title('Input image'); axis image;
%       subplot(1,2,2); imagesc(y); title('Denoised image'); axis image;
%       colormap(gray);
%
%   See also mfdpumping2d, mfdnolinear2d, mfdnorm2d, waveshrink2d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mfdbayesian2d ">mfdbayesian2d</a>

% Author: Pierrick Legrand 2002
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,6);
nargoutchk(1,1);

[N1,N2] = size(x); N = max(N1,N2);
if nargin > 2
    arguments = varargin;

    [regularity,arguments] = checkforargument(arguments,'increase',0.5);
    [nlevel,arguments] = checkforargument(arguments,'level',floor(log2(N)/2));
    if ~(isnumeric(regularity) && isscalar(regularity)), error('Invalid use of increase property'); end
    if regularity < 0, error('Invalid use of increase property'); end
    if ~(isnumeric(nlevel) && isscalar(nlevel)), error('Invalid use of level property'); end
    if ~(nlevel >= 1 && nlevel <= floor(log2(N))), error('Invalid use of level property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regularity = 0.5; nlevel = floor(log2(N)/2);
end

%--------------------------------------------------------------------------
nn = floor(log2(N));
[wt,wti,wtl] = FWT2D(x,nn,QMF);
wtout = wt;

% find the Kj
Kmax = zeros(1,nn-nlevel+1); K = Kmax;
for sc = 1:nn-nlevel+1
    for j = 1:3
        Kmax(j) = max(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)));
    end
    K(sc) = max(Kmax);
end
k = max(K);

for sc = 1:nn-nlevel+1
    for j = 1:3
        wtout(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)) = ...
            thebayes(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)),2.^(-regularity*(nn-sc+1)),k);
    end
end

out = IWT2D(wtout); % calling the mex-file
denx = out(1:N1,1:N2);
end
%--------------------------------------------------------------------------
function out = thebayes(in,s,k)
tmp = abs(in);
signe = sign(in);
out = max(tmp.*((tmp/k) < s),k*s*((tmp/k) >= s));
out = signe.*out;
end