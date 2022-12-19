function [a,b]=regression_elimination(x,y,SupOuInf,Sigma,Gamma,TolNum)
% REGRESSION_ELIMINATION
%   Evaluation de la liminf ou limsup par eliminations successives.
% --------------------------------------------------------------
% SYNTAX :
% [a,b]=regression_elimination(x,y,SupOuInf,Sigma,Gamma,TolNum)
% --------------------------------------------------------------
% INPUTS:
%   x           : Abscisses
%   y           : Ordonnées
%   SupOuInf    : 'lsup' si recherche de limsup, 'linf' sinon.
%   Point n éliminé si y(n)+TolNum+Sigma*sqrt(N)*n^Gamma est en dessous de la
%   droite de régression.
% --------------------------------------------------------------
% OUTPUTS:
%   a           :Pente
%   b           :Valeur de la droite à l'origine: offset

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Valeurs par défaut
if nargin<6;TolNum=[];end
if nargin<5;Gamma=[];end
if nargin<4;Sigma=[];end
if nargin<3;SupOuInf=[];end

if isempty(TolNum);TolNum=10^(-12);end
if isempty(Gamma);Gamma=0;end
if isempty(Sigma);Sigma=0;end
if isempty(SupOuInf);SupOuInf='linf';end

% Reshape x and y
x=shiftdim(x);
y=shiftdim(y);

% Computation
if strcmp(SupOuInf,'linf')    
    N=size(x,1);
    if N<2
        error('The regression needs more than one point');
    end
    while N>1
        [a,b]=monolr(x,y,'ls');
        indices=find(y+TolNum+Sigma*sqrt(N)*[1:N]'.^Gamma<a*x+b);
        y=y(indices);
        x=x(indices);
        N=size(x,1);
    end
elseif strcmp(SupOuInf,'lsup')
    [a,b]=regression_elimination(x,-y,'linf',Sigma,Gamma,TolNum);
    a=-a;b=-b;
else
    error('Troisième argument de regression_elimination:''lsup'' si recherche de limsup, ''linf'' sinon')
end