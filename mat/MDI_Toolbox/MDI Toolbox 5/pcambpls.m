function [X,m,S,It,diff,Xrec]=pcambpls(X,A,maxiter,tol)
% Missing Data Imputation Toolbox v1.0
% A. Folch-Fortuny, F. Arteaga and A. Ferrer
% Copyright (C) 2015 A. Folch-Fortuny and F. Arteaga
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%
% INPUTS
%
% X: data matrix with NaNs for the missing data.
% A: number of principal components.
%
% OUTPUTS
%
% X: original data set with the imputed values.
% m: estimated mean vector of X.
% S: estimated covariance matrix of X.
% It: number of iterations.
% Xrec: PCA reconstruction of X with A components. 


[n,p]=size(X);
for i=n:-1:1,
  r=~isnan(X(i,:));
  pat(i).O=find(r==1); % observed variables (subset of {1,2,...,p})
  pat(i).M=find(r==0); % missing variables (subset of {1,2,...,p})
  pat(i).nO=size(pat(i).O,2); % #{pat(i).O}
  pat(i).nM=size(pat(i).M,2); % #{pat(i).M}
end
mis=isnan(X);
[r c]=find(isnan(X));
X(mis)=0;
meanc=sum(X)./(n-sum(mis));
for k=1:length(r),
  X(r(k),c(k))=meanc(c(k));
end

h1 = waitbar(0,'Please wait...',...
    'Color',[0.5 0.6 0.7],... % background color
    'Name','Iteration number:',... % figure title
    'Position',[500 400 364 60]); % position of the figure
waitbar(0/maxiter,h1,[num2str(0)])

h2 = waitbar(0,'Please wait...',...
    'Color',[0.5 0.6 0.7],... % background color
    'Name','Actual tolerance:',... % figure title
    'Position',[500 300 364 60]); % position of the figure
waitbar(0,h2,[num2str(0)])

diff=100;
It=0;
while It<maxiter & diff>tol,
  It=It+1;
  Xmis=X(mis);
  mX=mean(X);
  S=cov(X);
  Xc=X-ones(n,1)*mX;
  for i=1:n,            % for each row
    if pat(i).nM>0,     % if there are missing values
      S11=S(pat(i).O,pat(i).O);
      S21=S(pat(i).M,pat(i).O);
      X1=Xc(:,pat(i).O);
      X2=Xc(:,pat(i).M);
      L=PLSred(X1,X2,min(A,pat(i).nO));
      z1=Xc(i,pat(i).O)';
      z2=S21*L*pinv(L'*S11*L)*L'*z1;
      Xc(i,pat(i).M)=z2';
    end
  end
  X=Xc+ones(n,1)*mX;
  d=(X(mis)-Xmis).^2;
  diff=mean(d);
  
  if rem(It,10)==0
    waitbar(It/maxiter,h1,[num2str(It)])
    waitbar(1-(diff-tol)/diff,h2,[num2str(diff)])
  end
  
end
S=cov(X);
m=mean(X);
[u d v]=svd(S,0);
P=v(:,1:A);
T=(X-ones(n,1)*m)*P;
Xrec=ones(n,1)*m+T*P';

close(h1)
close(h2)


function [Wstar]=PLSred(X,Y,A)
[N,K]=size(X);M=size(Y,2);
% Scores and Loadings
T=zeros(N,A);U=zeros(N,A);
W=zeros(K,A);C=zeros(M,A);
P=zeros(K,A);
nIt=zeros(1,A+1);
Tol=1e-10;
Xc=X;Yc=Y;
mX=mean(Xc);mY=mean(Yc);
E=Xc-ones(N,1)*mX;
F=Yc-ones(N,1)*mY;
for a=1:A,
  u=F(:,1);
  dif=100;
  while dif>Tol,
    nIt(a)=nIt(a)+1;
    w=E'*u/(u'*u);
    w=w/norm(w);
    t=E*w;
    c=F'*t/(t'*t);
    unew=F*c/(c'*c);
    dif=norm(unew-u);
    u=unew;
  end % while PLS
  p=E'*t/(t'*t);
  E=E-t*p';F=F-t*c';
  U(:,a)=u(:,1);T(:,a)=t(:,1);
  W(:,a)=w(:,1);C(:,a)=c(:,1);
  P(:,a)=p(:,1);
end    
Wstar=W*pinv(P'*W);
