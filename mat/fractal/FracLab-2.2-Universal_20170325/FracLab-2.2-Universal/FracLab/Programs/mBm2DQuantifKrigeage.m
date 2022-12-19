function mBm = mBm2DQuantifKrigeage(N,H,k)
% MBMQUANTIFKRIGEAGE Generates a 2D Multi-fractional Brownian Motion (mBm) using
%                    krigging and a prequantification.
%
%   MBM = MBM2DQUANTIFKRIGEAGE(N,H,K) Generates the multi-fractional brownian motion,
%   MBM, using a sample size, [N,N], a Holder function, H, and a number, K, of
%   levels for the prequantification, with N a positive integer. This allows to model
%   a process the pointwise regularity of which varies in time.
%
%   Example
%
%       % Synthesis of the Holder function H(t): 0 < t < 1
%       N = 128; x = linspace(0,1,N); y = linspace(0,1,N); 
%       [X,Y] = meshgrid(x,y); f = inline('0.1+0.8*x.*y','x','y'); Hxy = f(X,Y);
%       mBm2D = mBm2DQuantifKrigeage(N,Hxy,25);
%
%   See also synth2, mBm2DQuantif
%
%   References
%
%      [1] O. Barrière, "Synthèse et estimation de mouvements Browniens multifractionnaires
%          et autres processus à régularité prescrite. Définition du processus
%          autorégulé multifractionnaire et applications", PhD Thesis (2007).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc mBm2DQuantifKrigeage ">mBm2DQuantifKrigeage</a>

% Author Olivier Barrière, January 2006
% Modified by Christian Choque Cortez, March 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,3)
nargoutchk(1,1)

% Increase size
N = N + 2;
H = [H(:,1) H H(:,end)];
H = [H(1,:) ; H ; H(end,:)];

N = [N N];
Hxy = H;
eps = 10^-3;
H = min(1-eps,H) ;
H = max(eps,H) ;

h_waitbar = fl_waitbar('init');

Hline = reshape(H,[1 prod(N)]);

% k-moyennes
[moy, out, xmin, xmax] = k_means(Hline,k);

% Pour ne jamais être dans le cas de "3 voisins" on rajoute les valeurs min et max aux k moyennes
% avec une marge de "sécurité"
moymin = moy(1);
moymax = moy(end);
if 2*xmin-moymin < 0
    moyinf = max(eps,xmin-10*eps);
else
    moyinf = 2*xmin-moymin;
end
if 2*xmax-moymax > 1
    moysup = min(1-eps,xmax+10*eps);
else
    moysup = 2*xmax-moymax;
end
moy = [ moyinf moy moysup ];

%Step 1 and 2 : Generate u fBm 2D
U = k;

g = (fix(log(2*N-1)/log(2)+1));
m=2.^g;
W_xy = fft2(randn(m));
W_x = fft(randn(m(1),1))/sqrt(m(1));
W_y = fft(randn(1,m(2))).'/sqrt(m(2));

Bh = zeros(N(1),N(2),U+2);
Hu = zeros(U+2,1);
for u=1:U+2
    Hu(u) = moy(u);
    Bh(:,:,u) = fastfBm2D(N,Hu(u),W_xy,W_x,W_y,1);
    fl_waitbar('view',h_waitbar,u,U+2+(N(1)-2)*(N(2)-2));
end

mBm = zeros(N);
for i=2:N(1)-1
    %fl_waitbar('view',h_waitbar,1/2*(N(1)-1)+i/2, N(1)-1);
    for j=2:N(2)-1
        fl_waitbar('view',h_waitbar,U+2 + (i-2)*(N(2)-2) + j-1,U+2+(N(1)-2)*(N(2)-2));
        
        I = [i-1 i-1 i-1 i i i i+1 i+1 i+1 i-1 i-1 i-1 i i i i+1 i+1 i+1];
        J = [j-1 j j+1 j-1 j j+1 j-1 j j+1 j-1 j j+1 j-1 j j+1 j-1 j j+1];
        u=1;
        while Hxy(i,j) >= Hu(u)
            u = u+1;
        end
        u = max(2,u);
        u = min(u,U);
        if abs(Hxy(i,j)-Hu(u)) < eps
            mBm(i,j) = Bh(i,j,u);
        elseif abs(Hxy(i,j)-Hu(u-1)) < eps
            mBm(i,j) = Bh(i,j,u-1);
        else
            H_index = [(u-1)*ones(1,9) (u)*ones(1,9)];
            H = [Hu(u-1)*ones(1,9) Hu(u)*ones(1,9)];
            Z=zeros(18,1);
            B=zeros(18,1);
            A=zeros(18,18);
            for k=1:18
                x1 = I(k);
                x2 = J(k);
                Hx = H(k);

                Z(k,1) = Bh(x1,x2,H_index(k));

                Hij = Hxy(i,j);
                Hxy2 = (Hx+Hij)/2;
                B(k,1) = gg(Hx,Hij)/2*((x1^2+x2^2)^Hxy2+(i^2+j^2)^Hxy2+((x1-i)^2+(x2-j)^2)^Hxy2);

                for l=1:18
                    y1 = I(l);
                    y2 = J(l);
                    Hy = H(l);
                    Hxy2 = (Hx+Hy)/2;
                    A(k,l) = gg(Hx,Hy)/2*((x1^2+x2^2)^Hxy2+(y1^2+y2^2)^Hxy2+((x1-y1)^2+(x2-y2)^2)^Hxy2);
                end

            end
            g_opt = inv(A)*B;
            mBm(i,j) = g_opt'*Z;
        end
    end
end

mBm = mBm(2:N(1)-1,2:N(2)-1);

fl_waitbar('close',h_waitbar);
end
%--------------------------------------------------------------------------
function [gg] = gg(h1,h2)
gg = ii((h1+h2)/2)/sqrt(ii(h1)*ii(h2));
end

%--------------------------------------------------------------------------
function [ii]=ii(h)
if h<0.5
    q=1/h;
    ii=gamma(1-2*h)*q*sin(pi*(0.5-h));
elseif h==0.5;
    ii=pi;
else
    qq=1/(h*(2*h-1));
    ii=gamma(2-2*h)*qq*sin(pi*(h-0.5));
end
end