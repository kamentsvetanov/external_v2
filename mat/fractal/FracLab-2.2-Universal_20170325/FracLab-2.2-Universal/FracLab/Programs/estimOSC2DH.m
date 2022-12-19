function  H = estimOSC2DH(x,base,alpha,beta,varargin)
% estimOSC2DH Computes the Pointwise Holder exponent based on a method
%             that uses oscillations for a 2D signal (an image)
%
%   H = ESTIMOSC2DH(X,BASE,ALPHA,BETA) Estimates the Holder function, H, of the
%   input signal, X, using a least square regression. The parameters ALPHA and BETA
%   are real values in (0:1) which characterize the neighborhood of each point
%   where the exponent is computed. The neighborhood of points are included in
%   [BASE^rhomin : BASE^rhomax], with rhomin = N^ALPHA and rhomax = N^BETA. 
%
%   H = ESTIMOSC2DH(...,'REGPARAM') Estimates H using a specific kind of regression,
%   REGPARAM. If REGPARAM is not specified, the default value is REGPARAM = LS.
%
%   H = ESTIMOSC2DH(...,'timeinstant',[Tx,Ty]) Estimates H for a specific instant,
%   [Tx,Ty], of the image. The parameters Tx and Ty represent the x and y coordinates
%   of the timeinstant, they must be included in [1:length(X),1:length(Y)].
%
%   H = ESTIMOSC2DH(...,'average',[GAMMA,DELTA]) Estimates H doing an average of
%   oscillations. The parameters GAMMA and DELTA are real values in (0:1) which
%   characterize the neighborhood of each point used to compute the average.
%
%   H = ESTIMOSC2DH(...,'zones',N) Estimates H doing an alignment on the trend of
%   the signal X, which has been splitted over N zones.
%   If ZONES is not specified, the default value is N = 7.
%
%   H = ESTIMOSC2DH(...,'subsampling',S) Estimates H on a sub-sample signal of X
%   allowing to speed up the computation by processing only certain points.
%   The estimation is done every (2*S - 1) points.
%
%   Example
%         
%       N = 128; tx = linspace(0,1,N); ty = linspace(0,1,N); [X,Y]=meshgrid(tx,ty);
%       f = inline('0.1+0.8*tx.*ty','tx','ty'); Hxy = f(X,Y);
%       x = mBm2DQuantifKrigeage(N,Hxy,25);
%       H = estimOSC2DH(x,2.1,0.1,0.3);
%       Hlinf = estimOSC2DH(x,2.1,0.1,0.3,'linf');
%       H_64 = estimOSC2DH(x,2.1,0.1,0.3,'timeinstant',[64,64]);
%
%   See also estimGQV2DH
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
%     <a href="matlab:fl_doc estimOSC2DH ">estimOSC2DH</a>

% Author Christian Choque Cortez, January 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin < 4, error('Not enough input arguments'); end
if nargin > 4
    arguments = varargin;
    kv = floor(min(size(x))^alpha):ceil(min(size(x))^beta);
    list_reg1 = {'wls','pls','lapls'};
    list_reg2 = {'ls','lsup','linf','ml'};
    
    [regparam,arguments] = checkforargument(arguments,list_reg1,'ls','wo');
    if strcmp(regparam{1},'ls')
        [regparam,arguments] = checkforargument(arguments,list_reg2,'ls');
    end
    [subsampling,arguments] = checkforargument(arguments,'subsampling',1);
    [timeinstant,arguments] = checkforargument(arguments,'timeinstant',0);
    [average,arguments] = checkforargument(arguments,'average',0);
    [nzones,arguments] = checkforargument(arguments,'zones',7);
    
    if ~isnumeric(timeinstant), error('Invalid use of timeinstant property'); end
    if ~isnumeric(nzones), error('Invalid use of zones property'); end
    if ~isnumeric(subsampling), error('Invalid use of subsampling property'); end
    if norm(timeinstant) ~= 0 && (length(timeinstant(1,:)) ~= 2 || length(timeinstant(:,1)) ~= 1)
        error('timeinstant input argument must be a [x,y] vector');
    end
    if max(timeinstant) > length(x), error('timeinstant input argument is out of range'); end
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
    subsampling = 1;
    timeinstant = 0;
    average = 0;
    nzones = 7;
end

%--------------------------------------------------------------------------
[N1, N2] = size(x); N = min(N1,N2);
samplestep = 2*subsampling-1; coverage = (samplestep-1)/2;
rhomin = floor(min(N1,N2)^alpha); rhomax = ceil(min(N1,N2)^beta);
if round(base^rhomin) >= N/2
    error('alpha must not be too large in relation to the signal');
end

if timeinstant
    kx = timeinstant;
    x0 = kx(2); y0 = kx(1);
    larg = zeros(1,rhomax-rhomin+1);
    osc = zeros(1,rhomax-rhomin+1);
    for rho = rhomin:rhomax
        larg(rho-rhomin+1) = 1+2*round(base^rho);
        if average ~= 0
            osc(rho-rhomin+1) = average_osc(x,round(base^rho),average,kx);
        else
            px = max(1,x0-round(base^rho)):min(N1,x0+round(base^rho));
            py = max(1,y0-round(base^rho)):min(N2,y0+round(base^rho));
            interval = x(px,py);
            osc(rho-rhomin+1) = max(max(interval))-min(min(interval));
        end
    end
    H = fl_regression(log(larg),log(osc),...
        'a_hat','PointwiseHolderExponentOscillations',2,regparam{:});
    
else
    osc = zeros(N1,N2,rhomax-rhomin+1);
    H_osc = zeros(N1,N2,rhomax-rhomin+1);
    rho = rhomin:rhomax;
    ray = ((base.^rho)-base^rhomin)/(base^rhomax-base^rhomin);
    larg = 1+2*round(base.^rho);
    h_waitbar = fl_waitbar('init');
    
    for rho = rhomin:rhomax
        fl_waitbar('view',h_waitbar,rho,N1+rhomax);
        for i = 1:samplestep:N1
            px = max(1,i-round(base^rho)):min(N1,i+round(base^rho));
            for j = 1:samplestep:N2
                py = max(1,j-round(base^rho)):min(N2,j+round(base^rho));
                interval = x(px,py);
                osc(max(1,i-coverage):min(N1,i+coverage),...
                    max(1,j-coverage):min(N2,j+coverage),...
                    rho-rhomin+1) = max(max(interval))-min(min(interval));
            end
        end
    end
    
    if average ~= 0, osc = average_osc(osc,rhomin:rhomax,average); end
    
    osc(osc==0)=exp(1); %TO AVOID log(0) => régularity =1
    logosc = log(osc);
    logray = log(ray);
    
    for i=1:length(logray)
        H_osc(:,:,i) = logosc(:,:,i)/logray(i);
    end
    H_osc_mean = nanmean(H_osc(:,:,1:end-1),3);
    
    regab = log(larg);
    Hreg = zeros(N1,N2);
    for i = 1:N1
        fl_waitbar('view',h_waitbar,rhomax+i,N1+rhomax);
        for j = 1:N2
            [Hreg_hat] = fl_monolr(regab,logosc(i,j,:),regparam{:});
            Hreg(i,j) = Hreg_hat;
        end
    end

    moy_H_osc_mean = fl_tendance(H_osc_mean,nzones);
    moy_Hreg = fl_tendance(Hreg,nzones);
    
    H = H_osc_mean - moy_H_osc_mean + moy_Hreg;
    
    fl_waitbar('close',h_waitbar);
end
end
%--------------------------------------------------------------------------
function new_osc = average_osc(x,y,m,kx)
%x = signal| y = interval| m = average| kx = timeinstant:[x0,y0]

if nargin == 3, kx = 0; end %No timeinstant computation
N1 = size(x,1); N2 = size(x,2);
gamma = m(1); delta = m(2);
N1_delta = N1^(1-delta); N2_delta = N2^(1-delta);
k_inf = round(ceil(0.5*N1^delta - N1^(delta-gamma))*N1_delta);
k_max = round(floor(0.5*N1^delta + N1^(delta-gamma))*N1_delta);
m1 = ceil((abs(k_inf- N1/2) + abs(k_max- N1/2))/2);
k_inf = round(ceil(0.5*N2^delta - N2^(delta-gamma))*N2_delta);
k_max = round(floor(0.5*N2^delta + N2^(delta-gamma))*N2_delta);
m2 = ceil((abs(k_inf- N2/2) + abs(k_max- N2/2))/2);

if ~kx 
    pseudosc = zeros(N1,N2,y(end)-y(1)+1);
    for rho = y(1):y(end)
        for i = 1:N1
            lim_inf_i = max(1,i-m1); lim_sup_i = min(N1,i+m1);
            for j = 1:N2
                lim_inf_j = max(1,j-m2); lim_sup_j = min(N2,j+m2);
                temposc = mean(x(lim_inf_i:lim_sup_i,lim_inf_j:lim_sup_j,y-y(1)+1));
                pseudosc(i,j,y-y(1)+1) = mean(temposc);
            end
        end
    end
    new_osc = pseudosc;
else
    x0 = kx(1); y0 = kx(2);
    pseudosc = zeros(2*m1+1,2*m2+1);
    count_i = 0;
    for i = x0-m1:x0+m2
        count_i = count_i + 1; count_j = 0;
        for j = y0-m2:y0+m2
            count_j = count_j + 1;
            lim_inf_i = min(N1,i-y); lim_sup_i = max(1,i+y);
            lim_inf_j = min(N2,j-y); lim_sup_j = max(1,j+y);
            interval = x(max(1,lim_inf_i):min(N1,lim_sup_i),max(1,lim_inf_j):min(N2,lim_sup_j));
            pseudosc(count_i,count_j) = max(max(interval)) - min(min(interval));
        end
    end
    new_osc = mean(pseudosc);
    new_osc = mean(new_osc);
end
end