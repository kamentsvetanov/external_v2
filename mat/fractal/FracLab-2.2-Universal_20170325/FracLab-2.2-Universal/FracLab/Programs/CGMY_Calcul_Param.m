function [CGMY_res,res]=CGMY_Calcul_Param(Data)
%%---------------------Calibration of CGMY process ----------------------%%
% @ auteur : Hicham EL MEKEDDEM
% @ mail   : hicham.elmekeddem@gmail.com
%%-----------------------------------------------------------------------%%
global Model

Model.data=diff(Data);%RendementData(L,Type,exp(Data)); % load Data 
%%-----------------------------FFT Model---------------------------------%%
% Initializing the input parameters
xmax=max(abs(Model.data))+0.01;
mult =2;
n=12;
% Extend the interval to calculate the density
Model.xmax = xmax*(2^mult);
Model.mult=mult;
% incrementation of n 
Model.n = mult+n;
Model.M = 2^Model.n;
Model.R = pi/Model.xmax;
Model.dt = 1/(Model.R*Model.M);
% Descritisation the interval
Model.xx = (-2^(Model.n-1)+.5:(2^(Model.n-1)-.5))/(2^Model.n*Model.dt);
% Transition to the original interval
x = (2*pi)*((0:1:(Model.M-1))/(Model.M*Model.R)-1/(2*Model.R));
Model.x=x;
T = find((x<=Model.xmax/(2^Model.mult)) & (x>=-Model.xmax/(2^Model.mult)));
Model.T=T;
x = x(T); x = x(:);Model.x1=x;
t=1;
%%------------------------------End FFT Model----------------------------%%
Model.y1=ksdensity(Model.data,x); % empirical density of Data
%--------------------------------------------------------------------------
%%--------------------------starting parameter----------------------------%%
[Y, a, G_M]=TSestsym(Model.data);
lambda1=G_M;
lambda2=G_M;
x0=[a/2 lambda1 lambda2 Y];
lb=[0 0 0 0.01];
ub=[2 200 200 1.98];
%----------------------------------Estimation------------------------------
options = optimset('MaxIter', 10000, 'MaxFunEvals', 10000, 'TolFun', 1e-7, 'TolX',1e-7);
% LLfun : function for numerical calculation of -loglikelihood function
res=fminsearchbnd(@(PP)LLfun(t,PP(1),PP(2),PP(3),PP(4),Model),x0,lb,ub,options);
% function for optimization
C=res(1);G=res(2);M=res(3);Y=res(4);
%--------------------------------End of Estimation-------------------------

% Result
CGMY_res=[C G M Y]; 

%%-------------------------------END-------------------------------------%%
end