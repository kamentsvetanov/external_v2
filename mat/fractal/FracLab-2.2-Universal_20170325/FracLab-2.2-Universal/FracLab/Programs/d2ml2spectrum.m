function [vec_sprime,res]=d2ml2spectrum(f,temps, start_point1, end_point1, start_point2, end_point2, prec, barre_calcul,plot_pointwise,plot_local,fen);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%[N1,N2]=size(f);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Le resultat est l'ensemble des fontieres plus l'ensemble
% des exposants locaux et ponctuels d'Holder.
% Tout est stocke dans un tableau.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nb_estim1=end_point1-start_point1+1;
nb_estim2=end_point2-start_point2+1;
nb_estim=nb_estim1*nb_estim2;
res=zeros(nb_estim1,nb_estim2,prec+3);
ap1=zeros(nb_estim1,nb_estim2);
ap2=zeros(nb_estim1,nb_estim2);
al=zeros(nb_estim1,nb_estim2);

%%fprintf('Starting computations....\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Affichage waitbar
if (barre_calcul==1) fenetre=fl_waitbar('init');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Debut des calculs

for i=1:nb_estim1
for j=1:nb_estim2

% if (((i-1)*nb_estim2+j)==5)
%     fprintf('Point ');((i-1)*nb_estim2+j)
% end;

graph_plot=0;


[vec_sprime,res(i,j,1:prec),ap1(i,j),ap2(i,j),al(i,j)]=d2ml2frontier(f,start_point1+i-1,start_point2+i-1,temps,prec,20,0,0,graph_plot,graph_plot,0,2,15);




% Incrementation waitabr
if (barre_calcul==1) fl_waitbar('view',fenetre,i,nb_estim1);
end;


end;
end;

%%% Fin des calculs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fin d'affichage waitbar
if (barre_calcul==1) fl_waitbar('close',fenetre);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Affichage resultat

if (plot_pointwise==1)
%figure;
%plot(start_point:end_point,ap1,'r-');
%title('Pointwise Holder Exponents(1)');
%figure;
%plot(start_point:end_point,ap2,'r-');
%title('Pointwise Holder Exponents');
end;

if plot_local==1
%figure;
%plot(start_point:end_point,al,'r-');
%title('Local Holder Exponents');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%size(res(:,:,prec+1))
%size(ap1)

res(:,:,prec+1)=ap1;
res(:,:,prec+2)=ap2;
res(:,:,prec+3)=al;

