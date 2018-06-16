function H= plotfdesign(T,G,varargin)
%PLOTFDESIGN Plots data from a factorial design
%	H= plotfdesign(T,G) plots means of vector T, their 95% conf. interval 
%	(as a box) and st. deviations (as a line), for each combination 
%	of factors defined in G. 
% 
%	T is a numeric vector of data. G is a numeric or cell array of
%	strings defining the groups (factors) for each data value.
% 
%	It returns a figure handle H which allows to set the characteristics
%	of each component.
% 
%	Up to 4 factors are allowed. The first factor will be represented 
%	by adjacent bars in a plot, while the second factor (if present) 
%	is shown as different groups of bars in the same plot. 
%	Factors 3 and 4 (if present) will be columns and rows of subplots,
%	respectively, in the figure.
%	The raw data is plotted (jittered) over each bar. The color of the dots
%	(gray by default) is set to red if their distribution is not normal
%	according to Lilliefors test (alpha=0.05).
% 
% Example
%	Generate some data
% 	g= repmat(fullfact([2 2]),100,1);
% 	g1= find(g(:,1)==1);
% 	g2= find(g(:,1)==2);
% 	x= zeros(size(g,1),1);
% 	x(g1)= normrnd(10,1,numel(g1),1);
% 	x(g2)= normrnd(5,3,numel(g2),1);
%
%	H= plotfdesign(x,g);
%	H= plotfdesign(x,g,'cmap','prism','vname','temp.(C)','fname',{'Treat1';'Treat2'});
% 
% Use non-normal data for group 2
%	x(g2)= gamrnd(1,2,numel(g2),1);
%	H= plotfdesign(x,g);

%	Francisco de Castro, 2016
%	Requires Rob Campbell's function notBoxPlot (FEX ID: #26508).
%	Included is a version of notBoxPlot with narrower jitter for the data,
%	so they are more 'inside' their bar.



%% Defaults
vname= 'Data'; % Name of variable (for axes)
fname= {'Factor 1';'Factor 2';'Factor 3';'Factor4'};
cmname= 'lines'; % Colormap


%% Check input
if ~isnumeric(T)
	error('First argument must be a numeric vector')
end
if size(T,1)> 1 && size(T,2)> 1
	warning(['Only first column of data considered']);
	T= T(:,1);
end
if size(G,1) ~= numel(T) % Assume factors are in columns
	error(['The sizes of data vector and groups are different']);
end


%% Process optional arguments
for j= 1:2:length(varargin)
	string= lower(varargin{j});
	switch string(1:min(3,length(string)))
		case 'vna'
			vname= varargin{j+1};
		case 'cma'
			cmname= varargin{j+1};
		case 'fna'
			fname= varargin{j+1};
		otherwise
			error('Unknown argment name')
	end
end


%% Create a numerical version of factors (easier finds)
if ~isnumeric(G)
	nG= NaN(size(G,1),size(G,2));
	for j= 1:size(G,2)
		uG= unique(G(:,j)','stable');
		for k= 1:numel(uG)
			hits= find(strcmp(uG(k),G(:,j)));
			nG(hits,j)= k;
		end
	end
else
	nG= G;
end


%% Number of factors, and number of levels per factor
nfac= size(G,2);
if nfac > 4
	nfac= 4;
	warning(['Only first 4 columns of ',inputname(2),' considered']);
end

Factor= cell(4,1);
nlev=   ones(4,1);
for j= 1:nfac
	Factor(j)= {unique(nG(:,j),'stable')};
	nlev(j)= numel(Factor{j});
end


%% Initialize figure, color map, etc.
H= figure; hold on
cmap= colormap(cmname);
count= 1;
X= [];
hits= 1:numel(T);


%% For each level of Factors 3 and 4, select the data for one subplot
for f4= 1:nlev(4)
for f3= 1:nlev(3)
	switch nfac
		case 4
			hits= find(nG(:,4) == Factor{4}(f4) & nG(:,3) == Factor{3}(f3));
		case 3
			hits= find(nG(:,3) == Factor{3}(f3));
	end
	y= T(hits);
	g= nG(hits,:);


	%% Now, for each level of factor 2 create a plot for factor 1 values
	% with notBoxPlot (mean and conf. int. instead of median)

	% Open subplot for this combination of levels 3 and 4
	subplot(nlev(4),nlev(3),count); hold on
	bs= 0.4/(nlev(1)-1);		% Set bar separation (level 1)
	for j= 1:nlev(2)
		x= j-0.2:bs:j+0.2;	% x coord for bars of factor 1

		% Select rows for this level of factor 2 or all data if no factor 2
		if size(G,2) > 1
			rows= find(g(:,2) == Factor{2}(j)); 
		else
			rows= 1:numel(y);
		end

		if ~isempty(rows)
			% Put data in columns
			yy= reorderv(y(rows),g(rows,1)); 

			%---- Here do the actual plot. 
			% Use legacy call for now because the new one produces an error
			H= notBoxPlot(yy,x(unique(g(rows,1),'stable')),0.7*bs,'sdline');

			% Set colors for each level of factor 1
			for k= 1:nlev(1)
				% if not normal set dots red
				coldot= [.7 .7 .7];
% 				if lillietest(yy(:,k)),	coldot= [1 0 0]; end
				set([H(k).data],   'markersize',4,'markerfacecolor',coldot,'markeredgecolor',0.7*coldot);
				set([H(k).semPtch],'FaceColor', cmap(k,:),'EdgeColor','none');
				set([H(k).sd],		 'Color',0.75*cmap(k,:),'LineWidth',2);
				set([H(k).mu],		 'Color','k','LineWidth',2);
			end
			%----------------------------

		end

		% Legend if there is more than 1 factor
		if nfac > 1
			if isnumeric(G(:,1))
				legend([H.semPtch],num2str(unique(G(:,1),'stable')));
			else
				legend([H.semPtch],unique(G(:,1),'stable'));
			end
			legend('boxoff');
		end

		hold off
	end

	%% Axis names, ticks, titles
	xlim('auto')
	ylabel(vname);

	% If only 1 factor use it for the Xaxis
	if nfac == 1 
		xlabel(fname(1));
		set(gca,'XTick',x);
		set(gca,'XTickLabels',unique(G(:,1),'stable')); 
	else % Otherwise use factor 2 it for the Xaxis
		xlabel(fname(2));
		set(gca,'XTick',1:nlev(2));
		set(gca,'XTickLabels',unique(G(:,2),'stable')); 
	end
	
	% Titles
	switch nfac
		case 4
			uname3= unique(G(:,3),'stable');
			uname4= unique(G(:,4),'stable');
			title([char(uname3(f3)),':',char(uname4(f4))]);
		case 3
			uname= unique(G(:,3),'stable');
			title(uname(f3));
	end

	count= count+1; % Next sub-plot

end
end


end




% Helper function reorderv
function XX = reorderv(X,G)
%REORDERV regroups vector X into a matrix accorging to vector G

% How many groups
uG= unique(G,'stable');
ngroup= numel(uG);

% Maximum numel per group
maxn= 0;
for j= 1:ngroup
	if isnumeric(G)
		n= numel(X(G==uG(j)));
	else
		n= numel(X(strcmp(G,uG(j))));
	end
	if n > maxn, maxn= n; end
end

% Store
XX= NaN(maxn,ngroup);

% Reorder
for j= 1:ngroup
	if isnumeric(G)
		hits= find(G==uG(j));
	else
		hits= find(strcmp(G,uG(j)));
	end
	XX(1:numel(hits),j)= X(hits);
end

end
