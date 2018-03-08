%
% file:      	square_drill.m, (c) Matthew Roughan, Thu Mar 31 2011
% created: 	Thu Mar 31 2011 
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
% 
% Show how a Reuleaux triangle can drill an almost square hole
%
clear;
prefix = 'Animation2/square_drill';

% edge length 
a = 1;

% generate a standard Reuleaux triangle
[x_out, y_out, x_t, y_t] = reuleaux_triangle(0, 0, a, 0, 30);
[x_out,y_out] = reuleaux_rotate(x_out, y_out, 0, 0, pi);
[x_t,y_t] = reuleaux_rotate(x_t, y_t, 0, 0, pi);


% generate a little circle to use as the central "rod" of the triangle
phi = 0:pi/20:2*pi;
circ_radius = 0.15/7;
x_circ = circ_radius*cos(phi);
y_circ = circ_radius*sin(phi);


% the curve at the center is made up of four segments, so we derive one from 
%   "The Reuleaux Triangle and its Center of Mass", Fleibner and Zeitler

da = pi/60;
alpha = 0:da:pi/6-0.001;
beta = pi/3 - alpha;
n = length(alpha);

% three points of the triangle
A = a*[2-cos(beta)-sqrt(3)*sin(beta); 2-sin(beta)-sqrt(3)*cos(beta)]/2;
B = a*[ones(1,n)                    ; (1-sin(beta))];
C = a*[(1-cos(beta))                ;  ones(1,n)   ];

% center of mass (could use formular
%    S = a*[6-3*cos(beta)-sqrt(3)*sin(beta); 6-3*sin(beta)-sqrt(3)*cos(beta)]/6;
%, or just add
%    S = (A + B + C)/3;
% but he quadratic form is nicest
H = [[ 1 1/sqrt(3)];
     [1/sqrt(3) 1]
    ];
S = a - (a/2)*H*[cos(beta); sin(beta)];

i = 7;

figure(200)
hold off
plot([0 a a 0 0], [0 0 a a 0], 'b');
hold on
plot([A(1,i) B(1,i) C(1,i) A(1,i)], [A(2,i) B(2,i) C(2,i) A(2,i)], 'r');
plot([S(1,i)], S(2,i), 'ro');
axis equal

figure(201)
hold off
plot([0 a a 0 0], [0 0 a a 0], 'b');
hold on
plot([A(1,:)], A(2,:), 'r');
plot([B(1,:)], B(2,:), 'r');
plot([C(1,:)], C(2,:), 'r');
plot([S(1,:)], S(2,:), 'r');
axis equal

figure(202)
hold off
plot([0 a a 0 0], [0 0 a a 0], 'b');
hold on
for i=1:n
  [x,y] = reuleaux_rotate(x_out, y_out, 0, 0, -beta(i));
  x = x + S(1,i);
  y = y + S(2,i);
  plot(x,y);
end
plot([S(1,:)], S(2,:), 'r');
axis equal

% do the full rotation
S1 = S;
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -pi/2);
S2 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -pi);
S3 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -3*pi/2);
S4 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -2*pi);
S5 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -2*pi - pi/2);
S6 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -2*pi - pi);
S7 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -2*pi - 3*pi/2);
S8 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -4*pi);
S9 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -4*pi - pi/2);
S10 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -4*pi - pi);
S11 = [sx; sy];
[sx, sy] = reuleaux_rotate(S(1,:), S(2,:), a/2, a/2, -4*pi - 3*pi/2);
S12 = [sx; sy];

S = [S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12];

z = 0;
dz = 0.12;
X(1,:) = (a/2)*ones(size(x_out));
Y(1,:) = (a/2)*ones(size(x_out));
Z(1,:) = z*ones(size(x_out));
[x,y] = reuleaux_rotate(x_out, y_out, 0, 0, -pi/3 );
[x_t,y_t] = reuleaux_rotate(x_t, y_t, 0, 0, -pi/3 );
for i=1:size(S,2)
  xp = x + S(1,i);
  yp = y + S(2,i);
  z = z +dz;
  [x,y] = reuleaux_rotate(x, y, 0, 0, da);
  [x_t,y_t] = reuleaux_rotate(x_t, y_t, 0, 0, da);
  
  xc = x_circ + S(1,i);
  yc = y_circ + S(2,i);

  figure(203)
  hold off
  plot([0 a a 0 0], [0 0 a a 0], 'b', 'linewidth', 2);
  hold on
  plot([S(1,:)], S(2,:), 'r', 'linewidth', 2);
  plot(xp,yp, 'linewidth', 2);
  fill(xc, yc, [0 0 0])
  axis equal
  axis off
  set(gca, 'xlim', [-0.1 1.1]);
  set(gca, 'ylim', [-0.1 1.1]);
  set(gcf, 'PaperUnits', 'centimeters');
  set(gcf, 'PaperPosition', [0 0 5 5]);
  filename = sprintf('%s_%03d.png', prefix, i);
  print('-dpng', filename);
  
end


% these bits are machine dependent -- comment out if you don't have ImageMagick
%     http://www.imagemagick.org/script/index.php
cmd = sprintf('/usr/bin/mogrify -crop  220x220+42+32 %s_*.png', prefix);
unix(cmd);
unix(sprintf('/usr/bin/convert %s_*.png %s.gif', prefix, prefix)); % create a GIF animation
