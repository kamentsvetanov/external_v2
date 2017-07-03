function corrmap(data,labels,reord)
%CORRMAP Correlation map with variable grouping
%  CORRMAP produces a pseudocolor map which shows the
%  amount of correlation of between variables in a data
%  set. The function will reorder the variables by KNN
%  clustering if desired. The inputs are the data set 
%  (data) and an optional variable containing the labels
%  corresponding the variables. Another optional variable
%  (reord) will cause the function to keep the original
%  ordering of the variables if set to 0.
%
% The I/O syntax is: corrmap(data,labels,reord)

% Copyright 1997
% Eigenvector Research, Inc.
% by Barry M. Wise
if nargin < 3
  reord = 1;
end 
[m,n] = size(data);
if reord  ~= 0
  dist = -corrcoef(data);
  for i = 1:n
    dist(i,i) = inf;
  end
  for k = 1:n-1
    [min1,ind1] = min(dist);
    [min2,ind2] = min(min1);
    r = ind1(ind2);
    c = ind2;
    % Segment to order samples here
    if k == 1
      groups = zeros(round(n/2),n);
      groups(1,1:2) = [c r]; gi = 1;
    else
      % does r belong to an existing group?
      [zr1,zr2] = find(groups==r);
      % does c belong to an existing group?
      [zc1,zc2] = find(groups==c);
      % If neither c nor r belong to a group they form their own
      if isempty(zr1)   %r doesn't belong to a group
        if isempty(zc1) %c doesn't belong to a group
          gi = gi+1;
          groups(gi,1:2) = [c r];
        else   % r doesn't belong but c does, add r to group c
          sgc = size(find(groups(zc1(1),:)));   %how big is group c
		  % Figure out what side to add to
          cgc = groups(zc1(1),1:sgc(2));
		  [mindg,inddg] = min([dist(cgc(1),r) dist(cgc(sgc(2)),r)]);
		  if inddg == 2
            groups(zc1(1),sgc(2)+1) = r;
		  else
		    groups(zc1(1),1:sgc(2)+1) = [r groups(zc1(1),1:sgc(2))];
		  end
        end
      else   %r does belong to a group
        if isempty(zc1) %c doesn't belong to a group, add c to group r
          sgr = size(find(groups(zr1(1),:)));   %how big is group r
		  % Figure out what side to add to
		  cgr = groups(zr1(1),1:sgr(2));
		  [mindg,inddg] = min([dist(cgr(1),c) dist(cgr(sgr(2)),c)]);
		  if inddg == 2
            groups(zr1(1),sgr(2)+1) = c;
		  else
		    groups(zr1(1),1:sgr(2)+1) = [c groups(zr1(1),1:sgr(2))];
		  end
        else  %both c and r belong to groups, add group c to group r
          sgr = size(find(groups(zr1(1),:)));  %size of group r
          sgc = size(find(groups(zc1(1),:)));  %size of group c
		  % Figure out what side to add to
		  cgc = groups(zc1(1),1:sgc(2));  % current group c
		  cgr = groups(zr1(1),1:sgr(2));  % current group r
		  [mindg,inddg] = min([dist(cgc(1),cgr(1)) dist(cgc(1),cgr(sgr(2))) ...
		         dist(cgc(sgc(2)),cgr(1)) dist(cgc(sgc(2)),cgr(sgr(2)))]);
		  if inddg == 1
		    % flop group c and add to the left of r
		    groups(zr1(1),1:sgr(2)+sgc(2)) = [cgc(sgc(2):-1:1) cgr];
		  elseif inddg == 2
		    % add group c to the right of group r
            groups(zr1(1),sgr(2)+1:sgr(2)+sgc(2)) = cgc;
		  elseif inddg == 3
		    % add group c to the left of group r
		    groups(zr1(1),1:sgr(2)+sgc(2)) = [cgc cgr];
		  else
		    % flop group c and add to the right of group r
		    groups(zr1(1),1:sgr(2)+sgc(2)) = [cgr cgc(sgc(2):-1:1)];
		  end
          groups(zc1,:) = zeros(1,n);
        end
      end
    end
    dist(r,c) = inf;
    dist(c,r) = inf;
    z1 = find(dist(r,:)==inf);
    z2 = find(dist(c,:)==inf);
    z1n = z1(find(z1~=r));
    z1n = z1n(find(z1n~=c));
    z2n = z2(find(z2~=c));
    z2n = z2n(find(z2n~=r));
    z = [z1 z2];
    sz = size(z);
    for j = 1:max(sz);
      for k = 1:max(sz);
        dist(z(j),z(k)) = inf;
      end  
    end
  end
end
if reord ~= 0
  order = groups(find(groups(:,1)),:);
else
  order = 1:n;
end
if nargin > 1
  [ml,nl] = size(labels);
  if ml == n
    lflag = 1;
  else
    lflag = 0;
	nl = 2;
  end
else
  lflag = 0;
  nl = 2;
end
sim = corrcoef(data(:,order)); 
sim = [sim zeros(n,1); [zeros(1,n) -1]];
pcolor(0.5:1:n+0.5,0.5:1:n+0.5,sim), colormap('hot')
set(gca,'Ydir','reverse')
set(gca,'YTickLabel',[],'YTick',[])
set(gca,'XTickLabel',[],'XTick',[])
axis('square')
if n > 50
  fs = 7;
  os = 0.20*nl/8;
elseif n > 20
  fs = 9;
  os = 0.20*nl/6;
else
  fs = 12;
  os = 0.20*nl/4;  %Increase this to make white area around fig bigger
end
if lflag == 1
  text(-n*os*ones(n,1)+0.5*ones(n,1),1:n,labels(order,:))
  z = get(gca,'Children');
  set(z(1:n),'FontSize',fs)
  text(1:n,zeros(1,n),labels(order,:))
  z = get(gca,'Children');
  set(z(1:n),'Rotation',90);
  set(z(1:n),'FontSize',fs)
else
  for i = 1:n
    text(-n*os+0.5,i,int2str(order(i)));
  end
  z = get(gca,'Children');
  set(z(1:n),'FontSize',fs)
  for i = 1:n
    text(i,0,int2str(order(i)));
  end
  z = get(gca,'Children');
  set(z(1:n),'Rotation',90);
  set(z(1:n),'FontSize',fs)
end
hold on
plot([-n*os n+0.5],[-n*os -n*os],'-k');
plot([-n*os n+0.5],[n+.5 n+.5],'-k');
plot([-n*os -n*os],[-n*os n+.5],'-k');
plot([n+0.5 n+0.5],[-n*os n+.5],'-k');
hold off
axis image
colorbar
if reord ~= 0
  title('Correlation Map, Variables Regrouped by Similarity')
else
  title('Correlation Map, Variables in Original Order')
end
xlabel('Scale Gives Value of R for Each Variable Pair') 
