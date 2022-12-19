% function PLOT_ANNOTATE(T, X, Y, STYLE)
% Sets title(t), xlabel(x), ylabel(y).
% Adjusts various plot parameters according to STYLE:
%   STYLE = false: use defaults
%   STYLE = true or missing: fontsize = 16, linewidth = 2.
%   STYLE = [font]: set fontsize = font, linewidth = 2.
%   STYLE = [font line]: set fontsize = font, linewidth = line.
%   STYLE = [titlefont line otherfont]: etc.
function plot_annotate(t, x, y, style, rots)

% Default values
if nargin<1, t = ''; end
if nargin<2, x = ''; end
if nargin<3, y = ''; end
if nargin<4, style = true; end
if nargin<5, rots = []; end

% Preprocess to avoid inadvertent subscripting

ispath = @(str) (~isempty(str) && ~any(str==' ') && ~any(str=='^') && ~any(str=='\'));
if ispath(t), t = nicer_pathnames(t); end
if ispath(x), x = nicer_pathnames(x); end
if ispath(y), y = nicer_pathnames(y); end

if isequal(style, true), style = [16]; end % title size
if isnumeric(style) && numel(style)==1, style(2) = 2; end % linewidth
if isnumeric(style) && numel(style)==2, style(3) = style(1) - 3; end % other elements size
if isnumeric(style) && numel(style)<4, style(4) = style(3); end


if isequal(style,false)
    title(t)
    xlabel(x)
    ylabel(y)
    
elseif isnumeric(style)
    assert(numel(style) == 4);
    
    set(gca,'fontsize',style(4));
    set(gca,'LineWidth',style(2));
    title(t,'fontsize',style(1))
    xlabel(x,'fontsize',style(3))
    ylabel(y,'fontsize',style(3))
    
else
    assert(false);
end

if length(strfind(rots,'y'))
    set(get(gca,'ylabel'),'rotation',0)
    set(get(gca,'ylabel'),'verticalalignment','middle')
    set(get(gca,'ylabel'),'horizontalalignment','right')
end

if length(strfind(rots,'t'))
    set(get(gca,'xlabel'),'verticalalignment','top')
end

