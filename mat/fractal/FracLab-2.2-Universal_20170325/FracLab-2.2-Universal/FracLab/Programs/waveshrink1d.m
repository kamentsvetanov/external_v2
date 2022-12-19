function [denx trshold] = waveshrink1d(x,QMF,varargin)
% WAVESHRINK1D Performs the Denoising of a 1D signal using a Wavelet Shrinkage method
%
%   DENX = WAVESHRINK1D(X,QMF) Computes the denoised signal, DENX, of the input
%   signal X using a quadrature mirror filter QMF.
%
%   DENX = WAVESHRINK1D(...,'threshold',R) Computes DENX with a specific
%   threshold parameter, R, which is a positive real.
%   If THRESHOLD is not specified, the default value is R = 0.5.
%
%   DENX = WAVESHRINK1D(...,'THRESHOLDING') Computes DENX using a specific
%   kind of thresholding. The available methods are 'soft' in order to apply a 
%   soft thresholding and 'hard' in orde to apply a hard thresholding.
%   If THRESHOLDING is not specified, the default value is THRESHOLDING = SOFT.
%
%   DENX = WAVESHRINK1D(...,'level',L) Computes DENX with a specific start
%   level where the computation begins. The parameter L is positive integer
%   in (1,log2(length(X)).
%   If LEVEL is not specified, the default value is L = log2(length(X))/2.
%
%   [DENX,S] = WAVESHRINK1D(...,'autothreshold') Computes DENX using a
%   estimated threshold value, S, this value is then returned. 
%   If AUTOTHRESHOLD is not specified, the default value is S = 0.5.
%
%   Example
%
%       N = 1024 ; H = 0.5 ; t = linspace(0,1,N);
%       x = fbmwoodchan(N,H); b = randn(N,1);
%       xb = x + b/8;
%       QMF = MakeQMF('daubechies',4);
%       y = waveshrink1d(x,QMF,'threshold',0.1);
%       figure; plot(t,xb); hold on; plot(t,x,'r');
%       title ('Wavelet shrinkage denoising'); 
%       xlabel ('time'); legend('Noised Signal','Signal');
%       figure; plot(t,y); hold on; plot(t,x,'r');
%       title ('Wavelet shrinkage denoising');  
%       xlabel ('time'); legend('Denoised Signal','Signal');
%
%   See also mfdpumping1d, mfdnolinear1d, mfdnorm1d, mfdbayesian1d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc waveshrink1d ">waveshrink1d</a>

% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,7);
nargoutchk(1,2);

N = length(x);
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
[wt,wti,wtl] = FWT(x,nn,QMF);

wtout = wt;
if autotrshold
    sigma = (median(abs(wt(wti(1):(wti(1)+wtl(1)-1)))))/0.6745;
    trshold = sigma * 2^(-nn/2) * sqrt(2*nn);
end

for sc = 1:nn-nlevel+1,
    wtout(wti(sc):(wti(sc)+wtl(sc)-1)) = ...
        theshrink(wt(wti(sc):(wti(sc)+wtl(sc)-1)),trshold,thresholding{:});
end

out = IWT(wtout); % calling the mex-file
denx = out(1:N);
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