function gui_fl_graphplot()
% This is the machine-generated representation of a MATLAB object
% and its children.  Note that handle values may change when these
% objects are re-created. This may cause problems with some callbacks.
% The command syntax may be supported in the future, but is currently 
% incomplete and subject to change.
%
% To re-open this system, just type the name of the m-file at the MATLAB
% prompt. The M-file and its associtated MAT-file must be on your path.

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
              
a = figure('Position',[27 196 528 416], ...
        'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Tag','Fig_gui_fl_graphplot');

mat1 = [ 0         0    1.0000; ...
         0    0.5000         0; ...
    1.0000         0         0; ...
         0    0.7500    0.7500; ...
    0.7500         0    0.7500; ...
    0.7500    0.7500         0; ...
    0.2500    0.2500    0.2500]

b = axes('Parent',a, ...
	'FontUnits','normalized', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'ColorOrder',mat1, ...
	'FontSize',0.0426621, ...
	'Position',[0.104167 0.201923 0.844697 0.704327], ...
	'Tag','Axes_plot', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
c = text('Parent',b, ...
	'Color',[0 0 0], ...
	'HandleVisibility','callback', ...
	'HorizontalAlignment','center', ...
	'Position',[0.5 -0.0667808 0], ...
	'Tag','Text1', ...
	'VerticalAlignment','cap');
set(get(c,'Parent'),'XLabel',c);
c = text('Parent',b, ...
	'Color',[0 0 0], ...
	'HandleVisibility','callback', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.0595506 0.501712 0], ...
	'Rotation',90, ...
	'Tag','Text2', ...
	'VerticalAlignment','baseline');
set(get(c,'Parent'),'YLabel',c);
c = text('Parent',b, ...
	'Color',[0 0 0], ...
	'HandleVisibility','callback', ...
	'HorizontalAlignment','right', ...
	'Position',[-0.124719 1.13527 0], ...
	'Tag','Text3', ...
	'Visible','off');
set(get(c,'Parent'),'ZLabel',c);
c = text('Parent',b, ...
	'Color',[0 0 0], ...
	'HandleVisibility','callback', ...
	'HorizontalAlignment','center', ...
	'Position',[0.5 1.02568 0], ...
	'Tag','Text4', ...
	'VerticalAlignment','bottom');
set(get(c,'Parent'),'Title',c);
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','close(gcf);', ...
	'FontSize',0.326797333333333, ...
	'FontWeight','bold', ...
	'Position',[0.426136 0.00721154 0.208333 0.0985577], ...
	'String','Close', ...
	'Tag','Pushbutton_close');

fl_window_init(a);