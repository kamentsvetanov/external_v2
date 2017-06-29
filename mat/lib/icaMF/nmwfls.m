function [FACT, ssse, varexpl]=nmwfls(X,noc)


% Non-Negative Multi-way Factor analysis based on the Non-negative matrix
% factorization algorithm minimizing the least square error,  described in:
% Lee, Daniel D. 
% Seung, H. S. 
% Algorithms for non-negative matrix factorization
% Advances in Neural information processing (2001)
%
% The algorithm has been accelerated as suggested in:
% Salakhutdinov, Ruslan
% Roweis, Sam
% Adaptive Overrelaxed Bound Optimization Methods
% Proceedings of the twentieth International Conference o Machine Learning
% (ICML-2003)
%
% Written by Morten Mørup
%
% Usage:
% [FACT, ssse, varexpl]=nmwfls(X,noc)
%
% Input
% X             n-way array to decompose
% noc           number of components
%
% Output
% FACT          cell array: FACT{i} is the factors found for the i'th
%                           dimension
% ssse          Sum of square error
% varexpl       Variation explained by model


%random initialisation
for i=1:ndims(X)
    N(i)=size(X,i);
    if nargin<5
            FACT{i}=rand(N(i),noc);
    end
end
for i=1:ndims(X)
    Xi{i}=matrizicing(X,i);
end

FACTold=FACT;
krit1=10^-6; %Convergence criterion
krit2=2500;  %Maximal number of iterations
iter=0;
dsss=inf;
SST=sum(sum((matrizicing(X,1)-(mean(mean(matrizicing(X,1))))).^2));
ny=1;
alpha=1.1;   %Adaptive acceleration parameter
ssse=SST;
ssso=inf;
le=ndims(X);

disp([' '])
disp(['Adaptive Non-negative Multiway Factorization based on least square minimization'])
disp(['A ' num2str(noc) ' component model will be fitted']);
disp([' '])
disp(['To stop algorithm press control C'])
disp([' ']);
disp(' SS Cost function         Iteration         Expl. Var.')

while dsss>krit1*ssse & iter<krit2
    iter=iter+1;
    cont=0;
    for i=1:le
            ind=1:le;
            ind(i:end-1)=ind((i+1):end);
            ind=ind(1:(end-1));
            kr=FACT{ind(1)};
            for z=ind(2:end)
                kr=krprod(FACT{z}, kr);           
            end
            T=(Xi{i}*kr)./(FACT{i}*kr'*kr+eps);
            FACT{i}=FACT{i}.*(T.^ny);
     end
        
     ssse=sum(sum((Xi{i}-FACT{i}*kr').^2));
     dsss=ssso-ssse;
     if dsss>0
        ny=alpha*ny;
        FACTold=FACT;
        ssso=ssse;
     else
        ny=1;
        FACT=FACTold;
        dsss=inf;
     end
     if rem(iter,5)==0
        pause(0.00001); %Enables to break algorithm by pushing "Control C".
        fprintf(' %12.10f          %g           %15.4f \n',ssso,iter,(SST-ssso)/SST);
     end
end
ssse=ssso;
varexpl=(SST-ssso)/SST;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A=krprod(B,C);

% Khatri Rao product
% input
% B m x n matrix
% C p x n matrix
% output
% A m*p x n matrix
sb=size(B,1);
sc=size(C,1);
A=[];
for k=1:size(B,2)
    A=[A reshape(C(:,k)*B(:,k)',sb*sc,1)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y=matrizicing(X,n)

% The matrizicing operation, i.e.
% matrizicing(X,n) turns the multi-way array X into a matrix of dimensions:
% (size(X,n)) x (size(X,1)*...*size(X,n-1)*size(X,n+1)*...*size(X,N))
%
% Input
% X     Multi-way array
% n     Dimension along which matrizicing is performed
%
% Output
% Y     The corresponding matriziced version of X

N=ndims(X);
Y=reshape(permute(X, [n 1:n-1 n+1:N]),size(X,n),prod(size(X))/size(X,n));