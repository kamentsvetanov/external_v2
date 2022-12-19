function regx = wavereg2d(x,QMF,varargin)
% WAVEREG2D Performs the Multifractal Regularization of a 2D signal using a Multifractal
%           pumping method and multiplying the wavelets coefficients by a number Xj
%           in (0,1) constant by scales.
%
%   REGX = WAVEREG2D(X,QMF) Performs the regularization, REGX, of the input signal X
%   using a quadrature mirror filter QMF.
%
%   REGX = WAVEREG2D(...,'increase',R) Computes REGX with a specific regularity 
%   increase, R, which is a real number. If R is negative the signal is actually "noised"
%   If INCREASE is not specified, the default value is R = 0.5.
%
%   REGX = WAVEREG2D(...,'level',L) Computes REGX with a specific start level where
%   the computation begins. The parameter L is positive integer in 
%   (1+log2(max(size(X)))/2,log2(max(size(X))).
%   If LEVEL is not specified, the default value is L = 1+log2(max(size(X)))/2.
%
%   REGX = WAVEREG2D(...,'NORM') Computes REGX with NORM options. The possible NORM
%   options that can be applied are 'L2' in order to perform the computation with
%   an L2 normalization or 'kullback' in order to perform the computation with an
%   Kullback normalization, in tis case the level parameter is on (1,log2(max(size(X))-1).
%   If NORM is not specified, the default value is NORM = L2.
%
%   Example
%
%       images_loc = which('wavereg2d.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Denoising','sar.tif'));
%       x = ima2mat(x);
%       QMF = MakeQMF('daubechies',4);
%       y = wavereg2d(x,QMF,'increase',0.4);
%       figure; subplot(1,2,1); imagesc(x); title ('Input image'); axis image;
%       subplot(1,2,2); imagesc(y); title('Regularized image'); axis image;
%       colormap(gray); 
%
%   See also mfdnorm2d
%
% Reference page in Help browser
%     <a href="matlab:fl_doc wavereg2d ">wavereg2d</a>

% Author Pierrick Legrand, 2000
% Modified by Pierrick Legrand, January 2005
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,7);
nargoutchk(1,1);

[N1,N2] = size(x); N = max(N1,N2);
if nargin > 2
    arguments = varargin;
    list_norm = {'L2','kullback'};
    
    [normparam, arguments] = checkforargument(arguments,list_norm,'L2');
    [regularity,arguments] = checkforargument(arguments,'increase',0.5);
    [nlevel,arguments] = checkforargument(arguments,'level',round(log2(N)/2)+1);
    if strcmp(normparam{:},'L2'), L2 = 1; else L2 = 0; end
    if ~(isnumeric(regularity) && isscalar(regularity)), error('Invalid use of increase property'); end
    if ~(isnumeric(nlevel) && isscalar(nlevel)), error('Invalid use of level property'); end
    if L2
        if ~(nlevel > round(log2(N)/2) && nlevel <= floor(log2(N))), error('Invalid use of level property'); end
    else
        if ~(nlevel >= 0 && nlevel < floor(log2(N))), error('Invalid use of level property'); end
    end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regularity = 0.5; nlevel = round(log2(N)/2)+1; L2 = 1;
end

%--------------------------------------------------------------------------
nn = floor(log2(N));
[wt,wti,wtl] = FWT2D(x,nn,QMF);
k = 12/(nn^3-nn);

if ~L2  
    regularity = regularity/5;
    o = zeros(1,nn-nlevel);
    rap = zeros(1,nn-nlevel);
    for j = 1:nn-nlevel
        o(j) = j+nlevel-(nn+1)/2;
        rap(j) = (j+nlevel-(nn+1)/2)^2/(2^(j+nlevel));
    end;
    somme=sum(rap);

    xm=ones(1,nn-nlevel); % raz des multiplicateurs

    % calcul des Xj
    for j = 1:nn-nlevel
        xm(j) = 2^(-regularity*o(j)/(k*2^(j+nlevel)*somme));
    end
    xm2 = xm(end:-1:1);

    wtout = wt;
    for sc = 1:nn-nlevel
        for j=1:3
            wtout(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)) = ...
                thepump(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)),xm2(sc));
        end
    end
else
    energie = zeros(1,nn-nlevel+1);
    for sc = 1:nn-nlevel+1
        for j=1:3
            energie(sc) = energie(sc) + (wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1))) ...
                                        *(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)))';
        end
    end
    energie = energie(end:-1:1);

    o = (1:nn) - (nn+1)/2;
    o = o(nlevel:nn);
    ot = sum(o);

    xm = ones(1,nn-nlevel+1); % raz des multiplicateurs

    % la fonction a minimiser depend du rapport des energies par niveau sur les o(j)
    r = zeros(1,nn-nlevel+1);
    for j = 1:nn-nlevel+1
        r(j) = energie(j)/o(j);
    end

    rm = min(r);
    dl = regularity/k;

    m2 = ones(nlevel,nlevel-1);
    for j = 1:nlevel-1
        m2(j+1,1:j) = -1*ones(1,j);
    end

    oldopt= optimset('display','final','Algorithm','trust-region-reflective', ...
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
        [mu,fval,exitflag] = fsolve('lagr3',1^(-10),options,m2,s,nn-nlevel+1,nn,r,dl,ot,o);
        if exitflag > 0 && (mu/rm)-1 < 0 && mu > 0
            v(s) = real(mu);
            eps2 = 0;
            for j = 1:nn-nlevel+1
                xm(j) = real((1+m2(s,j)*sqrt(1-mu/r(j)))/2);
                eps2 = real(eps2+energie(j)*(1-xm(j))^2);
            end
            eps1(s) = eps2;
        end
    end
    [y,b] = min(eps1);
    mu1 = v(b);

    % calcul des Xj a partir de mu1
    for j = 1:nn-nlevel+1
        xm(j) = real((1+m2(b,j)*sqrt(1-mu1/r(j))))/2;
    end

    if min(eps1)==inf && regularity~=0, xm(:)=0; end %blindage

    wtout=wt;
    for sc = 1:nn-nlevel+1
        for j=1:3
            wtout(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)) = ...
                thepump(wt(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)),xm(sc));
        end
    end
end

out = IWT2D(wtout); % calling the mex-file
regx = out(1:N1,1:N2);
end
%--------------------------------------------------------------------------
function out = thepump(in,s)
out=in*s;
end