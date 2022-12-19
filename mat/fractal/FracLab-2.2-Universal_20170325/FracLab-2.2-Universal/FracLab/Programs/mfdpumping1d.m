function denx = mfdpumping1d(x,QMF,varargin)
% MDFPUMPING1D Performs the Multifractal Denoising of a 1D signal using a 
%              Multifractal Pumping method
%
%   DENX = MDFPUMPING1D(X,QMF) Computes the denoised signal, DENX, of the input
%   signal X using a quadrature mirror filter QMF.
%
%   DENX = MDFPUMPING1D(...,'increase',R) Computes DENX with a specific
%   regularity increase, R, which is a real number. If R is negative the
%   signal is actually "noised".
%   If INCREASE is not specified, the default value is R = 0.5.
%
%   DENX = MDFPUMPING1D(...,'level',L) Computes DENX with a specific start
%   level where the computation begins. The parameter L is positive integer
%   in (1,log2(length(X)).
%   If LEVEL is not specified, the default value is L = log2(length(X))/2.
%
%   Example
%
%       N = 1024 ; H = 0.5 ; t = linspace(0,1,N);
%       x = fbmwoodchan(N,H); b = randn(N,1);
%       xb = x + b/8;
%       QMF = MakeQMF('daubechies',4);
%       y = mfdpumping1d(xb,QMF,'increase',0.3);
%       figure; plot(t,xb); hold on; plot(t,x,'r');
%       xlabel ('time'); legend('Noised Signal','Signal');
%       figure; plot(t,y); hold on; plot(t,x,'r');
%       title ('Multifractal pumping denoising'); 
%       xlabel ('time'); legend('Denoised Signal','Signal');
%
%   See also mfdnolinear1d, mfdnorm1d, mfdbayesian1d, waveshrink1d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mfdpumping1d ">mfdpumping1d</a>

% Author: Pierrick Legrand 2004
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,6);
nargoutchk(1,1);

N = length(x);
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
[wt,wti,wtl] = FWT(x,nn,QMF);
wtout = wt;

for sc = 1:nn-nlevel+1
	wtout(wti(sc):(wti(sc)+wtl(sc)-1)) = ...
        thepump(wt(wti(sc):(wti(sc)+wtl(sc)-1)), 2.^(-regularity*(nn-sc+1)));
end

out = IWT(wtout); % calling the mex-file
denx = out(1:N);
end
%--------------------------------------------------------------------------
function out = thepump(in,s)
out=in*s;
end