function denx = mfdpumping2d(x,QMF,varargin)
% MDFPUMPING2D Performs the Multifractal Denoising of a 2D signal using a 
%              Multifractal Pumping method
%
%   DENX = MDFPUMPING2D(X,QMF) Computes the denoised signal, DENX, of the input
%   signal X using a quadrature mirror filter QMF.
%
%   DENX = MDFPUMPING2D(...,'increase',R) Computes DENX with a specific
%   regularity increase, R, which is a real number. If R is negative the
%   signal is actually "noised".
%   If INCREASE is not specified, the default value is R = 0.5.
%
%   DENX = MDFPUMPING2D(...,'level',L) Computes DENX with a specific start
%   level where the computation begins. The parameter L is positive integer
%   in (1,log2(max(size(X)))).
%   If LEVEL is not specified, the default value is L = log2(max(size(X)))/2.
%
%   Example
%
%       images_loc = which('mfdpumping2d.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Denoising','sar.tif'));
%       x = ima2mat(x);
%       QMF = MakeQMF('daubechies',4);
%       y = mfdpumping2d(x,QMF);
%       figure; subplot(1,2,1); imagesc(x); title('Input image'); axis image;
%       subplot(1,2,2); imagesc(y); title('Denoised image'); axis image;
%       colormap(gray);
%
%   See also mfdnolinear2d, mfdnorm2d, mfdbayesian2d, waveshrink2d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mfdpumping2d ">mfdpumping2d</a>

% Author: Pierrick Legrand 2004
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
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

for sc = 1:nn-nlevel+1
    for j = 1:3
        wtout(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)) = ...
            thepump(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) ), 2.^(-regularity*(nn-sc+1)));
    end
end

out = IWT2D(wtout); % calling the mex-file
denx = out(1:N1,1:N2);
end
%--------------------------------------------------------------------------
function out = thepump(in,s)
out=in.*s;
end