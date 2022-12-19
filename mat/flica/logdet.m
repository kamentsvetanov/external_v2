% LD = LOGDET(M, IGNOREZEROS)
%
%  Calculate log(det(M)), using an eigenvalue-based method to avoid
%  underflow errors.  Note that this is meant to work with precision
%  matrices, so it'll issue a warning if any of the eigenvalues are
%  negative (indicating there are negative precisions somewhere).
%  Optionally, can also work with rank-deficient matrices by specifying the
%  number of zeros eigenvalues to ignore. 

% Copyright Adrian Groves, 2007-07
% FMRIB Centre, University of Oxford
% 
% Created: Feb 2007 by Adrian Groves (adriang@fmrib.ox.ac.uk)
% Last modified: Feb 2007 by Adrian Groves (adriang@fmrib.ox.ac.uk)
%
function ld = logdet(M, ignorezeros)

if nargin<2, ignorezeros = 0; end
if nargin<2 && issparse(M), ignorezeros = nan; end % skip check, it crashes

if isequal(ignorezeros, 'chol')
    % Slightly faster method, but I don't know if it can also be used to
    % ignore zero eigenvalues
    ld = 2*sum(log(diag(chol(M))));
    return
%elseif isequal(ignorezeros, 'cholproj')
    % Slightly faster method, but I don't know if it can also be used to
    % ignore zero eigenvalues
    % Requires addpath ~/tools/lightspeed/ (MS lightspeed toolbox)
    % Which unfortunately overwrites this function with its own logdet!
%    ld = 2*sum(log(diag(cholproj(M))));
%    return
end

eigs = eig(M);

if any(imag(eigs)) || any(eigs<0)
    min(eigs)
    warning('logdet: Not positive definite! -- but probably just numerical (should normalize diagonal first)')
%    keyboard
end

if isnan(ignorezeros)
    % Okay, skipping checks
elseif rank(M) < length(M) && ~ignorezeros
    warning('Matrix seems to be singular in logdet')
    % Bad sign; often shortly followed by a not-positive-definite error
elseif rank(M) + ignorezeros ~= length(M)
    error('Wrong rank deficiency')
end

if ignorezeros>0
    % Remove the specified number of zero eigenvalues
    eigs = sort(eigs);
    eigs = eigs( 1+ignorezeros : end );
end

if ~isnan(ignorezeros)
    tinyTol = length(M)*eps(norm(M))/10;
    tinyIndices = abs(eigs) < tinyTol;
    if any(tinyIndices)
        warning('Setting tiny values to 1/10th the threshold used by RANK')
        eigs(tinyIndices) = tinyTol; % positive
    end
end

% Calculate log-determinant -- should be almost real
ld = sum(log(eigs));

if abs(imag(ld)) > 1e-10*abs(ld)
    warning('logdet: large imaginary parts.  How strange.')
%    keyboard
end

ld = real(ld);