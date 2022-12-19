function [H, G] = estimGQV1DH(x,gamma,delta,kv,varargin)
% ESTIMGQV1DH Computes a Generalized Quadratic Variations based estimation 
%             of the Holder exponent of a 1D signal
%
%   [H,G] = ESTIMGQV1DH(X,GAMMA,DELTA,KV) Estimates the Holder function, H,
%   and the scale factor, G, of the input signal, X, using a least square regression. 
%   The parameters GAMMA and DELTA are real values in (0:1) which characterize 
%   the neighborhood of each point where the exponent is computed. The vector KV 
%   gives the values of the succesive sub-samplings used for the computations of GQV.
%
%   [H,G] = ESTIMGQV1DH(...,'REGPARAM') Estimates H and G using a specific type of 
%   regression, REGPARAM. If REGPARAM is not specified, the default value is REGPARAM = LS.
%   When a no regression estimation is desired then KV will be automatically 1
%
%   H = ESTIMGQV1DH(...,'timeinstant',T,) Estimates H for a specific instant, T, 
%   of the input signal. The parameter T must be included in [1:length(X)].
%
%   [H,G] = ESTIMGQV1DH(...,'zones',N,) Estimates H and G doing an alignment on 
%   the trend of the signal X, which has been splitted over N zones.
%   If ZONES is not specified, the default value is N = 10.
%
%   Example
%
%       N = 2048; t = linspace(0,1,N); Ht=eval('0.5+0.3*sin(4*pi*t)');
%       x = mBmQuantifKrigeage(N,Ht,10);
%       [H,G] = estimGQV1DH(x,0.6,1,[1:1:5]);
%       [Hlinf,G] = estimGQV1DH(x,0.6,1,[1:1:5],'linf');
%       H_512 = estimGQV1DH(x,0.6,1,[1:1:5],'timeinstant',512);
%
%   See also estimOSC1DH
%
%   References
%
%      [1] A. Ayache, J. Lévy-Véhel, "Identification of the pointwise holder exponent 
%          of generalized multifractional brownian motion", Stochastic Processes and
%          their Applications, Vol 111 (2004) 119–156.
%
%      [2] O. Barrière, "Synthèse et estimation de mouvements Browniens multifractionnaires
%          et autres processus à régularité prescrite. Définition du processus
%          autorégulé multifractionnaire et applications", PhD Thesis (2007).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc estimGQV1DH ">estimGQV1DH</a>

% Author Olivier Barrière, January 2006
% Modified by Christian Choque Cortez, December 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin < 4, error('Not enough input arguments'); end
if nargin > 4
    arguments = varargin;
    list_reg1 = {'wls','pls','lapls'};
    list_reg2 = {'ls','lsup','linf','ml','noreg'};
    
    [regparam,arguments] = checkforargument(arguments,list_reg1,'ls','wo');
    if strcmp(regparam{1},'ls')
        [regparam,arguments] = checkforargument(arguments,list_reg2,'ls');
    end
    if ~strcmp(regparam{1},'noreg')
        [timeinstant,arguments] = checkforargument(arguments,'timeinstant',0);
        [nzones,arguments] = checkforargument(arguments,'zones',10);
        if length(kv(1,:)) == 1, error('kv input argument must be a vector'); end 
        if ~isnumeric(timeinstant), error('Invalid use of timeinstant property'); end
        if ~isnumeric(nzones), error('Invalid use of zones property'); end
        if timeinstant > length(x), error('timeinstant input argument is out of range'); end
        if timeinstant, error(nargoutchk(1, 1, nargout)); end
        if (strcmp(regparam{1},'pls') || strcmp(regparam{1},'wls') || strcmp(regparam{1},'lapls')) && length(regparam) ~= 2,
            error('Invalid use of reparam property'); end
        if strcmp(regparam{1},'pls') && (~isnumeric(regparam{2}) || ~isscalar(regparam{2}) || regparam{2} < 2),
            error('The number of iterations must be a scalar > 2'); end
        if strcmp(regparam{1},'wls') && (~isnumeric(regparam{2}) || length(regparam{2})~=length(kv)),
            error(['Weights vector must have ',num2str(length(kv)),' elements']); end        
        if strcmp(regparam{1},'lapls') && (~isnumeric(regparam{2}) || length(regparam{2})~=length(kv)),
            error(['Sequence of variances vector must have ',num2str(length(kv)),' elements']); end
    end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regparam = {'ls'};
    timeinstant = 0;
    nzones = 10;
end

%--------------------------------------------------------------------------
N = length(x);
if strcmp(regparam{1},'noreg'), kv = 1; timeinstant = 0; end 
M = length(kv); V = zeros(N,M);

if timeinstant
    x0 = timeinstant;
    variationsQ = GQV1D(x,gamma,delta,kv,x0);
    t = log2(N./kv);
    FORMULE = ['(a_hat-(1-(',num2str(gamma),')))/(-2*(',num2str(delta),'))'];
    H = fl_regression(t,log2(variationsQ),FORMULE,...
        'PointwiseHolderExponentOscillations',2,regparam{:});
else
    h_waitbar = fl_waitbar('init');
    
    for i = 1:M
        k = kv(i);
        fl_waitbar('view',h_waitbar,k/2,M);
        for ind = 1:k
            V(ind:k:N,i) = GQV1D(x(ind:k:N),gamma,delta);
        end
    end
    
    H_max = 1/(2*delta)*((1-gamma)-log2(V(:,1))./log2(N/min(kv)));  
    H_reg = zeros(1,N);
    
    if M > 1 %with strong regression
        t = log2(N./kv);
        for i = 1:N
            fl_waitbar('view',h_waitbar,1/2*(N) + i/2, N);
            [alpha1] = fl_monolr(t,log2(V(i,:)),regparam{:});
            H_reg(i) = (alpha1-(1-gamma))/(-2*delta);
        end    
        H_reg = H_reg';
        moy_reg = fl_tendance(H_reg,nzones)';
        moy_max = fl_tendance(H_max,nzones)';
        
        H = H_max-moy_max+moy_reg;
        G = N.^((H-H_max));
    else %with No regression
        H = H_max;
        G = ones(N,1);
    end
    fl_waitbar('close',h_waitbar);
end
end
%--------------------------------------------------------------------------
function V = GQV1D(x,gamma,delta,kv,x0)
%x = signal| kv = interval| x0 = timeinstant

if nargin == 3, x0 = 0; end %No timeinstant computation

if ~x0
    N = length(x);
    V = zeros(N,1);
    N_delta = N^(1-delta);
    
    for i = 1:N
        %Voisinage v_N(ti) = {p_i / 0<=p_i<=N-2 et |t_i-p_i/N^delta|<=N^-gamma}
        %Il suffit de calculer p_min et p_max pour chaque i
        t_i = (i-1)/N;
        p_min = ceil(N^delta*(t_i-N^(-gamma)));
        p_max = floor(N^delta*(t_i+N^(-gamma)));
        
        p_min = max(p_min,1);
        p_max = min(p_max,N-2);
        
        for p = p_min:p_max
            p0 = min(max(round(N_delta*(p)),1),N);
            p1 = min(max(round(N_delta*(p+1)),1),N);
            p2 = min(max(round(N_delta*(p+2)),1),N);
            
            V(i) = V(i)+(x(p0)-2*x(p1)+x(p2))^2;
        end
        if V(i) == 0, V(i) = NaN; end
    end
    
else
    M = length(x);
    V = zeros(1,length(kv));
    ind = 0;
    
    for k = kv
        ind = ind+1;
        avant = x0:-k:1; avant = avant(end:-1:1); apres = x0+k:k:M;
        sous_echant = [avant,apres];
        N = floor((M-x0-k)/k)+1+floor((x0-1)/k)+1;
        
        t_i = floor((x0-1)/k)/N;
        p_min = ceil(N^delta*(t_i-N^(-gamma)));
        p_max = floor(N^delta*(t_i+N^(-gamma)));
        
        N_delta = N^(1-delta);
        p_min = max(p_min,1);
        p_max = min(p_max,N-2);
        
        p0min = min(max(round(N_delta*(p_min)),1),N);
        p2max = min(max(round(N_delta*(p_max+2)),1),N);
        new_x = x(sous_echant(p0min:p2max)); %(sous_echant<=p2max));
        
        for p = p_min:p_max
            p0 = min(max(round(N_delta*(p)),1),N);
            p1 = min(max(round(N_delta*(p+1)),1),N);
            p2 = min(max(round(N_delta*(p+2)),1),N);
            V(ind) = V(ind)+(new_x(p0-p0min+1)-2*new_x(p1-p0min+1)+new_x(p2-p0min+1))^2;
        end
        if V(ind) == 0, V(ind) = NaN; end
    end
end
end
