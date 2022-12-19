%moment estimators parameter for starting point for the MLE
function[alpha,a,lambda]=TSestsym(X)
U=sign(X);
V=log(abs(X(X>0|X<0)));
nu=6/pi^2*var(V)-3/2*var(U)+1;
alpha=1/sqrt(nu);
if alpha>1.99
    alpha=1.8;
end
M=mean(V);
C=0.577215665; %Euler constant
a=exp(alpha*(M+C)-C)/(-cos(-alpha*pi/2)*gamma(-alpha));
b=1/(alpha-2);
lambda=(var(X)/(a*gamma(2-alpha)))^b;
end