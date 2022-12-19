function [VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]=besov_spq(Input,s,p,q,niveau,type_ond,siz1) 
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

d=MakeQMF(type_ond,siz1);

[wt,index,length]=FWT2D(Input,niveau,d);

VectEnergie=zeros(3,niveau);
VectEnergieTotale=zeros(1,niveau);

t=(1:niveau);
for sc=1:niveau
     VectEnergieT=[];
    for j=1:3
        VectWT=abs(wt(index(sc,j):(index(sc,j)+length(sc,1)*length(sc,2)-1))).^p;
        VectEnergie(j,sc)=2^(sc*(s+1/2-1/p))*(sum(VectWT)^(1/p));
        VectEnergieT=[VectEnergieT,VectWT];
%         size(VectEnergieT)
    end
    VectEnergieTotale(sc)=2^(sc*(s+1/2-1/p))*sum(VectEnergieT)^(1/p);
end
 
EnergieV=sum(VectEnergie(1,:).^q)^(1/q);
EnergieH=sum(VectEnergie(3,:).^q)^(1/q);
EnergieD=sum(VectEnergie(2,:).^q)^(1/q);
EnergieT=sum(VectEnergieTotale.^q)^(1/q);


figure;plot(t,VectEnergie(1,:),'r',t,VectEnergie(3,:),'b',t,VectEnergie(2,:),'k');legend('Vertical','Horizontal', 'Diagonal');
title('Besov Norms');xlabel('Level');ylabel('Norm');
   