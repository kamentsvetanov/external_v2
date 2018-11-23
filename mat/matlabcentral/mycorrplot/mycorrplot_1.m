%% Visualization of correlation results
% This function should present the result of correlations in a figure with table-like
% structure. Visualize the result of: *corr[X]*
%
% R values and Significance levels (range of P values) are visualized
% as the color and sizes of circle. User can also chose to see
% scatterplots, and/or text with R and P values on one triangle.
%
%%  Using [mycorrplot_1]
% *Syntax*
% 
% mycorrplot_1(X,xnames,type, colorbaron,textin)
%
% * X : array or table, the data, we are interested in correlation between
% each pair of columns in X; as in corr(X); for table, only numeric
% variables will be used (class is "double")
% * xnames : name of each column in X, stored in cell array of strings;
%                 default is {'1','2','3',....}
%                 if X is a table, default xnames is the variable names of
%                 the table. (or used place holder [] )
% * type :  style of output, can be 'C','T','S','B'; default is 'B'
% * colorbaron : 0 or 1; whether to plot out the legend or not; default is 0
% * textin : 0 or 1; whether to put labels in the diagnal; default is 1 if
% xnames not specified, 0 otherwise
%
%%% More about types
% * *'C'* means put all circles
% * *'T'* means put text and circles
% * *'S'* means put scatterplot and circles
% * *'B'* means put "Both" scatter plot and text. In this case, text will be put on top of the circles. 
%
% Example of usage: *[X_corrplots.m]*
%% File info.
% Author: *Wei-Ting Lin* (_2014/10/15_)
% 
% *Inspeired by* 
% 
% * corrplot : from Matlab econometrics tool box
% * correlationCircles:by David Legland http://www.mathworks.com/matlabcentral/fileexchange/45698-correlation-circles
% * R package corrplot: http://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html
% * num2cellstr.m : by Andrew Watson http://www.mathworks.com/matlabcentral/fileexchange/20639-num2cellstr
%
% *Dependent files*
% [plot_circle.m] [mycolor.m] [nancorr.m] [tnames.m]
%
% update 2015/10/30 : use mycolor function, compatible with data type "table", NaN ignored, new scatterplot style 
%% The function

 function mycorrplot_1(X,xnames,type, colorbaron,textin)
 
 % Add compatibility to data type "table"
     inputistable=0; % flag for whether input is a table (or matrix by default)
  if istable(X)
          inputistable = 1;
              indnum = strcmp(varfun(@class,X,'OutputFormat','Cell'), 'double'); 
          Xname = tnames(X(:,indnum)); % save names before change data type
          X = X{:,indnum} ;         
          if nargin < 2 || isempty(xnames)
                xnames = Xname;
          end        
  end
 
%%% message about NaN
 if  any(any(isnan(X)))
 disp('NaN removed before calculating correlation; see nancorr.m for detail')
 end
 
 %%% for corr(X)
 [Rvals, Pvals] = nancorr(X);
  
 [n, p] = size(X);
%%% Setting up default values
if (nargin < 5), textin = 0; end;
if (nargin < 4 ||isempty(colorbaron)), colorbaron= 0 ; end;
if (nargin < 3 ||isempty(type)), type = ('B'); end;
if (nargin < 2) && inputistable == 0, % Create a cell array of strings {'1','2',...,'p'} 
    xnames={};
    for i=1:p       
    xnames{i} = num2str(i); 
    end;
    textin = 1; % the default name is short enough
end;


%%% Error Message
if iscellstr(xnames)==0
    error('Names of variable should be in cell array of strings')
end

%%% Setting up the "subplot" parameters
XRange = 0.8/(p+1);
XBox = XRange*0.95;  
% Range = Box + Gap

Xss(1)=0.1+XBox;% Starting points of X   
         for j = 2:p
             Xss(j) = Xss(j-1) + XRange;
         end
Yss(1)=0.9-XRange; % starting points of Y
        for i = 2:p
            Yss(i) = Yss(i-1) -  XRange;
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setting size and color for the circle plots
Csize = ones(p,p);
    Csize(Pvals>=0.05) = 0.4;
    Csize(Pvals<0.05 & Pvals > 0.01) = 0.8;
Ccolor = 1+floor((Rvals+1)*32);
    Ccolor(Ccolor==65)=64;    
    % eventhough unlikely, this code prevent P=1 to have the 65th color

%%% Making the main figure    
figure
for j=1:p % each row  of subplot
    for i=1:p % each col of subplot
        % setting up the subplot frame and location
        axes('position',[Xss(i) Yss(j) XBox XBox]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% The lower-left triangle
       if i<j % the lower-left  triangle
            axis([-1 1 -1 1])
            % Plotting with circle
            if Csize(j,i) >= 0.8 % Significant
                   
                plot_circle([0 0],Csize(j,i),mycolor(Ccolor(j,i),'redblue'),[0 0 0])   
            else % Not significant
                plot_circle([0 0],Csize(j,i),mycolor(Ccolor(j,i),'redblue'))   
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            % Printing text on top of circles
                 if type=='B'
                 text(0,0,['R:' num2str(Rvals(j,i),'%.3f')],'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',8)
                 text(0,0,['p:' num2str(Pvals(j,i),'%.3f')],'HorizontalAlignment','center','VerticalAlignment','top','fontsize',8)
                 end
            set(gca,'Xtick',[],'Ytick',[])
        end % if i>j
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% The diagnal
        if i==j
            axis([-1 1 -1 1])
            if textin==1            
                text(0,0,xnames{i},'HorizontalAlignment','center','VerticalAlignment','middle','fontsize',8)          
            elseif type=='C' % Put all blue circle ( R=1 ) for self-correllation        
                plot_circle([0 0],Csize(j,i),mycolor(Ccolor(j,i),'redblue'))     
            end
              set(gca,'Xtick',[],'Ytick',[])
        end % if i==j
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  The upper-right triangle
        if i>j  % upper-right triangle
            if type=='C' % Plotting with circle
                 axis([-1 1 -1 1])                            
                 if Csize(j,i) >= 0.8 % significant
                     plot_circle([0 0],Csize(j,i),mycolor(Ccolor(j,i),'redblue'),[0 0 0])   
                 else % not significant
                     plot_circle([0 0],Csize(j,i),mycolor(Ccolor(j,i),'redblue'))   
                 end
            end % if type=='C'
            if type=='T' % print out the R and P
                axis([-1 1 -1 1])
                text(0,0,['R:' num2str(Rvals(j,i),'%.3f')],'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',8)
                text(0,0,['p:' num2str(Pvals(j,i),'%.3f')],'HorizontalAlignment','center','VerticalAlignment','top','fontsize',8)
            end % if type=='T'
            if type=='B'||type=='S' % print out scatter plot
                % plot(X(:,i),X(:,j),'.k');hold on
                 if  strcmp(version('-release'), '2015a')
                 scatter(X(:,i),X(:,j),25,'Markeredgecolor','none','Markerfacecolor',[0 0 0], 'Markerfacealpha',0.7); hold on
                 else
                 scatter(X(:,i),X(:,j),25,'Markeredgecolor','none','Markerfacecolor',[0 0 0]); hold on        
                 end
                 h =lsline;
                 set(h, 'linewidth',2,'color','b')
            end %  if type==...
             set(gca,'Xtick',[],'Ytick',[])  
        end % if i<j
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  Put on labels on the margin boxes
        if textin==0       
               if i==1 % Y- labels on the left; names of input X           
                    if max(cellfun('length',xnames))<=10  %%%%% Rotate if string is short; 
                        h=text(-1.5,0,xnames{j},'fontsize',10);
                        set(h, 'rotation', 90,'HorizontalAlignment','center');
                    else 
                        h=text(-1.2,0,xnames{j},'fontsize',8,'HorizontalAlignment','right');
                    end
                end % if i==
                if j==p % X- labels on the bottom; names of input Y                            
                    if max(cellfun('length',xnames))>=10 %%%%% Rotate if string is too long
                        h=text(0,-1.2,xnames{i},'fontsize',8,'HorizontalAlignment','left');
                        set(h, 'rotation', -90)
                    else
                        h=text(0,-1.5,xnames{i},'fontsize',10,'HorizontalAlignment','Center');
                    end
                end % if j==
        end % if texton==
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end % for i=
end % for j=

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Print a colorbar for the R values 
if colorbaron==1    
    
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
    
   
end