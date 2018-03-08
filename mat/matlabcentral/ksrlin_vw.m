function r=ksrlin_vw(x,y,k,N)
% KSRLIN_VW   Local linear kernel smoothing regression with variable window width
%
% r=ksrlin_vw(x,y) returns the local linear Gaussian kernel regression in
% structure r such that r.f(r.x) = y(x) + e. The input k, the bandwidth and the
% number of samples are also stored in r.k, r.h and r.n respectively.
%
% r=ksrlin_vw(x,y,k) performs the regression using as bandwidth the distance to the kth 
% nearest neighbor
%
% r=ksrlin_vw(x,y,k,n) calculates the regression in n points (default n=100).
%
% Without output, ksrlin_vw(x,y) or ksrlin_vw(x,y,h) will display the regression
% plot. 
%
% Algorithm
% The kernel regression is a non-parametric approach to
% estimate the conditional expectation of a random variable:
%
% E(Y|X) = f(X)
%
% where f is a non-parametric function. The normal kernel regression is a
% local constant estimator. The extension of local linear estimator is
% obtained by solving the least squares problem:
%
% min sum (y-alpha-beta(x-X))^2 kerf((x-X)/hi)
%
% where hi is the distance of xi from its kth nearest neighbor among the
% remaining datapoints.
%
% The local linear estimator can be given an explicit formula
%
% f(x) = 1/n sum((s2-s1*(x-X)).*kerf((x-X)/hi).*Y)/(s2*s0-s1^2)
%
% where si = sum((x-X)^i*kerf((x-X)/hi))/n. Compare with local constant
% estimator, the local linear estimator can improve the estimation near the
% edge of the region over which the data have been collected.
%
% See also gkde, ksdensity, ksr, ksrlin, ksr_vw
%
% By Fernando Duarte on Feb 24, 2012.
% References
%   [1] Nonparametric econometrics, by Adrian Pagan and Aman Ullah,
%       Cambridge University Press, 1999, ISBN 0521586119, 9780521586115.

% Example 1: smooth curve with noise
%{
x = 1:100;
y = sin(x/10)+(x/50).^2;
yn = y + 0.2*randn(1,100);
r=ksrlin_vw(x,yn);
r1=ksr_vw(x,yn); 
plot(x,y,'b-',x,yn,'co',r.x,r.f,'r--',r1.x,r1.f,'m-.','linewidth',2)
legend('true','data','local linear vw','local linear','location','northwest');
title('Local linear kernel regression with variable window width');
%}
% Example 2: with missing data
%{
x = sort(rand(1,100)*99)+1;
y = sin(x/10)+(x/50).^2;
y(round(rand(1,20)*100)) = NaN;
yn = y + 0.2*randn(1,100);
r=ksrlin_vw(x,yn);
r1=ksr_vw(x,yn);
plot(x,y,'b-',x,yn,'co',r.x,r.f,'r--',r1.x,r1.f,'m-.','linewidth',2)
legend('true','data','local linear vw','local linear','location','northwest');
title('Local linear kernel regression with variable window width and 20% missing data');
%}

% By Fernando Duarte on Feb 24, 2012.
% References
%   [1] Nonparametric econometrics, by Adrian Pagan and Aman Ullah,
%       Cambridge University Press, 1999, ISBN 0521586119, 9780521586115.
%       (section 2.2.5)

% Check input and output
error(nargchk(2,4,nargin));
error(nargoutchk(0,1,nargout));
if numel(x)~=numel(y)
    error('x and y are in different sizes.');
end

x=x(:);
y=y(:);
% clean missing or invalid data points
inv=(x~=x)|(y~=y)|(abs(x)==Inf)|(abs(y)==Inf);
x(inv)=[];
y(inv)=[];

% Default parameters
if nargin<4
    N=100;
elseif ~isscalar(N)
    error('N must be a scalar.')
end
r.n=length(x);
if nargin<3
    k = 2; % use as default the distance to the 2nd nearest neighbor
elseif mod(k,1) || k < 1 || k > r.n
    error('h must be positive integer and smaller than the sample size.')
end
if r.n-1<k
    error(['There are not enough points to find the nearest neighbor' num2str(k) '.'])
end
r.k=k;

% Gaussian kernel function
kerf=@(z)exp(-z.*z/2)/sqrt(2*pi);

[~, distance] = knnsearch(x,x,'K',k+1);
r.h = distance(:,end);

r.x=linspace(min(x),max(x),N);
r.f=zeros(1,N);
for k=1:N
    d=r.x(k)-x;
    z=kerf(d./r.h);
    s1=d.*z;
    s2=sum(d.*s1);
    s1=sum(s1);
    r.f(k)=sum((s2-s1*d).*z.*y)./(s2*sum(z)-s1.*s1);
end

% Plot
if ~nargout
    plot(r.x,r.f,'r',x,y,'bo')
    ylabel('f(x)')
    xlabel('x')
    title('Local linear kernel regression with variable window width');
end
