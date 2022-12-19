function [P,logP]=icaML_bic(X,K,draw)  
% icaML_bic : ICA by ML with square mixing matrix and no noise.
%
% function [P,logP]=icaML_bic(X,[K],[draw])     Use Bayes Information Criterion (BIC) [1] to
%                                               estimate number of components with the maximum
%                                               likelihood ICA (icaML) algorithm. SVD is used for 
%                                               dimension reduction.
%                                       
%                                               X     : Mixed signal matrix [M x N] or a struct
%                                                       holding the solution to the [U,S,V]=SVD(X), 
%                                                       thus X.U=U, X.S=S and X.V=V.
%                                               K     : Vector or scalar holding the number of 
%                                                       IC components to investigate. Values
%                                                       must be greater than 1. Default K=[2:10].
%                                               draw  : Output run-time information if draw=1. 
%                                                       Default draw=0.            
%
%                                               P     : Normalized model probability.
%                                               logP  : Model negative log probability.
%                                       
% - by Thomas Kolenda 2002 - IMM, Technical University of Denmark
% - version 1.2a

% Bibtex references:
% [1]  
%  @article{Hansen2001BIC,
%       author =       "Hansen, L. K. and Larsen, J. and Kolenda, T.",
%       title =        "Blind Detection of Independent Dynamic Components",
%       journal =      "In proc. IEEE ICASSP'2001",
%       volume =       "5",
%       pages =        "3197--3200",
%       year =         "2001",  
%       url =          "http://www.imm.dtu.dk/pubdb/views/edoc_download.php/827/pdf/imm827.pdf", 
%  }


% parse input
if nargin<2,
  K = [2:10];
end
if nargin<3,
  draw = 0;
end

if isstruct(X)==0,
  % Reduce dimension with PCA
  [M,N] = size(X);
  if N>M % Transpose if matrix is flat to speed up the svd and later transpose back again
    if draw==1,disp('Transpose SVD');end
    [V,D,U] = svd(X',0);
  else;  
    if draw==1,disp('SVD');end
    [U,D,V] = svd(X,0);
  end;
else
  U = X.U;
  D = X.S;
  V = X.V;
end;

M = size(U,1);
N = size(V,1);
X = D*V';

if draw==1,disp(sprintf('M=%d N=%d',M,N));end

index=0;  
for k = K,
  index = index+1;
  if draw==1,disp(sprintf('dim=%d',k));end

  % estimate ICA
  [S,A] = icaML(X(1:k,:));

  % log likelihood of ica
  logP(index) = N*log(abs(det(inv(A)))) - sum(sum(log( cosh(S) ))) - N*k*log(pi);

  % log likelihood of non included PCA space
  if k<M,
      V_UD = U(:,k+1:end)*D(k+1:end,k+1:end);
      sigma2 = sum(sum(V_UD.*V_UD))/((M-k)*N);
      
      logP(index) = logP(index) - 0.5*(M-k)*N*( log( 2 * pi * sigma2 ) + 1);
  end
  
  % bic term
  dim = k*(2*M-k+1)/2 + 1 + k*k ; % number of parameters to estimate
  logP(index) = logP(index) - 0.5*dim*log(N);
end;

% Normalize
P = exp( ( logP - max(logP) ) ); 
P = P / sum(P);


if nargout<1,
  bar(K,P); ylabel('P(K)'); xlabel('K');
end