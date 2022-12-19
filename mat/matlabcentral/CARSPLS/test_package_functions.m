%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  This script is used to test whether the functions in this  %%%%%%%%%%  
%%%%%%%%%%  package can run smoothly.                                  %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  H.D. Li, lhdcsu@gmail.com                                  %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%+++ Import data;
load corn_m51;
%+++ Cross validation
A=6;
K=5;
method='center';
N=500;
Nmcs=50;
CV=plscvfold(X,y,A,K,method)
MCCV=plsmccv(X,y,A,method,N)
DCV=plsrdcv(X,y,A,K,method,Nmcs)


%+++ Build a PLS regression model
nLV=CV.optPC;
PLS=pls(X,y,nLV)


%+++ Outlier detection
F=mcs(X,y,12,'center',1000,0.7)
figure;
plotmcs(F);


%+++ CARS-PLS for variable selection
A=10;
K=5; 
N=50;
CARS=carspls(X,y,A,K,method,N);
figure;
plotcars(CARS);

%+++  simplified version of CARS
sCARS=scarspls(X,y,A,K,method,N); 
figure;
plotcars(sCARS);


