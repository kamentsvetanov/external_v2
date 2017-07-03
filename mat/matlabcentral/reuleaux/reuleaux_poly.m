function [x_out, y_out, x_t, y_t] = reuleaux_poly(n, N, W)
%
% file:      	reuleaux_poly.m, (c) Matthew Roughan, Wed Mar 30 2011
% directory:   /home/mroughan/src/matlab/STL/
% created: 	Wed Mar 30 2011 
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
% 
% Generate a Reuleaux (constant-width) polygon (a polygon of equal width). 
%    NB: the polygon must have an odd number of vertices, and it is assumed to be regular
%
% e.g. see  
%      http://en.wikipedia.org/wiki/Curve_of_constant_width
%      http://www.cut-the-knot.org/Curriculum/Geometry/CWStar.shtml
%      http://www.howround.com/
% routine uses facts about regular polygons, e.g. see
%      http://en.wikipedia.org/wiki/Regular_polygon
%
% INPUTS:
% 	  n   = number of vertices (must be odd)
%                 NB: if n=3 you get a Reuleaux triangle
%	  N   = number of points to draw along each edge of the boundary of the Reuleaux polygon.
%         W   = edge width (default value is the length of the maximum length edge of the
%               input polygon
%
%     (I didn't bother to put a center, and a rotation angle in this routine as they are easy
%     enough to add by translating and rotating the object).
%
% OUTPUTS: 	  
%	 x_out, y_out = 1 x nN+1 vectors of (x,y) coordinates of points on the Reuleaux polygon.
% 	  


% check the inputs
if (nargin < 1)
  n = 5; % default is a pentagon
end
n = round(n);
if (n<3)
  error('we must have n >= 3');
end
if (round(n/2) == n/2)
  error('n must be odd');
end

if (nargin < 2)
  N = 20;
end
N = round(N);
if (N < 3)
  error('N >= 3');
end

if (nargin < 3)
  W = 1;
end
if (W <= 0) 
  error('W > 0');
end

% now calculate a "radius" (distance from polygon center to vertex) so the max width is W
alpha = 2*pi/n;
c = 1 + cos(alpha/2); 
s = sin(alpha/2);
unit_width = sqrt(c^2 + s^2);
R = W/unit_width;

% calculate the vertices of the polygon
theta = 0:alpha:2*pi;
x_t = R*cos(theta);
y_t = R*sin(theta);

% internal angle in the polygon
internal_angle = pi*(1 - 2/n);

% length of the sides of the polygon
edge_length = 2*R*sin(alpha/2);

% angle from one vertex to the two opposing vertices
beta = 2*atan2(sin(alpha/2), 1 + cos(alpha/2));

% now calculate one side of the polygon
phi = pi-beta/2:2*beta/N:pi+beta/2-0.0001;
x = R + W*cos(phi);
y =     W*sin(phi);

% now calculate each of the others by rotation, and cat them together
x_out = x;
y_out = y;
for i=2:n
  [x,y] = reuleaux_rotate(x,y,0,0,alpha);
  x_out = [x_out x];
  y_out = [y_out y];
end
x_out = [x_out x_out(1)];
y_out = [y_out y_out(1)];



