function [denx trshold] = waveshrink2d(x,QMF,varargin)
% WAVESHRINK2D Performs the Denoising of a 2D signal using a Wavelet Shrinkage method
%
%   DENX = WAVESHRINK2D(X,QMF) Computes the denoised signal, DENX, of the input
%   signal X using a quadrature mirror filter QMF.
%
%   DENX = WAVESHRINK2D(...,'threshold',S) Computes DENX with a specific
%   threshold parameter, S, which is a positive real.
%   If THRESHOLD is not specified, the default value is R = 0.5.
%
%   DENX = WAVESHRINK2D(...,'THRESHOLDING') Computes DENX using a specific
%   kind of thresholding. The available methods are 'soft' in order to apply a 
%   soft thresholding and 'hard' in orde to apply a hard thresholding.
%   If THRESHOLDING is not specified, the default value is THRESHOLDING = SOFT.
%
%   DENX = WAVESHRINK2D(...,'level',L) Computes DENX with a specific start
%   level where the computation begins. The parameter L is positive integer
%   in (1,log2(max(size(X))).
%   If LEVEL is not specified, the default value is L = log2(max(size(X)))/2.
%
%   [DENX,S] = WAVESHRINK2D(...,'autothreshold') Computes DENX using a
%   estimated threshold value, S, this value is then returned. 
%   If AUTOTHRESHOLD is not specified, the default value is S = 0.5.
%
%   Example
%
%       images_loc = which('waveshrink2d.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Denoising','sar.tif'));
%       x = ima2mat(x);
%       QMF = MakeQMF('daubechies',4);
%       y = waveshrink2d(x,QMF,'threshold',0.3);
%       figure; subplot(1,2,1); imagesc(x); title('Input image'); axis image;
%       subplot(1,2,2); imagesc(y); title('Denoised image'); axis image;
%       colormap(gray); 
%
%   See also mfdpumping2d, mfdnolinear2d, mfdnorm2d, mfdbayesian2d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc waveshrink2d ">waveshrink2d</a>

% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,7);
nargoutchk(1,2);

[N1,N2] = size(x); N = max(N1,N2);
if nargin > 2
    arguments = varargin;
    list_thres = {'soft','hard'};
    list_auto = {'autothreshold'};
    
    [thresh,arguments] = checkforargument(arguments,list_auto,'user');
    [thresholding,arguments] = checkforargument(arguments,list_thres,'soft');
    [trshold,arguments] = checkforargument(arguments,'threshold',0.5);
    [nlevel,arguments] = checkforargument(arguments,'level',floor(log2(N)/2));
    if strcmp(thresh,'autothreshold'), autotrshold = 1; else autotrshold = 0; end
    if ~(isnumeric(trshold) && isscalar(trshold) && trshold >= 0), ...
            error('Invalid use of theshold property'); end
    if ~(isnumeric(nlevel) && isscalar(nlevel)), error('Invalid use of level property'); end
    if ~(nlevel >= 1 && nlevel <= floor(log2(N))), error('Invalid use of level property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    thresholding = {'soft'}; trshold = 0.5; nlevel = floor(log2(N)/2); autotrshold = 0;
end

%--------------------------------------------------------------------------
nn = floor(log2(N));
[wt,wti,wtl] = FWT2D(x,nn,QMF);

wtout = wt;
if autotrshold
    sigma = (median(abs(wt(wti(1):(wti(1)+wtl(1)-1)))))/0.6745;
    trshold = sigma * 2^(-nn/2) * sqrt(2*nn);
end

for sc = 1:nn-nlevel+1
    for j = 1:3
        wtout(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)) = ...
            theshrink(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)),trshold,thresholding{:});
    end
end

out = IWT2D(wtout); % calling the mex-file
denx = out(1:N1,1:N2);
end
%--------------------------------------------------------------------------
function out = theshrink(in,s,method)
if strcmp(method,'soft')
    tmp = abs(in) - s;
	out = tmp .* sign(in) .* (tmp>0);
else
    tmp = abs(in);
	out = tmp .* sign(in) .* (tmp>s);   
end
end