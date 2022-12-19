function H_irs = estimirs(x,varargin)
% ESTIMIRS Computes the Hurst parameter based on a increment ratio statistic
%          method for a 1D signal
%
%   H = ESTIMIRS(X) Estimates the Hurst parameter of the 1D signal X.
%
%   H = ESTIMIRS(...,EPS) Estimates the Hurst parameter using a specific
%   tolerence, EPS. If the tolerence is not specified EPS = 1e-5.
%
%   Example
%
%       N = 10000; Hx = 0.8;
%       x = fbmwoodchan(N,Hx);
%       H = estimirs(x);
%
%   See also cwttrack, calc_H_W
%
%   References
%
%       [1] Bardet, J-M. & Surgailis, D. Measuring the roughness of random
%       paths by increment ratios. hal-00238556, version 1 - 4 Feb 2008

% Author Pierre Bertrand & Medhi Fhima, January 2009.
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(1,2)
nargoutchk(1,1)

tol = 1.e-5;
grad = 1;

try %#ok<TRYNC>
    tol = varargin{1};
end

%Newton algorithm
H_irs = 0;
ratio = ratio2(x);
while grad > tol
    step = deriveeGrandLambda2(H_irs)\(grandLambda2(H_irs)-ratio);
    grad = norm(step);
    H_irs = H_irs-step;
end
end

%--------------------------------------------------------------------------
%Ratio function
function [ra2] = ratio2(x)
delta2 = diff(x,2);
n = length(delta2);
ra2 = mean(abs(delta2(1:n-1)+delta2(2:n))./(abs(delta2(1:n-1))+abs(delta2(2:n))));
end

%%%%%%%%%%%%%%%%%%%% Fonction derivee de Lambda2
%Lambda2 function
function [gL2] = deriveeGrandLambda2(H)
[r2] = rho2(H);
[dr2] = deriveeRho2(H);
[gL2] = dr2*deriveeGrandLambda02(r2);
end

%Rho2 function
function [dr2] = deriveeRho2(H)
if(H == 1)
    dr2 = 0;
else
    c1 = (-2*3^(2*H)*log(3)+2*2^(2*H+2)*log(2))/(8-2^(2*H+1));
    c2 = 2*(-3^(2*H)+2^(2*H+2)-7)*2^(2*H+1)*log(2)/((8-2^(2*H+1))^2);
    dr2 = c1+c2;
end
end

%Lambda02 function
function [dgL02] = deriveeGrandLambda02(r)
if(r == 1)
    dgL02 = 1;
elseif(r == -1)
    dgL02 = 0;
else
    rr = sqrt((1+r)/(1-r));
    dgL02 = 1/(pi*sqrt(1-r^2))+1/2*log(2*1/(1+r))*(1/(1-r)+(1+r)/((1-r)^2))/(pi*rr)-rr/(pi*(1+r));
end
end

%%%%%%%%%%%%%%%%%%%% Fonction Lambda2
%Lambda2 function
function [gL2] = grandLambda2(H)
[r2] = rho2(H);
[gL2] = grandLambda02(r2);
end

%Rho2 function
function [r2] = rho2(H)
if(H == 1)
    r2 = 0;
else
    r2 = (-3^(2*H)+2^(2*H+2)-7)/(8-2^(2*H+1));
end
end

%Lambda02 function
function [gL02] = grandLambda02(r)
if(r == 1)
    gL02 = 1;
elseif(r == -1)
    gL02 = 0;
else
    gL02 = 1/pi*(acos(-r)+sqrt((1+r)/(1-r))*log(2/(1+r)));
end
end
