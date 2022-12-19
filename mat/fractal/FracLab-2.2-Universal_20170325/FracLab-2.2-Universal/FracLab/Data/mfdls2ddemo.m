% script mfdls2ddemo               
% Lim sup dimension spectrum on 2d measure: demo script 
%
% Inputs: 
%
% Outputs: plot measures
%
% Christophe Canus 2002

% load the 'famous' door image ...
door=imread('/usr/local/FRACLAB/Data/door.tif');
% show door image
figure(1); imshow(door);

% convert to double and "normalize it" ...
mu2d=double(door);
mu2d=mu2d/sum(sum(mu2d));
% Lim sup dimension spectrum estimation on 2d measure 
% with 'sum' measure with only one parameter
[alpha,fdls2d_alpha]=mfdls2d(mu2d);
figure(2); plot(alpha,fdls2d_alpha,'k');

pause;

% Modify some parameters:
n=[0 0];
capa='max';
epsilon=.1;
B=[1:2:21];
dim='box';
N=200;

[alpha,fdls2d_alpha]=mfdls2d(mu2d,n,capa,epsilon,B,dim);
figure(2); plot(alpha,fdls2d_alpha,'k');

pause;

% synthesize a quadrinomial measure ...
n=8;
bx=2;
by=2;
p=[.2 .3;.1 .4];
mu2d=multim2d(bx,by,p,'meas',n);

% Lim sup dimension spectrum estimation on 2d measure 
% with 'sum' measure with only one parameter
[alpha,fdls2d_alpha]=mfdls2d(mu2d);
figure(2); plot(alpha,fdls2d_alpha,'k');

pause;

% Funny, isn't it ? --> modify some parameters to get some better results:
n=[0 0];
capa='sum';
epsilon=.3;
B=[1:2:21];
dim='box';
N=200;
[alpha,fdls2d_alpha]=mfdls2d(mu2d,n,capa,epsilon,B,dim);
figure(2); plot(alpha,fdls2d_alpha,'k');

pause;

% compare it to the theoretical one
hold on
[talpha,tf_alpha]=multim2d(bx,by,p,'spec',N);
figure(2); plot(talpha,tf_alpha,'k+');
grid on

% load the 'urban80g' and 'urban90g' image ...
urban80g=imread('/home/users/canus/img/png/urban80g.png');
urban90g=imread('/home/users/canus/img/png/urban90g.png');
% show door image
figure; imshow(urban80g);
figure; imshow(urban90g);

% convert to double and "normalize them" ...
c2d=double(urban80g);
c2d=c2d/sum(sum(c2d));
mu2d=double(urban90g);
mu2d=mu2d/sum(sum(mu2d));
[alpha,fdls2d_alpha]=mfdls2d(c2d,n,capa,epsilon,B,dim,mu2d,N);
plot(alpha,fdls2d_alpha);
