% OUT = DESOMETHING(IN, DIMENSION, SOMETHING)
%   e.g. out = desomething(in, 2, 'mean') demeans in dimension 2
%        out = desomething(in, 0, 'max') de-maxes the entire matrix
% max: out = in - max(in)
% scale: out = in / max(in) 

function out = desomething(in, direction, something)

%if numel(in) == 0, out = in; return; end % That's easy!

% Something to consider: consistent treatment of NaNs as missing data?
% e.g. max([1 3 nan]) = 3, but mean([1 3 nan]) = nan (should be 2?)
%if any(~isfinite(in(:)))
%    warning('Non-finite values in input... results may be weird.')
%    keyboard
%end
if ~isnumeric(in) && ~islogical(in), in, error('Input isn''t numeric, it''s a %s!', class(in)); end
infinityProblem = any(~isfinite(in(:)));

% Causes problems later.. matchsize, and after that too.
%if direction == 0
%    in = in(:);
%    direction = 1;
%end
if iscell(something)
    out = in;
    for i = 1:numel(something)
        out = desomething(out, direction, something{i});
    end
    return
    
elseif ~ischar(something)
    error('Third argument must be a string (action to take) or cell array of strings')
end

% Maybe there are some useful string flags I could use for direction
if isequal(direction,'nop')
    % Apply it along NO dimension!  ;-)
    out = in;
    return
    
elseif isequal(direction,'all')
    direction = find(size(in))>1;
end

if length(direction)~=1
    out = in;
    for i = direction
        out = desomething(out, i, something);
    end
    return
end

if numel(in)==1 || (direction > 0 && size(in, direction) == 1)
    warning 'Desomething-ing and dimension is 1! probably a mistake.'
end

% First, calculate the normalization value
switch (lower(something))
    
    case {'max'} % max
              
        if direction == 0
            m = max(in(:));
        else
            m = max(in, [], direction);
        end
        
        infinityProblem = any(isnan(in(:)) | in(:)==inf); % -inf ok

    case {'scale'} % absmax
              
        if direction == 0
            m = max(abs(in(:)));
        else
            m = max(abs(in), [], direction);
        end
        
    case {'mean'} % mean
        if direction == 0
            m = mean_omitNaNs(in(:));
        else
            m = mean_omitNaNs(in, direction);
        end
        infinityProblem = any(abs(in(:))==inf); % nan ok
        
    case {'median'}
        if direction == 0
            m = median(in(:));
        else
            m = median(in, direction);
        end        
        
    case {'var'} % variance -> 1
        if direction == 0
            m = std(in(:));
        else
            m = std(in, direction);
        end
        
    case {'scalerms'}
%        m = rms(in, direction);
        if direction == 0
            m = sqrt(mean_omitNaNs(in(:).^2));
        else
            m = sqrt(mean_omitNaNs(in.^2, direction));
        end
        infinityProblem = any(abs(in(:))==inf); % nan ok

    case {'scalermslimit'}
        m = rms(in, direction);
        m = max(m, max(m)/1000);

    case {'scalesum2'}
        % Can't sensibly NaN-proof this
        if direction == 0
            m = sqrt(sum(in(:).^2));
        else
            m = sqrt(sum(in.^2, direction));
        end

    case {'scalesum'}
        if any(in(:)<0), warning('Negative values in scalesum!!!'); end
        if direction > 0
            m = sum(in, direction);
        else
            m = sum(in(:));
        end

    case {'scalesum2limit'}
        m = sqrt(sum(in.^2, direction));
        m = max(m, max(m)/1000);
        
    case {'nothing','nop'}
        out = in;
        return;
        
    otherwise
        error(['Unsupported action "' something '"... implement it!'])
end

% Prepare for pointwise calculation
m = matchsize(m, in);

% Then apply it in the appropriate way
switch (lower(something))
    
    case {'max', 'mean', 'median'} % additive
        
        out = in - m;
        
    case {'scale','var', 'scalerms','scalesum2', 'scalermslimit', 'scalesum2limit','scalesum'} % multiplicative
        
        out = in ./m;
        
    otherwise
        error 'Uh-oh.  Only half-supported action?'
end

% return out

if infinityProblem
    warning('Potentially problematic non-finite values in input... results may be weird.')
%    keyboard
end
