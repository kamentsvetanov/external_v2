function [len, angle, dx, dy] = getlineinfo(varargin)
%GETLINEINFO  Get information (length, angle) of a segment
%   GETLINEINFO draws a line using the pointer, and displays the length and
%   angle of the segment in the figure. The angle is in degrees by default,
%   (zero angle for a horizontal line).
%
%   [LEN, ANGLE, DX, DY] = GETLINEINFO returns the results.
%
%   ... = GETLINEINFO(OPT) specifies the angle property: OPT = 'rad', 'deg'
%   or 'slope' (default is 'deg').  OPT = 'angle' shows only the angle.
%
%   Note: The Image Processing Toolbox is required.
%
%   See also GETSLOPE, SHOWSLOPE.

%   F. Moisy, moisy_at_fast.u-psud.fr
%   Revision: 1.10,  Date: 2009/03/25
%   This function is part of the EzyFit Toolbox

% History:
% 2009/03/24: v1.00, first version.
% 2009/03/25: v1.01, use getline instead of imline
% 2009/09/16: v1.02, new option 'angle'

if false  % method #1: using imline (v1.00)
    if ~exist('imline','file')
        error('The Image Processing Toolbox is required for this operation.');
    end

    try
        h = imline(gca,[]);
    catch
        error('Unselect the current selection.');
    end

    hline = get(h,'Children');
    x = get(hline(3),'XData');
    y = get(hline(3),'YData');

else % method #2: using getline (v1.10)
    if ~exist('getline','file')
        error('The Image Processing Toolbox is required for this operation.');
    end
    [x,y] = getline;
    x=x(1:2);
    y=y(1:2);
    oldhold = ishold;
    hold on
    plot(x,y,'k:');
    if oldhold==false
        hold off
    end
end

dx = x(2)-x(1);
dy = y(2)-y(1);
len = sqrt(dx^2 + dy^2);

if any(strcmpi(varargin,'rad'))
    angle = atan(dy/dx);
    txtangle = ['Angle = ' num2str(angle) ' rad'];
elseif any(strcmpi(varargin,'slope'))
    angle = dy/dx;
    txtangle = ['Slope = ' num2str(angle)];
else
    angle = atan(dy/dx)*180/pi;
    txtangle = ['Angle = ' num2str(angle) ' deg'];
end

if any(strcmpi(varargin,'angle'))
    txt=txtangle;
else
    txt={['(' num2str(dx) ', ' num2str(dy) ')'],...
        ['Length = ' num2str(len)], txtangle};
end

if nargout==0
    text((x(1)+x(2))/2, (y(1)+y(2))/2,txt);
    clear len angle dx dy
end
