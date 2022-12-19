function [vec_sprime,res]=ml2spectrum(f,temps, start_point, end_point, prec,plot_graph, barre_calcul,plot_pointwise,plot_local);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N=length(f);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Le resultat est l'ensemble des fontieres plus l'ensemble
% des exposants locaux et ponctuels d'Holder.
% Tout est stocke dans un tableau.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nb_estim=end_point-start_point+1;
res=zeros(nb_estim,prec+3);
ap1=zeros(1,nb_estim);
ap2=zeros(1,nb_estim);
al=zeros(1,nb_estim);

%fprintf('Starting computations....\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Affichage waitbar
if (barre_calcul==1) fenetre=fl_waitbar('init');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Debut des calculs

for i=1:nb_estim

graph_plot=0;

if (plot_graph==1) 
if (i==(nb_estim/2))
graph_plot=1;
end;
end;

if ((i-1)/5==floor((i-1)/5))
%fprintf('Point %d....\n',start_point+i-1);
end;

[vec_sprime,res(i,1:prec),ap1(i),ap2(i),al(i)]=ml2frontier(f,start_point+i-1,temps,prec,20,0,0,graph_plot,graph_plot,0,2);




% Incrementation waitbar
if (barre_calcul==1) fl_waitbar('view',fenetre,i,nb_estim);
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
figure;
plot(start_point:end_point,ap2,'r-');
title('Pointwise Holder Exponents');
end;

if plot_local==1
figure;
plot(start_point:end_point,al,'r-');
title('Local Holder Exponents');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

res(:,prec+1)=ap1';
res(:,prec+2)=ap2';
res(:,prec+3)=al';

