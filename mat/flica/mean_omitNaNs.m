% MEAN_OMITNANS: an exact drop-in replacement for MEAN that ignores
% NaNs rather than propagating them.
function out = mean_omitNaNs(in, varargin)

wasnan = isnan(in);
in(wasnan) = 0;

out = mean(in, varargin{:});
norm = mean(1-wasnan, varargin{:});

if any(norm==0)
    warning 'Some entries are the mean of all-NaN values; setting to zero.'
    norm(norm==0) = eps;
end

out = out ./ norm;
