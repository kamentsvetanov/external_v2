%% plot_circle
%
% Draw a filled circle
%
% Syntax: 
%            plot_circle(center,radius,facecolor,edgcolor)
%           
%            [center] : coordinates of the center of the circle
%            [radius] :  radius of the circle
%            [facecolor] : optional; the three-number color code, default is red
%            [edgcolor] : optional; the three-number color code, default is the same as [facecolor]
%
% example 1:  
%             plot_circle([1,1],0.5,mycolor(25))
%             axis([0,3,0,3])
%
% example 2:  
%             plot_circle([1,1],0.5,mycolor(21),mycolor(28))
%
% update 2015/10/06: use mycolor instead of script, add help material
function plot_circle(center,radius,facecolor,edgcolor)

if (nargin < 3), facecolor =  mycolor(2); end;
if (nargin < 4), edgcolor = facecolor; end;
 
starts = center-radius;
sizes = repmat(radius,1,2)*2;
rectangle('position', [starts, sizes],'Curvatur',[1,1],'Facecolor',facecolor,'Edgecolor',edgcolor);