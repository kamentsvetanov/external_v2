function [x_out, y_out, x_t, y_t] = reuleaux_triangle(x, y, W, theta, N)
%
% created: 	Wed Mar 30 2011 
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
% 
% Create a set of Reuleaux Triangle based on an equilateral triangle (in fact this creates a
% polygon that approximates the Reuleaux Triangle).
%
% A Reuleaux Triangle is NOT actually a triangle, but rather is a curved shape of constant
% width. There are actually many such shapes (that aren't circles). For information see
%    http://mathworld.wolfram.com/ReuleauxTriangle.html
%    http://en.wikipedia.org/wiki/Reuleaux_triangle
% 
%
% INPUTS: 
%    (x,y) = center of the (equilateral) triangle used as the base
%    W     = width of Reuleaux triangle
%    theta = rotate the shape by angle theta
%    N     = number of points to plot around each edge
%
% OUTPUTS: 
%    x_d = 1 x 3N+1 vector of x points around the outside
%    y_d = 1 x 3N+1 vector of y points around the outside
%    x_t = 1 x 3 vector of x points of tips
%    y_t = 1 x 3 vector of y points of tips
%
%

% check inputs
if (nargin < 1)
  x = 0;
end
if (nargin < 2)
  y = 0;
end
if (nargin < 3)
  W = 1;
end
if (W <=0)
  error('W > 0');
end
if (nargin < 4)
  theta = 0;
end
if (nargin < 5)
  N = 30;
end
N = round(N);
if (N <= 2)
  error('N > 2')
end

% calculate corners of the equilateral triangle
phi = pi/2:2*pi/3:2*pi+pi/2;
R = sqrt(3)*W/3;
x0 = x + R*cos(phi);
y0 = y + R*sin(phi);
min_y = min(y0);

% create one arc of the Reuleaux triangle
phi = pi/2+pi/6:pi/(3*N):pi-0.001;
x_1 = x + W/2 + W*cos(phi);
y_1 = min_y + W*sin(phi);

% create the other two arcs by rotating the first around the triangle's center
[x_2,y_2] = reuleaux_rotate(x_1,y_1, x, y, 2*pi/3);
[x_3,y_3] = reuleaux_rotate(x_2,y_2, x, y, 2*pi/3);

% concatenate them together
x_out = [x_1 x_2 x_3 x_1(1)];
y_out = [y_1 y_2 y_3 y_1(1)];

% recalculate the tips
x_t = [x_1(1) x_2(1) x_3(1)];
y_t = [y_1(1) y_2(1) y_3(1)];

% now rotate by theta
[x_out, y_out] = reuleaux_rotate(x_out, y_out, x, y, theta);
[x_t, y_t] = reuleaux_rotate(x_t, y_t, x, y, theta);
