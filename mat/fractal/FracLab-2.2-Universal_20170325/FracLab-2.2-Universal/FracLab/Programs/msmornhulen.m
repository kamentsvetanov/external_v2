function msm = msmornhulen(N,alpha,lambda,M,m,varargin)
%MSMORNHULEN Generates a Ornstein-Uhlenbeck Multistable Motion.  
%
%   MSM = MSMORNHULEN(N,ALPHA,LAMBDA,M,m) Generates the Ornstein-Uhlenbeck multistable
%   motion, MSM, using a sample size, N, a stability function, ALPHA, an
%   Ornstein-Uhlenbeck parameter, LAMBDA, a kernel cut-off parameter, M and a number
%   of discretization steps, m. The parameters N,M and m are positive integers and
%   this triplet should be chosen so that the value m*(N+M) is a power of 2.
%   LAMBDA is a positive real and ALPHA is in (0,2). This allows to model a process
%   whose index of stability varies in time.
%
%   MSM = MSMORNHULEN(...,SEED) Generates MSM with a specific random seed, SEED. 
%   This useful to generate the same path several times or to compare the
%   paths of different MSMs
%
%   Example
%
%       % Synthesis of the stability function alpha(t): 0 < t < 1
%       N = 2000; lambda = 0.01; M = 48; m = 32;
%       t = linspace(0,1,N); 
%       alphat = eval('1.5+0.3*sin(2*pi*t)');
%       x = msmornhulen(N,alphat,lambda,M,m); figure; plot(t,x);
%       title ('Ornstein-Uhlenbeck Multistable Motion');
%       xlabel ('time');
%
%   See also msmlevy, msmlinmfrac, asmornhulen
%
%   References
%       [1] K. Falconer, J. Lévy Véhel "Multifractional, multistable, and other
%           processes with prescribed local form", J Theor Probab (2009) Vol. 22, pp 375-401
%
%       [2] R. Le Guével, J. Lévy Véhel "A Ferguson-Class-LePage series representation 
%           of multistable multifractional processes and related processes"
%
% Reference page in Help browser
%     <a href="matlab:fl_doc msmornhulen ">msmornhulen</a>

% Author R. Leguevel, 2009
% Modified by Christian Choque Cortez, May 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(5,6)
nargoutchk(1,1)

seed = rand(1) * 1e6;
try %#ok<TRYNC>
    seed = varargin{1};
end

%--------------------------------------------------------------------------
msm = zeros(N,1);
h_waitbar = fl_waitbar('init');

for i=1:N
    z = asmornhulen(N,alpha(i),lambda,M,m,seed);
    msm(i) = z(i);
    fl_waitbar('view',h_waitbar,i,N);
end
fl_waitbar('close',h_waitbar);

end