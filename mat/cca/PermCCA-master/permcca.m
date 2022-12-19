function varargout = permcca(varargin)
% Permutation inference for canonical correlation
% analysis (CCA).
%
% Usage:
% [pfwer,r,A,B,U,V] = permcca(Y,X,nP,Z,W,Sel,partial)
%
%
% Inputs:
% - Y        : Left set of variables, size N by P.
% - X        : Left set of variables, size N by Q.
% - nP       : An integer representing the number
%              of permutations.
%              Default is 1000 permutations.
% - Z        : (Optional) Nuisance variables for
%              both (partial CCA) or left side
%              (part CCA) only.
% - W        : (Optional) Nuisance variables for the
%              right side only (bipartial CCA).
% - Sel      : (Optional) Selection matrix or a selection vector,
%              to use Theil's residuals instead of Huh-Jhun's
%              projection. If specified as a vector, it can be
%              made of integer indices or logicals.
%              The R unselected rows of Z (S of W) must be full
%              rank. Use -1 to randomly select N-R (or N-S) rows.
% - partial  : (Optional) Boolean indicating whether
%              this is partial (true) or part (false) CCA.
%              Default is true, i.e., partial CCA.
%
% Outputs:
% - p   : p-values, FWER corrected via closure.
% - r   : Canonical correlations.
% - A   : Canonical coefficients, left side.
% - B   : Canonical coefficients, right side.
% - U   : Canonical variables, left side.
% - V   : Canonical variables, right side.
%
% ___________________________________________
% AM Winkler, O Renaud, SM Smith, TE Nichols
% NIH - Univ. of Geneva - Univ. of Oxford
% Mar/2020

% Read input arguments
narginchk(2,7)
Y = varargin{1};
Y = center(Y);
X = varargin{2};
X = center(X);
if nargin >= 3
    nP = varargin{3};
end
if nargin >= 4
    Z = varargin{4};
    Z = center(Z);
else
    Z = [];
end
if nargin >= 5
    W = varargin{5};
    W = center(W);
else
    W = [];
end
if nargin >= 6
    Sel = varargin{6};
else
    Sel = [];
end
if nargin >= 7
    partial = varargin{7};
else
    partial = true;
end
[Ny,P] = size(Y);
[Nx,Q] = size(X);
K = min(P,Q);
if Ny ~= Nx
    error('Y and X do not have same number of rows.')
end
N = Ny; clear Ny Nx
I = eye(N);

% Residualise Y wrt Z
if ~ isempty(Z)
    Qz = semiortho(Z,Sel);
else
    Qz = I;
end
Y    = Qz'*Y;
Pnew = size(Y,1);
R    = size(Z,2);

% Residualise X wrt W
if isempty(W) && partial
    W = Z;
end
if ~ isempty(W)
    if partial
        Qw = Qz;
    else % bipartial
        Qw = semiortho(W,Sel);
    end
else
    Qw = I;
end
X    = Qw'*X;
Qnew = size(X,1);
S    = size(W,2);

% Initial CCA
[A,B,r] = cca(Y,X,R,S);
U = Y*[A null(A')];
V = X*[B null(B')];

% Initialise counter
cnt = zeros(1,K);
lW  = zeros(1,K);

% For each permutation
parfor p = 1:nP
    fprintf('Permutation %d/%d: ',p,nP);
    
    % First permutation is no permutation
    if p == 1
        idxY = (1:Pnew);
        idxX = (1:Qnew);
    else
        idxY = randperm(Pnew);
        idxX = randperm(Qnew);
    end
    
    % For each canonical variable
    for k = 1:K
        fprintf('%d ',k);
        [~,~,rperm] = cca(Qz*U(idxY,k:end),Qw*V(idxX,k:end),R,S);
        lWtmp = -fliplr(cumsum(fliplr(log(1-rperm.^2))));
        lW(k) = lWtmp(1);
    end
    if p == 1
        lW1 = lW;
    end
    cnt = cnt + (lW >= lW1);
    fprintf('\n');
    lW = [];
end
punc  = cnt/nP;
varargout{1} = cummax(punc); % pfwer
varargout{2} = r;            % canonical correlations
varargout{3} = A;            % canonical weights (left)
varargout{4} = B;            % canonical weights (right)
varargout{5} = Qz*Y*A;       % canonical variables (left)
varargout{6} = Qw*X*B;       % canonical variables (right)

% =================================================================
function Q = semiortho(Z,Sel)
% Compute a semi-orthogonal matrix according to
% the Huh-Jhun or Theil methods. Note that, due to a
% simplification of HJ, input here is Z, not Rz.
if isempty(Sel)
    % If Sel is empty, do Huh-Jhun
    % HJ here is simplified as in Winkler et al, 2020 (see the Appendix text of the paper)
    [Q,D,~] = svd(null(Z'),'econ');
    Q = Q*D;
else
    % Theil
    [N,R] = size(Z);
    if isvector(Sel)
        % If Sel is a vector of logical or integer indices
        if islogical(Sel)
            Sel = find(Sel);
        end
        if Sel(1) > 0
            % If Sel is a column of indices
            unSel = setdiff(1:N,Sel);
            if rank(Z(unSel,:)) < R
                error('Selected rows of nuisance not full rank')
            end
        else
            % If Sel is -1 or anything else but empty [].
            % Try first with a faster approach
            Sel = true(N,1);
            Zs  = bsxfun(@rdivide,Z,mean(Z,2));
            [~,~,iU] = unique(Zs,'rows');
            nU = max(iU);
            for r = randperm(nU,R)
                idx = find(iU == r);
                idx = idx(randperm(numel(idx)));
                Sel(idx(1)) = false;
            end
            % but it it fails, go with another one
            if rank(Z(~Sel,:)) < R
                foundSel = false;
                while ~ foundSel
                    Sel   = sort(randperm(N,N-R));
                    unSel = setdiff(1:N,Sel);
                    if rank(Z(unSel,:)) == R
                        foundSel = true;
                    end
                end
            end
        end
        S = eye(N);
        S = S(:,Sel);
    else
        % Sel is a matrix proper
        S = Sel;
    end
    Rz = eye(N) - Z*pinv(Z);
    Q = Rz*S*sqrtm(inv(S'*Rz*S));
end

% =================================================================
function [A,B,cc] = cca(Y,X,R,S)
% Compute CCA.
N = size(Y,1);
[Qy,Ry,iY] = qr(Y,0);
[Qx,Rx,iX] = qr(X,0);
K  = min(rank(Y),rank(X));
[L,D,M] = svds(Qy'*Qx,K);
cc = min(max(diag(D(:,1:K))',0),1);
A  = Ry\L(:,1:K)*sqrt(N-R);
B  = Rx\M(:,1:K)*sqrt(N-S);
A(iY,:) = A;
B(iX,:) = B;

% =================================================================
function X = center(X)
% Mean center a matrix and remove constant columns.
icte = sum(diff(X,1,1).^2,1) == 0;
X = bsxfun(@minus,X,mean(X,1));
X(:,icte) = [];
