function res=mst_processes(N,alphat,C,G,M,Seed)
%%------------------simulation of MST process --------------------------%%
% @ auteur : Hicham EL MEKEDDEM
% @ mail   : hicham.elmekeddem@gmail.com
%%-----------------------------------------------------------------------%%
% Modified by Pierrick Legrand, November 2016

global Model
mult =4;n=12;xmax=0.1;
% elargir l'intervale pour calculer la densité
Model.xmax = xmax*(2^mult);Model.mult=mult;
% incrementation de n 
Model.n = mult+n;Model.M = 2^Model.n;Model.R = pi/Model.xmax;
Model.dt = 1/(Model.R*Model.M);
Model.xx = (-2^(Model.n-1)+.5:(2^(Model.n-1)-.5))/(2^Model.n*Model.dt);
x = (2*pi)*((0:1:(Model.M-1))/(Model.M*Model.R)-1/(2*Model.R));
Model.x=x;Model.h=x(2)-x(1);
T = find((x<=Model.xmax/(2^Model.mult)) & (x>=-Model.xmax/(2^Model.mult)));
Model.T=T;x = x(T); x = x(:);Model.x1=x;
%--------------------------------------------------------------------------
if isnan(Seed)
    Seed=round(rand()*10^6);
end
rand('state',Seed);
tt=linspace(0,1,N);
dt=tt(2)-tt(1);
MS=zeros(1,N);
h_waitbar = fl_waitbar('init');
if length(alphat)==1
    alphat=alphat.*ones(1,N);
end
for j=1:N
    [x,y] = MultiStableDensiteFFT(dt,C,G,M,alphat(j),Model );
    %figure;plot(x,y);
    z=cumtrapz(x,y);    [zp, idz] = unique(z);idz=sort(idz);xp=x(idz);
    %MS(j)=  interp1(zp,xp,rand(),'cubic');
    MS(j)=  interp1(zp,xp,rand(),'pchip');
    %-----------------------------------------------------------
    fl_waitbar('view',h_waitbar,j,N-1);
end
fl_waitbar('close',h_waitbar);

res=cumsum(MS);


end
