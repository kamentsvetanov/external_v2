function fBm = synth2(N,H,W,Wx,Wy)
%SYNTH2 Generates a 2D Fractional Brownian Motion (fBm) using an incremental Fourier
%       method for processes with stationary increments of order (0,1) and (1,0)
%
%   FBM = SYNTH2(N,H) Generates the fractional brownian motion, FBM, using a sample size,
%   [N,N] and a Holder exponent, H. The parameter N is a positive integer and the 
%   parameter H is a real value in (0:1) that governs both the pointwise regularity
%   and the shape around 0 of the power spectrum.
%
%   FBM = SYNTH2(...,W,Wx,Wy) Generates a FBM using a specific driving white zero-mean
%   Gaussian noise, [W,Wx,Wy].
%
%   Example
%
%       N = 128; H = 0.5;
%       fBm2D = synth2(N,H);
%
%   See also mBm2DQuantifKrigeage, mBm2DQuantif, fbmcwt, fbmfwt
%
% Reference page in Help browser
%     <a href="matlab:fl_doc synth2 ">synth2</a>

% Author B. Pesquet-Popescu, ENS-Cachan, February 1998
% Modified by Olivier Barrière, September 2004 (optionnal Gaussian Variables)
% Modified by Christian Choque Cortez, April 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,5)
nargoutchk(1,1)

M = 2*N;
core = 'strfbm';

if nargin == 2 && nargin ~=5
    W = fft2(randn(M));
    Wx = fft(randn(M,1))/sqrt(M); % variance of Wx, Wy equal to 1
    Wy = fft(randn(1,M))/sqrt(M);
end
h_waitbar = fl_waitbar('init');

% Step 2
%--------
% computation of the matrices Ind1 and Ind2 of vertical and horizontal coordinates
% the vertical coordinates are between 0:N/2
% and the horizontal coordinates are between 0:N/2 or -N/2+1:-1

ind = 0:M/2;	% k_y, m_x, m_y
ind1 = [ind -M/2+1:-1];
[Ind1,Ind2]= meshgrid(ind,ind1);
Ind1 = Ind1.';
Ind2 = Ind2.';

% computation of the correlation of the increments of order (1,1)

r2 = 1/2*(2*(feval(core,Ind1+1,Ind2,H)+feval(core,Ind1-1,Ind2,H)+...
    feval(core,Ind1,Ind2+1,H)+feval(core,Ind1,Ind2-1,H))-...
    (feval(core,Ind1+1,Ind2+1,H)+feval(core,Ind1+1,Ind2-1,H)+...
    feval(core,Ind1-1,Ind2+1,H)+feval(core,Ind1-1,Ind2-1,H))-4*feval(core,Ind1,Ind2,H));

% symmetrisation of the 2D correlation function
r2 = symcori(r2);

% Step 3
%--------
% compute the power spectrum

S2 = real(fft2(r2));
clear r2

% Step 4
%--------
% truncate the negative part of the spectrum

t = find(S2(:)<0);  S2(t) = zeros(size(t));
S2(1,:) = zeros(1,M); S2(:,1) = zeros(M,1);

% Step 5
%--------
% compute the DFT coefficients

I2 = sqrt(S2).*W;
clear S2 W

% Step 6
%--------
% compute the increments of order (1,1)

i2 = real(ifft2(I2));
inds = 1:N;
i2 = i2(inds,inds);

% Step 8
%--------
% calculate correlation functions of first order increments

rx = 1/2*(feval(core,Ind1+1,Ind2,H)+feval(core,Ind1-1,Ind2,H)...
    -2*feval(core,Ind1,Ind2,H));
ry = 1/2*(feval(core,Ind1,Ind2+1,H)+feval(core,Ind1,Ind2-1,H)...
    -2*feval(core,Ind1,Ind2,H));

% symmetrically expand

rx = symcori(rx);
ry = symcori(ry);

% Step 9
%--------
% spectrum of the increments of order (1,0)/(0,1)

Sx = real(fft(sum(rx.'))).';
Sy = real(fft(sum(ry))) ;
clear rx ry

% Step 10
%---------
% keep the positive part of the spectra

t = find(Sx<0); Sx(t) = zeros(size(t));
t = find(Sy<0); Sy(t) = zeros(size(t));

% Step 11
%---------
% DFT coefficients of the increments of order (1,0)/(0,1)

Ix = zeros(M); Iy = zeros(M);
indis = 1:M-1;

Ix(indis+1,indis+1) = -i*I2(indis+1,indis+1)/2.*(ones(M-1,1)*...
    (exp(-i*pi*indis/M)./sin(pi*indis/M)));

Iy(indis+1,indis+1) = -i*I2(indis+1,indis+1)/2.*...
    ((exp(-i*pi*indis/M)./sin(pi*indis/M)).'*ones(1,M-1));

Ix(:,1) = M*sqrt(Sx).*Wx; % variance of the noise normalized to N^2
Iy(1,:) = M*sqrt(Sy).*Wy ;

% Step 12
%---------
% first order increments along the image boundaries

ix = ifft(mean(Ix.')).';
ix = real(ix(1:N));

iy = ifft(mean(Iy));
iy = real(iy(1:N));

% Step 13
%---------
% add up the increments to obtain the fBm

fBm = zeros(N);
fBm(1,1) = 0;

for mx = 2:N
    fl_waitbar('view',h_waitbar,mx,3*N);
    fBm(mx,1) = fBm(mx-1,1) + ix(mx-1);
end

for my = 2:N
    fl_waitbar('view',h_waitbar,N+my,3*N);
    fBm(1,my) = fBm(1,my-1) + iy(my-1);
end

for mx = 2:N
    fl_waitbar('view',h_waitbar,2*N+mx,3*N);
    for my = 2:N
        fBm(mx,my) = fBm(mx,my-1)+fBm(mx-1,my)-fBm(mx-1,my-1)+i2(mx-1,my-1);
    end
end

fl_waitbar('close',h_waitbar);
end

