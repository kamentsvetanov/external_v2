function varargout = datacheck(varargin)

% remove records with empty values
argnum = nargin;

i_NAN = [];
for i = 1 : argnum
    c_iNAN = isnan(varargin{i});
    c_iNAN = find(sum(c_iNAN,2) > 0);
    i_NAN = union(c_iNAN, i_NAN);
end

for i = 1 : argnum
    varargin{i}(i_NAN,:) = [];    
end
varargout = varargin;
end
