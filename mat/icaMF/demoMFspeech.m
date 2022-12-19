clear all, randn('seed',1234), rand('seed',1234), %profile on

% set up data 
load speech.mat
M=2; % number of sources
%M=2 is square mixing 2->2 and M=3 is underdetermined 3->2 
N=8000; % number of samples
% normalize sources
Sr=S(:,1:N)./repmat(max(abs(S(:,1:N)),[],2),1,N);
% mix with predefined A and add noise
sigma2=0.0; 
D=size(A,1);
X=A(:,1:M)*Sr(1:M,:)+sqrt(sigma2)*randn(D,N);

% set up MF
par.optimizer = 'aem' ;                 % optimizer
par.solver = 'ec'; %variational' ;      % solver
par.sources = M ;                       % number of sources
par.Aprior = 'free' ;                   % free optimization
par.Sprior = 'mog' ;                    % mixture of Gaussians (heavy-tailed)
%par.Sprior = 'combi' ;                 % the same prior defined with combi 
%par.S(1).prior= 'mog' ;
%par.S(2).prior = 'mog' ;
prior.Sigmaprior = 'isotropic' ;        % noise variance

par.S_tol = 1e-15 ;                     % error tolerance E-step
par.S_max_ite = 100 ;                   % maximum number of iterations E-step                 
par.tol = 1e-5;                         % error tolerance M-step for bfgs and conjgrad 
par.max_ite = 50;                       % maximum number of iterations M-step
par.draw = 1 ;                          % plot run time information

% run MF
[Sest,Aest,ll,Sigma,chiv3] = icaMF(X,par) ;

% run ML
[SestML,AestML,llML]=icaML(X);
llML=llML/(M*N);

figure(1)
clf, title('true vs estimated sources - MF')
MMF=size(Sest,1);
corrMF=zeros(M,MMF);
k=0;
for i=1:M
  for j=1:MMF
    k=k+1;
    subplot(M,MMF,k); plot(Sr(i,:),Sest(j,:),'.')
    corrMF(i,j)=abs((Sr(i,:)*(Sest(j,:))')/sqrt(Sr(i,:)*(Sr(i,:))'*Sest(j,:)*(Sest(j,:))'));
  end
end
corrMF

figure(2) 
clf, title('true vs estimated sources - ML') 
MML=size(SestML,1);
corrML=zeros(M,MML);
k=0;
for i=1:M
  for j=1:MML
    k=k+1; 
    subplot(M,MML,k); plot(Sr(i,:),SestML(j,:),'.')
    corrML(i,j)=abs((Sr(i,:)*(SestML(j,:))')/sqrt(Sr(i,:)*(Sr(i,:))'*SestML(j,:)*(SestML(j,:))'));
  end
end
corrML

figure(3)   
clf, title('A-directions and scatter-plot of X'); hold on
plot(X(1,:),X(2,:),'.')
for i=1:M plot([0 A(1,i)],[0 A(2,i)],'g','LineWidth',2); end
n=sqrt(diag(Aest'*Aest));
for i=1:MMF plot([0 Aest(1,i)/n],[0 Aest(2,i)/n],'r','LineWidth',2); end
n=sqrt(diag(AestML'*AestML));
for i=1:MML plot([0 AestML(1,i)/n],[0 AestML(2,i)/n],'m','LineWidth',2); end

figure(4);
clf, title('original speech signals'); 
for i=1:M subplot(M,1,i); plot(Sr(i,:)); end

figure(5); 
clf, xlabel('reconstructed speech - MF');
for i=1:MMF subplot(MMF,1,i); plot(Sest(i,:)./repmat(max(abs(Sest(i,:)),[],2),1,N)); end

figure(6); 
clf, xlabel('reconstructed speech - ML');
for i=1:MML subplot(MML,1,i); plot(SestML(i,:)); end

figure(7);
clf, xlabel('mixed signals');
for i=1:2 subplot(2,1,i); plot(X(i,:)); end

% profview, profile off
