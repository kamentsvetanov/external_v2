function [X,m,S,It,diff,Xrec]=pcambnipals(X,A,maxiter,tol)
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


[N,K]=size(X);
missX=isnan(X);
HX=1-missX;
T=zeros(N,A);P=zeros(K,A);
It=zeros(1,A);
diff=zeros(1,A);



m=zeros(1,K);
for j=1:K,
    x=X(:,j);
    ind = ~isnan(x);
    n=sum(ind);
    m(j)=mean(x(ind));
end
E=X;
E=E-ones(N,1)*m;


E(missX)=0;
for a=1:A,
    
  h1 = waitbar(0,'Please wait...',...
    'Color',[0.5 0.6 0.7],... % background color
    'Name',['Iteration number (PC #' num2str(a) '):'],... % figure title
    'Position',[500 400 364 60]); % position of the figure
  waitbar(0/maxiter,h1,[num2str(0)])

  h2 = waitbar(0,'Please wait...',...
    'Color',[0.5 0.6 0.7],... % background color
    'Name',['Actual tolerance (PC #' num2str(a) '):'],... % figure title
    'Position',[500 300 364 60]); % position of the figure
  waitbar(0,h2,[num2str(0)])
    
  t=E(:,1);
  dif=100;
  while It(a)<maxiter & dif>tol,
    It(a)=It(a)+1;
    p=zeros(K,1);
    for i=1:K,
      p(i)=(HX(:,i).*E(:,i))'*t/((HX(:,i).*t)'*t);
    end
    p=p/norm(p);
    tnew=zeros(N,1);
    for i=1:N,
      tnew(i)=(HX(i,:).*E(i,:))*p/((HX(i,:)'.*p)'*p);
    end
    dif=norm(tnew-t);
    t=tnew;
    
    if rem(It(a),10)==0
        waitbar(It(a)/maxiter,h1,[num2str(It(a))])
        waitbar(1-(dif-tol)/dif,h2,[num2str(dif)])
    end
    diff(a)=dif;
        
    
  end
  E=E-t*p';
  T(:,a)=t(:,1);P(:,a)=p(:,1);
  
  close(h1)
  close(h2)
  
end
Xrec=T*P';
Xrec=Xrec+ones(N,1)*m;

X(missX)=Xrec(missX);
m=mean(X);
S=cov(X);

It=sum(It);
diff=sum(diff);