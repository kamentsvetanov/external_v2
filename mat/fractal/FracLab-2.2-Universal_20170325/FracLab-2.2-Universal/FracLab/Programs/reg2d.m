function [out]=fracreg2d(in,trshld)
%Régularisation de signaux 2D par multiplication des coeff d'ondelettes par un nombre Xj
%entre 0 et 1 constant par echelle

% Author Pierrick Legrand, 2000

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------%PL 2000

q=MakeQMF('daubechies',4);
n=floor(log2(max(size(in))));
[wt,wti,wtl,siz] =FWT2D(in,n,q);
d=trshld;N=2^n;
% on met dans chaque ligne j de c les coeff a l'echelle j
%e(j) est l'energie a l'echelle j
c=cell(n,1,1);
e=zeros(1,n);
for j=1:n-1
      c(n-j+1)={[wt(wti(j,1):wti(j+1,1)-1)]};
      e(n-j+1)=c{n-j+1}*c{n-j+1}';
end;
nn=floor((n+1)/2);
   
c(1)={[wt(wti(n,1):wti(n,n-nn))]};
e(1)=c{1}*c{1}';

%definition des coefficients intervenant dans la regression
%et donc dans la contrainte. On ne traite pas les nn= int((n+1)/2) 
% premiers coeff
o=zeros(1,n-nn);
for j=1:n-nn
   o(j)=j+nn-(n+1)/2;
end;
ot=sum(o);
k=12/(n^3-n);

% raz des multiplicateurs
xm=ones(1,n-nn);


% la fonction a minimiser depend du rapport des energies par 
%niveau sur les o(j)
r=zeros(1,n-nn);
for j=1:n-nn
   r(j)=e(j+nn)/o(j);
end;
rm=min(r);
dl=d/k;
edl=2^(-dl);

%%%%%%%%%%%%%%%%Matrice de tous les cas%%%%%%%%%%
m1=cell(2^(n-nn),n-nn,1);
tmp=2;
m1(1,1,1)={[1]};  
m1(2,1,1)={[-1]};
for i=1:n-nn-1
   for j=1:tmp
      m1(2*(j-1)+1,i+1,1)={[m1{j,i,1} 1]};
      m1(2*j,i+1,1)={[m1{j,i,1} -1]};
   end;
   tmp=tmp*2;
end;      
m2=zeros(2^(n-nn),n-nn);
for i=1:n-nn
   for j=1:2^(n-nn)
      m2(j,i)=m1{j,n-nn,1}(i);
   end;
end;   

%%%%%%%%%%%%%%%%optimisation%%%%%%%%%%%%%%%%%%%%%
p=version;
oldopt= optimset('display','final','LargeScale','on', ...
   'TolX',1e-6,'TolFun',1e-6,'DerivativeCheck','off',...
   'Jacobian','off','MaxFunEvals','100*numberOfVariables',...
   'Diagnostics','off',...
   'DiffMaxChange',1e-1,'DiffMinChange',1e-8,...
   'PrecondBandWidth',0,'TypicalX','ones(numberOfVariables,1)','MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
   'TolPCG',0.1,'MaxIter',400,'JacobPattern',[], ...
   'LineSearchType','quadcubic','LevenbergMarq','off');
if str2num(p(1))>5
  %oldopt=optimset('fsolve');
  options=optimset(oldopt,'Display','off');
else 
  options=optimset(oldopt);
end;

eps1=zeros(1,2^(n-nn));
for i=1:2^(n-nn)
   eps1(i)=inf;
end;   
v=zeros(1,2^(n-nn));
mu=inf;mu1=inf;      
for s=1:2^(n-nn)
  [mu,fval,exitflag]=fsolve('lagr3',1^(-10),options,m2,s,nn,n,r,dl,ot,o);
  if exitflag>0 & ((mu/rm)-1)<0 & mu>0 
     v(s)=real(mu);
     eps2=0;
     for j=1:n-nn
        xm(j)=real((1+m2(s,j)*sqrt(1-mu/r(j)))/2);
        eps2=real(eps2+e(j)*(1-xm(j))^2);
     end;
     eps1(s)=eps2;
  end;   
end;

[a,b]=min(eps1);
mu1=v(b);
  
% calcul des Xj a partir de mu1
   for j=1:n-nn
      xm(j)=real((1+m2(b,j)*sqrt(1-mu1/r(j))))/2;
   end;
xm   
%blindage
   if min(eps1)==inf & d~=0
      xm(:)=0;
   end;   

%calcul des nouveaux coeff obtenus en multipliant les anciens
%a partir de nn+1 par les Xj
g = c;dd=[];
  for j=1:n-nn
     g(j+nn)={xm(j)*c{j+nn}};
  end;
  for j=1:n
     dd=[g{j},dd];
  end;   
%calcul de la nouvelle TO
rwt=wt;
u=0;
for i=1:n-nn
   u=u+3*wtl(i,1)^2;
end;   
for i=1:u
    rwt(wti(1,1)+i-1)=dd(i);
end;

wtout=rwt;
out=IWT2D(wtout);
out=out(1:siz(1),1:siz(2));

