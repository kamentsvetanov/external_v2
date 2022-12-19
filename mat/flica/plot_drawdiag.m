% PLOT_DRAWDIAG(WHERE, TYPE, varargin)
% Superimpose some lines on a plot.
%   TYPE:
%       diag (draw diagonal: default, ignores where)
%       vert (draw vertical line at where)
%       horz (draw horizontal line at where)
%       -- Also, append linestyle to this.  eg diagm = magenta diag line

function plot_drawdiag(where, type, varargin)


if nargin<1
    where = 0;
    type = 'diag';
elseif ischar(where) && nargin < 2
    type = where;
    where = 0;
elseif ischar(where)
    where = str2double(where);
elseif numel(where)>1
    for i = 1:numel(where)
        plot_drawdiag(where(i),type);
    end
    return
end

% else should have two arguments

washold = ishold;

if ~ischar(type) || length(type)<4
    error(['First parameter must be a line type!'])
end

if length(type)>4
    look = type(5:end);
else
    look = ':k';
end

switch type(1:4)
    case 'diag'

    aorig = axis;
    asmall = [max(aorig([1 3])) min(aorig([2 4]))]; % don't expand the image at all

    hold on
%    plot(a, a, look);
    for i = 1:numel(where)
        plot(asmall,asmall+where(i), look, varargin{:});
    end
    % why? axis([asmall asmall])
    axis(aorig)
   
    case 'axes'
        a = axis;
        hold on
        %plot([a(1:2) 0 0 0], [0 0 0 a(3:4)], look)
        for w = where(:)'
            plot([a(1:2) w w w], [w w w a(3:4)], look, varargin{:})
        end
        
    case 'vert'
        a = axis;
        %if isequal(get(gca, 'YScale'), 'log')
        % Broken -- changes axis to include eps!
        %    if a(3)==0,
        %        a(3)=eps;
        %    elseif a(4)==0
        %        a(4)=-eps;
        %    else
        %        disp(a)
        %    end
        %end
        hold on
        for w = where(:)'
            plot([w w], a(3:4), look, varargin{:})
        end
        
        axis(a);
        
    case 'horz'
        a = axis;
        if isequal('log',get(gca, 'XScale'))
            a(1) = 1; % Just a guess!
        end
        hold on
%        if length(type)>4
%            look = type(5:end);
%        else
%            look = ':r';
%        end
        plot(a(1:2), [1 1]*where, look, varargin{:})
        % should loop over multiple wheres
    
    otherwise
        error 'Unrecognized line type!'
    
end

if ~washold
    hold off;
end