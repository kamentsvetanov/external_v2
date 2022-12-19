function [denx sigma] = mfdnorm2d(x,QMF,varargin)
% MFDNORM2D Performs the Multifractal Denoising of a 2D signal using a Multifractal
%           pumping method and multiplying the wavelets coefficients by a number Xj
%           in (0,1) constant by scales.
%
%   DENX = MFDNORM2D(X,QMF) Computes the denoised signal, DENX, of the input signal X
%   using a quadrature mirror filter QMF.
%
%   DENX = MFDNORM2D(...,'increase',R) Computes DENX with a specific regularity 
%   increase, R, which is a positive real.
%   If INCREASE is not specified, the default value is R = 0.5.
%
%   DENX = MFDNORM2D(...,'noise',SIGMA) Computes DENX with a specific noise standard
%   deviation, SIGMA, which is a positive real.
%   If NOISE is not specified, the default value is SIGMA = 0.5.
%
%   DENX = MFDNORM2D(...,'level',L) Computes DENX with a specific start level where
%   the computation begins. The parameter L is positive integer in 
%   (1+log2(max(size(X)))/2,log2(max(size(X))).
%   If LEVEL is not specified, the default value is L = 1+log2(max(size(X)))/2.
%
%   [DENX,SIGMA] = MFDNORM2D(...,'autonoise') Computes DENX using a estimated standard
%   deviation of the signal noise, SIGMA, this value is then returned. 
%   If AUTONOISE is not specified, the default value is SIGMA = 0.5.
%
%   Example
%
%       images_loc = which('mfdnorm2d.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Denoising','sar.tif'));
%       x = ima2mat(x);
%       QMF = MakeQMF('daubechies',4);
%       y = mfdnorm2d(x,QMF,'increase',1.7);
%       figure; subplot(1,2,1); imagesc(x); title('Input image'); axis image;
%       subplot(1,2,2); imagesc(y); title('Denoised image'); axis image;
%       colormap(gray);
%
%   See also mfdpumping2d, mfdnolinear2d, mfdbayesian2d, waveshrink2d, wavereg2d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mfdnorm2d ">mfdnorm2d</a>

% Author Pierrick Legrand, 2000
% Modified by Pierrick Legrand, January 2005
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,8);
nargoutchk(1,2);

[N1,N2] = size(x); N = max(N1,N2);

if nargin > 2
    arguments = varargin;
    list_noise = {'autonoise'};

    [noising,arguments] = checkforargument(arguments,list_noise,'user');
    [regularity,arguments] = checkforargument(arguments,'increase',0.5);
    [sigma,arguments] = checkforargument(arguments,'noise',0.5);
    [nlevel,arguments] = checkforargument(arguments,'level',round(log2(N)/2)+1);
    if strcmp(noising,'autonoise'), autonoise = 1; else autonoise = 0; end
    if ~(isnumeric(regularity) && isscalar(regularity) && regularity >= 0), ...
            error('Invalid use of increase property'); end
    if ~(isnumeric(sigma) && isscalar(sigma) && sigma >= 0), error('Invalid use of noise property'); end
    if ~(isnumeric(nlevel) && isscalar(nlevel)), error('Invalid use of level property'); end
    if ~(nlevel > round(log2(N)/2) && nlevel <= floor(log2(N))), error('Invalid use of level property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regularity = 0.5; sigma = 0.5; nlevel = round(log2(N)/2)+1; autonoise = 0;
end

%--------------------------------------------------------------------------
nn = floor(log2(N));
[wt,wti,wtl] = FWT2D(x,nn,QMF);
if autonoise, sigma = (median(abs(wt(wti(1):(wti(1)+wtl(1)-1)))))/0.6745; end

energie = zeros(1,nn-nlevel+1);
for sc = 1:nn-nlevel+1
    for j = 1:3
        energie(sc) = energie(sc) + (wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)))*(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)))';
    end
end
energie = energie(end:-1:1);

o = (1:nn) - (nn+1)/2;
o = o(nlevel:nn);
ot = sum(o);
k = 12/(nn^3-nn);

xm = ones(1,nlevel-1); % raz des multiplicateurs

% la fonction a minimiser depend du rapport des energies par niveau sur les o(j)
r = zeros(1,nn-nlevel+1); a = r; fr = r;
for j = 1:nn-nlevel+1
   r(j) = (energie(j)-2^(1-j)*sigma^2)/o(j);
   a(j) = (energie(j)-2^(1-j)*sigma^2)/(energie(j));
   fr(j) = r(j)*a(j);
end

rm = min(fr);
dl = regularity/k;

m2 = ones(nlevel,nlevel-1);
for j = 1:nlevel-1
    m2(j+1,1:j) = -1*ones(1,j);
end

oldopt= optimset('display','final','LargeScale','on', ...
   'TolX',1e-10,'TolFun',1e-10,'DerivativeCheck','off',...
   'Jacobian','off','MaxFunEvals','100*numberOfVariables',...
   'Diagnostics','off',...
   'DiffMaxChange',1e-1,'DiffMinChange',1e-8,...
   'PrecondBandWidth',0,'TypicalX','ones(numberOfVariables,1)','MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
   'TolPCG',0.1,'MaxIter',400,'JacobPattern',[]);%, ...
   %'LineSearchType','quadcubic','LevenbergMarq','off');

options = optimset(oldopt,'Display','off');

eps1 = ones(1,nn-nlevel+1)*Inf;
v = zeros(1,nn-nlevel+1);
mu = inf; mu1 = inf; %#ok<NASGU>
for s = 1:nn-nlevel+1
    [mu,fval,exitflag]=fsolve('lagr10',1^(-10),options,m2,s,nn-nlevel+1,nn,r,dl,ot,o,a);
    if exitflag > 0 && (mu/rm)-1 < 0 && mu > 0
        v(s) = real(mu);
        eps2 = 0;
        for j = 1:nn-nlevel+1
            xm(j) = real((1+m2(s,j)*sqrt(1-mu/(a(j)*r(j))))/2);
            eps2 = real(eps2+(energie(j)-2^(1-j)*sigma^2)*(1-xm(j))^2);
        end
        eps1(s) = eps2;
    end
end
[y,b] = min(eps1);
mu1 = v(b);

% calcul des Xj a partir de mu1
for j = 1:nn-nlevel+1
    xm(j) = real((1+m2(b,j)*sqrt(1-mu1/(a(j)*r(j)))))/2;
end

if min(eps1)==inf && regularity~=0, xm(:)=0; end %blindage

wtout=wt;
for sc = 1:nn-nlevel+1
    for j=1:3
        wtout(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)) = ...
            thepump(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)),xm(sc));
    end
end

out = IWT2D(wtout); % calling the mex-file
denx = out(1:N1,1:N2);
end
%--------------------------------------------------------------------------
function out = thepump(in,s)
out=in*s;
end