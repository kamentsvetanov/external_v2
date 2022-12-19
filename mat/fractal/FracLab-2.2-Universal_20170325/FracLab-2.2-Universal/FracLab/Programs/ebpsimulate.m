function ebp = ebpsimulate(N,H,varargin)
% EBPSIMULATE Generates a Self Similar process using an Embedded Branching Process (EBP)
%
%   EBP = EBPSIMULATE(N,H) Generates the self similar process, EBP, using a sample
%   size, N, and a Hurst parameter, H. The parameter N is a positive integer
%   and H is a real value in (0,1).
%
%   EBP = EBPSIMULATE(N,H,'maxvar',M) Generates EBP using a maximum variation 
%   parameter, M, which is a positive integer. When this parameter is used only
%   two values {2,2*M} are taken from the offspring sampling distribution. 
%   If MAXVAR is not specified, the default value is M = 0.
%
%   EBP = EPBSIMULATE(...,'seed',SEED) Generates EBP with a specific random seed,
%   SEED. This is useful to generate the same path several times or to compare
%   the paths of different EBPs.
%
%   Example:
%
%       N = 1024 ; H = 0.5 ; t = linspace(0,1,N);
%       x = ebpsimulate(N,H);
%       figure; plot(t,x);
%       title ('EBP Self Similar Process with H = 0.5'); xlabel ('time');
%
%   References
%       [1] Owen Dafydd Jones "Fast, efficient on-line simulation of self-similar
%           processes; Corrected version",(2004).
%
% Reference page in Help browser
%     <a href="matlab:fl_doc ebpsimulate">ebpsimulate</a>

% Author Owen Jones, July 2003
% Modified by Christian Choque Cortez, June 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,6)
nargoutchk(1,1)

if ~(0 < H && H <= 1 ), error('H input argument must be a real in (0,1)'); end

if nargin > 2
    arguments = varargin;
    [maxvar,arguments] = checkforargument(arguments,'maxvar',0);
    if ~isnumeric(maxvar) || maxvar < 0, error('Invalid use of maxvar property'); end
    [seed, arguments] = checkforargument(arguments,'seed',rand(1)*1e6);
    if ~isnumeric(seed), error('Invalid use of seed property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    maxvar = 0;
    seed = rand(1) * 1e6;
end

%--------------------------------------------------------------------------
ebp = zeros(N,1);
h_waitbar = fl_waitbar('init');
rand('state',seed);

ebpstate = ebpinitialise(samplingftn(H,maxvar));

for k = 1:N-1
	ebpstate = ebpexpand(ebpstate,H,maxvar);
	ebpstate = ebpincrement(ebpstate,H,maxvar,0);
    if ebpstate(1,4) == 1 || ebpstate(1,4) == 3 || ebpstate(1,4) == 5
        ebp(k+1) = ebp(k) + 1;
    else
        ebp(k+1) = ebp(k) - 1;
    end
    fl_waitbar('view',h_waitbar,k,N-1);
end
fl_waitbar('close',h_waitbar);

end
%--------------------------------------------------------------------------
function [n, m] = samplingftn(H,k,var)
%SAMPLINGFTN function returns values in {2,4,6,...}
%
% H is the Hurst parameter
% k represents the maximum variation, this value is used when it is wanted
% a two-values output {2, 2*k}

outputvar = 1;
try outputvar = var; end %#ok<TRYNC>

a = 2^((H-1)/H);
r = rand;
n = 1; m = 1; prb1 = a; prb2 = a^2;

while r > prb2, n = n+1; prb2 = prb2 + n*(1-a)^(n-1)*a^2; end
while r > prb1, m = m+1; prb1 = prb1 + (1-a)^(m-1)*a; end

n = 2*n; m = 2*m;

if k
    a = (2^(1/H)-2*k)/(2-2*k);
    mu = 2*a + 2*k*(1-a); n = 2; m = 2;
    if r > 2*a/mu, n = 2*k; end
    if r > a, m = 2*k; end
end

if outputvar ~= 1, 
    nn = m; m = n; n = nn; 
end
end
%--------------------------------------------------------------------------
function X = ebpinitialise(samplingftn)
%EBPINITIALISE returns a randomly chosen initial state for an EBP process
%
% samplingftn is a value from the sampling distribution n*p(n)/mu
%
% X = (kappa(0,0,0), S(0,0,1), Z(0,1,1), alpha(0,0,1))
% types are 0+ 0- 1+ 1- -1+ -1-, labelled 1 2 3 4 5 6

X = [1 0 0 0];
X(3) = samplingftn;
X(2) = ceil(rand*X(3));

if X(2) == X(3)
    if rand < 0.5, X(4) = 3; else X(4) = 6; end
elseif mod(X(2),2) == 1
    if rand < 0.5, X(4) = 1; else X(4) = 2; end
else
    if rand < 0.5, X(4) = 4; else X(4) = 5; end
end
end
%--------------------------------------------------------------------------
function X = ebpexpand(Y,H,k)
% EBPEXPAND adds new levels to the state of an EBP process
%
% Y is the current state of the process at step P (levels 0 to nmax)
% A value from the sampling distribution n*p(n)/mu is computed and used
% X is the expanded state of the process at step P (nmax may have increased)
%
% row n+1 of Y is (kappa(0,n,P), S(0,n,P), Z(0,n+1,P), alpha(0,n,P))
% row nmax+1 of X satisfies S(0,nmax,P) < Z(0,nmax+1,P)
% types are 0+ 0- 1+ 1- -1+ -1-, labelled 1 2 3 4 5 6

X = Y;
nmax = size(X,1) - 1;
while X(nmax+1,2) == X(nmax+1,3)
    nmax = nmax + 1;
    X = [X; 1 0 0 0]; %#ok<AGROW>
    X(nmax+1,3) = samplingftn(H,k);
    X(nmax+1,2) = ceil(rand*X(nmax+1,3));
    if X(nmax,4) == 3
        if X(nmax+1,2) == X(nmax+1,3), X(nmax+1,4) = 3;
        elseif mod(X(nmax+1,2),2) == 1, X(nmax+1,4) = 1;
        else X(nmax+1,4) = 5;
        end
    else
        if X(nmax+1,2) == X(nmax+1,3), X(nmax+1,4) = 6;
        elseif mod(X(nmax+1,2),2) == 1, X(nmax+1,4) = 2;
        else X(nmax+1,4) = 4;
        end
    end
end
end
%--------------------------------------------------------------------------
function X = ebpincrement(Y,H,k,n)
% EBPINCREMENT increments the state of an EBP process
%
% Y is the current state of the process at step P (levels 0 to nmax)
% A value from offspring distribution p(n) is computed and used
% n is the level being incremented
% X is the state of the process at step P+1
%
% row n+1 of Y is (kappa(0,n,P), S(0,n,P), Z(0,n+1,P), alpha(0,n,P))
% row n+1 of X is (kappa(0,n,P+1), S(0,n,P+1), Z(0,n+1,P+1), alpha(0,n,P+1))
% types are 0+ 0- 1+ 1- -1+ -1-, labelled 1 2 3 4 5 6

X = Y;
if (n > 0) && ~(X(n,2) == X(n,3)), error('X is not at end of level n crossing'); end

if X(n+1,2) == X(n+1,3)
    X = ebpincrement(X,H,k,n+1);
    X(n+1,2) = 1; 
    X(n+1,3) = samplingftn(H,k,2);
else
    X(n+1,2) = X(n+1,2) + 1;
end

X(n+1,1) = X(n+1,1) + 1;

nmax = size(X,1) - 1;
if n == nmax
    if X(n+1,2) == X(n+1,3)
        if X(n+1,4) == 1, X(n+1,4) = 3; else X(n+1,4) = 6; end
    elseif mod(X(n+1,2),2) == 1
        if rand < 0.5, X(n+1,4) = 1; else X(n+1,4) = 2; end
    else
        if X(n+1,4) == 1, X(n+1,4) = 4; else X(n+1,4) = 5; end
    end
else
    if X(n+1,2) == X(n+1,3)
        if (X(n+2,4) == 1 || X(n+2,4) == 3 || X(n+2,4) == 5), X(n+1,4) = 3; else X(n+1,4) = 6; end
    elseif X(n+1,2) == X(n+1,3) - 1
        if (X(n+2,4) == 1 || X(n+2,4) == 3 || X(n+2,4) == 5), X(n+1,4) = 1; else X(n+1,4) = 2; end
    elseif mod(X(n+1,2),2) == 1
        if rand < 0.5, X(n+1,4) = 1; else X(n+1,4) = 2; end
    else
        if X(n+1,4) == 1, X(n+1,4) = 4; else X(n+1,4) = 5; end
    end
end
end