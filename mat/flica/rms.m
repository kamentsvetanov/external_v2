% OUT = RMS(IN, DIM, OPTIONS)
%   OUT = root-mean-square of IN
%   DIM = dimension to operate in.
%       Defaults to DIM = 0 (operate in all dims; OUT is scalar)
%   If DIM>0, works only in the given dimension.
%   Valid OPTIONS: 
%       'sum' == do root-sum-squares instead of RMS
%       'nanremove' == treat NaNs as missing data (NOT IMPLEMENTED YET)
function out = rms(in, dim, options);

% Parse inputs
if nargin<3, options = ''; end
if nargin<2, dim = 0; end
if ~isnumeric(dim), options=dim; dim=[]; end
if islogical(in), in = single(in); end
assert(isnumeric(in))
if ~isreal(in), in = abs(in); end
assert(ischar(options) || isempty(options))

% Do the calculation
if isempty(dim) || isequal(dim,0)
    out = sqrt(mean(in(:).^2)); % mean over entire matrix
    
elseif numel(dim)==1
    out = sqrt(mean(in.^2, dim)); % mean in specified dim
else % vector of values to rms across all of them?
    assert(numel(dim)==length(dim))
    out = in;
    for i = 1:length(dim)
        out = rms(out,dim(i));
    end
end

% Apply options
if strcmpi(options,'sum')
    out = out * sqrt(numel(in)/numel(out));
else
    assert(isempty(options))
end

if issparse(out) && length(out)==1
    out = full(out);
end
