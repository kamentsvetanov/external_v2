function [H, H_lb, H_ub] = calc_H_W(X,levels,l,biasCorrected, method,diagnosticPlot, opt1, opt2);
% Hurst index estimate and confidence interval
% 
% X: Cell of subcrossings
% levels: is a matrix of 2 colums. Cell index (1st) for the corespending
% level (2nd).
% l: >= 1, level of crossings used
% method: 'iid' for iid Z_i, 'srd' for correlated short-range dept Z_i,
%     'lrd for long-range dept Z_i
% biasCorrected: if 1 then bias correction for log transform is included
% diagnosticPlot: if 1 then diagnostic plot required for methods srd or lrd
% opt1, opt2: option parameters, passed to calc_subX_stats
%
% requires functions calc_subX_stats and calc_alpha_exponent
% calc_subXstats returns mean, variance and 95% CI for subcrossing distribution

% Author Y. Shen, December 2002
% Modified by O.D. Jones, July 2003
% Modified By W. Arroum December 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

j=find(levels(:,2)==l);
if isempty(j)
    disp(['The subcrossings of level ' num2str(l)  ' does not exist'] );
    H=NaN ;
    H_lb=NaN ;
    H_ub=NaN ;
    return
end

if nargin  <6
    diagnosticPlot=0;
    if nargin <4
        method='iid';
        biasCorrected=0;
        diagnosticPlot=0;
    elseif nargin == 4
        method='iid';
    else
        if strcmp(method,'srd') || strcmp(method,'lrd')
                %diagnosticPlot=1;
                %disp(['The diagnosticPlot parameters is set to be actived (diagnosticPlot=1).'] );
        elseif ~strcmp(method,'iid')
            disp(['The ''' method ''' method does not exist. Please chose among ''iid'', ''lrd'' and ''srd''.'] );
            H=NaN ;
            H_lb=NaN ;
            H_ub=NaN ;
        end
    end
    [m, m_var, m_lb, m_ub] = calc_subX_stats_W(X{levels(j,1)}, method, diagnosticPlot);
elseif nargin >= 6
    if strcmp(method,'srd') || strcmp(method,'lrd')
        %if diagnosticPlot~=1;
        %    diagnosticPlot=1;
        %    disp(['The diagnosticPlot parameters is set to be actived (diagnosticPlot=1).'] );
        %end
    elseif strcmp(method,'iid')
        if diagnosticPlot~=0;
            diagnosticPlot=0;
            disp(['There is no diagnostic Plot for this method.'] );
        end
    else
            disp(['The ''' method ''' method does not exist. Please chose among ''iid'', ''lrd'' and ''srd''.'] );
            H=NaN ;
            H_lb=NaN ;
            H_ub=NaN ;
    end
    if nargin == 6
        [m, m_var, m_lb, m_ub] = calc_subX_stats_W(X{levels(j,1)}, method, diagnosticPlot);
    elseif nargin == 7
        [m, m_var, m_lb, m_ub] = calc_subX_stats_W(X{levels(j,1)}, method, diagnosticPlot, opt1);
    elseif nargin == 8
        [m, m_var, m_lb, m_ub] = calc_subX_stats_W(X{levels(j,1)}, method, diagnosticPlot, opt1, opt2);
    else
        disp(['Maximum number of input equal 8.'] );
        H=NaN ;
        H_lb=NaN ;
        H_ub=NaN ;
        return
    end
end


if biasCorrected == 1
	% H = log 2/ log mu = f(mu)
	% m is estimator of mu, bias corrected estimator of H is f(m) - f''(m)*m_var/2
	correction = m_var*log(2)/2/(m*log(m))^2*(1 + 2/log(m));
	correction_lb = m_var*log(2)/2/(m_ub*log(m_ub))^2*(1 + 2/log(m_ub));
	correction_ub = m_var*log(2)/2/(m_lb*log(m_lb))^2*(1 + 2/log(m_lb));
else
	correction = 0;
	correction_lb = 0;
	correction_ub = 0;
end
H = 1/log2(m) - correction;
H_lb = 1/log2(m_ub) - correction_ub;
H_ub = 1/log2(m_lb) - correction_lb;
if H_lb <0
    H_lb = 0;
end
if H_ub >1
    H_ub = 1;
end 
%==========================================================================
function [m, m_var, m_lb, m_ub] = calc_subX_stats_W(Z, method, diagnosticPlot, opt1, opt2)

% mean, variance and CI for number of subcrossings of crossing of size 2^level
%
% fname: base file name
% level: >= 1, level of crossings used
% method: 'iid' for iid Z_i, 'srd' for correlated short-range dept Z_i,
%     'lrd for long-range dept Z_i
% diagnosticPlot: if 1 then diagnostic plots are produced (for methods srd or lrd only)
% opt1, opt2: option parameters
%     'iid' uses no options
%     'srd' uses opt1 in (0,1) for proportion of data used to calc delta, default 0.5
%     'lrd' uses opt1 and opt2, both passed to calc_alpha_exponent, defaults 10 and 1
%     opt1 is order of the wavelet basis, opt2 is the onset ot the scaling region
%
% requires function calc_alpha_exponent
%
% Y.Shen 12.2002, O.D.Jones 7.2003

if ~isempty(Z)
if method == 'iid'
    m = mean(Z);
    S2 = var(Z);
    n = length(Z);
    m_var = S2/n;
    err = 1.96*sqrt(S2/n);
    m_lb = m - err;
    m_ub = m + err;
    
elseif method == 'srd'
    m = mean(Z);
    S2 = var(Z);
    if nargin <= 4
        opt1 = 0.5;
    end
    [rho, m, S2] = autocorr(Z);
    if ~isnan(rho)  
        n = length(Z);
        if n*opt1>=2
            for N = 2:n*opt1
                x = 2*(1 - [1:N-1]/N).*rho(2:N);
                delta(N) = sum(x);
            end
        
            m_var = S2*(1 + delta(N))/n;
            err = 1.96*sqrt(S2*(1 + delta(N))/n);
            m_lb = m - err;
            m_ub = m + err;    
            if diagnosticPlot == 1% diagnostic plot, if series is srd then delta(N) converges
                subplot(2,1,1);
                plot(1 + delta);
                title('variance correction factor')
                subplot(2,1,2);
                plot(rho);
                title('autocorrelation')
            end
        else
            m=NaN;
            m_var=NaN;
            m_lb=NaN;
            m_ub=NaN;   
        end
    else
        m=NaN;
        m_var=NaN;
        m_lb=NaN;
        m_ub=NaN;
    end

elseif method == 'lrd' 
    if nargin <= 4
        opt1 = 10;
    end
    if nargin <= 5
        opt2 = 1;
    end
    m = mean(Z);
    n = length(Z);
    
    [alpha, cfc, var_a, var_b, cov_ab] = calc_alpha_exponent(Z, diagnosticPlot, opt1, opt2);
    % a = log2(cfc);
    b  = 1 - alpha;
    if b > 1
        %disp('WARNING: sequence of subcrossings apparently not LRD');
        fl_warning('WARNING: sequence of subcrossings apparently not LRD','blue'),
    end
    m_var = cfc*(2*pi*n)^(-b)*f(b)^2;
    [lb, ub] = ZW_CI(n, b, var_a, var_b, cov_ab, 0.95);
    m_lb = m - sqrt(m_var)*ub;
    m_ub = m - sqrt(m_var)*lb;
end
else
    m=NaN;
    m_var=NaN;
    m_lb=NaN;
    m_ub=NaN;
end
%==========================================================================
function [rho, m, S2] = autocorr(x)

% empirical autocorrelation function
% rho(r+1) is lag r autocorrelation of x
% m is mean of x
% S2 is variance of x

m = mean(x);
S2 = var(x);
x = x - m;
n = length(x);
if S2~=0
    for r = 0:n-1
        rho(r+1) = sum(x(1:n-r).*x(r+1:n))/(n-r)/S2;
    end
else
    rho=NaN;
end

%==========================================================================
function [lb, ub] = ZW_CI(n, b, var_a, var_b, cov_ab, sig_lvl);

% Monte-Carlo estimate of CI for Z/W

sample_size = 10000; % size of Monte-Carlo sample
delta_b = 0.001; % used to estimate f'
Z = randn(1,sample_size);
C = [var_a cov_ab;cov_ab var_b];
R = chol(C); 
L = R';
Z2 = L*randn(2,sample_size);
W = 2.^(Z2(1,:)/2).*(2*pi*n).^(Z2(2,:)/2).*(1 + Z2(2,:)*(f(b+delta_b) - f(b))/delta_b/f(b));
ZW = sort(Z./W);
lb = ZW(round((1-sig_lvl)/2*sample_size));
ub = ZW(round((1 - (1-sig_lvl)/2)*sample_size));

%==========================================================================
function y = f(x)
% used by ZW_CI

y2 = 2*pi*x/((1-x)*(2-x)*gamma(1-x)*sin(pi*x/2)*(2-2^(1-x)));
y = sqrt(y2);
