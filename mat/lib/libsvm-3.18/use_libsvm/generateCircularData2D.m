function d = generateCircularData2D(r1,r2,sigma,N)

r = r1+rand(N,1)*(r2-r1); % the deterministic radius
r = r + randn(N,1)*sigma;
theta = rand(N,1)*2*pi; % radian
d = [r.*cos(theta), r.*sin(theta)];