function res=CGMY_Principal(alpha_,C_,G_,M_,size_,seed_)
%%------------------simulation of CGMY process --------------------------%%
% @ auteur : Hicham EL MEKEDDEM
% @ mail   : hicham.elmekeddem@gmail.com
%%-----------------------------------------------------------------------%%
%%------------------------Input parameters ------------------------------%%
if isnan(seed_)
    seed_=round(rand()*10^6);
end
rand('state',seed_);
C=C_;
G=G_;
M=M_;
Y=alpha_;
N=size_;t=1;Model.t=t;
xmax=5;
%%-----------------------------------------------------------------------%%
%%-----------------------------FFT Model---------------------------------%%
% Initializing the input parameters
mult =6;
n=12;
% Extend the interval to calculate the density
Model.xmax = xmax*(2^mult);
Model.mult=mult;
% incrementation de n 
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
x = x(T); 
x = x(:);Model.x1=x;
%%------------------------------End FFT Model----------------------------%%

%%-------------------------------Simulation------------------------------%%
CGMY=zeros(1,N);
[x,y] = DensiteCGMY_FFT(Model,C,G,M,Y);
z=cumtrapz(x,y);[zp, idz] = unique(z);idz=sort(idz);xp=x(idz);
h_waitbar = fl_waitbar('init');
for i=1:N
    CGMY(i)=interp1(zp,xp,rand(),'cubic');
    fl_waitbar('view',h_waitbar,i,N-1);
end
fl_waitbar('close',h_waitbar);
res=cumsum(CGMY);

%%-------------------------------END-------------------------------------%%
end
