function xspec = contmultspecf(x,varargin)
%CONTMULTSPECF Computes the continuous multifractal spectrum estimation for a 1D function.
%  The code will estimate the multifractal spectrum of any 1D signal. However, for
%  the estimated spectrum to make statistical sense, it is important to check that,
%  at the considered resolutions, a form of scale invariance holds. This is why errorbars
%  are displayed along with the spectrum. We emphasize the fact that the errorbars are NOT
%  an indication that the true spectrum lies within the bars. 
%  Indeed, the theoretical spectrum may be very different from the one estimated at the
%  available scales. Rather, small errorbars should be taken as a sign that the estimation
%  procedure gave consistent results across the considered scales, which means that
%  the estimation is robust.
%
%   SPEC = contmultspecf(X) Estimates the continous multifractal spectrum, SPEC, of
%   the input signal, X using default values. The ouput signal SPEC is a graph structure
%   that contains the type of data SPEC.type, the alpha values, SPEC.alpha, the corresponding
%   spectrum values SPEC.spec and the errorbars SPEC.errors.
%
%   SPEC = contmultspecf(...,'sampling',KV) Computes SPEC using a specific vector
%   KV = [ALPHADISC,EPSIDICS]. ALPHADISC is the number of values used to discretize
%   the abcissa in the spectrum, i.e. the Hölder exponents. EPSIDDISC is the number
%   of values used to discretize the "epsilon" tolerance for the computation of
%   the counts (see the reference below for more details).
%   If SAMPLING is not specified, the default value is KV = [30,20].
%
%   SPEC = contmultspecf(...'limits',KL) Computes SPEC using a specific vector 
%   KL = [MINSCALE, MAXSCALE]. The MINSCALE and MAXSCALE parameters represent
%   respectively the sizes for the minimum and the maximum bins. The
%   parameter KL is particulary used particulary for the kind of
%   pregression (see below).
%   If LIMITS is not specified, the default value is KL = [2,8].
%
%   SPEC = contmultspecf(...,'base',B) Computes SPEC using a specific base value, B,
%   which defines the step for the increase of bin size. The parameter B is particulary
%   used for the kind of pregression (see below).
%   If BASE is not specified, the deafult value is B = 2.
%
%   SPEC = contmultsepcf(...,'PROGRESSION') Computes SPEC using a specific type of
%   progression, which decides how the sizes of the bins increase with scale. The possible
%   PROGRESSION that are available are:
%   - 'linear' in order to use a linear increase by steps of size BASE, i.e. the succesive
%   sizes are: MINSCALE*BASE,(MINSCALE+1)*BASE,...,MAXSCALE*BASE.
%   - 'power' in order to use a power law increase by steps of size BASE, i.e. the succesive
%   size are : BASE^(MINSCALE-1),BASE^MINSCALE,...,BASE^MAXSCALE.
%   If PROGRESSION is not specified, the default value is PROGRESSION = POWER.
%
%   SPEC = contmultspecf(...,'KERNEL') Computes SPEC using a specific type of kernel,
%   which decides how to "count" the number of bins having a given coarse-grained Holder
%   exponent at each scale. The possible KERNEL that are available are: 'epanechnikov' 
%   in order to use a kernel density estimation based on the Epanechnikov kernel,
%   or 'rectangular' in order to use a simple count.
%   If KERNEL is not specified, the default value is KERNEL = EPANECHNIKOV.
%
%   SPEC = contmultspecf(...,'ESTIMTYPE') Computes SPEC using a specific type of
%   method to estimate the most frequent Höler exponent of the signal.
%   Contrarily to the case of measures, there is no natural normalization of the samples. 
%   An affine transform of the input data results in a distorted spectrum. 
%   A simple normalization is to ensure that the mode of the spectrum coincides with
%   the one of the Hölder exponents estimated through oscillations. The possible
%   ESTIMTYPE that are available are: 'hqgv' in order to perform a estimation through
%   Generalized Quadratic Variations, 'hosc' in order to perform the estimation from
%   Oscillations, or 'hdwt' is order to perform a Discrete Wavelet-based estimation.
%   If ESTIMTYPE is not specified, the default value is ESTIMTYPE = HGQV.
%
%   SPEC = contmultspecf(...,'VARTYPE') Computes SPEC using a specific type
%   of variation which decides how to measure the variation of the signal
%   inside a bin. The possible VARTYPE that are available are: 'inc' in
%   order to use the absolute increments between the endpoints of the bin,
%   or 'osc' in order to use the oscillation inside the bin.
%   If VARTYPE is not specified, the default value is VARTYPE = INC.
%
%   SPEC = contmultspecf(...,'SMOOTH') Computes SPEC using the smoothed
%   version of the spectrum or not. The possible options that are available are:
%   'smooth' in order to use the smoothed version or 'nosmooth' in order to
%   use the non-smoothed version.
%   If the option is not specified, the default value is option = SMOOTH.
%
%   Example
%
%   % Synthesize an alpha-stable motion:
%   asm_levy0 = asmlevy(4000,1.5,0);
% 
%   % Estimate its multifractal spectrum:
%   asm_levy0_multspecf0 = contmultspecf(asm_levy0,'hgqv','epanechnikov','inc','smooth','linear','sampling',[30 20],'limits',[2 8],'base',2);
%
%   See also contmultspecm
%
%   References
%
%      [1] On various multifractal spectra
%          J. Lévy Véhel and C. Tricot
%          Fractal Geometry and Stochastics III, Progress in Probability, C.
%          Bandt, U. Mosco and M. Zähle (Eds), Birkhäuser Verlag, Vol. 57, pp.23-42, 2004.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc contmultspecf ">contmultspecf</a>
%
% Author Jacques Lévy-Véhel, November 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
% error(nargchk(3,5,nargin));
% error(nargoutchk(1,3,nargout));

N = length(x);
if nargin > 1
    arguments = varargin;
    list_estim = {'hgqv','hosc','hdwt'};
    
    [estimtype,arguments] = checkforargument(arguments,list_estim,'hgqv');
    [kernel, arguments] = checkforargument(arguments,{'rectangular','epanechnikov'},'epanechnikov');
    [vartype, arguments] = checkforargument(arguments,{'inc','osc'},'inc');
    [optsmooth, arguments] = checkforargument(arguments,{'smooth','nosmooth'},'smooth');
    [progression, arguments] = checkforargument(arguments,{'linear','power'},'power');
    [kv, arguments] = checkforargument(arguments,'sampling',[30,20]);
    if ~isnumeric(kv) || size(kv,1) ~= 1 || size(kv,2) ~= 2, error('Invalid use of sampling property'); end
    alphadisc = kv(1); epsdisc = kv(2);
    [limits,arguments] = checkforargument(arguments,'limits',[2,8]);
    if ~isnumeric(limits) || size(limits,1) ~= 1 || size(limits,2) ~= 2, error('Invalid use of limits property'); end
    minscale = limits(1); maxscale = limits(2);
    [base,arguments] = checkforargument(arguments,'base',2);
    if strcmp(progression{:},'linear')
        if ~(isnumeric(base) && isscalar(base) && base>=1), error('Invalid use of base property'); end
        if maxscale >= N/2, error('Invalid use of limits property'); end
    else
        if ~(isnumeric(base) && isscalar(base) && base>=1.1), error('Invalid use of base property'); end
        if maxscale >= log(N)/log(base), error('Invalid use of limits property'); end    
    end
    if ~isempty(arguments), error('Too many input arguments'); end
else
    estimtype = {'hgqv'}; kernel = {'epanechnikov'};
    vartype = {'inc'}; optsmooth={'smooth'};    
    alphadisc = 30; epsdisc = 20;
    minscale = 2; maxscale = 8; 
    progression = {'power'}; base = 2;
end

%--------------------------------------------------------------------------
%to avoid problems on the sides, the signal is mirrored
%First make sure that the signal is a line rather than a column
s = size(x);
if s(1) > s(2), x = x'; end
fm = [x,fliplr(x)];

%Computation of the coarse-grained exponents: 
%For a 'linear' progression, the values of the measure are grouped by 1,base,2*base,etc, and are then added.
%For a 'power' law progression, the values of the measure are grouped by 1,base,base^2,etc, and are then added.
%Since this is a continuous spectrum, the values are not decimated by
%scale, i.e. there are exactly L coarse-grained exponents at each scale
%between minscale and maxscale. Thus the matrix of coarse-grained
%exponents has size maxscale-minscale+1 x L.
%An exponent is equal to the log of the increment or oscillation of f 
%in a given bin divided by the log of the size of the bin, with 
%the convention that the function is supported on [0,1]. Thus, for a bin 
%composed of k samples, the size is k/L.
fms=zeros(1,N);
alphank=zeros(maxscale-minscale+1,N);

if strcmp(vartype{:},'osc')
    if strcmp(progression{:},'linear')
        for i = minscale:maxscale
            for j=1:N
                fms(j) = max(fm(j:round(j+i*base-1)))- min(fm(j:round(j+i*base-1)));
                alphank(i-minscale+1,j) = log(fms(j))/(log(round(i*base))-log(N));
            end
        end
    else
        for i = minscale:maxscale
            for j=1:N
                fms(j) = max(fm(j:round(j+base^(i-1)-1)))- min(fm(j:round(j+base^(i-1)-1)));
                alphank(i-minscale+1,j) = log(fms(j))/(log(round(base^(i-1)))-log(N));
            end
        end
    end
else
    if strcmp(progression{:},'linear')
        for i = minscale:maxscale
            for j=1:N
                fms(j) = abs(fm(round(j+i*base-1))- fm(j));
                alphank(i-minscale+1,j) = log(fms(j))/(log(round(i*base))-log(N));
            end
        end
    else
        for i = minscale:maxscale
            for j=1:N
                fms(j) = abs(fm(round(j+base^(i-1)-1))- fm(j));
                alphank(i-minscale+1,j) = log(fms(j))/(log(round(base^(i-1)))-log(N));
            end
        end
    end
end

%Renormalization of the coarse-grained exponents: first the (non-coarse-grained) Hölder
%exponents are estimated through oscillations,
%GQV or wavelets:
switch estimtype{:}
    case 'hosc'
        H = estimOSC1DH(x,2.1,0.1,0.3,'ls');
    case 'hgqv'
        H = estimGQV1DH(x,0.8,1,[1:1:5]); %#ok<NBRAK>
    case 'hdwt'
        H=DWTestim_all(x,[],{'ls'},'daubechies',10,0,0,0.5,1,1,1,0,[1 2 3 4 5 6 7 8 9 10 11 12]);
end

%At each scale, alphank is  translated so that its mode coincides with the one of H.
%When the mod of H is estimated, 10% points are not included in the computation on each side.
Hmod = median(H(round(N/10):round(9*N/10)));
for i = minscale:maxscale
    alphank(i-minscale+1,:) = alphank(i-minscale+1,:) - median(alphank(i-minscale+1,:))+ Hmod;
end

%It might occur that some alphank are infinite when the signal is constant
%over an interval or when increments are used and two points have same values.
%We filter those out. This has to be done after the median alignment because
%MatLab yields an NaN for median when the data contains Nan: "NaN" fools "median"
%but not "max" and "min", while "Inf" fools "max" but not "median"...
alphank =  alphank.*isfinite(alphank);

%Computation of the overall bounds for the vector of discretized coarse-grained exponents: 
%these are just the smallest and largest observed coarse-grained exponents
alphamin = min(min(alphank)); alphamax=max(max(alphank));
%Computation of the vector of coarse-grained exponents. 
alphavect = alphamin:(alphamax-alphamin)/(alphadisc-1):alphamax;
%Computation of the overall bounds for the tolerance parameters
%epsilon and of the matrice of tolerance : each line corresponds to a scale.
%First the computed coarse-grained exponents are sorted:
alphasort = sort(alphank,2); 
epsmat = zeros(maxscale-minscale+1,epsdisc);
%The smallest epsilon at all scales is half the largest distance between two consecutive
%coarse-grained exponents once they have been sorted:
epsmat(:,1) = max(diff(alphasort'))'/2+0.001;
%The largest epsilon at all scales is half the distance between the smallest and largest
%coarse-grained exponents:
epsmat(:,end) = ((alphasort(:,end)-alphasort(:,1))/2+0.001);
%Between these values, a power law is used for the progression of epsilon:
epspas = (epsmat(:,end)./epsmat(:,1)).^(1/(epsdisc-1));
for j = 1:maxscale-minscale+1
    for k = 2:epsdisc-1
        epsmat(j,k) = epsmat(j,k-1)*epspas(j);
    end
end

%Initialisation of the counts: Nn(i,j,k) is the number of coarse-grained exponents at scale(i)
%which are within distance epsilon(j) from the discretized value alpha(k). 
%Kn is a wighted version of Nn: instead of counting, one uses a kernel to obtain smoother results.
if strcmp(kernel{:},'rectangular')
    Nn = zeros(maxscale-minscale+1,epsdisc,alphadisc);
    h_waitbar = fl_waitbar('init');
    % Couting the Nn:
    for i = 1:alphadisc
        fl_waitbar('view',h_waitbar,i,alphadisc);
        for niv = 1:maxscale-minscale+1
            for ep = 1:epsdisc
                Nn(niv,ep,i) = sum(abs(alphank(niv,:)-alphavect(i))<epsmat(niv,ep));
            end
        end
    end
    fl_waitbar('close',h_waitbar);
    % The key quantities are the log of the previous counts renormalized by the log of the number
    % of all possible exponents, i.e. log(N). To avoid problem in the sequel when taking the log
    % in case the counts are 0, we consider version of LNLL where -Inf are replaced by NaN when 
    % computing mean, min and max: this is fLNLL. However, for computing medians, we need Inf rather than NaN...
    LNLL = log(Nn(:,:,:))/log(N); 
    fLNLL = LNLL.*isfinite(LNLL);
    
    if strcmp(optsmooth{:},'smooth')
        %Finally, smoothed versions are computed:
        sp = smooth(reshape(fLNLL(1,1,:),1,alphadisc),12);
        a = (1-min(sp))/(max(sp)-min(sp));
        b = 1-a*max(sp);
        sp = a*sp+b;

        spopt = zeros(maxscale-minscale+1, alphadisc);
        spopt(1,:) = sp;
        for niv = 2:maxscale-minscale+1
            err = Inf; eopt=1;
            spe = zeros(alphadisc,epsdisc);
            for e = 1:epsdisc
                spe(:,e) = smooth(reshape(fLNLL(niv,e,:),1,alphadisc),12);
                a = (1-min(spe(:,e)))/(max(spe(:,e))-min(spe(:,e)));
                b = 1-a*max(spe(:,e));
                spe(:,e) = a*spe(:,e)+b;
                spee=spe(:,e);
                if norm(spee(find(isfinite(spee+sp)))-sp(find(isfinite(spee+sp)))) %#ok<FNDSB>
                    err = norm(spee(find(isfinite(spee+sp)))-sp(find(isfinite(spee+sp)))); %#ok<FNDSB>
                    eopt = e;
                end
            end
            spopt(niv,:)=spe(:,eopt);
        end
        resultat = spopt(2,:);
        stdresultat = std(spopt);
    else
        % Initialization of the "median" spectra: fm is the median of the LNLL. The idea is that
        % the median will be the best estimate.
        sn = size(Nn);
        % We may now evaluate the robustness, or, equivalently, the "multifractal
        % behaviour" of our data: we compute the "best" spectra by minimizing over
        % epsilon at each scale. This will allow to check whether the spectra at
        % different scales look alike: The matrices below will yield errorbars
        % for the estimated spectra.
        fechellem=zeros(sn(1),sn(3));
        for i = 1:sn(1)
            %to compute medians, we filter out NaNs and Infs.
            for k = 1:sn(3)
                eLNLL=[];
                for ep = 1:epsdisc
                    if isfinite(LNLL(i,ep,k))
                        eLNLL = [eLNLL,LNLL(i,ep,k)];
                    end
                end
                fechellem(i,k)=median(eLNLL);
            end
        end
        % The reference spectra obtained with this approach are the ones at scale 2:
        % scale 1 is often to sensitive to small variations, while scales larger
        % than 2 tend to smooth too much the data. Again we rescale to have max=1:
        fech2 = fechellem(2,:);
        a = (1-min(fech2))/(max(fech2)-min(fech2));
        b = 1-a*max(fech2);
        fech2 = a*fech2+b;
        resultat = fech2;
        stdresultat = std(fechellem);        
    end
%     % A theorem asserts that the maximum of the coarse-grained spectrum is equal to the dimension
%     % of the support of the measure. We assume in this code that x is has support [0,1], 
%     % thus the max of all spectra is 1. We take advantage of this fact by rescaling all the
%     % estimated spectra in a multiplicative way so that its max is 1
    
%     % Since the code will always yield a spectrum, whatever the data are, it is important to be
%     % able to assess whether this spectrum has any meaning at all: for the estimation to make sense,
%     % we should have that the renormalized log-counts at various scales are not too different
%     % from each other. In that view, for each alpha(k), any given scale(i) and any epsilon(j),
%     % we compute the smallest distance between LNLL(i,j,k) and all other LLNL on another "line",
%     % i.e. another scale and all possible tolerances epsilon. All these distances are then summed up
%     % to obtain a "score" that depends on i,j,k: this score is the smallest variation between
%     % the estimate LNLL(i,j,k) and the estimates at all other scales and tolerances. 
%     % Then, for any given alpha, we choose the estimate that minimizes this score. 
%     score = zeros(size(LNLL));
%     for k = 1:sn(3)
%         for i = 1:sn(1)
%             for j = 1:sn(2)
%                 for m = 1:sn(1)
%                     score(i,j,k) = score(i,j,k) + min(abs(fLNLL(i,j,k)-fLNLL(m,:,k)));
%                 end
%             end
%         end
%     end
else
    Kn = zeros(maxscale-minscale+1,epsdisc,alphadisc);
    h_waitbar = fl_waitbar('init');
    % "Couting" the Kn: this amounts to a kernel-based density estimation:
    for niv = 1:maxscale-minscale+1
        fl_waitbar('view',h_waitbar,niv,maxscale-minscale+1);
        for ep = 1:epsdisc
            Kn(niv,ep,:) = ksdensity(alphank(niv,:),alphavect,'width',epsmat(niv,ep)/2,'kernel','epanechnikov');
        end
    end
    fl_waitbar('close',h_waitbar);
    % The key quantities are the log of the previous counts renormalized by the log of the number
    % of all possible exponents, i.e. log(N). To avoid problem in the sequel when taking the log
    % in case the counts are 0, we replace -Inf by NaN
    LKLL = 1+log(Kn(:,:,:))/log(N);
    fLKLL = LKLL.*isfinite(LKLL);
    
%     % A theorem asserts that the maximum of the coarse-grained spectrum is equal to the dimension
%     % of the support of the measure. We assume in this code that x is has support [0,1], 
%     % thus the max of all spectra is 1. We take advantage of this fact by rescaling all the
%     % estimated spectra in a multiplicative way so that its max is 1:
%     
%     %Since the code will always yield a spectrum, whatever the data are,
%     %it is important to be able to assess whether this spectrum has
%     %any meaning at all: for the estimation to make sense, we should
%     %have that the renormalized log-counts at various scales are not too
%     %different from each other. In that view, for each alpha(k), any given
%     %scale(i) and any epsilon(j), we compute the smallest distance between
%     %LNLL(i,j,k) and all other LLNL on another "line", i.e. another scale
%     %and all possible tolerances epsilon. All these distances are then
%     %summed up to obtain a "score" that depends on i,j,k: this score is the
%     %smallest variation betwenn the estimate LNLL(i,j,k) and the estimates at
%     %all other scales and tolerances. Then, for any given alpha, we choose the
%     %estimate that minimizes this score. Of course the same is done for Kn.
%     scoreK = zeros(size(LKLL));
%     for k = 1:sn(3)
%         for i = 1:sn(1)
%             for j = 1:sn(2)
%                 for m = 1:sn(1)
%                     scoreK(i,j,k) = scoreK(i,j,k) + min(abs(fLKLL(i,j,k)-fLKLL(m,:,k)));
%                 end
%             end
%         end
%     end
    
    if strcmp(optsmooth{:},'smooth')
        %Finally, smoothed versions are computed:
        spk = smooth(reshape(fLKLL(1,1,:),1,alphadisc),6);
        a = (1-min(spk))/(max(spk)-min(spk));
        b = 1-a*max(spk);
        spk = a*spk+b;
        
        spoptk = zeros(maxscale-minscale+1, alphadisc);
        spoptk(1,:) = spk;
        for niv = 1:maxscale-minscale+1
            err = Inf; eopt=1;
            spek = zeros(alphadisc,epsdisc);
            for e = 1:epsdisc
                spek(:,e) = smooth(reshape(fLKLL(niv,e,:),1,alphadisc),12);
                a = (1-min(spek(:,e)))/(max(spek(:,e))-min(spek(:,e)));
                b = 1-a*max(spek(:,e));
                spek(:,e) = a*spek(:,e)+b;
                speke=spek(:,e);
                if norm(speke(find(isfinite(speke+spk)))-spk(find(isfinite(speke+spk)))) %#ok<FNDSB>
                    err = norm(speke(find(isfinite(speke+spk)))-spk(find(isfinite(speke+spk)))); %#ok<FNDSB>
                    eopt = e;
                end
            end
            spoptk(niv,:) = spek(:,eopt);
        end
        resultat = spoptk(2,:);
        stdresultat = std(spoptk);
    else
        % Initialization of the "median" spectra: fk is the median of the LKLL. 
        % The idea is that the median will be the best estimate. 
        % Since Kn is a density rather than a count, one has to add 1 in this case: 
        % indeed, roughly speaking, Kn(x,y,z) "=" Nn(x,y,z)/N, thus a 1 pops up when taking the log.
        sn = size(Kn);
        % We may now evaluate the robustness, or, equivalently, the "multifractal
        % behaviour" of our data: we compute the "best" spectra by minimizing over
        % epsilon at each scale. This will allow to check whether the spectra at
        % different scales look alike: The matrices below will yield errorbars
        % for the estimated spectra.
        fechellemK=zeros(sn(1),sn(3));
        for i = 1:sn(1)
            %to compute medians, we filter out NaNs and Infs.
            for k = 1:sn(3)
                eLKLL = [];
                for ep = 1:epsdisc
                    if isfinite(LKLL(i,ep,k))
                        eLKLL = [eLKLL,LKLL(i,ep,k)];
                    end
                end
                fechellemK(i,k) = median(eLKLL);
            end
        end
        % The reference spectra obtained with this approach are the ones at scale 2:
        % scale 1 is often to sensitive to small variations, while scales larger
        % than 2 tend to smooth too much the data. Again we rescale to have max=1:
        fechk2 = fechellemK(2,:);
        ak = (1-min(fechk2))/(max(fechk2)-min(fechk2));
        bk = 1-ak*max(fechk2);
        fechk2 = ak*fechk2+bk;
        resultat = fechk2;
        stdresultat = std(fechellemK);        
    end
end
figure; errorbar(alphavect,resultat,stdresultat);
xspec = struct('type','graph','alpha',alphavect,'spec',resultat,'errors',stdresultat);
end