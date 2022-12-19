% dof = est_DOF_eigenspectrum(S)
% Where S is a vector (eigenspectrum from an SVD)
%   or a diagonal matrix (eigenspectrum from an SVD)
%   or a 2D block of data (voxels x timepoints)
%   or a 4D block of data (X x Y x Z x timepoints)
%
% Note that if you're starting with a positive-definite covariance matrix
%   and taking the eigenvalues directly (with eig), you should square-root
%   the values before passing them into this function.
%
% You should replace any suspicious (non-null) bits of the spectrum with
%   NaNs.  If there are no NaNs, automatically ignores the first third of
%   the spectrum, and the last four points.  Supply a second argument 'all'
%   if you want to use the whole spectrum.
%
%

% OLD HELP:
% optional secont argument (r) is the ranges to 
%   look in to calculate the ratio
%   (defaults to [0.5 0.7 0.9]*end)
%
% NOTE: It only makes sense to do this if the white noise levels are
% equal!!
% It's still not a great estimator... i.e. splitting data in two,
% rearranging T axis randomly, still isn't additive DOF.
function dof = est_DOF_eigenspectrum(S, r)
if numel(S) == length(S)
    % Good!
    assert(all(diff(S(isfinite(S)))<0))
elseif isequal(size(S),[1 1]*length(S)) && isequal(S,diag(diag(S)))
    S = diag(S);
elseif length(size(S)) == 2
    if size(S,2)>size(S,1)
        error 'Matrix is wider than it is tall -- eigenspectrum method won''t work!'
    end
    s2 = flipud(sqrt(eig(S'*S)));
    %[u S v] = svd(S,'econ');
    %S = diag(S);
    %assertalmostequal(S, s2);
    S = s2;
else
    [~,S,~] = svd(reshape(S,[],size(S,4)),'econ');
    S = diag(S);
end

if 1
    % Use new analytic method!
    if all(isfinite(S)) && nargin==1
%        S(1:ceil(end/3)) = nan;
%        S(end-3:end) = nan;
        keep = false(size(S));
        keep([ceil(end*0.25) floor(end*0.75)]) = true;
        %S(floor([1:end*.25-1, end*.25+1:end*.75-1, end*.75+1:end])) = nan; % Christian's recommended method
        %S(end) = nan; % Especially important to mask out the smallest eigenvalue, and sometimes the floor above doesn't quite catch it.  (484 data set ok, 'cuz it's a multiple of 4).
        S(~keep) = NaN;
        assert(sum(isfinite(S))==2)
    elseif all(isfinite(S))
        assert(isequal(r,'all'))
    end
    gam = fit_eigenspectrum(S.^2);
    dof = length(S) / gam(1);
    return
end

warning 'Using old, slow, inaccurate method.'


T = length(S);
assert(T>1)

if nargin<2
    r = [0.5 0.7 0.9];
end
if any(r<1)
    if r(2)*2==r(1)+r(3)
        r = floor(r(2)*T)+[-1 0 1]*floor((r(2)-r(1))*T);
    else
        r = floor(r*T);
    end
end
calcRatio = @(S) sum(S(r(1):r(2)))/sum(S(r(2):r(3)));
goalRatio = calcRatio(S)
maxT = 5999;
realRatio = nan(maxT,1);

cacheFile = sprintf('/vols/Scratch/adriang/caches/eigenspectrum/T%d_r%d-%d-%d',T,r(1),r(2),r(3))
try
    load(cacheFile)
    printf('Cache hit!')
    maxT = length(realRatio);
catch
    printf('Cache miss...')
    for N = T+1:1:maxT
        r = randn(N,T);
        %[u s v] = svd(r,'econ');
        %s1 = diag(s);
        s2 = flipud(sqrt(eig(r'*r)));
        %assertalmostequal(s1,s2);
        realRatio(N) = calcRatio(s2);
        if gcf ~= 10, figure(10); end
        clf
        semilogy(realRatio)
        plot_drawdiag(goalRatio, 'horzr')
        drawnow
    end
    printf('Caching!')
    save(cacheFile,'realRatio')
    printf('Added to cache')
end

cost = cumsum(realRatio<goalRatio) + ...
    flipud(cumsum(flipud(realRatio)>goalRatio));
dof = mean(find(cost==min(cost)));

if dof > 0.9*maxT || dof < 100
    warning 'Might want to double-check that'
    % Should test a wider range
end

if nargout < 1
    plot(realRatio)
    plot_drawdiag(goalRatio, 'horzr:')
    plot_drawdiag(dof, 'vertr:')
end

