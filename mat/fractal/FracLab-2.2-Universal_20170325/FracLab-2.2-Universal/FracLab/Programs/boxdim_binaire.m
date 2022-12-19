function [boxdim,Nboites,handlefig,bounds]=boxdim_binaire(matrice,tailles_carres,pave_elementaire,Axes,Waitbar,reg,varargin);
% BOXDIM_BINAIRE 
%   Box dimension, computed with the box method, of the white points in 
%   a black and white image or, more generally, of non-zero-points in an
%   N-dimensional array.
% -----------------------------------------------------------------------
% SYNTAX :
%
% [boxdim,Nboxes,handlefig]=...
%       boxdim_binaire(BWimg, Size, Ratio, Axes, Waitbar ,reg, ...
%                       lrstr, optvarargin)
% -----------------------------------------------------------------------
% INPUTS :
%
% BWimg  :  N-dimensional array
%           Usually, it is a matrix containing 0 and 1. If BWImg contains values 
%           different from 0 and 1, all non-zero values are treated as ones.
%           
% Size, Ratio : 
%       Ratio defines the lengths of the sides of a "first box". If BWimg 
%       is an image, it is a 1x2 array. (1xN array if BWimg is an
%       N dimensional array)
%       The successive boxes will be deduced from this first box by
%       homotheties with ration Size(i). 
%       More precisely, the box at at the i - th iteration will
%       have a length along the k - th axis equal to Ratio(k)*Size(i)
%       
% Axes   :   . If BWImg is an array, Axes is a 1x2 array : [Xmin,Xmax].
%              Xmin is the abscissa corresponding to Signal(1) and Xmax the
%              abscissa corresponding to Signal(end).
%            . If BWImg is a matrix(black and white image), 
%              Axes is a 2 x 2 matrix containing the coordinates of its
%              corners : [Xmin Xmax ; Ymin Ymax].
%            . If BWImg is an N-dimensional array, Axes is an Nx2 matrix.
%
% Waitbar : 1 if you want a waitbar to appear during the calculation, else 0
%
% reg     : The way you choose the bounds.
%           See the help on fl_regression for more information.
%
% lrstr,optvarargin   : 
%           Regression parameters. 
%           It defines the regression type. Type " help monolr" for more
%           information
% ------------------------------------------------------------------------
% OUTPUTS :
%
% boxdim :    The estimated box dimension
%
% Nboxes :    Nboxes is a vector. 
%             Nboxes(i) is the number of non-empty boxes at the i - th
%             iteration. A non-empty box is a box that contains at least one
%             non-zero element.
%
% handlefig : If reg~=0 , a window appears to help you choosing the
%              linearity bounds. handlefig is the handle of this figure.
% bounds    : Bounds of linearity of log2(Nboxes) in function of log2(Size).
%             Interesting if reg==2.
% ---------------------------------------------------------------------
% Optional arguments :
%
% All arguments except BWimg are optional.
% For example, the syntax : boxdim_binaire(BWimg) is correct.
% If you don't want to precise an argument, you can also type [].
% The missing arguments take their default values:
%
% Size=[1 1/2 1/4 ... 1/4096]
% Ratio =[1 1 ...] 
% Axes=[0 1;0 1 ; ...]
% Waitbar = 0
% reg=2
% lrstr='ls'
%
% These default values are not always relevant, especially Size, 
% so use reg ~=0 when you don't know the interesting 
% box sizes.
% ---------------------------------------------------------------------
% Example : Computes the box dimension of a self-similar image. Its theorical
% dimension is log(7)/log(3)=1.77
%
%   % load the image
%   load('fleche.mat');
%   % Plot the image
%   figure;imagesc(fleche);colormap('gray');pause;
%   % Compute its box dimension
%   reg=1;
%   Waitbar=1;
%   [boxdim,Ntailles,handlefig,bounds]=boxdim_binaire(fleche,[],[],[],Waitbar,reg);
%   boxdim
%   bounds
%
%   % You should find bounds = -9 -3. It means that
%   % the progression is linear when log2(size) is in [-9 -3]. You may keep these
%   % bounds, take more points and try another regression type.
%   reg=0;
%   Size=2.^[-9 : 0.5 : 0-3];
%   boxdim=boxdim_binaire(fleche,Size,[],[],Waitbar,reg,'pls',30);
%   boxdim
%
% -------------------------------------------------------------------------
%
% See also BOXDIM_CLASSIQUE, BOXDIM_LISTEPOINTS, FL_REGRESSION

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

u=varargin;
Dim_matrice=size(matrice);
Ncoordonnees=sum(Dim_matrice>1);
indices_presents=find(matrice);

if nargin<2;tailles_carres=[];end
if nargin<3;pave_elementaire=[];end
if nargin<4;Axes=[];end
if nargin<5;Waitbar=[];end
if nargin<6;reg=[];end
if nargin<7;RegParam=[];end

if isempty(Axes)
        Axes=repmat([0 1],[Ncoordonnees,1]);
end

listepoints=[];
indices=indices_presents;
for i=1:Ncoordonnees
    cote=Dim_matrice(i);
    coordonnees=mod(indices-1,cote)+1;
    indices=(indices-coordonnees)/cote+1;   
    vecteur_normalise=(Axes(i,2)-Axes(i,1))/(cote-1)*(coordonnees-1)+Axes(i,1);
    listepoints=[listepoints,vecteur_normalise];
end


[boxdim,Nboites,handlefig,bounds]=boxdim_listepoints(listepoints,tailles_carres,pave_elementaire,Waitbar,reg,u{:});
