function [X,m,S,It,diff,Xrec]=pcambia(X,A,maxiter,tol)
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
  Xc=X-ones(n,1)*mX;
  if n<p,[P,D,U] = svd(Xc',0);else [U,D,P] = svd(Xc,0); end
  T=U*D;
  T=T(:,1:A);
  P=P(:,1:A);
  Xrec=T*P';
  Xrec=Xrec+ones(n,1)*mX;
  X(mis)=Xrec(mis);
  d=(X(mis)-Xmis).^2;
  diff=mean(d);
  
  if rem(It,10)==0
    waitbar(It/maxiter,h1,[num2str(It)])
    waitbar(1-(diff-tol)/diff,h2,[num2str(diff)])
  end
  
end
S=cov(X);
m=mean(X);

close(h1)
close(h2)
