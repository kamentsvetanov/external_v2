%% mycorrplot_2
% Viisualize the result of correlation (i.e. the results from * corr(X,Y) *). 
%
% by Wei-Ting Lin, _2014/10/23_

% Dependent
% [plot_circle.m] [mycolor.m] [nancorr.m] [tnames.m]
%
% *Example* : [X_corrplots_2.m]

%%  Using [mycorrplot_2]
% *Syntax*
% 
% mycorrplot_2(X,Y,xnames,ynames,type,plotson)
%
% * X, Y: array or table, the data; X and Y should have the same number of rows; we are
% interested in correlation between each column of X and each column of Y.
% as in corr(X,Y), NaN will be removed
% * xnames, ynames : name of each column in X and Y, stored in cell array of strings; default is {'1','2','3',....}
%                 if X, Y are table, default xnames is the variable names of the table. (or used place holder [] )
% * type :  style of output, can be 'C' (for circle),'T' (for text),'B';
% default is 'B' (for both)
% * plotson: a  vector of 3 numbers,0 or 1, indicate whether each plot will
% be made. Default: [1 0 0]
% 
% *Plotson*
%
% * plotson(1): the main plot with R and p values
% * plotson(2): the scatterplots with LS line
% * plotson(3): the color bar for the circles
%      
% update 2015/10/30 : use mycolor function, compatible with data type "table", NaN ignored, new scatterplot style 
%%
 function mycorrplot_2(X,Y,xnames,ynames,type, plotson)
  % Add compatibility to data type "table"
     inputxtable=0; % flag for whether input is a table (or matrix by default)
     inputytable=0; 
  if istable(X)
          inputxtable = 1;
          Xname = tnames(X); % save names before change data type
          X = X{:,strcmp(varfun(@class,X,'OutputFormat','Cell'), 'double')} ;         
          if nargin < 3 || isempty(xnames)
                xnames = Xname;
          end        
  end
  if istable(Y)
          inputytable = 1; 
          Yname = tnames(Y); % save names before change data type
          Y = Y{:,strcmp(varfun(@class,Y,'OutputFormat','Cell'), 'double')} ;         
          if nargin < 4 || isempty(ynames)
                ynames = Yname;
          end        
  end
 
 
 % for corr(X,Y)
  if  any(any(isnan([X Y])))
 disp('NaN removed before calculating correlation; see nancorr.m for detail')
  end
 
 [Rvals, Pvals] = nancorr(X,Y);
 [p1,p2] = size(Rvals);
 
%%% Setting up default values
if (nargin < 3) && inputxtable == 0
    xnames={};
    for i=1:p1       
        xnames{i} = num2str(i); 
    end;
end;
if (nargin < 4) && inputytable == 0,
ynames={};
    for i=1:p2       
        ynames{i} = num2str(i); 
    end;
end;

if (nargin < 5|| isempty(type)), type = ('B'); end;
if (nargin < 6), plotson = [1 1 0]; end;
%%% Error %%%
if isempty(find(plotson==1))
    error('At least one element in plotson must be 1')
end

%%% Setting up the "subplot" parameters
XRange = 0.8/(p2+1); YRange=0.8/(p1+1);
XBox = XRange*0.95;  YBox=YRange*0.95;
% Range = Box + Gap

Xss(1)=0.1+XBox;% Starting points of X
    if p2>1
         for j = 2:p2
             Xss(j) = Xss(j-1) + XRange;
         end
    end
Yss(1)=0.9-YRange; % starting points of Y
    if p1>1
        for i = 2:p1
            Yss(i) = Yss(i-1) -  YRange;
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make a plot to visualize R and P
Csize = ones(p1,p2);
    Csize(Pvals>=0.05) = 0.4;
    Csize(Pvals<0.05 & Pvals > 0.01) = 0.8;
Ccolor = 1+floor((Rvals+1)*32);
    Ccolor(Ccolor==65)=64;    
    % eventhogh unlikely, this code prevent P=1 to have the 65th color
if plotson(1)==1
figure
%subplot1(2,3)
for j=1:p1 % each row  of subplots
    for i=1:p2 % each col of subplot
        % setting up the subplots
        axes('position',[Xss(i) Yss(j) XBox YBox]);
         axis([-1 1 -1 1])
        % Plotting with circle
        if type=='C' || type=='B'      
            if Csize(j,i) >= 0.8 % Significant
                plot_circle([0 0],Csize(j,i),mycolor(Ccolor(j,i),'redblue'),[0 0 0])   
            else % Not significant
                plot_circle([0 0],Csize(j,i),mycolor(Ccolor(j,i),'redblue'))   
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Printing out texts 
        if type=='T' || type=='B'
        text(0,0,['R:' num2str(Rvals(j,i),'%.3f')],'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',8)
         text(0,0,['p:' num2str(Pvals(j,i),'%.3f')],'HorizontalAlignment','center','VerticalAlignment','top','fontsize',8)
        end
        set(gca,'Xtick',[],'Ytick',[])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  put on lebels on the margin boxes
         if i==1 % Y- labels on the left; names of input X           
             if max(cellfun('length',xnames))<=round(50/p1) %%%%% Rotate if string is too long
                  h=text(-1.5,0,xnames{j},'fontsize',10);
                set(h, 'rotation', 90,'HorizontalAlignment','center');
             else
                  h=text(-1.07,0,xnames{j},'fontsize',8,'HorizontalAlignment','right');
             end
         end
          if j==p1 % X- labels on the bottom; names of input Y                            
                if max(cellfun('length',ynames))>=round(50/p2) %%%%% Rotate if string is too long
                     h=text(0,-1.07,ynames{i},'fontsize',8,'HorizontalAlignment','left');
                    set(h, 'rotation', -90)
                else
                     h=text(0,-1.5,ynames{i},'fontsize',10,'HorizontalAlignment','Center');
                end
          end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
end % if plotson(1)==1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Second figure is the correlation scatter plots with an LS line
if plotson(2)==1
    
figure
%subplot1(2,3)
for j=1:p1 % each row  of subplots
    for i=1:p2 % each col of subplot
    % subplot(2,3,i)
        axes('position',[Xss(i) Yss(j) XBox YBox]);
           if  strcmp(version('-release'), '2015a')
        scatter(X(:,j),Y(:,i),25,'Markeredgecolor','none','Markerfacecolor',[0 0 0], 'Markerfacealpha',0.7); hold on
           else
        scatter(X(:,j),Y(:,i),25,'Markeredgecolor','none','Markerfacecolor',[0 0 0]); hold on
           end
        h =lsline;
        set(h, 'linewidth',2,'color','b')
        set(gca,'Xtick',[],'Ytick',[])       
      
    end
end

%%%% labels
    for  j=1:p1 % each row  of subplots
     axes('position',[0.1 Yss(j) XBox YBox]);
     axis([-1 1 -1 1])
     axis off
     box off
     set(gca,'Xtick',[],'Ytick',[])
             if max(cellfun('length',xnames))<=round(40/p1) %%%%% Rotate if string is short
                  h=text(0.5,0,xnames{j},'fontsize',10);
                set(h, 'rotation', 90,'HorizontalAlignment','center','VerticalAlignment','middle');
             else
                  h=text(0.9,0,xnames{j},'fontsize',8,'HorizontalAlignment','right');
             end
    end
    for  i=1:p2 % Label on each column
     axes('position',[Xss(i) 0.1 XBox YBox]);
     axis([-1 1 -1 1])
     axis off
     box off
     set(gca,'Xtick',[],'Ytick',[])
           if max(cellfun('length',ynames))>=round(50/p2) %%%%% Rotate if string is too long
                     h=text(0,0.9,ynames{i},'fontsize',8,'HorizontalAlignment','left','VerticalAlignment','middle');
                    set(h, 'rotation', -90)
           else
                     h=text(0,0.5,ynames{i},'fontsize',10,'HorizontalAlignment','Center');
           end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Third figure print a colorbar for the R values 
if plotson(3)==1
    
    temp = [-1:0.04:1];
figure
 axes('position',[0.1 0.6 0.8 0.1]);
        colormap(mycolor('redblue')) % set color mat to a red-blue scale
    imagesc(temp)
    set(gca,'YTick',[],'Xtick',[1 13 26 39 51],'Xticklabel',{'-1','-0.5','0','0.5','1'},'fontsize',14)
    xlabel('Correlation Coefficient','fontsize',15)

 axes('position',[0.1 0.2 0.2 0.2]); 
    plot_circle([0 0],1,mycolor(4,'gray'),[0 0 0])  
        axis([-1 1 -1 1])
        set(gca,'YTick',[],'Xtick',[])
        xlabel('p < 0.01','fontsize',12)
 axes('position',[0.4 0.2 0.2 0.2]); 
    plot_circle([0 0],0.8,mycolor(4,'gray'),[0 0 0])
        set(gca,'YTick',[],'Xtick',[])
         axis([-1 1 -1 1])
         xlabel(' 0.01 < p < 0.05','fontsize',12)
 axes('position',[0.7 0.2 0.2 0.2]); 
    plot_circle([0 0],0.4,mycolor(4,'gray'))
        set(gca,'YTick',[],'Xtick',[])
         axis([-1 1 -1 1])
     xlabel('p > 0.05','fontsize',12)
end