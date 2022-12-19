% Sum a matrix in various dimensions
% BUT be prepared for the fact that the input matrix might be smaller than
% it should be.
% e.g. M is a 5x4 matrix and N is a 5x1 matrix, but conceptually they're
% both the same size...
%   sum_dims(M,[5 0]) = sum(M,1)
%   sum_dims(N,[5 0]) = 5*sum(N,1) = 5*N
%   sum_dims(M,[0 4]) = sum(M,2)
%   sum_dims(N,[0 4]) = sum(N,2)
%   sum_dims(M,[5 4]) = sum(M(:))
%   sum_dims(N,[5 4]) = sum(N)*5.
% An error will result if there's a size mismatch, e.g. sum_dims(M,[6 0]).
function M = sum_dims(M, dims, opts)

if nargin<3
    % ok
elseif isequal(opts, 'nan->zero')
    M(isnan(M))=0;
else
    opts
    error('Unrecognized opts!')
end

for d = 1:length(dims)
    if dims(d) == 0
        continue;
    elseif dims(d) == size(M,d)
        M = sum(M,d);
    elseif dims(d)>0 && size(M,d)==1
        M = M*dims(d);
    elseif dims(d)>1 && size(M,d)>1
        error('Dimension mismatch in d=%g: expected %g, was %g.',d, dims(d), size(M,d))
    else
        d
        dims
        size(M)
        error 'Huh??'
    end
end