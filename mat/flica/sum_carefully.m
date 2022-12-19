% S = sum_carefully(X)
%
% Add all the elements of X, in such a way as to avoid quantization errors
% as much as possible while accumulating.  (Really only useful if there
% are large numbers being summed that precisely cancel each other.)
%
% e.g.
% sum_carefully([1e120 1 -1e120]) is 1 (not 0)
% sum_carefully({[1e120 1 -1e120], [4;5;-5;-4], [1 1e-120; -2 0]}) is 1e-120 (not -1)
function [S X] = sum_carefully(X)

X = columnify(X);

% if isstruct(X)
%     X = struct2cell(X);
% end
% 
% if iscell(X)
%     for i = 1:inf
%         if i > numel(X), break; end
%         if ~isnumeric(X{i}), 
%             %X{i}, error 'Unsupported but really should be done recursively using a columnify() function!'; 
%             for j = 1:numel(X{i})
%                 X(end+1) = X{i}{j};
%             end
%             X{i} = [];
%         else
%             X{i} = X{i}(:)';
%         end
%     end
%     X = [X{:}];
% end
% 
% X = X(:);

X(X==0) = []; % might speed things up
[~, order] = sort(abs(X),'descend');
X = X(order);

% Show details: 
% for i=1:length(X), disp(sprintf(' + %g = %g',X(i), sum(X(1:i)))), end

S = sum(X);

