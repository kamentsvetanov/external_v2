function [P,logP]=icaMFbic(X,par,Mint)  

% ICAMFBIC  Mean field independent component analysis (ICA) 
%    [P,logP]=ICAMFBIC(X,par,M)     
%    Uses ICAMF and the Bayes Information criterion 
%    (BIC) [1] to estimate the number of sources. 
%
%    Input and output arguments: 
%       
%     X        : Mixed signal
%     par      : Specifies the parameters used in ICAMF
%     Mint     : Vector or scalar holding the number of 
%                source to be investigated, default K=[1:10].   
%     P        : Normalized model probability.
%     logP     : Model log probability.
%
%    par and Mint are optional parameters.
                                       
% - by Ole Winther 2002 and 2005 - IMM, Technical University of Denmark
% - version 1.0

% Bibtex references:
% [1]  
%   @incollection{mackay92bayesian,
%       author = "D.J.C. MacKay",
%       title = "Bayesian Model Comparison and Backprop Nets",
%       booktitle = "Advances in Neural Information Processing Systems 4",
%       publisher = "Morgan Kaufmann Publishers",
%       editor = "John E. Moody et al.",
%       pages = "839--846",
%       year = "1992",
% }

% parse input
if nargin<2
  par=[];
end
if nargin<3
  Mint=[1:10];
end
try 
  par.Ainit;
  nerror('par.Ainit is not allowed be defined')
end 

try draw = par.draw; catch draw=0; end 
par.draw=0; % don't plot run time info for each run

if draw
    h = waitbar(0,'Mean Field ICA - running BIC...') ;
end

index=0;  
N=size(X,2);

for k=Mint
  index=index+1;

  if draw waitbar(index/length(Mint),h), end
  
  % estimate ICA
  par.sources=k;
  [S,A,loglikelihood,Sigma]=icaMF(X,par);

  % bic term
  [D,M]=size(A);
  if size(Sigma,2)~=1 % full covariance
    Sigma_par=D*(D+1)/2;
  else
    Sigma_par = length(Sigma);
  end
  dim = D*M + Sigma_par; % number of parameters not integrated over
  
  logP(index)=N*loglikelihood - 0.5*dim*log(N); % loglikelihood is loglikelihood per sample
  
  if draw 
    if size(Sigma,1) * size(Sigma,2) == D
      fprintf(' noise variance = %g \n\n',sum(Sigma)/D);
    else       
      fprintf(' noise variance = %g \n\n',trace(Sigma)/size(Sigma,1));
    end  
    fprintf(' M = %d, loglikelihood = %g, loglikelihoodBIC = %g per sample\n\n',M,loglikelihood,logP(index)/N);
  end
  
end;

par.draw = draw; 

% Normalize
P=exp((logP-max(logP))); 
P=P/sum(P);

if nargout<1,
  %figure(1), clf, title('M = number of sources')  
  bar(Mint,P); ylabel('P(M)'); xlabel('M');
end
