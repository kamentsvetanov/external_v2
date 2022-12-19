% ASSERTEQUAL(X, Y1, Y2, Y3, ...)
%
% Causes an error unless all Yi == X.
% Note that NaN ~= NaN --- so assertequal(x) fails if x has any NaNs.
%
% As an edge base, when called with zero or one arguments, it will never
% throw an error (but will display a warning instead)
function assertequal(varargin)

if nargin<2
    disp 'assertequal: nothing to compare!'
    return
end

x = varargin{1};

for i = 1:length(varargin)
    y = varargin{i};
    if ~isequal(x, y)
%    if any(x ~= varargin{i}) % NO!! 
        x
        y
%        if isequal(x*0, y*0)
%            rx = rms(x)
%            ry = rms(y)
%            rd = rms(x-y)
%            disp('Same size but different. Error ratio:')
%            ratio = rd / max(rx,ry)
%            if ratio < 1e-10
%                warning 'Not identical, but close enough'
%                return
%            end
%        end
        error('Not identical in assertequal!')
%        keyboard
    end
end

