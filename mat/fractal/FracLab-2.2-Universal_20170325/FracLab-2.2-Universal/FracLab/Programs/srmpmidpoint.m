function srmp = srmpmidpoint(N,gz,varargin)
% SRMPMIDPOINT Generates a Self-Regulating Multifractional Process using an iterative
%              midpoint displacement method.
%
%   SRMP = SRMPMIDPOINT(N,'GZ') Generates the self-regulating multifractional process, 
%   SRMP, using a sample size, N, and a function of z, GZ. The parameter N is a positive
%   integer and the parameter GZ must be a function from R to (0,1), written in a symbolic
%   way, linking the pointwise Holder exponent to the amplitude.
%
%   SRMP = SRMPMIDPOINT(...,'limits',[initial,final]) Generates SRMP with specific
%   initial and final values for the output signal. If LIMITS are not specified,
%   the default vector is [initial,final] = [0,0].
%
%   SRMP = SRMPMIDPOINT(...,'ampli',M) Generates SRMP with a specific multiplication
%   factor of the regularity, M. This influences the amplitude of the variations of 
%   the output signal. If AMPLI is not specified the default value is M = 0.8
%
%   SRMP = SRMPMIDPOINT(...,'seed',SEED) Generates SRMP with a specific random seed, SEED. 
%   This is useful to generate the same path several times or to compare the paths 
%   of different SRMPs
%
%   Example
%
%       % Synthesis of self-regulating multifractional process
%       N = 1024; gz = '1./(1+5*z.^2)';
%       x = srmpmidpoint(N,gz);
%       figure; plot(x)
%
%   See also srmpfbm
%
% Reference page in Help browser
%     <a href="matlab:fl_doc srmpmidpoint ">srmpmidpoint</a>

% Author Antoine Echelard, May 2009.
% Modified by Christian Choque Cortez, June 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,8)
nargoutchk(1,1)

if mod(log2(N),2) ~= 0 && mod(log2(N),2) ~= 1, error('The sample size must be a power of 2'); end
try 
    z = 0; z = eval(gz); %#ok<NASGU>
catch %#ok<CTCH>
    error('The function must be a function of z');
end 
if nargin > 2
    arguments = varargin;
    [limits,arguments] = checkforargument(arguments,'limits',[0,0]);
    if ~isnumeric(limits) || size(limits,1) ~= 1 || size(limits,2) ~= 2, error('Invalid use of limits property'); end
    zinitial = limits(1); zfinal = limits(2);
    [M,arguments] = checkforargument(arguments,'ampli',0.8);    
    if ~isnumeric(M) || size(M,1) ~= 1 || size(M,2) ~= 1, error('Invalid use of amplitude property'); end
    [seed, arguments] = checkforargument(arguments,'seed',rand(1)*1e6);
    if ~isnumeric(seed), error('Invalid use of seed property'); end
    if ~isempty(arguments), error('Too many input arguments'); end
else
    zinitial = 0; zfinal = 0; 
    M = 0.8;
    seed = rand(1) * 1e6;
end

%--------------------------------------------------------------------------
NN = log2(N);
V = zeros(1,2^NN+1);
V(1) = zinitial; V(end) = zfinal;

randn('state',seed);
h_waitbar = fl_waitbar('init');

for i = 0:NN-1
    fl_waitbar('view',h_waitbar,i,NN-1);
    pas = 2^(NN-i);
    for j = pas/2+1:pas:2^NN+1
        z = (V(j-pas/2) + V(j+pas/2))/2;
        V(j) = z + M * (pas/(2*2^NN))^(eval(gz))*randn;
    end
end
fl_waitbar('close',h_waitbar);

srmp = V(1:end-1);
end