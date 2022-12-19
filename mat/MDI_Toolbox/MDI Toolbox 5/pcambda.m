function [X,mest,Sest,Xrec]=pcambda(X,M,CL,A)
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
% X: data matrix with NaN for the missing data.
% M: number of independent chains (we use M=10).
% CL: length of each chain (we use CL=100).
% A: number of principal components.
%
% OUTPUTS
%
% Y: original data set with the imputed values.
% DAm:  estimated means for the M chains in M rows.
% DAS:  estimated covariance matrices for the M chains DAS(1).co,..., DAS(M).co.
% mest: estimated means (mest=mean(DAm)).
% Sest: estimated covariance matrix (averaging DAS(1).co,..., DAS(M).co).
% Xrec: PCA reconstruction of X with A components. 


[n,p]=size(X);
for i=n:-1:1,
  r=~isnan(X(i,:)); 
  pat(i).O=find(r==1); % observed variables
  pat(i).M=find(r==0); % missing variables
  pat(i).nO=size(pat(i).O,2); % number of observed variables
  pat(i).nM=size(pat(i).M,2); % number of missing variables
end
mis=isnan(X);        	% mis are the positions of the md in X
[r c]=find(isnan(X));	% r and c store the row and the column for all the md
X(mis)=0;               % fill in the md with 0's
meanc=sum(X)./(n-sum(mis)); % average of the known values for each column
for k=1:length(r),
  X(r(k),c(k))=meanc(c(k)); % fill in each md with the mean of its column
end
mini=mean(X); Sini=cov(X);  	% initial mean vector an covariance matrix
DAm=zeros(M,p);

Tot=M*CL;
Cur=0.01;
Step=Cur;

h1 = waitbar(0,'Please wait...',...
    'Color',[0.5 0.6 0.7],... % background color
    'Name','Iteration number:',... % figure title
    'Position',[500 400 364 60]); % position of the figure
waitbar(0/Tot,h1,[num2str(0)])

for run=1:M,
  S=Sini;
  m=mini;
  for It=1:CL,
    for i=1:n,              % for each row
      if pat(i).nM>0,           % if there are missing values
        m1=m(1,pat(i).O)';           % nOx1
        m2=m(1,pat(i).M)';           % nMx1
        S11=S(pat(i).O,pat(i).O);    % nOxnO
        S12=S(pat(i).O,pat(i).M);    % nOx1
        S22=S(pat(i).M,pat(i).M);   % nMxnM
        z1=X(i,pat(i).O)';           % nOx1
        z2=m2+S12'*pinv(S11)*(z1-m1);% nMx1
        z2=z2+chol(S22-S12'*pinv(S11)*S12)*randn(pat(i).nM,1); % nMx
        X(i,pat(i).M)=z2';           % 1xp
      end
    end
    m=mean(X);
    S=cov(X);
    [m,S]=DrawPost(m,S,10*n*n);
    
    if CL*(run-1)+It>=Cur*Tot
        Cur=Cur+Step;
        waitbar((CL*(run-1)+It)/Tot,h1,[num2str(CL*(run-1)+It)])
    end
    
  end
  DAm(run,:)=m;
  DAS(run).co=S;
end
mest=mean(DAm);
Sest=zeros(p,p);
for k=1:M,
  Sest=Sest+DAS(k).co;
end
Sest=Sest/M;

for i=1:n,            % for each row
  if pat(i).nM>0,     % if there are missing values
    m1=mest(1,pat(i).O)';          % nOx1
    m2=mest(1,pat(i).M)';          % nMx1
    S11=Sest(pat(i).O,pat(i).O);   % nOxnO
    S12=Sest(pat(i).O,pat(i).M);   % nOxnM
    z1=X(i,pat(i).O)';             % nOx1
    z2=m2+S12'*pinv(S11)*(z1-m1);  %nMx1
    X(i,pat(i).M)=z2';  % fill in the md positions of row i
  end
end
Xc=X-ones(n,1)*mean(X);
[u d v]=svd(Xc,0);
T=u(:,1:A)*d(1:A,1:A);
P=v(:,1:A);
Xrec=T*P'+ones(n,1)*mean(X);
close(h1)


 
function [mpost,Spost]=DrawPost(m,S,n)
d=chol(S/n);
p=size(S,1);
if n<=81+p,
  x=randn(n-1,p)*d;
else,
  a=diag(sqrt(chi2rnd(n-(0:p-1))));
  for i=1:p-1,
    for j=i+1:p,
      a(i,j)=randn(1,1);
    end
  end
  x=a*d;
end
Spost=x'*x;
mpost=(m'+chol(Spost/(n-1))*randn(size(S,1),1))';
