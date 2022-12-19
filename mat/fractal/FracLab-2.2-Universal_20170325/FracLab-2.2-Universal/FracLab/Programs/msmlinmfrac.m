function [msm,msmn] = msmlinmfrac(N,alpha,H,M,m,varargin)
%MSMLINMFRAC Generates a Linear Multifractional Multistable Motion  
%
%   MSM = MSMLINMFRAC(N,ALPHA,H,M,m) Generates the linear multifractional multistable
%   motion, MSM, using a sample size, N, a stability function, ALPHA, a self-similarity
%   function, H, a kernel cut-off parameter, M and a number of discretization steps, m.
%   The parameters N,M and m are positive integers and this triplet should be chosen so that
%   the value m*(N+2*M) is a power of 2. ALPHA is in (0,2) and H is in (0,1). 
%   This allows to model a process of which the index of stability and the self-simlarity
%   parameter vary in time.
%
%   MSM = MSMLINMFRAC(...,SEED) Generates MSM with a specific random seed, SEED. 
%   This useful to generate the same path several times or to compare the paths 
%   of different MSMs.
%
%   [MSM, MSMN] = MSMLINMFRAC(...) Generates MSM and its normalized signal MSMN.
%
%   Example
%
%       % Synthesis of the stability function alpha(t): 0 < t < 1
%       N = 2000; H = 0.5; M = 24; m = 32;
%       t = linspace(0,1,N); 
%       alphat = eval('1.5+0.3*sin(2*pi*t)'); Ht = eval('0.1+0.8*t');
%       x = msmlinmfrac(N,alphat,Ht,M,m); figure; plot(t,x);
%       title ('Linear Multifractional Multistable Motion');
%       xlabel ('time');
%
%   See also msmlevy, msmornhulen, asmlinfrac
%
%   References
%       [1] K. Falconer, J. Lévy Véhel "Multifractional, multistable, and other
%           processes with prescribed local form", J Theor Probab (2009) Vol. 22, pp 375-401
%
%       [2] R. Le Guével, J. Lévy Véhel "A Ferguson-Class-LePage series representation 
%           of multistable multifractional processes and related processes"
%
% Reference page in Help browser
%     <a href="matlab:fl_doc msmlinmfrac ">msmlinmfrac</a>

% Author Ronan Leguevel, 2009
% Modified by Christian Choque Cortez, May 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(5,6)
nargoutchk(1,2)

seed = rand(1) * 1e6;
try %#ok<TRYNC>
    seed = varargin{1};
end

%--------------------------------------------------------------------------
msm = zeros(N,1);
msmn = zeros(N,1);
h_waitbar = fl_waitbar('init');

for i=2:N
    z = asmlinfrac(N,alpha(i),H(i),M,m,seed)/power(N,H(i));
    msm(i)=z(i-1);
    msmn(i)=z(i-1)/max(abs(z));
    fl_waitbar('view',h_waitbar,i,N);
end
fl_waitbar('close',h_waitbar);

end