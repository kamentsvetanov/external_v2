function [boxdim,Nboites,handlefig,bounds]=boxdim_listepoints(listepoints,tailles_carres,pave_elementaire,Waitbar,reg,varargin)
% BOXDIM_LISTEPOINTS 
%   Box dimension of a set of points computed with the box method
% -----------------------------------------------------------------------
% SYNTAX :
%
% [boxdim,Nboxes,handlefig]=...
%       boxdim_listepoints(PointsList, Size, Ratio, Waitbar ,reg, ...
%                       lrstr, optvarargin)
% -----------------------------------------------------------------------
% INPUTS :
%
% PointsList  :  N x M matrix
%                Set of points which box dimension is to be computated.
%                Each line corresponds to a point, each column corresponds 
%                to a coordinate.
%
%                N is the number of points
%                M is the number of coordinates (the dimension of the
%                space). For example, if the points lie in an plane, M=2.
%
% Size, Ratio : Ratio defines the lengths of the sides of the reference box.
%               It is a 1xM array.
%               The successive boxes will be deduced from this first box by
%               homotheties with ration Size(i). 
%               More precisely, the box at at the i - th iteration will
%               have a length along the k - th axis equal to Ratio(k)*Size(i)
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
%             iteration. A non-empty box is a box that contains at least one
%             point.
%
% handlefig : If reg==1 or -1 , a window appears. handlefig is the handle of this figure.
%
% bounds    : Bounds of linearity of log2(Nboxes) in function of log2(Size).
%             Interesting if reg==1.
% ---------------------------------------------------------------------
% Optional arguments :
%
% All arguments except PointsList are optional.
% For example, the syntax : boxdim_listepoints(PointsList) is correct.
% If you don't want to precise an argument, you can also type [].
% The missing arguments take their default values:
%
% Size=[1 1/2,1/4,...1/4096]
% Ratio =[1 1 ...] 
% Waitbar = 0
% reg=0
% lrstr='ls'
%
% These default values are not always relevant, especially Size, 
% so use reg ~=0 when you don't know the correct box sizes.
% ---------------------------------------------------------------------
% Example:
% Computes the box dimension of a self-similar set of points. Its theorical
% dimension is log(5)/log(3)=1.46
%
%   % load the list of points
%   load('fusee.mat');
%   % Plot the list of points
%   figure;plot(fusee(:,1),fusee(:,2),'.');
%   % Compute its box dimension
%   reg=1;
%   Waitbar=1;
%   [boxdim,Ntailles,handlefig,bounds]=boxdim_listepoints(fusee,[],[],Waitbar,reg);
%   boxdim
%   bounds
%
%   % You should find bounds = -6 -2. This means that
%   % the progression is linear when log2(size) is in [-6 -2]. You may keep these
%   % bounds, take more points and try another regression type.
%   reg=0;
%   Size=2.^[-6 : 0.5 : -2];
%   boxdim=boxdim_listepoints(fusee,Size,[],Waitbar,reg,'pls',30);
%   boxdim
% --------------------------------------------------------------------
%
% See also BOXDIM_CLASSIQUE, BOXDIM_BINAIRE, FL_REGRESSION, NORMALIZE_LIST

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin<2;tailles_carres=[];end
if nargin<3;pave_elementaire=[];end
if nargin<4;Waitbar=[];end
if nargin<5;reg=[];end
RegParam=varargin;

if isempty(tailles_carres);tailles_carres=2.^[0:-1:-12];end
if isempty(pave_elementaire);pave_elementaire=ones(1,size(listepoints,2));end
if isempty(Waitbar);Waitbar=0;end
if isempty(reg);reg=2;end
if isempty(RegParam);RegParam={'ls'};end

Npoints=size(listepoints,1);
Ncoordonnees=size(listepoints,2);
Ntailles=size(tailles_carres,2);
Nboites=[];

if Waitbar;h = fl_waitbar('init');end
for i=1:Ntailles
    taille=tailles_carres(i);
    pave=pave_elementaire*taille;
    pavemat=ones(Npoints,1)*pave;
    paves_non_vides=floor(listepoints./pavemat);
    paves_ranges=sortrows(paves_non_vides);
    differences=paves_ranges(2:Npoints,:)-paves_ranges(1:Npoints-1,:);
    Nchangements=sum(sum(differences~=0,2)>0);
    Nboites(i)=Nchangements+1;
    if Waitbar;fl_waitbar('view',h,i,Ntailles);end
end
if Waitbar;fl_waitbar('close',h);end 

% p=polyfit(log(tailles_carres),log(Nboites),1);
% boxdim=-p(1);

%[boxdim,handlefig,bounds]=fl_regression(log2(tailles_carres),log2(Nboites),'-a_hat','BoxDimension',reg,RegParam{:});
[boxdim,handlefig,bounds]=fl_regression(log2(tailles_carres),log2(Nboites),'-a_hat','BoxDimension',reg,RegParam{:});