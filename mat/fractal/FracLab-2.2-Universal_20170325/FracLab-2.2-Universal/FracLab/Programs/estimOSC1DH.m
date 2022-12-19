function H = estimOSC1DH(x,base,alpha,beta,varargin)
% ESTIMOSC1DH Computes the Pointwise Holder exponent based on a method that 
%             uses oscillations for a 1D signal
%
%   H = ESTIMOSC1DH(X,BASE,ALPHA,BETA) Estimates the Holder function, H, of the
%   input signal, X, using a least square regression. The parameters ALPHA and BETA
%   are real values in (0:1) which characterize the neighborhood of each point
%   where the exponent is computed. The neighborhood of points are included in
%   [BASE^rhomin : BASE^rhomax], with rhomin = N^ALPHA and rhomax = N^BETA. 
%   
%   H = ESTIMOSC1DH(...,'REGPARAM') Estimates H using a specific kind of regression,
%   REGPARAM. If the REGPARAM is not specified, the default value is REGPARAM = LS.
%
%   H = ESTIMOSC1DH(...,'timeinstant',T,) Estimates H for a specific instant, T,
%   of the signal. The parameter T must be included in [1 : length(X)].
%
%   H = ESTIMOSC1DH(...,'average',[GAMMA,DELTA]) Estimates H doing an average of
%   oscillations. The parameters GAMMA and DELTA are real values in (0:1) which
%   characterize the neighborhood of each point used to compute the average.
%
%   H = ESTIMOSC1DH(...,'zones',N,) Estimates H doing an alignment on the trend of
%   the signal X, which has been splitted over N zones. 
%   If ZONES is not specified, the default value is N = 10.
%
%   Example
%
%       N = 1024; Ht = eval('0.5+0.3*sin(4*pi*t)');
%       x = mBmQuantifKrigeage(N,Ht,10);
%       H = estimOSC1DH(x,2.1,0.1,0.3);
%       Hlinf = estimOSC1DH(x,2.1,0.1,0.3,'linf');
%       H_512 = estimOSC1DH(x,2.1,0.1,0.3,'timeinstant',512);
%
%   See also estimGQV1DH
%
%   References
%
%      [1] C. Tricot, "Curves and Fractal Dimension" Springer-Verlag (1995).
%
%      [2] O. Barrière, "Synthèse et estimation de mouvements Browniens multifractionnaires
%          et autres processus à régularité prescrite. Définition du processus
%          autorégulé multifractionnaire et applications", PhD Thesis (2007).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc estimOSC1DH ">estimOSC1DH</a>

% Author Olivier BARRIERE, January 2006
% Modified by Christian Choque Cortez, November 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin < 4, error('Not enough input arguments'); end
if nargin > 4
    arguments = varargin;
    kv = floor(length(x)^alpha):ceil(length(x)^beta);
    list_reg1 = {'wls','pls','lapls'};
    list_reg2 = {'ls','lsup','linf','ml'};
    
    [regparam,arguments] = checkforargument(arguments,list_reg1,'ls','wo');
    if strcmp(regparam{1},'ls')
        [regparam,arguments] = checkforargument(arguments,list_reg2,'ls');
    end
    [timeinstant,arguments] = checkforargument(arguments,'timeinstant',0);
    [average,arguments] = checkforargument(arguments,'average',0);
    [nzones,arguments] = checkforargument(arguments,'zones',10);
    
    if ~isnumeric(timeinstant), error('Invalid use of timeinstant property'); end
    if ~isnumeric(nzones), error('Invalid use of zones property'); end
    if ~isnumeric(average), error('Invalid use of average property'); end
    if (timeinstant > length(x)), error('timeinstant input argument is out of range'); end
    if timeinstant, error(nargoutchk(1, 1, nargout)); end
    if (strcmp(regparam{1},'pls') || strcmp(regparam{1},'wls') || strcmp(regparam{1},'lapls')) && length(regparam) ~= 2,
        error('Invalid use of reparam property'); end
    if strcmp(regparam{1},'pls') && (~isnumeric(regparam{2}) || ~isscalar(regparam{2}) || regparam{2} < 2),
        error('The number of iterations must be a scalar > 2'); end
    if strcmp(regparam{1},'wls') && (~isnumeric(regparam{2}) || length(regparam{2})~=length(kv)),
        error(['Weights vector must have ',num2str(length(kv)),' elements']); end        
    if strcmp(regparam{1},'lapls') && (~isnumeric(regparam{2}) || length(regparam{2})~=length(kv)),
        error(['Sequence of variances vector must have ',num2str(length(kv)),' elements']); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regparam = {'ls'};
    timeinstant = 0;
    average = 0;
    nzones = 10;
end

%--------------------------------------------------------------------------
N = length(x);
rhomin = floor(N^alpha); rhomax = ceil(N^beta);
if round(base^rhomin) >= N/2
    error('alpha must not be too large in relation to the signal');
end

if timeinstant
    x0 = timeinstant;
    larg = zeros(1,rhomax-rhomin+1);
    osc = zeros(1,rhomax-rhomin+1);
    for rho = rhomin:rhomax
        larg(rho-rhomin+1) = 1+2*round(base^rho);
        if average ~= 0
            osc(rho-rhomin+1) = average_osc(x,round(base^rho),average,x0);
        else
            interval = x(max(1,x0-round(base^rho)):min(N,x0+round(base^rho)));
            osc(rho-rhomin+1) = max(interval)-min(interval);
        end
    end
    H = fl_regression(log(larg),log(osc),...
        'a_hat','PointwiseHolderExponentOscillations',2,regparam{:});

else
    osc = zeros(N,rhomax-rhomin+1);
    H_osc = zeros(N,rhomax-rhomin+1);
    rho = rhomin:rhomax;
    ray = ((base.^rho)-base^rhomin)/(base^rhomax-base^rhomin);
    larg = 1+2*round(base.^rho);
    h_waitbar = fl_waitbar('init');

    for rho = rhomin:rhomax
        fl_waitbar('view',h_waitbar,rho/2,rhomax-rhomin+1);
        for i = 1:N
            interval = x(max(1,i-round(base^rho)):min(N,i+round(base^rho)));
            osc(i,rho-rhomin+1) = max(interval)-min(interval);
        end
    end

    if average ~= 0, osc = average_osc(osc,rhomin:rhomax,average); end

    osc(osc==0)=exp(1); %TO AVOID log(0) => régularity =1
    logosc = log(osc);
    logray = log(ray);
    
    for i=1:length(logray)
        H_osc(:,i) = logosc(:,i)/logray(i);
    end
    H_osc_mean = nanmean(H_osc(:,1:end-1),2);
    
    regab = log(larg);
    Hreg = zeros(1,N);
    for i = 1:N
        fl_waitbar('view',h_waitbar,1/2*N+i/2,N);
        [Hreg_hat] = fl_monolr(regab,logosc(i,:),regparam{:});
        Hreg(i) = Hreg_hat;
    end

    moy_H_osc_mean = fl_tendance(H_osc_mean,nzones)';
    moy_Hreg = fl_tendance(Hreg,nzones)';
    
    H = H_osc_mean - moy_H_osc_mean + moy_Hreg;

    fl_waitbar('close',h_waitbar);
end
end
%--------------------------------------------------------------------------
function new_osc = average_osc(x,y,m,x0)
%x = signal| y = interval| m = average = [gamma,delta]| x0 = timeinstant

if nargin == 3, x0 = 0; end %No timeinstant computation
N = length(x);
gamma = m(1); delta = m(2);
N_delta = N^(1-delta);
k_inf = round(ceil(0.5*N^delta - N^(delta-gamma))*N_delta);
k_max = round(floor(0.5*N^delta + N^(delta-gamma))*N_delta);
m = ceil((abs(k_inf- N/2) + abs(k_max- N/2))/2);

if ~x0 
    pseudosc = zeros(N,y(end)-y(1)+1);
    for rho = y(1):y(end)
        for i = 1:N
            lim_inf = max(1,i-m); lim_sup = min(N,i+m);
            pseudosc(i,y-y(1)+1) = mean(x(lim_inf:lim_sup,y-y(1)+1));
        end
    end
    new_osc = pseudosc;
else
    pseudosc = zeros(2*m+1,1);
    count = 0;
    for i = x0-m:x0+m
        count = count + 1;
        lim_inf = min(N,i-y); lim_sup = max(1,i+y);
        interval = x(max(1,lim_inf):min(N,lim_sup));
        pseudosc(count) = max(interval) - min(interval);
    end
    new_osc = mean(pseudosc);
end
end