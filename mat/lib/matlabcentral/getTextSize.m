function textSize = getTextSize(limits,orientation,hAx)
% Determine the size of text in data units.  This value is dependent on
% font size, axes data limits and the size of the axes on screen. 

% Notes:
% - There doesn't appear to be a problem with the value returned for
%   'Extent' if the text object is located outside of the axes limits.  
% - 'Extent' does not appear to change when the axes scale is set to 'log'.
% - Requires a valid axes handle.
% - 'Extent' is not valid for 3D views.

% Get axes properties
s = get(hAx);

% Get text size in data units
hTest = text(1,1,'2','Units','data','FontUnits',s.FontUnits,...
    'FontAngle',s.FontAngle,'FontName',s.FontName,'FontSize',s.FontSize,...
    'FontWeight',s.FontWeight,'Parent',hAx);
textExt = get(hTest,'Extent');
delete(hTest)
textHeight = textExt(4);
textWidth = textExt(3);

% If using a proportional font, shrink text width by a fudge factor to
% account for kerning.
if ~strcmpi(s.FontName,'FixedWidth')
    textWidth = textWidth*0.8;
end

% Restore axes limits and set output
if strcmp(orientation,'h')
    textSize = textWidth*(limits(2)-limits(1))/(s.XLim(2)-s.XLim(1));
else
    textSize = textHeight*(limits(2)-limits(1))/(s.YLim(2)-s.YLim(1));
end    

end % End of calcticks/getTextSize