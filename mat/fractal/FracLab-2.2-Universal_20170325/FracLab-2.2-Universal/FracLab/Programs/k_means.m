function [moy, out, xmin, xmax] = k_means(x,K)
% No help found

% Author Olivier Barrière, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%Tri
n = length(x);
x0 = x;
[x indice] = sort(x);
xmin = x(1);
xmax = x(n);

%Initialisation des K moyennes : linéairement réparties entre xmin et xmax
moy = linspace(x(1),x(n),K);
moy0 = zeros(1,K);
sepx = zeros(1,K-1);

while (sum(abs(moy0-moy))~=0) %(moy0 ~= moy)
	
	%Anciennes moyennes
	moy0 = moy;
	
	%Affectation des classes aux noyaux
	%x(i) appartient à la kième classe ssi abs(x(i)-z(k)) = min(j, abs(x(i)-z(j)))
	%+ cas particulier valeurs scalaires et triées : séparatrice = moyenne entre 2 noyaux
	for i = 1:K-1
		sepx(i) = 0.5*(moy(i)+moy(i+1));
	end
	
	%clear sep;
    sep = zeros(1,K-1);
	for i = 1:K-1
		for j = 1:n-1
			if x(j) <= sepx(i) && sepx(i) <= x(j+1)
				sep(i) = j;
			end	
		end
	end
	sep =  [1 sep n];  %taille K-1, plus les extrémités
	
	%Recalcul des moyennes
	for i = 1:K
		moy(i) = mean(x(sep(i):sep(i+1)));
	end
end

%on crée le vecteur résultant de la projection des points sur leur noyau correspondant
out1 = zeros(1,n);
for i=1:K
	out1(sep(i):sep(i+1)) = i;
end

%On réordonne dans l'ordre initial
out(indice)=out1;


%En utilisant la fonction kmeans de la toolbox stats de Matlab
%(Encore plus lent !)
%sizex = size(x);                         
%if sizex(1) == 1                         
%	[out, moy] = kmeans(x', K);      
%	out = out';                      
%	moy = moy';                      
%else                                     
%	[out, moy] = kmeans(x, K);	 
%end                                      
%xmin = min(x);                           
%xmax = max(x);                           
                                         