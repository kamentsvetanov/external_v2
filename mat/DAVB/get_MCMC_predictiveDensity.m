function [pX,gX,pY,gY,X,Y] = get_MCMC_predictiveDensity(f_fname,g_fname,u,n_t,options,dim,N,np)

% Get time
et0 = clock;

% default sample size and histogram resolution
try; N; catch N=1e3; end
try; np; catch np = 50; end

% fix precision parameters
alpha = options.priors.a_alpha./options.priors.b_alpha;
sigma = options.priors.a_sigma./options.priors.b_sigma;

% fill in missing optional fields
try
    if isinf(options.priors.a_alpha)
        options.priors.a_alpha = 1;
        options.priors.b_alpha = 1;
    end
end
options.priors.AR = 0;
options.verbose = 0;
dim.n_t = n_t;
[options] = VBA_check([],u,f_fname,g_fname,dim,options);

fprintf(1,'MCMC sampling...')
fprintf(1,'%6.2f %%',0)
Y = zeros(dim.p,n_t,N);
X = zeros(dim.n,n_t,N);
for i=1:N
    [x0,theta,phi] = sampleFromPriors(options,dim);
    [y,x] = simulateNLSS(...
        n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options,x0);
    Y(:,:,i) = y;
    X(:,:,i) = x;
    fprintf(1,'\b\b\b\b\b\b\b\b')
    fprintf(1,'%6.2f %%',i*100/N)
end
fprintf(1,'\b\b\b\b\b\b\b\b')
fprintf(1,[' OK (took ',num2str(etime(clock,et0)),' seconds).'])
fprintf(1,'\n')

et0 = clock;
fprintf(1,'Forming histograms along X dimensions...')
fprintf(1,'%6.2f %%',0)
pX = zeros(n_t,np,dim.n);
gX = zeros(np,dim.n);
for i=1:dim.n
    Xi = squeeze(X(i,:,:));
    m = mean(Xi(:));
    sv = std(Xi(:));
    nx = m-3*sv:6*sv/(np-1):m+3*sv;
    [ny,nx] = hist(Xi',nx);
    pX(:,:,i) = ny';
    gX(:,i) = nx;
    fprintf(1,'\b\b\b\b\b\b\b\b')
    fprintf(1,'%6.2f %%',i*100/dim.n)
end
fprintf(1,'\b\b\b\b\b\b\b\b')
fprintf(1,[' OK (took ',num2str(etime(clock,et0)),' seconds).'])
fprintf(1,'\n')

et0 = clock;
fprintf(1,'Forming histograms along Y dimensions...')
fprintf(1,'%6.2f %%',0)
pY = zeros(n_t,np,dim.p);
gY = zeros(np,dim.p);
for i=1:dim.p
    Yi = squeeze(Y(i,:,:));
    m = mean(Yi(:));
    sv = std(Yi(:));
    nx = m-3*sv:6*sv/(np-1):m+3*sv;
    [ny,nx] = hist(Yi',nx);
    pY(:,:,i) = ny';
    gY(:,i) = nx;
    fprintf(1,'\b\b\b\b\b\b\b\b')
    fprintf(1,'%6.2f %%',i*100/dim.p)
end
fprintf(1,'\b\b\b\b\b\b\b\b')
fprintf(1,[' OK (took ',num2str(etime(clock,et0)),' seconds).'])
fprintf(1,'\n')



function [x0,theta,phi] = sampleFromPriors(options,dim)

priors = options.priors;

if dim.n > 0
    if ~isequal(priors.SigmaX0,zeros(size(priors.SigmaX0)))
        [u,s,v] = svd(priors.SigmaX0);
        sV = u*sqrt(s)*v';
        x0 = priors.muX0 + sV*randn(dim.n,1);
    else
        x0 = priors.muX0;
    end
else
    x0 = [];
end

if dim.n_theta > 0
    if ~isequal(priors.SigmaTheta,zeros(size(priors.SigmaTheta)))
        [u,s,v] = svd(priors.SigmaTheta);
        sV = u*sqrt(s)*v';
        theta = priors.muTheta + sV*randn(dim.n_theta,1);
    else
        theta = priors.muTheta;
    end
else
    theta = [];
end

if dim.n_phi > 0
    if ~isequal(priors.SigmaPhi,zeros(size(priors.SigmaPhi)))
        [u,s,v] = svd(priors.SigmaPhi);
        sV = u*sqrt(s)*v';
        phi = priors.muPhi + sV*randn(dim.n_phi,1);
    else
        phi = priors.muPhi;
    end
else
    phi = [];
end


