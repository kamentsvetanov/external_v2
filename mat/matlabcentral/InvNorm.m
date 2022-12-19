function x=InvNorm(u)
% Beasley-Springer-Moro algorithm for approximating the inverse normal.
% Input: u, a sacalar or matrix with elements between 0 and 1
% Output: x, an approximation for the inverse normal at u
%
% Reference:
% Pau Glasserman, Monte Carlo methods in financial engineering, 
% vol. 53 of Applications of Mathematics (New York), 
% Springer-Verlag, new York, 2004, p.67-68
%
% Example:
% a=0.1:0.1:0.9;
% b=InvNorm(a);

error(nargchk(1,1,nargin))     % Allow 1 input
error(nargoutchk(0,1,nargout))   % Allow 0 to 1 output

a0=2.50662823884;
a1=-18.61500062529;
a2=41.39119773534;
a3=-25.44106049637;

b0=-8.47351093090;
b1=23.08336743743;
b2=-21.06224101826;
b3=3.13082909833;

c0=0.3374754822726147;
c1=0.9761690190917186;
c2=0.1607979714918209;
c3=0.0276438810333863;
c4=0.0038405729373609;
c5=0.0003951896511919;
c6=0.0000321767881768;
c7=0.0000002888167364;
c8=0.0000003960315187;

y=u-0.5;

index1=abs(y)<0.42;
index2=not(index1);

x=zeros(size(u));

r1=abs(y(index1));
r=r1.^2;
x(index1)=r1.*polyval([a3,a2,a1,a0],r)./polyval([b3,b2,b1,b0,1],r);

r=u(index2);
r=min(r,1-r);
r=log(-log(r));
x(index2)=polyval([c8,c7,c6,c5,c4,c3,c2,c1,c0],r);

x=x.*sign(y);

end
