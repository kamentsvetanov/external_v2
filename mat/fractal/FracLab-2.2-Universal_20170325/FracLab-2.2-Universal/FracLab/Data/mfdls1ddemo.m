% script mfdls1ddemo               
% Lim sup dimension spectrum on 1d measure: demo script 
%
% Inputs: 
%
% Outputs: plot spectra
%
% Christophe Canus 2002
FracLabReleaseHome=getenv('FracLabReleaseHome');

% load the nikkei ...
nikkei=load([FracLabReleaseHome,'/Data/nikkei225.txt']);
% plot nikkei signal
figure(1);
plot(nikkei);

%  "normalize it" ...
c1d=nikkei/sum(sum(nikkei));
% Lim sup dimension spectrum estimation on 1d measure 
% with 'sum' measure with only one parameter
[alpha,fdls1d_alpha]=mfdls1d(c1d);
figure(2);
plot(alpha,fdls1d_alpha,'k');
grid on;
box on;
pause;

% Modify some parameters:
n=[0 0];
capa='max';
epsilon=.1;
B=[1:2:21];
dim='box';
N=200;

[alpha,fdls1d_alpha]=mfdls1d(c1d,n,capa,epsilon,B,dim);
figure(3);
plot(alpha,fdls1d_alpha,'k');
grid on;
box on;
pause;

% synthesize a binomial measure ...
n=16;
p=.2;
mu1d=binom(p,'meas',n);

% Lim sup dimension spectrum estimation on 1d measure 
% with 'sum' measure with only one parameter
[alpha,fdls1d_alpha]=mfdls1d(mu1d);
figure(4);
plot(alpha,fdls1d_alpha,'k');
grid on;
box on;
hold on;
pause;

% Funny, isn't it ? --> modify some parameters to get some better results:
n=[0 0];
capa='sum';
epsilon=.3;
B=[1:2:21];
dim='box';
N=200;
[alpha,fdls1d_alpha]=mfdls1d(mu1d,n,capa,epsilon,B,dim);
plot(alpha,fdls1d_alpha,'k');

% compare it to the theoretical one
[talpha,tf_alpha]=binom(p,'spec',N);
plot(talpha,tf_alpha,'k+');
pause;