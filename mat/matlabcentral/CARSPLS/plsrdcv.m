function DCV=plsrdcv(X,y,A,K,method,Nmcs,OPT,order)
%+++ Repeaded double cross validation Cross-validation for PLS regression
%+++ Input:  X: m x n  (Sample matrix)
%            y: m x 1  (measured property)
%            A: The maximal number of latent variables for cross-validation
%            K: fold. when K = m, it is leave-one-out CV
%       method: pretreatment method. Contains: autoscaling, center etc.
%         Nmcs: The number of Monte Carlo sampling.
%          OPT: =1 Print process.
%               =0 No print.
%               pareto,minmax,center or none.
%+++ Order: =1  sorted. For CV partition.
%           =0  random, default. 
%+++ Output: Structural data: CV
%+++ Hongdong Li, Oct. 16, 2008.
%+++ Revised on Dec.3, 2009.

if nargin<8;order=0;end
if nargin<7;OPT=1;end;
if nargin<6;Nmcs=100;end;
if nargin<5;method='center';end;
if nargin<4;K=10;end;
if nargin<3;A=2;end;


check=0; %+++ status variable:  1: Inf
[Mx,Nx]=size(X);
Qs=floor(Mx*(1-1/K));

yytest=[];yp=[];
nLV=zeros(Nmcs,1);


for group=1:Nmcs
    perm=randperm(Mx);
    calk=perm(1:Qs);testk=perm(Qs+1:end);
    
    Xcal=X(calk,:);ycal=y(calk);
    Xtest=X(testk,:);ytest=y(testk);
    
    CV=plscvfold(Xcal,ycal,A,K,method,0,order);
    optPC=CV.optPC;
    
    if CV.check==1;check==1;break;end;    
    PLS=pls(Xcal,ycal,CV.optPC,method);
    [ypred,RMSEPtemp]=plsval(PLS,Xtest,ytest);
    
    RMSEP(group)=RMSEPtemp;
    
    yytest=[yytest;ytest];
    yp=[yp;ypred;];
    nLV(group)=CV.optPC;       
    if OPT==1;fprintf('The %d/%dth Monte Carlo Sampling finished.\n',group,Nmcs);end;
end

%+++ output
if check==0
  RMSECV=sqrt(sum((yp-yytest).^2)/length(yp));
  Q2=1-sumsqr(yp-yytest)/sumsqr(yytest-mean(yytest));
  DCV.method=method;
  DCV.check=check;
  DCV.yreal=yytest;
  DCV.ypred=yp;
  DCV.RMSECV=RMSECV;
  DCV.Q2=Q2;
  DCV.nLV=nLV;
  DCV.RMSEP=RMSEP;
elseif check==1
  DCV.method=method;
  DCV.check=check;  
end
  
  