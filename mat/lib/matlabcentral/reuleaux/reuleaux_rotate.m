function [x,y] = reuleaux_rotate(x,y, x0, y0, theta)
%
% file:      	rotate.m, (c) Matthew Roughan, Wed Mar 30 2011
% directory:   /home/mroughan/src/matlab/STL/Reuleaux/
% created: 	Wed Mar 30 2011 
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
% 
% rotate points: x,y are row vectors
%
%


% translate to the origin
x = x - x0;
y = y - y0;


% rotate by theta
A = [[ cos(theta) -sin(theta)];
     [sin(theta) cos(theta)]];
P = [x;
     y;
     ];
P = A*P;
x = P(1,:);
y = P(2,:);

% translate back
x = x + x0;
y = y + y0;
