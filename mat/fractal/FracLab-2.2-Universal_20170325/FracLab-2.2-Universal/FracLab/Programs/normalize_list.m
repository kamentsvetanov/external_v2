function liste=normalize_list(liste,a,b)
% NORMALIZE_LIST 
% Apply an affine transform to each column of a matrix in
% order to get each column between two given values.
% ----------------------------------------------------
% SYNTAX
% ListOut=normalize_list(ListIn,a,b)
% ----------------------------------------------------
% INPUTS
% ListIn    : Matrix whose columns are to be normalized.
% a         : Minimum of the Output matrix
% b         : Maximum of the Ouput matrix
% -------------------------------------------------
% OUTPUT
% ListOut   : Each column of ListOut is deduced from the application of 
% an affine transform to the same column of ListIn. The minimum of each
% column of ListOut is a and its maximum is b.
% If a column of ListIn is constant, then the same column of ListOut will be
% constant, equal to (a+b)/2.
% --------------------------------------------------
% Example
% theta=[0:0.1:2*pi]';
% x=3*cos(theta)+1;
% y=17*sin(theta)-179;
% ListIn=[x,y];
% ListOut=normalize_list([x,y],0,1);
% x_normalized=ListOut(:,1);
% y_normalized=ListOut(:,2);
% plot(x,y);Title('Initial shape');figure;
% plot(x_normalized,y_normalized);Title('Normalized Shape');

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin<2
    a=0;b=1;
end

%%%%%%%% On se ramène entre 0 et 1  par transformation linéaire %%%%%%%%%%
maxL=max(liste);
minL=min(liste);
% On récupère les indices sur lesquels la liste est constante
Indices_bien=find(maxL-minL);
Indices_mal=find(maxL-minL==0);
% On fait la transformaton sur les indices pour lesquels la liste n'est pas
% constante
liste_cool=liste(:,Indices_bien);
maxL_cool=maxL(Indices_bien);
minL_cool=minL(Indices_bien);
liste_cool=liste_cool-ones(size(liste,1),1)*minL_cool;
liste_cool=liste_cool./(ones(size(liste,1),1)*(maxL_cool-minL_cool));
% On remet le vecteur en place
liste(:,Indices_bien)=liste_cool;
liste(:,Indices_mal)=0.5*ones(size(liste,1),length(Indices_mal));

%%%%%%%%% On revient entre a et b par transformation linéaire %%%%%%
liste=(b-a)*liste+a;
