function [x_out, y_out, x_t, y_t, xi_1, yi_1, xi_2, yi_2, xi_3, yi_3] ...
    = reuleaux_triangle2(x, y, W, E, theta, N)
%
% created: 	Wed Mar 30 2011 
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
% 
% 
% Create a set of Reuleaux Triangle based on an equilateral triangle, but now with
% extensions, e.g., see
%     http://www.cut-the-knot.org/do_you_know/cwidth.shtml
% 
% A Reuleaux Triangle is NOT actually a triangle, but rather is a curved shape of constant
% width. There are actually many such shapes (that aren't circles). For information see
%    http://mathworld.wolfram.com/ReuleauxTriangle.html
%    http://en.wikipedia.org/wiki/Reuleaux_triangle
% 
%
% INPUTS: 
%    (x,y) = center of (equilateral) triangle
%    W     = width of Reuleaux triangle
%    E     = radius of extension (r=0 generates the ordinary Reuleaux triangle)
%    theta = angle offset of shape
%    N     = number of points to plot around each edge
%
% OUTPUTS: 
%    x_d = 3Nx1 vector of x points around the outside
%    y_d = 3Nx1 vector of y points around the outside
%    x_t = 3x1 vector of x points of tips
%    y_t = 3x1 vector of y points of tips
%    xi_1, yi_1 = 2x1 vectors defining the first defining side of the shape
%    xi_2, yi_2 = 2x1 vectors defining the first defining side of the shape
%    xi_3, yi_3 = 2x1 vectors defining the first defining side of the shape
%             NB: plotting these last three should make it obvious what they are
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
  E = 0.1;
end
if (E <=0)
  error('E > 0');
end
if (E > W/2)
  error('E < W/2');
end
if (nargin < 5)
  theta = 0;
end
if (nargin < 6)
  N = 30;
end
N = round(N);
if (N <= 2)
  error('N > 2')
end

% calculate the length of the side of the triangle
S = W-2*E; 

% calculate the triangle corners
m = 3;
phi = pi/2:2*pi/3:2*pi+pi/2;
R = sqrt(3)*S/3;
x0 = x + R*cos(phi);
y0 = y + R*sin(phi);
x_t = x0(1:3);
y_t = y0(1:3);

% now calculate the three lines that define the new shape
xi_1(1) = x0(1) - E*cos(pi/3);
xi_1(2) = x0(3) + E*cos(pi/3);
yi_1(1) = y0(1) + E*sin(pi/3);
yi_1(2) = y0(3) - E*sin(pi/3);

xi_2(1) = x0(1) + E*cos(pi/3);
xi_2(2) = x0(2) - E*cos(pi/3);
yi_2(1) = y0(1) + E*sin(pi/3);
yi_2(2) = y0(2) - E*sin(pi/3);

xi_3(1) = x0(2) - E;
xi_3(2) = x0(3) + E;
yi_3(1) = y0(2);
yi_3(2) = y0(3);

min_y = min(y0);

% calculate the two arcs that make up one side of the "triangle"
phi = pi/2+pi/6:pi/N:pi;
x_1 = x + (S)/2 + (S+E)*cos(phi);
y_1 = min_y + (S+E)*sin(phi);

phi = pi/2-pi/6:pi/N:pi/2+pi/6;
x_1d = x + E*cos(phi);
y_1d = y + R + E*sin(phi);

% concatenate the two together
x_1 = [x_1d x_1];
y_1 = [y_1d y_1];

% create the other two sides by rotating the first around the center
[x_2,y_2] = reuleaux_rotate(x_1,y_1, x, y, 2*pi/3);
[x_3,y_3] = reuleaux_rotate(x_2,y_2, x, y, 2*pi/3);

% concatenate them together to get a complete "triangle"
x_out = [x_1 x_2 x_3 x_1(1)];
y_out = [y_1 y_2 y_3 y_1(1)];

% now rotate by theta
[x_out, y_out] = reuleaux_rotate(x_out, y_out, x, y, theta);
[x_t, y_t] = reuleaux_rotate(x_t, y_t, x, y, theta);
