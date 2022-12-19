clear all, randn('seed',0), rand('seed',0), %profile on

% set up data 
load digits.mat; 
X=X/max(max(X));

% set up MF ICA
par.sources=25;                         % number of sources
par.optimizer = 'aem' ;                 % optimizer
par.solver = 'ec' ; %variational' ;     % solver
par.method = 'positive' ;               % positive ICA
%possible methods: {'positive','neg_kurtosis','pos_kurtosis','fa','ppca'}
par.Sigmaprior = 'isotropic' ;          % noise variance

par.S_tol = 1e-15 ;                     % error tolerance E-step
par.S_max_ite = 100 ;                   % maximum number of iterations E-step                 
par.tol = 1e-5;                         % error tolerance M-step for bfgs and conjgrad 
par.max_ite = 5;                       % maximum number of iterations M-step
par.draw = 1 ;                          % plot run time information

sparseimages = 1 ; 
if sparseimages
    
% run ICA
bic=0; % to bic or not to bic
if bic    
  Minterval = 1:10;  
  icaMFbic(X,par,Minterval);
else
  [S,A,loglikelihood,Sigma]=icaMF(X,par); 

  figure(1), clf, title('columns in S - sparse represenation')
  nplot = ceil(sqrt(par.sources)) ;
  colormap(1-gray);
  for mm=1:par.sources;
    subplot(nplot,nplot,mm);
    imagesc(reshape(S(mm,:),16,16)');
    if mm == par.sources - 0.5 * ( sqrt(par.sources)  - 1 )
      xlabel('columns in S - sparse represenation')
    end
  end;
  %xlabel('columns in S - sparse represenation')

  figure(2), clf, title('A representation for 3 3s')
  colormap(1-gray);
  for i=1:3
    subplot(3,2,2*i-1);
    imagesc(reshape(X(i,:),16,16)');
    subplot(3,2,2*i);
    bar(A(i,:))
    axis([0 par.sources+1 min(A(i,:)) max(A(i,:))]) 
  end;
  xlabel('A representation for 3 3s')
  
  nmf = 0 ; % negative matrix factorization
  if nmf 
  fact = nmwfls(X,par.sources) ;
  Anmf = fact{1} ; Snmf = fact{2}';
  
  figure(3), clf, title(' NMF: columns in S - sparse represenation')
  colormap(1-gray);
  for mm=1:par.sources;
    subplot(nplot,nplot,mm);
    imagesc(reshape(Snmf(mm,:),16,16)');drawnow;
    if mm == par.sources - 0.5 * ( sqrt(par.sources)  - 1 )
      xlabel(' NMF: columns in S - sparse represenation')
    end
  end;
  %xlabel(' NMF: columns in S - sparse represenation')

  figure(4), clf, title(' NMF: A representation for 3 3s')
  colormap(1-gray);
  for i=1:3
    subplot(3,2,2*i-1);
    imagesc(reshape(X(i,:),16,16)');
    subplot(3,2,2*i);
    bar(Anmf(i,:))
    axis([0 par.sources+1 min(Anmf(i,:)) max(Anmf(i,:))]) 
  end;
  xlabel(' NMF: A representation for 3 3s')
  end
  
end
    
else % sparse weights (sources)

X = X' ; % transpose the data   
    
% run ICA
bic=0; % to bic or not to bic
if bic    
  Minterval = 1:10;  
  icaMFbic(X,par,Minterval);
else
  [S,A,loglikelihood,Sigma]=icaMF(X,par); 

  figure(1), clf, title('columns in A - sparse represenation')
  nplot = ceil(sqrt(par.sources)) ;
  colormap(1-gray);
  for mm=1:par.sources;
    subplot(nplot,nplot,mm);
    imagesc(reshape(A(:,mm),16,16)');
    if mm == par.sources - 0.5 * ( sqrt(par.sources)  - 1 )
      xlabel('columns in A - sparse represenation')
    end
  end;
  %xlabel('columns in A - sparse represenation')

  figure(2), clf, title('hidden representation for 3 3s')
  colormap(1-gray);
  for i=1:3
    subplot(3,2,2*i-1);
    imagesc(reshape(X(:,i),16,16)');
    subplot(3,2,2*i);
    bar(S(:,i))
    axis([0 par.sources+1 min(S(:,i)) max(S(:,i))]) 
  end;
  xlabel('hidden representation for 3 3s')
  
  figure(3), clf, title('sampling from the generative mode for 3s')
  colormap(1-gray);
  for mm=1:par.sources;
    subplot(nplot,nplot,mm);
    imagesc(reshape(-A*log(rand(par.sources,1)),16,16)');
    if mm == par.sources - 0.5 * ( sqrt(par.sources)  - 1 )
      xlabel('sampling from the generative mode for 3s')
    end
  end; 
  %xlabel('sampling from the generative mode for 3s')
  
  nmf = 0 ; 
  if nmf
  fact = nmwfls(X,par.sources) ;
  Anmf = fact{1} ; Snmf = fact{2}';

  figure(4), clf, title('NMF: columns in A - sparse represenation')
  colormap(1-gray);
  for mm=1:par.sources;
    subplot(nplot,nplot,mm);
    imagesc(reshape(Anmf(:,mm),16,16)');
    if mm == par.sources - 0.5 * ( sqrt(par.sources)  - 1 )
      xlabel('NMF: columns in A - sparse represenation')
    end
  end;
  %xlabel('NMF: columns in A - sparse represenation')

  figure(5), clf, title('NMF: hidden representation for 3 3s')
  colormap(1-gray);
  for i=1:3
    subplot(3,2,2*i-1);
    imagesc(reshape(X(:,i),16,16)');
    subplot(3,2,2*i);
    bar(Snmf(:,i))
    axis([0 par.sources+1 min(Snmf(:,i)) max(Snmf(:,i))]) 
  end;
  xlabel('NMF: hidden representation for 3 3s')
  end
  
end

end
