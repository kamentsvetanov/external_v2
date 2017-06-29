function [X,Y] = rolling_polygon(x, y, x1, y1, delta_a, prefix, figure_n)
%
% file:      	rolling_polygon.m, (c) Matthew Roughan, Thu Mar 31 2011
% created: 	Thu Mar 31 2011 
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
% 
% Take a polygon defined by points (x,y) and roll it along a flat surface
%
% Also rack the points (on the polygon) (x1, y1) as the polygon rolls.
%
% INPUTS:
%    (x,y) = vectors defining the polygon (assume that the last point repeates the first)
%    (x1, y1) = a set of points to track as the polygon rotates
%    delta_a = the maximum step size for rotation
%                  -- Some steps may be smaller as it depends on how many vertices the
%                     polygon has. Mostly the polygon will roll by with each step revolving
%                     completely around one corner if the angles are small.
%    prefix = prefix to use for constructing the animation files we output
%    figure_n = figure number for the figure to use for plots
%
%  OUTPUTS: 
%    [X,Y] track the points (x1,y1) as the polygon rotates
%
% The code assumes that 
%    (1) the polygon is convex
%    (2) the last point repeats the first vertex
%    (3) vectors are row vectors
%    (4) works better when there are no repeated vertices
%    (5) points are in anti-clockwise order
%
% It uses ImageMagick (near the end) to take the series of images and convert them into a GIF
% animation.
% 
%

if (nargin < 5)
  delta_a = pi/10; % max angle for one step of rotation
end 


mn_y = min(y);
y  = y - mn_y; 
y1 = y1 - mn_y;

% calculate the angles of the edges
dx = diff(x);
dy = diff(y);
edge_lengths = sqrt(dx.^2 + dy.^2);
edge_angles = atan2(dy,dx);
I = find(y == min(y), 1,'last');

%  draw a picture of the original object
figure(figure_n)
hold off
plot(x,y, 'b', 'linewidth', 2);
hold on
plot(x1, y1, 'g.', 'linewidth', 2)

% set up size of plot to be nice
P = poly_perimeter(x, y);
set(gca, 'xlim', [min(x)-0.5, max(x) + 0.5 + P]); 
plot([min(x)-0.5, max(x) + 0.5 + P], [0 0], '-', 'linewidth', 2)
set(gca, 'ylim', [-0.1 max(y)+0.1]); 
Dx = max(x) - min(x) + 1 + P;
Dy = max(y)+0.2;
ratio = Dy/Dx;
set(gcf, 'Position', [906 760 916 335]);
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 12 12*ratio]);
axis equal
axis off
filename = sprintf('%s_000.png', prefix);
print('-dpng', filename);

% keep track of some set of points
X = [x1];
Y = [y1];
m = 1;
for i=1:length(x)-1
  if (edge_angles(I) < 0)
    phi = 2*pi + edge_angles(I);   
  else
    phi = edge_angles(I);
  end
  
  % if the angle is small, then, do one step, but if its bigger, do the rotation in a few steps
  if (abs(edge_lengths(I)) < eps)
    % if the line is too short, skip the point
    fprintf('skip')
  elseif  (phi > delta_a)
    steps = ceil(phi  / delta_a);
    phi2 = phi / steps;
    for j=1:steps
      [x, y] = reuleaux_rotate(x, y, x(I), y(I), -phi2);
      [x1, y1] = reuleaux_rotate(x1, y1, x(I), y(I), -phi2);
      X = [X; x1]; 
      Y = [Y; y1];
      
      % plot
      figure(figure_n)
      plot(x,y, 'r');
      plot(X(end-1:end, :), Y(end-1:end, :), 'g');
      filename = sprintf('%s_%03d.png', prefix, m);
      print('-dpng', filename);
      m = m + 1;
    end
  else
    [x, y] = reuleaux_rotate(x, y, x(I), y(I), -phi);
    [x1, y1] = reuleaux_rotate(x1, y1, x(I), y(I), -phi);
    X = [X; x1]; 
    Y = [Y; y1];

    % plot
    figure(figure_n)
    plot(x,y, 'r');
    plot(X(end-1:end, :), Y(end-1:end, :), 'g');
    filename = sprintf('%s_%03d.png', prefix, m);
    print('-dpng', filename);
    m = m + 1;
  end
  edge_angles = edge_angles - edge_angles(I);
  I = mod(I, length(x)-1) + 1;
end


% these bits are machine dependent -- comment out if you don't have ImageMagick
%     http://www.imagemagick.org/script/index.php
cmd = sprintf('/usr/bin/mogrify -crop  325x100+200+10 %s_*.png', prefix);
unix(cmd);
unix(sprintf('/usr/bin/convert %s_*.png %s.gif', prefix, prefix)); % create a GIF animation




function P = poly_perimeter(xv, yv)
% Calculate the perimeter of a polygonx
%
% Call:
%   [x_c, y_c] = poly_perimeter(xv, yv)
% 
% INPUTS:
%   (xv, yv)   = row vectors giving the locations of polygon vertices
%
% OUTPUTS:
%   P = perimeter of the polygon
%

% compute the lengths of each edge
dx = diff(xv);
dy = diff(yv);
edge_length = sqrt(dx.^2 + dy.^2);

% total
P = sum(edge_length);
