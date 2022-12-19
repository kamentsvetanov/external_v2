function msm = msmlevy(N,alpha,varargin)
%MSMLEVY Generates a Multistable Lévy Motion. 
%
%   MSM = MSMLEVY(N,ALPHA) Generates the multistable Lévy motion, MSM, using a
%   sample size, N, and a stability function, ALPHA. The parameter N is a positive
%   integer and the parameter ALPHA is in (0,2). This allows to model a process
%   whose index of stability varies in time.
%
%   MSM = MSMLEVY(...,SEED) Generates MSM with a specific random seed, SEED. 
%   This useful to generate the same path several times or to compare the
%   paths of different MSMs
%
%   Example
%
%       % Synthesis of the stability function alpha(t): 0 < t < 1
%       N = 2000; t = linspace(0,1,N); 
%       alphat = eval('1.5+0.3*sin(2*pi*t)');
%       x = msmlevy(N,alphat); figure; plot(t,x);
%       title ('Multistable Levy Motion');
%       xlabel ('time');
%
%   See also msmlinmfrac, msmornhulen, asmlevy
%
%   References
%       [1] K. Falconer, J. Levy Vehel "Multifractional, multistable, and other
%           processes with prescribed local form", J Theor Probab (2009) 22: 375–401
%
% Reference page in Help browser
%     <a href="matlab:fl_doc msmlevy ">msmlevy</a>

% Author Ronan Leguevel, 2009
% Modified by Christian Choque Cortez, May 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,3)
nargoutchk(1,1)

seed = rand(1) * 1e6;
try %#ok<TRYNC>
    seed = varargin{1};
end

%--------------------------------------------------------------------------
msm = zeros(N,1);
h_waitbar = fl_waitbar('init');

mesh = power(1/N,power(alpha,-1));
for i=2:N
    z = mesh(i)*asmlevy(N,alpha(i),0,seed);
    msm(i) = z(i-1);
    fl_waitbar('view',h_waitbar,i,N-1);
end
fl_waitbar('close',h_waitbar);

end
