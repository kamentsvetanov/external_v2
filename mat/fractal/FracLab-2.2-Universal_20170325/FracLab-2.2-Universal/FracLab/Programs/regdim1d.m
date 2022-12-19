function zz = regdim1d(x,bounds,voices,varargin)
% REGDIM1D Estimates the regularization dimension of a 1D signal
%
%   REGDIM1D(X,BOUNDS,VOICES) Estimates the regularization dimension, REGDIM, 
%   of the input signal X using a Gaussian kernel and least square regression. 
%   The vector BOUNDS represents the minimum and maximum standard deviations 
%   (in number of samples) for the smoothing kernel. The parameter VOICES is 
%   the number of intermediate sizes for the standard deviation, or more generally
%   the width of the kernel, between the smallest and largest ones. 
%   A figure is displayed showing the value of REGDIM at the top of the figure.
%
%   REGDIM1D(...,'REGPARAM') Estimates REGDIM using a specific type
%   of regression, REGPARAM. 
%   If REGPARAM is not specified, the default value is REGPARAM = LS.
%
%   REGDIM1D(...,'KERNEL') Estimates REGDIM using a specific type of 
%   smoothing kernel, KERNEL. The possible KERNEL that are available are 'gauss' 
%   in order to use a Gaussian kernel, 'rect' in order to use a rectangle kernel. 
%   If KERNEL is not specified, the default value is KERNEL = GAUSS.
%
%   REGDIM1D(...,'noise',STD) Estimates REGDIM when the data are contaminated
%   with an additive white Gaussian noise whose standard deviation is known and
%   is given by STD. The algorithm takes into account the noise in the estimating
%   REGDIM. The parameter STD is a positive real.
%   If NOISE is not specified, the default value is STD = 0.
%
%   ZZ = REGDIM1D(...) Estimates REGDIM and displays a figure showing the
%   regularized graphs, ZZ.
% 
%   Example
%
%       N = 1024; H = 0.5;
%       x = fbmwoodchan(N,H);
%       regdim1d(x,[5,512],32);
%
%   See also cwttrack, cwtspec
%
%   References
%
%      [1] F. Roueff, J. Lévy-Véhel, "A regularization approach to fractional dimension estimation",
%          Fractals 98, (1998).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc regdim1d ">regdim1d</a>

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

if ~(isvector(x) && isnumeric(x) && ~isscalar(x)), error('The input signal must be a vector'); end
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
N = length(x);
Nmin = bounds(1); Nmax = bounds(2);
regdim = [];

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
if size(x,2) == 1, x=x'; end
x = [x(1)*ones(1,floor(imax/2)),x,x(length(x))*ones(1,floor(imax/2))]; %#ok<NASGU>

%%%%%%%%%%%%%%%%%%
%a:scale
%%%%%%%%%%%%%%%%%
a=[]; L=[]; Lnoisy=[]; R=[]; z = zeros(jmax,N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot regularized graphs if wanted %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if graphs
    for j = 1:jmax
        eval(['[z1,a(j)]=' kernel{:} 'conv(x,iv(j));']);
        z(j,:) = z1(floor(iv(j)/2)+1+floor(imax/2):N+floor(iv(j)/2)+floor(imax/2));
    end
    figure
    regdim = [regdim gcf];
    plot(z'); zz = z';
    title('Regularized graphs');
end

for j = 1:jmax
    i = round(iv(j));
    eval(['[z1prim,a(j)]=' kernel{:} 'primconv(x,iv(j));']);
    z1prim = z1prim(floor(iv(j)/2)+1+floor(imax/2):N+floor(iv(j)/2)+floor(imax/2));
    dl = abs(z1prim);
    if isempty(dl)
        break;
    end
    if sigma>0
        Lnoisy(j) = mean(dl); %#ok<AGROW>
        %%%%%%%%%%%%%
        % signal/noise component rate
        %%%%%%%%%%%%
        s = sigma/sqrt(sqrt(2*pi)*a(j)^3);
        dln = 2*s/sqrt(pi).*exp(-(dl.^2)./s^2);
        dlsb = dl-dln;
        R(j) = mean(dln)/Lnoisy(j); %#ok<AGROW>
        %%%%%%%%%
        %Corrected unbiased lengths
        %%%%%%%%%
        c = ones(1,i)./i;
        dlsbm = conv(dlsb,c);
        dlsbm = dlsbm(floor(i/2)+1:floor(i/2)+length(dlsb));
        dlsbc = s*sqrt(2)*invfonc(dlsbm./(s*sqrt(2)));
        L(j) = mean(dlsbc); %#ok<AGROW>
    else
        L(j) = mean(dl)+N^(-2); %#ok<AGROW>
    end
end

[dim, newhfig] = reg_dimR(a,L,R,2,sigma,regdim,1,regparam{:}); %#ok<NASGU>
end
%--------------------------------------------------------------------------
function [z,a] = gaussconv(x,iv) %#ok<DEFNU>
global alpha;
i = round(iv);
y = gauss(i,alpha);
a = (iv-1.0)/(2.0*sqrt(alpha*log(10)));
y = y./(a*sqrt(pi));
z = conv(x,y);
end
%--------------------------------------------------------------------------
function [z,a] = gaussprimconv(x,iv) %#ok<DEFNU>
global alpha;
i = round(iv);
yprim = gauss(i,alpha,1);
a = (i-1.0)/(2.0*sqrt(alpha*log(10)));
yprim = yprim./(a*sqrt(pi));
z = conv(x,yprim);
end
%--------------------------------------------------------------------------
function z = invfonc(x)
z=(sign(x).*sqrt(sqrt(pi)/2*abs(x))+x.^4.*(x+exp(-x.^2)/sqrt(pi).*sign(x)))./(x.^4+1);
end
%--------------------------------------------------------------------------
function [z,a] = rectconv(x,iv) %#ok<DEFNU>
i = round(iv);
a = (iv-1.0);
y = ones(1,i);
y = y./iv;
z = conv(x,y);
end
%--------------------------------------------------------------------------
function [z,a] = rectprimconv(x,iv) %#ok<DEFNU>
i = round(iv);
a = (i-1.0);
z = [x,zeros(1,i-1)]-[zeros(1,i-1),x];
z = z/iv;
end
%--------------------------------------------------------------------------
function [dim, newhfig,Kreg] = reg_dimR(a,L,R,reg,sigma,hfig,d,varargin)

regdim = hfig;

I = find(L>0);
if length(I)<2
    disp('Choose a wider range or more voices: could not make any regression.')
    dim = NaN;
    newhfig = regdim;
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
[dim,regdim] = fl_regression(la(Kreg),lL(Kreg),[num2str(d) '-a_hat'],'RegularizationDimension',reg,varargin{:});

newhfig=regdim;
end