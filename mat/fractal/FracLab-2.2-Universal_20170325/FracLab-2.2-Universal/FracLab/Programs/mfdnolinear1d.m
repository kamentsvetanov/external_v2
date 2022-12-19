function [denx trshold] = mfdnolinear1d(x,QMF,varargin)
% MFDNOLINEAR1D Performs the Multifractal Denoising of a 1D signal using a 
%               Multifractal Non Linear method
%
%   DENX = MFDNOLINEAR1D(X,QMF) Computes the denoised signal, DENX, of the input
%   signal X using a quadrature mirror filter QMF.
%
%   DENX = MFDNOLINEAR1D(...,'increase',R) Computes DENX with a specific
%   regularity increase, R, which is a real number. If R is negative the signal
%   is actually "noised".
%   If INCREASE is not specified, the default value is R = 0.5.
%
%   DENX = MFDNOLINEAR1D(...,'threshold',S) Computes DENX with a specific threshold
%   parameter, S, which is a positive real.
%   If THRESHOLD is not specified, the default value is S = 0.5.
%
%   DENX = MFDNOLINEAR1D(...,'level',L) Computes DENX with a specific start
%   level where the computation begins. The parameter L is positive integer
%   in (1,log2(length(X)).
%   If LEVEL is not specified, the default value is L = log2(length(X))/2.
%
%   [DENX,S] = MFDNOLINEAR1D(...,'autothreshold') Computes DENX using a
%   estimated threshold value, S, this value is then returned. 
%   If AUTOTHRESHOLD is not specified, the default value is S = 0.5.
%
%   Example
%
%       N = 1024 ; H = 0.5 ; t = linspace(0,1,N);
%       x = fbmwoodchan(N,H); b = randn(N,1);
%       xb = x + b/8;
%       QMF = MakeQMF('daubechies',4);
%       y = mfdnolinear1d(xb,QMF,'increase',0.3);
%       figure; plot(t,xb); hold on; plot(t,x,'r');
%       title ('Multifractal non linear denoising'); 
%       xlabel ('time'); legend('Noised Signal','Signal');
%       figure; plot(t,y); hold on; plot(t,x,'r');
%       title ('Multifractal non linear denoising'); 
%       xlabel ('time'); legend('Denoised Signal','Signal');
%
%   See also mfdpumping1d, mfdnorm1d, mfdbayesian1d, waveshrink1d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mfdnolinear1d ">mfdnolinear1d</a>

% Author: Pierrick Legrand 2004
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,8);
nargoutchk(1,2);

N = length(x);

if nargin > 2
    arguments = varargin;
    list_thres = {'autothreshold'};
    
    [thresholding,arguments] = checkforargument(arguments,list_thres,'user');
    [regularity,arguments] = checkforargument(arguments,'increase',0.5);
    [trshold,arguments] = checkforargument(arguments,'threshold',0.5);
    [nlevel,arguments] = checkforargument(arguments,'level',floor(log2(N)/2));
    if strcmp(thresholding,'autothreshold'), autotrshold = 1; else autotrshold = 0; end
    if ~(isnumeric(regularity) && isscalar(regularity)), error('Invalid use of increase property'); end
    if ~(isnumeric(trshold) && isscalar(trshold) && trshold > 0), error('Invalid use of threshold property'); end
    if ~(isnumeric(nlevel) && isscalar(nlevel)), error('Invalid use of level property'); end
    if ~(nlevel >= 1 && nlevel <= floor(log2(N))), error('Invalid use of level property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regularity = 0.5; trshold = 0.5; nlevel = floor(log2(N)/2); autotrshold = 0;
end

%--------------------------------------------------------------------------
nn = floor(log2(N));
[wt,wti,wtl] = FWT(x,nn,QMF);

wtout = wt;
if autotrshold
    sigma = (median(abs(wt(wti(1):(wti(1)+wtl(1)-1)))))/0.6745;
    trshold = sigma*2^(-nn/2)*sqrt(2*nn);
end

for sc = 1:nn-nlevel,
	wtout(wti(sc):(wti(sc)+wtl(sc)-1)) = ...
        thepump(wt(wti(sc):(wti(sc)+wtl(sc)-1)),2.^(-regularity*(nn-sc+1)),trshold);
end

out = IWT(wtout); % calling the mex-file
denx = out(1:N);
end
%--------------------------------------------------------------------------
function out = thepump(in,s,threshold)
out = in.*((abs(in) > threshold) + (abs(in) < threshold).*s);
end