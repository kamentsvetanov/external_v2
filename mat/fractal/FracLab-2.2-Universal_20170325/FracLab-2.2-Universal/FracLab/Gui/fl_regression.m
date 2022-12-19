function [dim,handlefig,bounds]=fl_regression(x,y,FORMULE,ChoixTextes,reg,varargin)
% ----------------------------------------------------------------
% Linear regression with a possible choice of the linearity bounds on a
% drawing.
%
% ----------------------------------------------------------------
% [dim,handlefig,bounds]=fl_regression(x,y,FORMULE,ChoixTextes,reg,RegParam)
%
% Inputs :
% x : vector       = abscissas of the points
% y : vector       = ordinates of the points
%
% FORMULE :         Expression of dim as a function of the regression 
%                   slope a_hat (e.g if it is '-a_hat', the output dim will be the 
%                   opposite of the calculated slope).
%
% ChoixTextes :     If ChoixTextes is a string arrray, the titles and
%                   label axes will be consistent with the calculation 
%                   of the corresponding dimension.
%                   ChoixTextes = 'BoxDimension' => Box dimension calculation
%                   ChoixTextes = []             => Default displaying
%                   
%                   You may also define ChoixTextes the following way:
%                   ChoixTextes=strvcat(title1,title2,title_estimated, ...
%                   xlabel1,xlabel2,ylabel1,ylabel2,FORMULE)
%                   with :
%                   title1,title2: Titles of both graphs before estimation
%                   title_estimated : Title of the second graph after
%                   estimation (eg 'Slope = ').
%                   xlabel1,xlabel2,ylabel1,ylabel2 : Axes labels
%
% reg     : 0 : All box sizes are taken into consideration when computing 
%               the linear regression.
%           1 : The output 'dim' is empty, but a figure appears.
%               In this figure, you will be able to choose manually a 
%               range of sizes where the evolution of x versus y
%               is linear and to read the result of the calculation with this range.
%           2  : All box sizes are taken into consideration when computing 
%               the output 'dim'. Moreover, the same figure appears on
%               which you will be able to choose another regression range.
%           -1 : The same figure appears, but the function waits for your choice
%               of bounds and returns the resulting dimension in the
%               output 'dim'.
%
% RegParam : Regression parameters. See the help of monolr for more
% informations.
%
% ----------------------------------------------------------------
% Outputs : 
% dim       : Ouptut calculated with the formula FORMULE 
%             as a function of the regression slope a_hat.
%             By default, dim is the slope of the regression line.
% handlefig : figure handle
% bounds    : Vector [xmin xmax] : Bounds of linearity of y.
% -------------------------------------------------------------
% Default arguments.
% If you don't precise all arguments or type an empty matrix []
% the missing argument(s) will take their default value.
% Default value     :
% Of y              : [1:N]
% Of FORMULE        : 'a_hat' (the slope)
% Of HandleOut      : -1 (no uicontrol output)
% Of ChoixTextes    : Simple titles and labels
% Of reg            : 2
% Of RegParam       : 'ls'
% ----------------------------------------------------------------
%
% See also MONOLR, FL_MONOLR

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin<3;FORMULE=[];end
if nargin<4;ChoixTextes=[];end
if nargin<5;reg=[];end
RegParam=varargin;

if isempty(FORMULE);FORMULE='a_hat';end
if isempty(ChoixTextes);ChoixTextes=' ';end
if isempty(reg);reg=2;end
if isempty(RegParam);RegParam={'ls'};end

n=length(x);
bounds=[1,n];

if (reg==0)|(reg==2)         % Pas de choix des bornes
    [a_hat,b_hat]=fl_monolr(x,y,RegParam{:});
    dim=eval(FORMULE);bounds=[];
    handlefig=[];
end
if (reg==-1)|(reg==1)|(reg==2)                % Choix des bornes sur un graphique
    handlefig=figure;%('MenuBar','figure');
    %%%%%%%%%%%%%%%%%%
    % Message to hit "return" or "escape" to end the cursor capture
    TextER = uicontrol('Parent',gcf,...
	'Units','normalized', ...
	'FontUnits','pixels', ...
	'FontSize',14, ...
    'ForegroundColor','w',...
    'BackgroundColor','k',...
	'FontWeight','bold', ...
    'Position',[0 0 1 0.04], ...
	'String','Choose the bounds of the interval. Press ESCAPE or RETURN to end', ...
	'Style','text', ...
   'Tag','info');

    %%%%%%%%%%%%%%%%%%
    % Affectation des titres du graphique
	if size(ChoixTextes,1)>1
        texts=ChoixTextes
	else
        switch(ChoixTextes)
            case('BoxDimension')
                texts=strvcat(' ','Box Dimension','   Estimated Box Dimension = ','log2(size)','log2(size)','Increments \Delta log2(number)','log2(number)');
            case('RegularizationDimension')
                texts=strvcat(' ','Regularization Dimension','   Estimated Regularization Dimension = ','scale','scale','Increments \Delta log2(L)','log2(L)');
	    case('GlobalScalingExponent')
                texts=strvcat(' ','Global Scaling Exponent','   Estimated Global Scaling Exponent = ','scale','scale','Increments \Delta log2(spec)','log2(spec)');                
	    case('LocalHolderExponent')
                texts=strvcat(' ','Local Holder Exponent','   Estimated Local Holder Exponent = ','scale','scale','Increments \Delta log2(line)','log2(line)');                   
      case('PointwiseHolderExponentOscillations')
                texts=strvcat(' ','Pointwise Holder Exponent','   Estimated Pointwise Holder Exponent = ','log(size)','log(size)','Increments \Delta log(osc)','log(osc)');                   
            otherwise
                texts=strvcat(' ',' ','Estimated slope = ','x','x','Increment','Value');
        end
    end
	title1=texts(1,:);
	title2=texts(2,:);
	title_estimated=texts(3,:);
	xlabel1=texts(4,:);
	xlabel2=texts(5,:);
	ylabel1=texts(6,:);
	ylabel2=texts(7,:);
    
	%%%%%%%%%%%%%%%%
	% Range les x par ordre croissant
	ranges=[x',y'];
	bienranges=sortrows(ranges);
	x=bienranges(:,1);
	y=bienranges(:,2);
	
    %%%%%%%%%%%%%%%%
    % Tracé de x en fonction de y sur le graphe inférieur
    set(handlefig,'Units','normalized','Position',[0.232 0.200 0.660 0.75])
    subplot(2,1,1)
    plot(x,y,'k');hold on;
    plot(x,y,'ko');
    lesx=get(gca,'XLim');
    axis manual;

    %%%%%%%%%%%%%%%%
    % Tracé de la dérivée de x sur le graphe supérieur
    subplot(2,1,2)
    diffY=diff(y);
    diffX=diff(x);
    dLdarate=diffY./diffX;
    newx=x(2:end);
    plot(newx,dLdarate,'ko');
    set(gca,'XLim',lesx);
    
    %%%%%%%%%%%%%%%%%
    % Affichage des titres
    subplot(2,1,2);
    title(title1);
    ylabel(ylabel1);
    xlabel(xlabel1);
    grid;
    subplot(2,1,1);
    title(title2)
    ylabel(ylabel2);
    xlabel(xlabel2);
    grid;

    h.x=x;
    h.y=y;
    h.FORMULE=FORMULE;
    h.texts=texts;
    h.reg=reg;
    h.RegParam=RegParam;
    h.efface=0;
    h.TextER=TextER;
    h.HandleOut=-1;
    guidata(handlefig,h);
    
    figure(handlefig);
    subplot(2,1,1);
    
    %%%%%%%%%%%%%%%%%
    % Application du thème
    fl_window_init(handlefig,'Figure');
    
    if reg==1
        dim=[];
        bounds=[];
        choixbornes('init');
    end
    if reg==-1
        choixbornes('init');
        waitfor(handlefig,'CreateFcn','ComputationOK');
        h=guidata(handlefig);
        dim=h.dim;
        bounds=h.bounds;
    end
    if reg==2
        bounds=[min(x),max(x)];
        choixbornes('init');
        choixbornes('FullRange');
        choixbornes('Sortie',gcf);
    end
end
