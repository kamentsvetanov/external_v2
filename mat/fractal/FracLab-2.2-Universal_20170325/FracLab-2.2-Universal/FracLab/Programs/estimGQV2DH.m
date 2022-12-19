function  [H, G] = estimGQV2DH(x,gamma,delta,kv,varargin)
% ESTIMGQV2DH Computes a Generalized Quadratic Variations based estimation 
%             of the Holder exponent of a 2D signal (an image)
%
%   [H,G] = ESTIMGQV2DH(X,GAMMA,DELTA,KV) Estimates the Holder function, H,
%   and the scale factor, G, of the input image, X, using a least square regression.
%   The parameters GAMMA and DELTA are real values in (0:1) which characterize
%   the neighborhood of each point where the exponent is computed. The vector KV 
%   gives the values of the succesive sub-samplings used for the computations of GQV.
%
%   [H,G] = ESTIMGQV2DH(...,'REGPARAM') Estimates H and G using a specific type of
%   regression, REGPARAM. If REGPARAM is not specified, the default value is REGPARAM = LS.
%   When a no regression estimation is desired then KV will be automatically 1
%
%   H = ESTIMGQV2DH(...,'timeinstant',[Tx,Ty]) Estimates H for a specific instant, [Tx,Ty],
%   of the input image. The parameters Tx and Ty represent the x and y coordinates of
%   the timeinstant, they must be included in [1:length(X),1:length(Y)].
%
%   [H,G] = ESTIMGQV2DH(...,'zones',N,) Estimates H and G, doing an alignment on
%   the trend of the signal X, which has been splitted over N zones.
%   If ZONES is not specified, the default value is N = 7.
%
%   Example
%         
%       N = 128; tx = linspace(0,1,N); ty = linspace(0,1,N); [X,Y]=meshgrid(tx,ty);
%       f = inline('0.1+0.8*tx.*ty','tx','ty'); Hxy = f(X,Y);
%       x = mBm2DQuantifKrigeage(N,Hxy,25);
%       [H,G] = estimGQV2DH(x,0.8,1,[1:1:5]);
%       [Hlinf,G] = estimGQV2DH(x,0.8,1,[1:1:5],'linf');
%       H_64 = estimGQV2DH(x,0.8,1,[1:1:5],'timeinstant',[64,64]);
%
%   See also estimOSC2DH
%
%   References
%
%      [1] A. Ayache, J. Lévy-Véhel, "Identi?cation of the pointwise holder exponent 
%          of generalized multifractional brownian motion", Stochastic Processes and
%          their Applications, Vol 111 (2004) 119–156.
%
%      [2] O. Barrière, "Synthèse et estimation de mouvements Browniens multifractionnaires
%          et autres processus à régularité prescrite. Définition du processus
%          autorégulé multifractionnaire et applications", PhD Thesis (2007).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc estimGQV2DH ">estimGQV2DH</a>

% Author Olivier Barrière, January 2006
% Modified by Antoine Echelard, November 2008
% Modified by Christian Choque Cortez, January 2009

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
        [nzones,arguments] = checkforargument(arguments,'zones',7);
        if length(kv(1,:)) == 1, error('kv input argument must be a vector'); end
        if ~isnumeric(timeinstant), error('Invalid use of timeinstant property'); end
        if ~isnumeric(nzones), error('Invalid use of zones property'); end
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
    end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    regparam = {'ls'};
    timeinstant = 0;
    nzones = 7;
end

%--------------------------------------------------------------------------
[N1, N2] = size(x); N = N1*N2;
if strcmp(regparam{1},'noreg'), kv = 1; timeinstant = 0; end 
M=length(kv); V = zeros(N1,N2,M);

if timeinstant
    kx = timeinstant;
    variationsQ = GQV2D(x,gamma,delta,kv,kx);
    Nt = max(N1,N2);
    t = log2(Nt./kv);
    FORMULE=['(a_hat-(1-(',num2str(gamma),')))/(-2*(',num2str(delta),'))',];
    H = fl_regression(t,log2(variationsQ),FORMULE,...
        'PointwiseHolderExponentOscillations',2,regparam{:});
else
    h_waitbar = fl_waitbar('init');
    
    for indk = 1:M
        k = kv(indk);
        fl_waitbar('view',h_waitbar,indk,M+N1);
        for indi = 1:k
            for indj = 1:k
                V(indi:k:N1,indj:k:N2,indk) = GQV2D(x(indi:k:N1,indj:k:N2),gamma,delta);
            end
        end
    end
    
    H_max = 1/(2*delta)*(2*(1-gamma)-log2(V(:,:,1))./log2(N/min(kv)));
    H_reg = zeros(N1,N2);
    
    if M > 1 %with strong regression
        t = log2(N./kv);
        for i = 1:N1
            fl_waitbar('view',h_waitbar,M+i,M+N1);
            for j = 1:N2
                [alpha1] = fl_monolr(t(:),log2(V(i,j,:)),regparam{:});
                H_reg(i,j) = (alpha1-2*(1-gamma))/(-2*delta);
            end
        end
        moy_reg = fl_tendance(H_reg,nzones);
        moy_max = fl_tendance(H_max,nzones);
        
        H = H_max-moy_max+moy_reg;
        G = N.^((H-H_max));
    else %with No regression
        H = H_max;
        G = ones(N1,N2);
    end
    fl_waitbar('close',h_waitbar);
end
end
%--------------------------------------------------------------------------
function V = GQV2D(x,gamma,delta,kv,kx)
%x = signal| kv = interval| kx = timeinstant position

if nargin == 3, kx = 0; end %No timeinstant computation

if ~kx
    [N1, N2] = size(x);
    V = zeros(N1,N2);
    N1_delta = N1^(1-delta); N2_delta = N2^(1-delta);
    
    for i = 1:N1
        x_i = (i-1)/N1;
        p_min = ceil(N1^delta*(x_i-N1^(-gamma)));
        p_max = floor(N1^delta*(x_i+N1^(-gamma)));
        p_min = max(p_min,1); p_max = min(p_max,N1-2);
        new_x = x(p_min:p_max+2,:);
        
        for j = 1:N2
            %Voisinage v_N(ti) = {p_i / 0<=p_i<=N-2 et |t_i-p_i/N^delta|<=N^-gamma}
            %Il suffit de calculer p_min et p_max pour chaque i
            y_j = (j-1)/N2; 
            q_min = ceil(N2^delta*(y_j-N2^(-gamma)));
            q_max = floor(N2^delta*(y_j+N2^(-gamma)));
            q_min = max(q_min,1); q_max = min(q_max,N2-2);
            
            for p = p_min:p_max
                p0 = min(max(round(N1_delta*(p)),1),N1)-p_min+1;
                p1 = min(max(round(N1_delta*(p+1)),1),N1)-p_min+1;
                p2 = min(max(round(N1_delta*(p+2)),1),N1)-p_min+1;
                for q = q_min:q_max
                    %  1 -2  1
                    % -2  4 -2
                    %  1 -2  1
                    q0 = min(max(round(N2_delta*(q)),1),N2);
                    q1 = min(max(round(N2_delta*(q+1)),1),N2);
                    q2 = min(max(round(N2_delta*(q+2)),1),N2);
                    
                    V(i,j) = V(i,j)+...
                        (new_x(p0,q0)-2*new_x(p1,q0)+new_x(p2,q0)...
                        -2*new_x(p0,q1)+4*new_x(p1,q1)-2*new_x(p2,q1)...
                        +new_x(p0,q2)-2*new_x(p1,q2)+new_x(p2,q2) )^2;
                end
            end
            if V(i,j) == 0, V(i,j) = NaN; end
        end
    end
    
else
    x0 = kx(1); y0 = kx(2);
    [M1, M2] = size(x);
    V = zeros(1,length(kv));
    ind = 0;
    
    for k = kv
        ind = ind+1;
        avantx = x0:-k:1; apresx = x0:k:M1; sous_echantx = [avantx(end:-1:2),apresx];
        avanty = y0:-k:1; apresy = y0:k:M2; sous_echanty = [avanty(end:-1:2),apresy];
        placex = length(avantx); placey = length(avanty);
        
        N1 = length(sous_echantx); N2 = length(sous_echanty);
        N1_delta = N1^(1-delta); N2_delta = N2^(1-delta);
        placex = (placex-1)/N1; placey = (placey-1)/N2;
        
        p_min = ceil(N1^delta*(placex-N1^(-gamma)));
        p_max = floor(N1^delta*(placex+N1^(-gamma)));  
        q_min = ceil(N2^delta*(placey-N2^(-gamma)));
        q_max = floor(N2^delta*(placey+N2^(-gamma)));
        
        p0min = min(max(round(N1_delta*(p_min)),1),N1);
        p2max = min(max(round(N1_delta*(p_max+2)),1),N1);
        q0min = min(max(round(N2_delta*(q_min)),1),N2);
        q2max = min(max(round(N2_delta*(q_max+2)),1),N2); 
        new_x = x(sous_echantx(p0min:p2max),sous_echanty(q0min:q2max));
        
        p_min = max(p_min,1); p_max = min(p_max,N1-2);
        q_min = max(q_min,1); q_max = min(q_max,N2-2);
        
        for p = p_min:p_max
            for q = q_min:q_max
                %  1 -2  1
                % -2  4 -2
                %  1 -2  1
                p0 = min(max(round(N1_delta*(p)),1),N1)-p0min+1;
                p1 = min(max(round(N1_delta*(p+1)),1),N1)-p0min+1;
                p2 = min(max(round(N1_delta*(p+2)),1),N1)-p0min+1;
                q0 = min(max(round(N2_delta*(q)),1),N2)-q0min+1;
                q1 = min(max(round(N2_delta*(q+1)),1),N2)-q0min+1;
                q2 = min(max(round(N2_delta*(q+2)),1),N2)-q0min+1;
                
                V(ind) = V(ind)+...
                        (new_x(p0,q0)-2*new_x(p1,q0)+new_x(p2,q0)...
                        -2*new_x(p0,q1)+4*new_x(p1,q1)-2*new_x(p2,q1)...
                        +new_x(p0,q2)-2*new_x(p1,q2)+new_x(p2,q2))^2;
            end
        end
        if V(ind) == 0, V(ind) = NaN; end
    end
end
end
