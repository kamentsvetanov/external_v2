function [xi nowaitbar] = fracinterp1d(x,ninterp,varargin)
% FRACINTERP1D Computes the interpolation of a 1D signal
%
%   XI = FRACINTERP1D(X,NI) Computes the interpolated signal, XI, of the input signal,
%   X, using a specific number of interpolation, NI and a Triangle biorthonormal
%   quadrature mirror filter. Beware, if the number of interpolations NI > 3 the
%   process will take a long time.
%
%   XI = FRACINTERP1D(...,'levels',[START,END]) Computes XI with specific start level
%   and end level values. The parameters START and END are positive integers that
%   specify the minimum and maximum scales which are used to compute the interpolation.
%   The START value must be at least equal to 2 and the END level must be lower
%   than log2 of the length input signal.
%   If LEVELS is not specified, the default vector is [START,END] = [2,log2(length(X))].
%
%   Example
%
%       x = fbmwoodchan(1024,0.5,'support',1,'sigma',1);
%       y = fracinterp1d(x,1,'Triangle','levels',[2,10]);
%       figure;plot(fbmwch0); hold on;
%       plot(interp_fbmwch00,'r');
%       xlim([0 length(y)]); legend('input signal','interpolated signal');
%
% Reference page in Help browser
%     <a href="matlab:fl_doc fracinterp1d ">fracinterp1d</a>

% Author: Pierrick Legrand 2003
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,6);
nargoutchk(1,2);

N = length(x);
if nargin > 2
    arguments = varargin;
    list_filter1 = {'daubechies','coiflet'};
    list_filter2 = {'Triangle'};
    
    [filterparam, arguments] = checkforargument(arguments,list_filter1,'Triangle','wo');
    if strcmp(filterparam{1},'Triangle')
        [filterparam, arguments] = checkforargument(arguments,list_filter2,'Triangle');
    end
    [level, arguments] = checkforargument(arguments,'levels',[2,floor(log2(N))]);
    if ~isnumeric(level), error('Invalid use of level property'); end
    if norm(level) ~= 0 && (length(level(1,:)) ~= 2 || length(level(:,1)) ~= 1)
        error('level input argument must be a [x,y] vector');
    end
    lmin = level(1); lmax = level(2);
    if lmin < 2, error('Start level input argument must be higher than 2'); end
    if lmax > floor(log2(N)), error('End level input argument is out of range'); end
    if (strcmp(filterparam{1},'daubechies') || strcmp(filterparam{1},'coiflet')) && length(filterparam) ~= 2,
        error('Invalid use of filterparam property'); end
    if (strcmp(filterparam{1},'daubechies') || strcmp(filterparam{1},'coiflet')) && (~isscalar(filterparam{2}) || filterparam{2} <= 0),
        error('The wave order must be a positive integer'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    filterparam = {'Triangle'};
    lmin = 2; lmax = floor(log2(N));
end

%--------------------------------------------------------------------------
nb = 1; marq = 0; lambda = 1;
if strcmp(filterparam{1},'Triangle'),
    wave_order = 0;
else
    wave_order = filterparam{2};
end
if nargout == 2
    nowaitbar = 1;
else
    nowaitbar = 0;
    h = fl_waitbar('init');
end

for ni = 1:ninterp
    if ~nowaitbar, fl_waitbar('view',h,ni,ninterp); end
    N = length(x);
    n = floor(log2(N));
    
    if size(x,1) > size(x,2), x = x'; marq = 1; end

    if ~wave_order
        [qmf,dqmf] = MakeBSFilter(filterparam{:});
        wc = FWT_SBS(x,1,qmf,dqmf);
        matrice1 = zeros(n,2^(n-1));
        for j = 1:n
            matrice1(j,1:2^(j-1)) = wc(2^(j-1)+1:2^(j));
        end
        wc2 = wc;
        for t = n:n+nb-1
            wc2 = [wc2  zeros(1,2^(t))];
        end
    else
        q = MakeQMF(filterparam{1},wave_order);
        [wc,wti,wtl] = FWT(x,n,q);
        for sc = 1:n
            matrice1(n-sc+1,1:length(wc(wti(sc):(wti(sc)+wtl(sc)-1)))) = wc(wti(sc):(wti(sc)+wtl(sc)-1));
        end
        wc2=wc;
        for t = n:n+nb-1
            wc2 = [wc(1:(end-2^n)),zeros(1,2^(t)),wc((end-2^n+1):end)];
        end
    end
    
    n2=n+nb;
    matrice2=zeros(n2,2^(n2-1));
    for j = 1:n2
        matrice2(j,1:2^(j-1)) = wc2(2^(j-1)+1:2^(j));
    end;
    %Attention regression jusqu'au niveau 2 (pas le niveau 1 !)

    % redondance
    for j = 1:n
        for k = 1:2^(j-1)
            matrice3(j,1+(k-1)*floor(2^(n-1)/2^(j-1)):(k)*floor(2^(n-1)/2^(j-1))) = matrice1(j,k);
        end
    end

    for k = 1:2^(n-1)
        for j = 1:n
            vecteur1{k}(j) = matrice3(j,k);
        end
    end

    eps1 = 0.001; eps2 = eps1; eps3 = eps1;
    index1=[];
    for k = 1:2^(n-1)
        vecteur_reg1{k} = lmin:lmax; %attention 2<lmin<n
        vecteur1{k} = vecteur1{k}(lmin:lmax);
        if abs(vecteur1{k}(end)) >= eps1 || abs(vecteur1{k}(end-1)) >= eps2
            for t = length(vecteur1{k}):-1:1
                if abs(vecteur1{k}(t)) <= eps3
                    vecteur1{k}(t) = []; vecteur_reg1{k}(t) = [];
                end
            end
            if length(vecteur1{k}) >= 2, index1=[index1 k]; end
        end
    end

    %Regression sur la totalité des coeffs
    for k = index1
        [a_hat,b_hat] = monolr(vecteur_reg1{k},log2(abs(matrice3(vecteur_reg1{k},k))));
        pente1(k) = a_hat;
        ordo(k) = b_hat;
    end

    matrice6(1:n,1:2^(n-1)) = matrice1; matrice6(n+1,1:2^n)=0;
    matrice7(1:n,1:2^(n-1))=matrice1; matrice7(n+1,1:2^n)=0;

    for k = index1
        if pente1(k) < -1/2
            if sign(matrice1(n,k)) > 0 && x(2*k) > x(min(2*k+1,N))
                matrice6(n+1,2*k-1) = 0;%'cas 1';
                matrice6(n+1,2*k) = lambda*sign(matrice1(n,k))*2^(pente1(k)*(n+1)+ordo(k));
            end
            if sign(matrice1(n,k)) < 0 && x(2*k) >= x(min(2*k+1,N))
                matrice6(n+1,2*k) = 0;%'cas 2';
                matrice6(n+1,2*k-1) = lambda*sign(matrice1(n,k))*2^(pente1(k)*(n+1)+ordo(k));
            end
            if sign(matrice1(n,k)) > 0 && x(2*k) <= x(min(2*k+1,N))
                matrice6(n+1,2*k) = 0;%'cas 3';
                matrice6(n+1,2*k-1) = lambda*sign(matrice1(n,k))*2^(pente1(k)*(n+1)+ordo(k));
            end;
            if sign(matrice1(n,k)) < 0  && x(2*k) < x(min(2*k+1,N))
                matrice6(n+1,2*k-1) = 0;%'cas 4';
                matrice6(n+1,2*k) = lambda*sign(matrice1(n,k))*2^(pente1(k)*(n+1)+ordo(k));
            end
        end
    end

    if ~wave_order
        wc3 = wc2;
        for j = 1:n2
            wc3(2^(j-1)+1:2^(j)) = matrice6(j,1:2^(j-1));
        end
        xi = IWT_SBS(wc3,1,qmf,dqmf);
    else
        wc3 = wc2;
        wc3(1) = 2^(n+1); wc3(2) = n+1;
        v = length(wc);
        wc3(v-2^n+1:v) = matrice6(n-sc+1,1:end);
        xi = IWT(wc3);
    end
    x = xi;
end

if marq==1, xi=xi'; end
if ~nowaitbar, fl_waitbar('close',h); end
end
