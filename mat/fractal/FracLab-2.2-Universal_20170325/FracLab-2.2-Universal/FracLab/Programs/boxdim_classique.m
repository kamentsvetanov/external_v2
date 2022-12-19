function [boxdim,Nboites,handlefig,bounds]=boxdim_classique(matrice,tailles_carres,pave_elementaire,Axes,Waitbar,reg,varargin)
% BOXDIM_CLASSIQUE 
%   Box dimension of the graph of a function from R^N to R computed using 
%   the box-method.
% -----------------------------------------------------------------------
% SYNTAX :
%
% [boxdim,Nboxes,handlefig]=...
%       boxdim_binaire(Signal, Size, Ratio, Axes, Waitbar ,reg, ...
%                       lrstr, optvarargin)
% -----------------------------------------------------------------------
% INPUTS :
%
% Signal :  Usually, Signal is a 1-D array (values of a function), but it can 
%           also be a matrix 2-D array (Grayscale image, white pixels considered 
%           as peaks and dark pixels as valleys) or an N dimensional array
%           with any N, where the function goes fram R^n to R
%
% Size, Ratio : 
%       Ratio defines the lengths of the sides of a reference box.
%        . If Signal is 1D, then Ratio is a 1x2 array.
%          Ratio(1,1) is the X-length of this first box, and Ratio(1,2) is his Y-length.
%        . If Signal is 2D, then Ratio is a 1x3 array.
%          Ratio(1,3) is the Z-length : the height of this box, if you consider light 
%          pixels as peaks and dark pixels as valleys.
%        . If Signal is an N-dimensional array, then Ratio is a 1x(N+1) array.
%
%       The successive boxes will be deduced from this first box by
%       homotheties with ration Size(i). 
%       More precisely, the box at at the i - th iteration will
%       have a length along the k - th axis equal to Ratio(k)*Size(i)
%       
% Axes   :   Domain of definition of the signal. For example, if f goes
%            from [0,1]x[0,1] to R, then Axes=[0,1;0,1]. In general:
%            . If Signal is a vector, Axes is a 1x2 array : [Xmin,Xmax].
%              Xmin is the abscissa corresponding to Signal(1) and Xmax the
%              abscissa corresponding to Signal(end).
%            . If Signal is a 2D array(grayscale image), Axes is a 2 x 2 matrix :
%              [Xmin Xmax ; Ymin Ymax].
%            . If Signal is an ND-array, Axes is an Nx2 array.
%
% Waitbar : 1 if you want a waitbar to appear during the calculation, else 0
%
% reg     : The way you choose the bounds.
%           See the help on fl_regression for more information.
%
% lrstr,optvarargin   : 
%           Regression parameters. 
%           They define the regression type. Type " help monolr" for more
%           information
% ------------------------------------------------------------------------
% OUTPUTS :
%
% boxdim :    The estimated box dimension
%
% Nboxes :    Nboxes is a vector. 
%             Nboxes(i) is the number of non-empty boxes at the i - th
%             iteration. A non-empty box is a box that contains at leat one
%             point of the graph of the function.
%
% handlefig : If reg~=0, a window appears to help you choosing the
%              linearity bounds. handlefig is the handle of this figure.
% bounds    : Bounds of linearity of log2(Nboxes) in function of log2(Size).
%             Interesting if reg==1.
% ---------------------------------------------------------------------
% Optional arguments :
%
% All arguments except Signal are optional.
% For example, the syntax : boxdim_classique(Signal) is correct.
% If you don't want to precise an argument, you can also type [].
% The missing arguments take their default values:
%
% Size=[1 1/2 1/4 ... 1/2048 1/4096]
% Ratio =[1 1 ...] 
% Axes=[0 1;0 1 ; ...]
% Waitbar = 0
% reg=2
% lrstr='ls'
%
% These default values are not always relevant, especially Size, 
% so when you don't know how to define Size, try to use reg = +-1 in order to precise 
% manually the correct box sizes.
% ---------------------------------------------------------------------
% Example:
% Computes the box dimension of a Weierstrass function. 
%
%   % Computes a Weierstrass function with h=0.5
%   % Theorically, the boxdimension of its graph is 2-0.5 = 1.5
%   Wei=GeneWei(4096,'0.5');
%   t=linspace(0,1,4096);
%   % Plot the graph
%   figure;plot(t,Wei);pause;
%   % Compute its box dimension
%   reg=1;
%   Waitbar=1;
%   [boxdim,Ntailles,handlefig,bounds]=boxdim_classique(Wei,[],[],[],Waitbar,reg);
%   boxdim
%   bounds
%
%   % You should find bounds = -4 0. This means that
%   % the progression is linear when log2(size) is in the range [-4 0]. You may keep these
%   % bounds, take more points and try another regression type.
%   reg=0;
%   Size=2.^[-4 : 0.1 : 0];
%   boxdim=boxdim_classique(Wei,Size,[],[],Waitbar,reg,'pls',30);
%   boxdim

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

Dim_matrice=size(matrice);
Ncoordonnees=ndims(matrice);
Coordonnees={};

if nargin<2;tailles_carres=[];end
if nargin<3;pave_elementaire=[];end
if nargin<4;Axes=[];end
if nargin<5;Waitbar=[];end
if nargin<6;reg=[];end
RegParam=varargin;

if isempty(Axes)
    if sum(Dim_matrice>1)==1 
        % matrice est un vecteur
        Axes=[0 1];
    else
        Axes=repmat([0 1],[length(Dim_matrice),1]);
    end
end


if sum(Dim_matrice>1)==1
    % matrice est un vecteur    
    matrice=shiftdim(matrice);
    N=length(matrice);
    abscisses_normalisees=(Axes(2)-Axes(1))/(N-1)*([1:N]'-1)+Axes(1);
    listepoints=[abscisses_normalisees,matrice];
else
    % matrice est une image ou un objet de dimension >2
    % Coordonnees{i} est alors constituee des numeros de la i-ème coordonnée normalisée.
    % Exemple : matrice=rand(2,3) alors Coordonnees{1}=[0 0 0;1 1 1] et
    % Coordonnees{2}=[0 0.5 1;0 0.5 1];
    for i=1:Ncoordonnees
         longueur_i=Dim_matrice(i);
    %     taille_a_repeter=ones(Ncoordonnees);
    %     taille_a_repeter(i)=longueur_i;   
        permutations=[2:i,1,i+1:Ncoordonnees];
        vecteur_normalise=(Axes(i,2)-Axes(i,1))/(longueur_i-1)*([1:longueur_i]'-1)+Axes(i,1);
        vecteur_a_repeter=permute(vecteur_normalise,permutations);
        repete=Dim_matrice;
        repete(i)=1;
        Coordonnees{i}=repmat(vecteur_a_repeter,repete);    
    end

    % On cree la liste des points comme suit: Chaque colonne est une
    % coordonnee, la dernière colonne est la valeur de matrice en ce
    % point.
    listepoints=[];
    for i=1:Ncoordonnees
        listecoordonnees=reshape(Coordonnees{i},[],1);
        listepoints=[listepoints,listecoordonnees];
    end
    listecoordonnees=reshape(matrice,[],1);
    listepoints=[listepoints,listecoordonnees];
end

[boxdim,Nboites,handlefig,bounds]=boxdim_listepoints(listepoints,tailles_carres,pave_elementaire,Waitbar,reg,RegParam{:});
