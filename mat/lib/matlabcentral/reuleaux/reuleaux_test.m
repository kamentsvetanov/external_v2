%
% file:      	reuleaux_triangle.m, (c) Matthew Roughan, Wed Mar 30 2011
% created: 	Wed Mar 30 2011 
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
% 
% 
% Create a Reuleaux Triangles and other objects of constant width, and play around with them.
%   
%
% Various references
%   http://mathworld.wolfram.com/ReuleauxTriangle.html
%   http://en.wikipedia.org/wiki/Reuleaux_triangle
%   http://en.wikipedia.org/wiki/Equilateral_triangle
%   http://www.raymondswan.com/shop/PDF files/dril square holes.pdf
%   http://www.workshopshed.com/2010/10/drilling-square-holes.html
%   http://www.jacquesmaurel.com/Html-EN/index_redir.php?page=http://www.jacquesmaurel.com/Html-EN/mechanical-paradoxical-gears.htm
%   http://www.jacquesmaurel.com/Html-EN/index_redir.php?page=http://www.jacquesmaurel.com/Html-EN/square-hole-drilling.htm
%   http://demonstrations.wolfram.com/DrillingASquareHole/
%   http://linearlyindependent.blogspot.com/2008/07/drilling-square-holes.html
%   http://www.howround.com/
%   http://www.triz-journal.com/404.asp?404;http://www.triz-journal.com:80/archives/2007/02/07/
%   http://algo.inria.fr/csolve/rx.pdf
%   http://files.asme.org/asmeorg/Communities/History/Landmarks/12729.pdf
%   http://curvebank.calstatela.edu/reu/reuleaux.htm
%   
%   
%   
%   "The Reuleax triangle and its Center of Mass", Gleibner and Zeitler, 1999
%   "Reuleaux Triangle Constants", Steven Finch, 2003
%   http://qjmath.oxfordjournals.org/content/3/1/296.short
%   http://projecteuclid.org/DPubS/Repository/1.0/Disseminate?view=body&id=pdf_1&handle=euclid.pjm/1103038230
%   http://scitation.aip.org/getabs/servlet/GetabsServlet?prog=normal&id=AMREAD000056000002000261000001&idtype=cvips&gifs=yes
%   http://ijr.sagepub.com/content/8/5/79.short
%   http://www.springerlink.com/content/m17305632784q1r7/fulltext.pdf
% 
%   Barbier's theorem: All curves of constant width W have the same perimeter pi x W
%   Blaschke's theorem: Reuleaux triangle has minimal area, and maximal asymmetry for such shapes
%           though other theorems take this name
% 


%
% create a simple Reuleaux triangle
%
x = 0;
y = 0;
W = 1;
theta = 0;
N = 30;
[x_out, y_out, x_t, y_t] = reuleaux_triangle(x, y, W, theta, N);

figure(1)
hold off
plot(x,y,'o', 'linewidth', 2);
hold on
plot([x_t x_t(1)], [y_t y_t(1)], 'r', 'linewidth', 2);
plot(x_out, y_out, 'b', 'linewidth', 3);
axis equal
axis off
print('-dpng', 'Plots/reuleaux_triangle.png');

% show it rolling -- generate a series of GIFs for animation
x1 = [0 x_t(1) 0];
y1 = [0 y_t(1) y_t(1)/2];
prefix = 'Animation/rolling_reuleux_tri';
[X,Y] = rolling_polygon(x_out, y_out, x1, y1, 2*pi/(3*30), prefix, 2);


%  show the track of the fixed points on the triangle
figure(3)
set(gcf, 'PaperPosition', [0 0 6 3]);
hold off
plot(x_out, y_out-min(y_out), 'b');
hold on
plot(X, Y, 'linewidth', 2);
set(gca, 'xlim', [-1 1+pi])
axis equal
print('-dpng', 'Plots/reuleaux_rolling.png');

% now show animation of the Reuleaux triangle being rotated (with an offset center) so that
% it "drills" an approximately square hole.
square_drill_animation;


%
% Reuleaux triangle with extensions on triangle corners
%
[x_out, y_out, x_t, y_t, xi_1, yi_1, xi_2, yi_2, xi_3, yi_3] = reuleaux_triangle2(0, 0, 1, 0.2);

figure(4)
hold off
plot(x,y,'o', 'linewidth', 2);
axis equal
hold on
plot(xi_1, yi_1, 'r--', 'linewidth', 2)
plot(xi_2, yi_2, 'r--', 'linewidth', 2)
plot(xi_3, yi_3, 'r--', 'linewidth', 2)
plot([x_t x_t(1)], [y_t y_t(1)], 'r', 'linewidth', 2)
plot(x_out, y_out, 'b', 'linewidth', 3);
axis equal
axis off
print('-dpng', 'Plots/reuleaux_triangle2.png');



% 
% Reuleaux pentagon
% 
[x_out, y_out, x_t, y_t] = reuleaux_poly(5, 30, 1);

figure(5)
hold off
plot(x_t, y_t, 'r-o', 'linewidth', 2);
hold on
plot(x_out, y_out, 'linewidth', 3);
axis equal
axis off
print('-dpng', 'Plots/reuleaux_pentagon.png');



