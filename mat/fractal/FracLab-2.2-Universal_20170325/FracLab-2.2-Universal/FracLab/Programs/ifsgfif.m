function ifs = ifsgfif(N,mi,H)
% IFSGFIF Generates a Generalized Fractal Interpolation function with prescribed
%         Holder function based on Iterated Function System.
%
%   IFS = IFSGFIF(N,MI,H) Generates the generalized fractal interpolation function, IFS,
%   using a sample size N, a 3x2 matrix of interpolation points, MI, and a prescribed
%   Holder function H. The parameter N is a positive, power of 2, integer and the
%   parameter H must be a function from R to (0,1), written in a symbolic way.
%
%   Example
%
%       %Synthesis of a generalized fractal interpolation function
%       N = 1024; t = linspace(0,1,N); H = 'abs(sin(3*pi*t))';
%       x = ifsgfif(N,[0 0;0.5 1;1 0],H);
%       figure; plot(t,x);
%       title ('Generalized Fractal Interpolation Function'); xlabel ('time');
%
%   See also ifsfif, ifstfif
%
%   References
%
%       [1] K. Daoudi, J. Levy Vehel and Y. Meyer "Construction of continuous functions with 
%           prescribed local regularity", Constructive Approximation, Vol. 014(03) (1998), 349-385.
%
%       [2] J. Levy Vehel and K. Daoudi "Generalized IFS for Signal Processing",
%           IEEE DSP Workshop, Loen, Norway, September 1-4, 1996.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc ifsgfif ">ifsgfif</a>

% Author Khalid DAOUDI, June 1997
% Modified by Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,3);
nargoutchk(1,2);

if mod(log2(N),2) ~= 0 && mod(log2(N),2) ~= 1, error('The sample size must be a power of 2'); end
if size(mi,1)~=3 || size(mi,2)~=2, error('The interpolation points must be 3x2 matrix'); end
if isequal(mi(1,:),mi(2,:)) || isequal(mi(1,:),mi(3,:)) || isequal(mi(2,:),mi(3,:))
    error('The interpolation points must be differents');
end
try 
    t = 0; t = eval(H); %#ok<NASGU>
catch %#ok<CTCH>
    error('The function must be a function of t');
end 

%--------------------------------------------------------------------------
nn = log2(N);
mi = sortrows(mi);
coefs = zeros(1,N-2);
p=1;

for j=1:nn-1,
	for k=0:2^j-1
		t = k*2^(-j); %#ok<NASGU>
		coefs(p) = eval(H);
		p=p+1 ;
	end
end

[x,y] = prescalpha(mi,coefs,nn); % calling the mex-file
ifs = y(1:N);

end