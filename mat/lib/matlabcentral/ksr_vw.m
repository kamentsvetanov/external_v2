function r=ksr_vw(x,y,k,N)
% KSR_VW   Kernel smoothing regression with variable window width
%
% r=KSR_VW(x,y) returns the Gaussian kernel regression in structure r such that
%   r.f(r.x) = y(x) + e
% The input k, the bandwidth and the number of samples are also stored in r.k, r.h and r.n
% respectively.
%
% r=KSR_VW(x,y,k) performs the regression using as bandwidth the distance to the kth 
% nearest neighbor
%
% r=KSR_VW(x,y,k,n) calculates the regression in n points (default n=100).
%
% Without output, KSR_VW(x,y) or KSR_VW(x,y,k) will display the regression plot.
%
% Algorithm
% The kernel regression is a non-parametric approach to estimate the
% conditional expectation of a random variable:
%
% E(Y|X) = f(X)
%
% where f is a non-parametric function. Based on the kernel density
% estimation, this code implements the Nadaraya-Watson kernel regression
% using the Gaussian kernel  and variable window width as follows:
%
% f(x) = sum(kerf((x-X)/hi.*Y)/sum(kerf((x-X)/hi))
%
% where hi is the distance of xi from its kth nearest neighbor among the
% remaining datapoints.
%
% See also gkde, ksdensity, ksr, ksrlin, ksrlin_vw

% Example 1: smooth curve with noise
%{
x = 1:100;
y = sin(x/10)+(x/50).^2;
yn = y + 0.2*randn(1,100);
r=ksr_vw(x,yn);
r1=ksr(x,yn); 
plot(x,y,'b-',x,yn,'co',r.x,r.f,'r--',r1.x,r1.f,'m-.','linewidth',2)
legend('true','data','local constant vw','local constant','location','northwest');
title('Gaussian kernel regression with variable window width')
%}
% Example 2: with missing data
%{
x = sort(rand(1,100)*99)+1;
y = sin(x/10)+(x/50).^2;
y(round(rand(1,20)*100)) = NaN;
yn = y + 0.2*randn(1,100);
r=ksr_vw(x,yn);
r1=ksr(x,yn);
plot(x,y,'b-',x,yn,'co',r.x,r.f,'r--',r1.x,r1.f,'m-.','linewidth',2)
legend('true','data','local constant vw','local constant','location','northwest');
title('Gaussian kernel regression with variable window width and 20% missing data');
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
inv=(x~=x)|(y~=y);
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

r.x=linspace(min(x),max(x),N);
r.f=zeros(1,N);
[~, distance] = knnsearch(x,x,'K',k+1);
r.h = distance(:,end);

for q=1:N    
    z=kerf((r.x(q)-x)./r.h);
    r.f(q)=sum(z.*y)/sum(z);
end

% Plot
if ~nargout
    plot(r.x,r.f,'r',x,y,'bo')
    ylabel('f(x)')
    xlabel('x')
    title('Kernel Smoothing Regression with variable window width');
end
