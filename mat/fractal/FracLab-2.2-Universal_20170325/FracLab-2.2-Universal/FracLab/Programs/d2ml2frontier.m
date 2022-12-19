function [vec_sprime,resultat,ap1,ap2,al]=d2ml2frontier(in,position1,position2,temps,precision_exp,precision_approx,graphe_approx,barre_calcul,graphe_frontiere,trace,write_ecarts,frontier_or_spectrum,fen);
% C'est une procedure qui estime la frontiere microlocale d'une image
% en un point, par une methode developpee dans un article Seuret-Levy Vehel
%
% f est l'image a etudier, sous forme d'une matrice N*N.
% position1 est l'abscisse du point a etudier(c'est un nombre entre 1 et N)
% position1 est l'ordonnee du point a etudier(c'est un nombre entre 1 et N)
% temps est le vecteur temps correspondant au support de l'image f
%
% precision_exp : combien de points seront utilises pour tracer la frontiere
% precision_approx: combien de points seront utilises pour l'estimation 
% de chaque point de la frontiere
%
% Le reste est un ensemble d'options, auxquels on repond par 0(non) ou 1(oui).
%
% barre_calcul: pour afficher une estimation du temps restant a calculer
%
% graphe_frontiere: pour voir un exemple d'estimation faite pour calculer
% un point de la frontiere
% trace: pour tracer la frontiere a la fin
% write_ecarts: aide pour la methode de choix parmi les 2 frontieres possibles.
%
% frontier_or_spectrum: sert a presque rien: quand cette procedure est appelee
% par fl_ml2frontier, c'est pour calculer une seule frontiere, et on affiche
% "debut du calcul", "debut de l'algorithme". Quand elle est appelee par
% fl_ml2spectrum, on ne veut pas que ca s'affiche. 1=ml2frontier, et 
% 2=ml2spectrum
%
%
% fen = 15 pour avoir quelques points a analyser.

% Modified by Stephane Seuret, March 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

f=in;
%
%if a<b
%    f=f';
%end

[N1,N2]=size(f);
N=max(max(size(f)));

precision_exp=floor(precision_exp);
resultat1=zeros(1,precision_exp);
resultat2=zeros(1,precision_exp);
ap1=0;
ap2=0;
al=0;


r1=zeros(1,precision_exp);
r2=zeros(1,precision_exp);
r3=zeros(1,precision_exp);
r4=zeros(1,precision_exp);
r5=zeros(1,precision_exp);
r6=zeros(1,precision_exp);
r7=zeros(1,precision_exp);
r8=zeros(1,precision_exp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Construction des premieres matrices  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if frontier_or_spectrum==1
  %fprintf('Matrix computation ...\n')
%end;

%%%%%%%%%%%%%%%%%%%% Restriction des matrices

x=(max(1,position1-fen):min(N1,position1+fen));
y=(max(1,position2-fen):min(N2,position2+fen));



A1=f(x,y);

[n1,n2]=size(A1);
Nb=n1*n2;


%%%%%%%%%%%% Matrice des log(fi-fj)

logF=zeros(Nb,Nb);
for i1=1:n1
for i2=1:n1
for j1=1:n2
for j2=1:n2
logF((i1-1)*n2+j1,(i2-1)*n2+j2)=log(abs(A1(i1,j1) -A1(i2,j2))+0.0001);
end;
end;
end;
end;

%%%%%%%%%%%% Matrice des (xi-xj)
%%%%%%%%%%%% et des (xi-xposition)

temps1=temps(x)-temps(position1);
temps2=temps(y)-temps(position2);

X=zeros(Nb,Nb);
X1=zeros(Nb,Nb);
X2=zeros(Nb,Nb);
for i1=1:n1
for i2=1:n2
for j1=1:n1
for j2=1:n2

X((i1-1)*n2+j1,(i2-1)*n2+j2)=abs(temps1(i1)-temps1(i2))+abs(temps2(i2)-temps2(j2))+0.0001;

X1((i1-1)*n2+j1,(i2-1)*n2+j2)=(abs(temps1(i1))+abs(temps2(j1)))+0.0001;

X2((i1-1)*n2+j1,(i2-1)*n2+j2)=abs(temps1(i2))+abs(temps2(j2))+0.0001;

end;
end;
end;
end;

logX=log(X);


%%%%%%%%%%%% Matrice des log(1+(xi-x_position)/(xi-xj))
%%%%%%%%%%%%            +log(1+(x_position-xj)/(xi-xj))
logY=log(1+X1./X)+log(1+X2./X);


%%%%%%%%%%%% Preparation a l'eclatement de la matrice

minX=min(min(logX));
maxX=max(max(logX));
Xindice=floor(precision_approx*(logX-minX)/(maxX-minX));

%%%%%%%%%%% Nettoyage
clear A;
clear B;
clear X1;
clear X2;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% ALGORITHME     %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (barre_calcul==1) fenetre=fl_waitbar('init');
end;

if frontier_or_spectrum==1
  %fprintf('Starting exponents computations...\n')
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Debut du calcul de la frontiere

vecmax=zeros(1,precision_approx+1);
sprime=-1.25;
Zsprime=logF+(sprime/2)*logY;
clear logF;

vec_sprime=-1.25+2*(1:precision_exp)/precision_exp;

for index=1:precision_exp;

sprime=sprime+2/precision_exp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Debut du calcul de l'exposant s a s' fixe

% On obtient a chaque etape Zsprime=Zsprime+sprime/2*logY,
% ou sprime=-1.25+2*index/precision_exp;

Zsprime=Zsprime+logY/precision_exp;


%%% Eclatement de la matrice
K=1000*Xindice+Zsprime;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Recherche des maxima

for p=0:precision_approx
K1=K(K<(1000*p+100));
K2=K1(K1>(1000*p-150));
if ~isempty(K2) vecmax(p+1)=max(K2)-p*1000;
end;
end;


clear K1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Regression sur les maxima

v=(minX+(0:precision_approx)*(maxX-minX)/precision_approx);

%% sorte d'approximation adaptative... On choisit ou on estime...

[P1,s]=polyfit(v(11:(length(v)-2))',vecmax(11:(length(v)-2))',1);
[P2,s]=polyfit(v(10:(length(v)-3))',vecmax(10:(length(v)-3))',1);
[P3,s]=polyfit(v(9:(length(v)-4))',vecmax(9:(length(v)-4))',1);
[P4,s]=polyfit(v(8:(length(v)-5))',vecmax(8:(length(v)-5))',1);
[P5,s]=polyfit(v(7:(length(v)-6))',vecmax(7:(length(v)-6))',1);
[P6,s]=polyfit(v(6:(length(v)-7))',vecmax(6:(length(v)-7))',1);
[P7,s]=polyfit(v(6:(length(v)-8))',vecmax(6:(length(v)-8))',1);
[P8,s]=polyfit(v(6:(length(v)-2))',vecmax(6:(length(v)-2))',1);


r1(index)=P1(1);
r2(index)=P2(1);
r3(index)=P3(1);
r4(index)=P4(1);
r5(index)=P5(1);
r6(index)=P6(1);
r7(index)=P7(1);
r8(index)=P8(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin du calcul de l'exposant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Trace d'un graphe montrant la regression
if (graphe_approx==1)
if (index==11)
%size(logX)

%%%
figure
plot(v,vecmax,'ko')
hold
for i=0:10-1
i+1
for j=(i+1):10
j+1
plot(logX(10*i+2,10*j),Zsprime(10*i+2,10*j),'r+')
end
end
plot(v(6:(length(v)-2))',(resultat(index)*v(6:(length(v)-2))+P(2))','b-')
hold off;


end;
end;

%%%%%%%%%%%%%%%%%%%%%% Fin de trace des graphes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nettoyage
clear K;
clear K2;
clear v;
clear s;
clear X;

if (barre_calcul==1) fl_waitbar('view',fenetre,index,precision_exp);
end;


end;

%%%%%%%%%%%%%%%%%% Fin du calcul de la frontiere
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nettoyage
clear Zsprime;
clear logF;
clear vecmax;


if (barre_calcul==1) fl_waitbar('close',fenetre);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Convexification des resultats
r1=convex(r1);
r2=convex(r2);
r3=convex(r3);
r4=convex(r4);
r5=convex(r5);
r6=convex(r6);
r7=convex(r7);
r8=convex(r8);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Fin de l'algorithme  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Calcul de la frontiere  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Estimation de la frontiere

% Deux cas apparemment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% 1er cas
resultat1=r8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% 2eme cas

resultat2(1)=r1(1);
i=2;
choix=1;

%%%%%%% 1ere boucle

while (choix==1)&(min([r3(i+1) r3(i+2) r3(i+3)])>max(r1))

if (i<precision_exp-1)
resultat2(i)=r1(i);
i=i+1;
end;

if (i>precision_exp-3)
choix=2;
end;

end;

%%%%%%% phase transitoire

resultat2(i)=r1(i);
resultat2(i+1)=r2(i+1);
resultat2(i+1)=r2(i+2);
i=i+3;

%%%%%%% 2eme boucle
if (i<precision_exp-1)

while (choix==2)&(r3(i)<min(r5(i+1),r5(i+2)))

if (i<precision_exp-1)
resultat2(i)=r3(i);
i=i+1;
end;

if (i>precision_exp-2)
choix=3;
end;

end;
end;

%%%%%%% phase transitoire

if (i<precision_exp+1)
resultat2(i)=r4(i);
i=i+1;
end;

%%%%%%% boucle finale

while (i<precision_exp+1)
resultat2(i)=r5(i);
i=i+1;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Convexification...

resultat1=convex(resultat1);
resultat2=convex(resultat2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Choix final de la frontiere...


ecart1=max([abs(r2(2)-r1(2)) abs(r3(2)-r2(2)) abs(r4(2)-r3(2)) abs(r5(2)-r4(2)) abs(r6(2)-r5(2)) abs(r7(2)-r6(2))]);
ecart2=abs(r7(2)-r1(2));

N=length(r7);
i0=floor(N*1.25/2);
ecart3=max([abs(r2(i0)-r1(i0)) abs(r3(i0)-r1(i0)) abs(r4(i0)-r1(i0)) abs(r5(i0)-r1(i0)) abs(r6(i0)-r1(i0)) abs(r7(i0)-r1(i0))]);


%%%%%%%%%%%%%%
% Sert a choisir le resultat
%if write_ecarts==1
%ecart1
%ecart2
%ecart3
%end;
%%%%%%%%%%%%%%

if (ecart1<0.25)

if(ecart3<0.218+0.31*ecart2)
resultat=resultat2; 
end;

if (ecart3>0.218+0.31*ecart2) resultat=resultat1;
end;

end;

if (ecart1>0.25)
resultat=resultat2;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Fin du calcul de la frontiere %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Estimation des exposants d'Holder%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frontier=resultat;

N2=length(frontier);

i0=floor(N2*1.25/2);
if abs(frontier(i0)-frontier(i0+1))<0.06
al=0.5*(frontier(i0)+frontier(i0+1));
end;

if abs(frontier(i0)-frontier(i0+1))>0.06
al=frontier(i0);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% 1er exposant ponctuel possible

index2=1;
sprime=-1.25+2*index2/N2;

while(sprime<-frontier(index2))&(index2<N2)
index2=index2+1;
sprime=-1.25+2*index2/N;
end;

index2=min(index2,N2);
index2=max(index2,2);

if abs(frontier(index2)-frontier(index2-1))<0.06
ap1=0.5*(frontier(index2)+frontier(index2-1));
end;

if abs(frontier(index2)-frontier(index2-1))>0.06
ap1=frontier(index2-1);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% 2eme exposant ponctuel possible

ap2=0.5*(frontier(1)+frontier(2));


clear frontier;
clear index2;
clear i0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Fin de l'estimation des exposants%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Trace de la frontiere micro-locale  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (trace==1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Frontieres diverses

if (graphe_frontiere==1)

figure;
hold;
plot(r1,-1.25+2*(1:precision_exp)/precision_exp,'rv:');
plot(r2,-1.25+2*(1:precision_exp)/precision_exp,'yv:');
plot(r3,-1.25+2*(1:precision_exp)/precision_exp,'gv:');
plot(r4,-1.25+2*(1:precision_exp)/precision_exp,'bv:');
plot(r5,-1.25+2*(1:precision_exp)/precision_exp,'ro:');
plot(r6,-1.25+2*(1:precision_exp)/precision_exp,'yo:');
plot(r7,-1.25+2*(1:precision_exp)/precision_exp,'go:');
plot(r8,-1.25+2*(1:precision_exp)/precision_exp,'bo:');
plot(resultat1,-1.25+2*(1:precision_exp)/precision_exp,'kv:');

%%%%%%%%%%%%%%%%%%   Axes
plot(zeros(1,10),-1.75+2.74*(1:10)/10,'k:');
plot(-0.75+1.75*(1:10)/10,zeros(1,10),'k:');

%%%%%%%%%%%%%%%%%%   Diagonales
plot((-0.69+1.65*(1:10)/10),-(-0.69+1.65*(1:10)/10),'k-');
plot((-0.05+0.93*(1:10)/10),-(-0.05+0.93*(1:10)/10)+1,'k-');

hold off;

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Vraies Frontieres
figure;
hold;

if (ecart1<0.25)

if(ecart3<0.218+0.31*ecart2)
%%%plot(resultat1,vec_sprime,'k.:');
plot(resultat2,vec_sprime,'kv-');
end;

if (ecart3>0.218+0.31*ecart2)
plot(resultat1,vec_sprime,'kv-');
%%%plot(resultat2,vec_sprime,'k.:');
end;

end;

if (ecart1>0.25)
plot(resultat2,vec_sprime,'kv-');
%%%plot(resultat1,vec_sprime,'k.:');
end;

%%%%%%%%%%%%%%%%%%   Axes
plot(zeros(1,10),-1.75+2.74*(1:10)/10,'k:');
plot(-0.75+1.75*(1:10)/10,zeros(1,10),'k:');

%%%%%%%%%%%%%%%%%%   Diagonales
plot((-0.77+1.765*(1:10)/10),-(-0.75+1.765*(1:10)/10),'k-');
plot((-0.1+1.1*(1:10)/10),-(-0.1+1.1*(1:10)/10)+1,'k-');

hold off;

end;

%%% Fin du trace de la frontiere micro-locale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear r1;
clear r2;
clear r3;
clear r4;
clear r5;
clear r6;
clear r7;
clear r8;
clear P1;
clear P1;
clear P2;
clear P3;
clear P4;
clear P5;
clear P6;
clear P7;
clear P8;
clear i;
clear choix;
clear ecart1;
clear ecart2;
clear ecart3;

clear logX;












