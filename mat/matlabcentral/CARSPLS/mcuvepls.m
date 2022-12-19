function F=mcuvepls(X,Y,A,method,N,ratio)
%+++ uninformative variable elimination(UVE)-PLS.
%+++ Input:  X: m x n  (Sample matrix)
%            y: m x 1  (measured property)
%           PC: The max PC for cross-validation
%            N: The number of Monte Carlo Simulation.
%        ratio: The ratio of calibration samples to the total samples.
%       method: pretreatment method. Contains: autoscaling,
%               pareto,minmax,center or none.

%+++ Default parameters
if nargin<6;ratio=0.8;end
if nargin<5;N=1000;end
if nargin<4;method='center';end
if nargin<3;A=2;end

%+++ Monte Carlo Uninformative Variable Elimination.
[Mx,Nx]=size(X);
K=floor(Mx*ratio);
A=min([size(X) A]);
C=zeros(N,Nx);  

for group=1:N
      temp=randperm(Mx);
      calk=temp(1:K);      
      Xcal=X(calk,:);ycal=Y(calk);  
      PLS=pls(Xcal,ycal,A,method);
      coef=PLS.coef_origin;
      C(group,:)=coef(1:end-1,end);    
      fprintf('The %d/%dth sampling for MC-UVE finished.\n',group,N);
  end
  U=mean(C);  SD=std(C);  RI=abs(U./SD);
  [RIs,indexRI]=sort(-RI);
  Vsel=indexRI;
%+++ Output
F.RI=RI;
F.SortedVariable=Vsel;
F.Coefficient=C;

%+++ There is a song you like to sing.

