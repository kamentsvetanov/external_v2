clear all, randn('seed',0), rand('seed',0), %profile on

% set up data 
load brain_images.mat;
% data consists of a time-series of 80 frames of 29*33 pixel images
% activiation study of rest-activity-rest-activity (20 frames each).
X=X11/max(max(abs(X11)));                    % this is spatial ICA
%X=X11'/max(max(abs(X11)));                  % this is temporal ICA

% X = X .* (X>0) ; remove negative values

% set up MF ICA
par.sources=4;                         % number of sources
par.optimizer = 'aem' ;                % optimizer
par.solver = 'ec'; %variational' ;     % solver
%par.method = 'positive' ;               % positive ICA
% possible methods: {'positive','neg_kurtosis','pos_kurtosis','fa','ppca'}
par.Sigmaprior = 'isotropic' ;          % noise variance

par.S_tol = 1e-16 ;                     % error tolerance E-step
par.S_max_ite = 100 ;                   % maximum number of iterations E-step                 
par.tol = 1e-5;                         % error tolerance M-step for bfgs and conjgrad 
par.max_ite = 50;                       % maximum number of iterations M-step
par.draw = 1 ;                          % plot run time information

% run ICA
bic=1; % to bic or not to bic
if bic               
  Minterval = 1:5 ;
  icaMFbic(X,par,Minterval);
else
  [S,A,loglikelihood,Sigma]=icaMF(X,par); 

  figure(1)
  nplot = ceil(sqrt(par.sources)) ;
  clf, title('estimated sources - brain images')
  colormap('default') %colormap(gray);
  for mm=1:par.sources;
    subplot(nplot,nplot,mm);
    imagesc(flipud(reshape(S(mm,:),29,33)'));
    if mm == par.sources - 0.5 * ( sqrt(par.sources)  - 1 )
      xlabel('estimated sources - brain images')
    end
  end;
  bigfig(12,2,10)
  figure(2)
  clf, title('estimated mixing matrix - brain images')
  D=size(A,1);
  for mm=1:par.sources;
    subplot(nplot,nplot,mm);
    plot(1:D,A(:,mm)), hold on
    axis([1 D min(A(:,mm)) max(A(:,mm))])
    plot(1:D,paradigm*max(A(:,mm)),'r--'), hold off
    if mm == par.sources - 0.5 * ( sqrt(par.sources)  - 1 )
      xlabel('estimated mixing matrix - brain images')
    end
  end;
  
  %subplot(nplot,nplot,nplot^2);
  %Minterval = 1:5 ;
  %icaMFbic(X,par,Minterval);
  
  bigfig(12,2,10)
  
end
