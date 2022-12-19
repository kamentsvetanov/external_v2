
% ASSERTALMOSTEQUAL(X, Y1, Y2, Y3, ...)
%
% Causes an error unless all Yi == X (within a very narrow tolerance)
% Note that NaN ~= NaN --- so assertequal(x) fails if x has any NaNs.
function assertalmostequal(varargin)

x = varargin{1};

for i = 1:length(varargin)
    y = varargin{i};
    if ~isequal(x, y)
%    if any(x ~= varargin{i}) % NO!! 
        if isequal(size(x), size(y))
            rx = rms(x);
            ry = rms(y);
            rd = rms(x-y);
            ratio = rd / max(rx,ry);
            if ratio < 1e-9
                return % silently without a warning
            end
            if ratio < 1e-7 && (isequal(class(x),'single') || isequal(class(y),'single'))
                %disp 'Not THAT close, but I''ll let that one slide because you''re single'
                return
            end
            disp('Same size but different. Error ratio:')
            ratio
            rx_ry_rd = [rx ry rd]
            if ratio < 1e-5
                warning 'Not identical, but close enough'
                %keyboard
                return
            end
            x
            y            
            if isnan(ratio)
                warning('Non-finite values found in assertalmostequal!')
            else
                warning('Not close in assertalmostequal!')
            end
            if ratio > 1e-2 % Okay, this is really serious now
                keyboard
            end
        else
            error('Not even comparable in assertequal!')
        end
    end
end

