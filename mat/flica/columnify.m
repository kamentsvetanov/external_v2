% C = columnify(X) turns X into a column of numbers.  It's most useful
%   when X is a structure or cell array.
%
function C = columnify(X)

if isnumeric(X)
    C = X(:);
    if issparse(C) && nnz(C) > 0.5*numel(C)
        C = full(C);
    else
        C = double(C);
    end
    
elseif iscell(X)
    
    % Slow because of loop-growing
    %C = [];
    %for i = 1:numel(X)
    %    C = [C; columnify(X{i})];
    %end
    
    C = cell(size(X));
    for i = 1:numel(X)
        C{i} = columnify(X{i});
    end
    C = vertcat(C{:});
    
elseif isstruct(X)
    C = columnify(struct2cell(X));
else
    error 'Unsupported input type!'
end