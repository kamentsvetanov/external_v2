function [B] = fastfBm2D(n,h,W_xy,W_x,W_y,forceSameGaussianInputs)
%   Fast Synthesis of a 2D fractional Brownian motion
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [B] = fastfBm2D(n,H,[W_xy,[W_x,[W_y]]])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o   n  : Positive integer
%      Vertical/Horizontal dimension of the generated field
%
%   o   H  : Real in [0,1]
%      Parameter of the structure function (e.g. : Hurst parameter)
%
%   o   W_xy, W_x, W_y : Real vectors [1,N], [N,N], [N,N]
%      Optional Gaussian inputs  
%
%   1.2.  Output parameters
%
%   o   B  : real matrix  [N,N]
%      Synthesized random field
%
%   2.  See also:
%
%   synth2
%
%   3.  Example:
%
%   4.  Examples
%
%   % Computes a [128 x 128] 2D fBm with H = 0.8
%   B = fastfBm2D([128 128],0.8);
%   surf(B);

% Author Olivier Barrière, January 2006

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin <= 5
    forceSameGaussianInputs = 0;
end 

g = (fix(log(2*n-1)/log(2)+1));
m=2.^g;

ind_x = [0:m(1)/2, -m(1)/2+1:-1];
ind_y = [0:m(2)/2, -m(2)/2+1:-1];
[Ind_x,Ind_y]= meshgrid(ind_x,ind_y);
Ind_x = Ind_x/n(1).';
Ind_y = Ind_y/n(2).';

C_xy = 1/2*(2*(normfBm(Ind_x+1/n(1),Ind_y,h)+normfBm(Ind_x-1/n(1),Ind_y,h)+...
normfBm(Ind_x,Ind_y+1/n(2),h)+normfBm(Ind_x,Ind_y-1/n(2),h))-...
(normfBm(Ind_x+1/n(1),Ind_y+1/n(2),h)+normfBm(Ind_x+1/n(1),Ind_y-1/n(2),h)+...
normfBm(Ind_x-1/n(1),Ind_y+1/n(2),h)+normfBm(Ind_x-1/n(1),Ind_y-1/n(2),h))-4*normfBm(Ind_x,Ind_y,h));
C_x = 1/2*(normfBm(Ind_x+1/n(1),Ind_y,h)+normfBm(Ind_x-1/n(1),Ind_y,h)-2*normfBm(Ind_x,Ind_y,h));
C_y = 1/2*(normfBm(Ind_x,Ind_y+1/n(2),h)+normfBm(Ind_x,Ind_y-1/n(2),h)-2*normfBm(Ind_x,Ind_y,h));

C_xy = C_xy.';
C_x = C_x.';
C_y = C_y.';

TailleM = ['Taille [' num2str(m(1)) ' x ' num2str(m(2)) ']'];
%disp(['Matrices Circulantes : ' TailleM ]);

eigC_xy = real(fft2(C_xy));
eigC_xy(1,:) = zeros(1,m(2)); eigC_xy(:,1) = zeros(m(1),1);
eigC_x = real(fft(sum(C_x')));
eigC_y = real(fft(sum(C_y)));
%disp(['FFT Valeurs propres : ' TailleM ]);

if forceSameGaussianInputs 
     eigC_xy(eigC_xy<0)=0;
     eigC_x(eigC_x<0)=0;
     eigC_y(eigC_y<0)=0;
else
    while ( ((min(min(eigC_xy))<0) | (min(eigC_x)<0) | (min(eigC_y)<0)) & (prod(m)<2^17) )
        m=2*m;
        ind_x = [0:m(1)/2, -m(1)/2+1:-1];
        ind_y = [0:m(2)/2, -m(2)/2+1:-1];
        [Ind_x,Ind_y]= meshgrid(ind_x,ind_y);
        Ind_x = Ind_x/n(1).';
        Ind_y = Ind_y/n(2).';
        C_xy = 1/2*(2*(normfBm(Ind_x+1/n(1),Ind_y,h)+normfBm(Ind_x-1/n(1),Ind_y,h)+...
        normfBm(Ind_x,Ind_y+1/n(2),h)+normfBm(Ind_x,Ind_y-1/n(2),h))-...
        (normfBm(Ind_x+1/n(1),Ind_y+1/n(2),h)+normfBm(Ind_x+1/n(1),Ind_y-1/n(2),h)+...
        normfBm(Ind_x-1/n(1),Ind_y+1/n(2),h)+normfBm(Ind_x-1/n(1),Ind_y-1/n(2),h))-4*normfBm(Ind_x,Ind_y,h));
        C_x = 1/2*(normfBm(Ind_x+1/n(1),Ind_y,h)+normfBm(Ind_x-1/n(1),Ind_y,h)-2*normfBm(Ind_x,Ind_y,h)); 
        C_y = 1/2*(normfBm(Ind_x,Ind_y+1/n(2),h)+normfBm(Ind_x,Ind_y-1/n(2),h)-2*normfBm(Ind_x,Ind_y,h)); 

        TailleM = ['Taille [' num2str(m(1)) ' x ' num2str(m(2)) ']'];
        %disp(['Matrices Circulantes : ' TailleM ]);

        eigC_xy = real(fft2(C_xy));
        eigC_xy(1,:) = zeros(1,m(2)); eigC_xy(:,1) = zeros(m(1),1);
        eigC_x = real(fft(sum(C_x')));
        eigC_y = real(fft(sum(C_y)));
        %disp(['FFT Valeurs propres : ' TailleM ]);
    end
end

Sqrt_eigC_xy = sqrt(eigC_xy);
Sqrt_eigC_x = sqrt(eigC_x)';
Sqrt_eigC_y = sqrt(eigC_y)';
 
switch nargin
  case 2
    W_xy = fft2(randn(m));
    W_x = fft(randn(m(1),1))/sqrt(m(1)); % variance of Wx, Wy equal to 1
    W_y = fft(randn(1,m(2))).'/sqrt(m(2));
end 
 
A_xy = Sqrt_eigC_xy.*W_xy;
a_x = Sqrt_eigC_x.*W_x;
a_y = Sqrt_eigC_y.*W_y;


A_x = zeros(m);
A_y = zeros(m);
A_x(:,1)=m(1)*a_x;
A_y(1,:)=m(2)*a_y';
ind_x = 1:m(1)-1;
ind_y = 1:m(2)-1;
A_x(ind_x+1,ind_y+1) = A_xy(ind_x+1,ind_y+1).*(ones(m(1)-1,1)*(1./(exp(sqrt(-1)*2*pi*(ind_y)/m(2))-1))); 
A_y(ind_x+1,ind_y+1) = A_xy(ind_x+1,ind_y+1).*((1./(exp(sqrt(-1)*2*pi*(ind_x)/m(1))-1)).'*ones(1,m(2)-1)); 



Y_xy = real(ifft2(A_xy));
Y_x = real(ifft(mean(A_x.')));
Y_y = real(ifft(mean(A_y)));

B = zeros(n); 
B(1,1) = 0; 


 
for mx = 2:n(1) 
    B(mx,1) = B(mx-1,1) + Y_x(mx-1); 
end 
 
for my = 2:n(2) 
    B(1,my) = B(1,my-1) + Y_y(my-1); 
end 
 
 
for mx = 2:n(1) 
	for my = 2:n(2) 
	    B(mx,my) = B(mx,my-1)+B(mx-1,my)-B(mx-1,my-1)+Y_xy(mx-1,my-1); 
	end 
end 
 
 


function Y = normfBm(x,y,h)

Y = (x.^2 + y.^2).^h;
