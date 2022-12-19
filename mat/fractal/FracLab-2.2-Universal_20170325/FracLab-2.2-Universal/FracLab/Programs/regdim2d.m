function zz = regdim2d(x,bounds,voices,varargin)
% REGDIM2D Estimates the regularization dimension of a 2D signal
%
%   REGDIM = REGDIM2D(X,BOUNDS,VOICES) Estimates the regularization dimension, REGDIM, 
%   of the input signal X using a Gaussian kernel and least square regression. 
%   The vector BOUNDS represents the minimum and maximum standard deviations 
%   (in number of samples) for the smoothing kernel. The parameter VOICES is 
%   the number of intermediate sizes for the standard deviation, or more generally
%   the width of the kernel, between the smallest and largest ones.
%   A figure is displayed showing the value of REGDIM at the top of the figure.
%
%   REGDIM = REGDIM2D(...,'REGPARAM') Estimates REGDIM using a specific type 
%   of regression, REGPARAM. 
%   If REGPARAM is not specified, the default value is REGPARAM = LS.
%
%   REGDIM = REGDIM2D(...,'KERNEL') Estimates REGDIM using a specific type of 
%   smoothing kernel, KERNEL. The possible KERNEL that are available are 'gauss'
%   in order to use a Gaussian kernel, 'rect' in order to use a rectangle kernel. 
%   If KERNEL is not specified, the default value is KERNEL = GAUSS.
%
%   REGDIM = REGDIM2D(...,'noise',STD) Estimates REGDIM when the data are contaminated
%   with an additive white Gaussian noise whose standard deviation is known and
%   is given by STD. The algorithm takes into account the noise in the estimating
%   REGDIM. The parameter STD is a positive real.
%   If NOISE is not specified, the default value is STD = 0.
%
%   ZZ = REGDIM2D(...) Estimates REGDIM and displays a figure showing the
%   regularized graphs, ZZ.
%
%   Example
%
%       N = 512; H = 0.5;
%       x = synth2(N,H);
%       regdim2d(x,[5,64],16);
%
%   See also cwttrack, cwtspec
%
%   References
%
%      [1] F. Roueff, J. Lévy-Véhel, "A regularization approach to fractional dimension estimation",
%          Fractals 98, (1998).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc regdim2d ">regdim2d</a>

% Author François Roueff, March 1998
% Modified by Christian Choque Cortez, March 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global alpha
alpha=3;
narginchk(3,8);
nargoutchk(0,1);

if min(size(x)) == 1, error('The input signal must be a matrix'); end
if ~(size(bounds,1) == 1 && size(bounds,2) == 2), error('Invalid bounds input vector'); end
if ~isnumeric(voices), error('Invalid voices input value'); end
if nargout, graphs = 1; else graphs = 0; end
if nargin > 3
    arguments = varargin;
    list_reg1 = {'wls','pls','lapls'};
    list_reg2 = {'ls','lsup','linf','ml'};
    list1 = {'gauss','rect'};

    [regparam,arguments] = checkforargument(arguments,list_reg1,'ls','wo');
    if strcmp(regparam{1},'ls')
        [regparam,arguments] = checkforargument(arguments,list_reg2,'ls');
    end
    [kernel,arguments] = checkforargument(arguments,list1,'gauss');
    [sigma,arguments] = checkforargument(arguments,'noise',0);

    if ~isnumeric(sigma), error('Invalid use of noise property'); end
    if (strcmp(regparam{1},'pls') || strcmp(regparam{1},'wls') || strcmp(regparam{1},'lapls')) && length(regparam) ~= 2,
        error('Invalid use of reparam property'); end
    if strcmp(regparam{1},'pls') && (~isnumeric(regparam{2}) || ~isscalar(regparam{2}) || regparam{2} < 2),
        error('The number of iterations must be a scalar > 2'); end
    if strcmp(regparam{1},'wls') && (~isnumeric(regparam{2}) || length(regparam{2})~=voices),
        error(['Weights vector must have ',num2str(voices),' elements']); end
    if strcmp(regparam{1},'lapls') && (~isnumeric(regparam{2}) || length(regparam{2})~=voices),
        error(['Sequence of variances vector must have ',num2str(voices),' elements']); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regparam = {'ls'}; kernel = {'gauss'}; sigma = 0;
end

%--------------------------------------------------------------------------
[N,P]=size(x);
Nmin = bounds(1); Nmax = bounds(2);
handlefig=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vector of kernel sizes: iv
%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(voices) == 1
    jmax = voices;
    iv = round(logspace(log10(Nmin),log10(Nmax),jmax));
else
    iv = round(voices);
end
imax = max(iv);
K = find(diff(iv));
iv = [iv(K),imax]; %#ok<FNDSB>
jmax = length(iv);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% prolongation by a constant
%%%%%%%%%%%%%%%%%%%%%%%%%%
x = [x(:,ones(1,floor(imax/2))),x,x(:,ones(1,floor(imax/2))*N)];
x = [x(ones(1,floor(imax/2)),:);x;x(ones(1,floor(imax/2))*P,:)]; %#ok<NASGU>

%%%%%%%%%%%%%%%%%%
%a:scale
%%%%%%%%%%%%%%%%%
a = []; L = []; Lnoisy = []; R = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot regularized graphs if wanted %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_waitbar = fl_waitbar('init');
if graphs
    zz = cell(jmax,1);
    figure
    handlefig = [handlefig gcf];
    hold on
    for j = 1:jmax
        fl_waitbar('view',h_waitbar,j,2*jmax);
        eval(['[z1,a(j)]=' kernel{:} '2dconv(x,iv(j));']);
        z1 = z1(floor(iv(j)/2)+1+floor(imax/2):N+floor(iv(j)/2)+floor(imax/2),...
            floor(iv(j)/2)+1+floor(imax/2):P+floor(iv(j)/2)+floor(imax/2));
        zz{j} = z1;
        contour(z1);
    end
    title('Regularized graphs');
    hold off
end

for j = 1:jmax
    fl_waitbar('view',h_waitbar,j+jmax,2*jmax);
    eval(['[dzx,dzy,a(j)]=' kernel{:} '2dprimconv(x,iv(j));']);
    dzx = dzx(floor(iv(j)/2)+1+floor(imax/2):N+floor(iv(j)/2)+floor(imax/2),...
        floor(iv(j)/2)+1+floor(imax/2):P+floor(iv(j)/2)+floor(imax/2));
    dzy = dzy(floor(iv(j)/2)+1+floor(imax/2):N+floor(iv(j)/2)+floor(imax/2),...
        floor(iv(j)/2)+1+floor(imax/2):P+floor(iv(j)/2)+floor(imax/2));
    dlx = abs(dzx);
    dly = abs(dzy);
    dl = dlx+dly;
    if isempty(dl)
        break;
    end
    if sigma >0
        Lnoisy(j) = mean(mean(dl)); %#ok<AGROW>
        eval(['[dz,a(j)]=' kernel{:} '2dconv1(dzx,dzy,iv(j));']);
        dl = abs(dz);
        LRT = mean(mean(dl));
        %%%%%%%%%%%%%
        % signal/noise component rate
        %%%%%%%%%%%%
        s = sigma/sqrt(sqrt(2*pi)*a(j)^3);
        dln = 2*s/sqrt(pi).*exp(-(dl.^2)./s^2);
        dlsb = dl-dln;
        R(j) = mean(mean(dln))/LRT; %#ok<AGROW>
        L(j) = mean(mean(dlsb))*Lnoisy(j)/LRT; %#ok<AGROW>
    else
        L(j) = mean(mean(dl))+max([N,P])^(-2); %#ok<AGROW>
    end
end

[dim, newhfig] = reg_dimR(a,L,R,2,sigma,handlefig,2,regparam{:}); %#ok<NASGU>

fl_waitbar('close',h_waitbar);
end
%--------------------------------------------------------------------------
function g = gauss2d(n,a)
% GAUSS2D      GAUSS2D(N,A) returns the NxN-point Gauss 2d-window.
%            a corresponds to an attenuation of 10^(-a) at the end of the
%            Gauss window
% Input:     -N number of points in one direction
%            -a dB attenuation. Default value is a = 2.
% Output:    -g time samples of the Gauss window

if nargin == 1, a = 2; end
t = (-(n-1)/2:(n-1)/2);
tt = flipud(t');
t2 = t(ones(1,n),:)+i*tt(:,ones(1,n));
g = exp(-(a*log(10)/((n-1)/2)^2)*abs(t2).^2);
end
%--------------------------------------------------------------------------
function [z,a] = gauss2dconv(x,iv) %#ok<DEFNU>
global alpha;
i = round(iv);
y = gauss2d(i,alpha);
a = (iv-1.0)/(2.0*sqrt(alpha*log(10)));
z = conv2(x,y);
Norm = (a*sqrt(pi))^2;
z = z/Norm;
end
%--------------------------------------------------------------------------
function [z,a] = gauss2dconv1(x,y,iv) %#ok<DEFNU>
global alpha;
ii = round(iv);
g = gauss(ii,alpha);
a = (ii-1.0)/(2.0*sqrt(alpha*log(10)));
zx = conv2(g,1,x);
zx = zx(floor(ii/2)+1:floor(ii/2)+size(x,1),:);
zy = conv2(1,g,y);
zy = zy(:,floor(ii/2)+1:floor(ii/2)+size(x,2));
z = zx+zy;
Norm = a*sqrt(pi);
z = z/Norm;
end
%--------------------------------------------------------------------------
function [gx,gy] = gauss2dprim(n,alpha) %#ok<DEFNU>
% GAUSS2DPRIM      GAUSS2DPRIM(N,A) returns the derivative of
%                  NxN-point Gauss 2d-window.
%            a corresponds to an attenuation of 10^(-a) at the end of the
%            Gauss window
% Input:     -N number of points in one direction
%            -a dB attenuation. Default value is a = 2.
% Output:    -g time samples of the derivative of Gauss window

if nargin == 1, alpha = 2; end
a = (n-1)/(2.0*sqrt(alpha*log(10)));
t = (-(n-1)/2:(n-1)/2);
tt = flipud(t');
t2 = t(ones(1,n),:)+i*tt(:,ones(1,n));
gx = -2.0*t(ones(1,n),:)./(a^2).*exp(-abs(t2).^2 ./ a^2);
gy = 2.0*tt(:,ones(1,n))./(a^2).*exp(-abs(t2).^2 ./ a^2);
end
%--------------------------------------------------------------------------
function [zx,zy,a] = gauss2dprimconv(x,iv) %#ok<DEFNU>
global alpha;
ii = round(iv);
gx = gauss(ii,alpha,1);
a = (ii-1.0)/(2.0*sqrt(alpha*log(10)));
zx = conv2(1,gx,x);
zy = conv2(gx,1,x);
Norm = a*sqrt(pi);
zx = zx/Norm;
zy = zy/Norm;
end
%--------------------------------------------------------------------------
function [z,a] = rect2dconv(x,iv) %#ok<DEFNU>
i = round(iv);
a = (iv-1.0);
y = ones(i,i);
z = conv2(x,y);
Norm = iv^2;
z = z/Norm;
end
%--------------------------------------------------------------------------
function [z,a] = rect2dconv1(x,y,iv) %#ok<DEFNU>
ii = round(iv);
g = ones(1,ii);
a = (iv-1.0);
zx = conv2(g,1,x);
zx = zx(floor(ii/2)+1:floor(ii/2)+size(x,1),:);
zy = conv2(1,g,y);
zy = zy(:,floor(ii/2)+1:floor(ii/2)+size(x,2));
z = zx+zy;
Norm = iv;
z = z/Norm;
end
%--------------------------------------------------------------------------
function [zx,zy,a] = rect2dprimconv(x,iv) %#ok<DEFNU>
[n,p] = size(x);
j = round(iv);
a = (iv-1.0);
zx = [x,zeros(n,j-1)]-[zeros(n,j-1),x];
zy = [zeros(j-1,p);x]-[x;zeros(j-1,p)];
Norm = iv;
zx = zx/Norm;
zy = zy/Norm;
end
%--------------------------------------------------------------------------
function [dim, newhfig,Kreg] = reg_dimR(a,L,R,reg,sigma,hfig,d,varargin)

handlefig = hfig;

I = find(L>0);
if length(I)<2
    disp('Choose a wider range or more voices: could not make any regression.')
    dim = NaN;
    newhfig = handlefig;
    return;
end
la = log(a(I));
lL = log(L(I));

if sigma>0
    J = find((R(I)>0)&(R(I)<0.5));
    if length(J)<2
        warning('The regression is done in an area where the noise prevalence ratio is upper than 0.5 (log10(NPR) > -0.3)'); %#ok<WNTAG>
        J = [length(I)-1,length(I)];
    end
    Kreg = J;
else
    Kreg = 1:length(la);
end

if length(Kreg) < 3
    varargin = cell(1,1);
    varargin{1} = 'ls';
end;

switch varargin{1}
    case  'wls'
        RegWeight = varargin{2}(Kreg)./sum(varargin{2}(Kreg)) ;
        a_hat = monolr(la(Kreg),lL(Kreg),varargin{1},RegWeight);
    case  'linf'
        a_hat = regression_elimination(la(Kreg),lL(Kreg),'linf');
    case  'lsup'
        a_hat = regression_elimination(la(Kreg),lL(Kreg),'lsup');
    otherwise
        a_hat = monolr(la(Kreg),lL(Kreg),varargin{:});
end

dim = d - a_hat(1); %#ok<NASGU>
[dim,handlefig] = fl_regression(la(Kreg),lL(Kreg),[num2str(d) '-a_hat'],'RegularizationDimension',reg,varargin{:});

newhfig=handlefig;
end