function fig = gui_axes()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

% Modified by Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a = figure('Name','Axes Control','Tag','gui_axes_control_panel', ...
	'HandleVisibility','callback','MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[280 50 300 400]);

get(findobj('Tag','gui_axes_control_panel'),'Name');

%%%%%%%%%%%%%%%%%%%% TITLE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','frame','Tag','Frame1', ...
	'Units','normalized','Position',[0.0298754 0.898052 0.947755 0.0884558], ...
	'FontUnits','normalized','FontSize',0.339152435453639);

uicontrol('Parent',a,'Style','text','Tag','StaticText6', ...
	'Units','normalized','Position',[0.142762 0.920001 0.726625 0.04], ...
	'FontUnits','normalized','FontSize',0.75,'FontWeight','bold', ...
	'String','Axes Control Panel');

%%%%%%%%%%%%%%%%%%%% FIGURE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
uicontrol('Parent',a,'Style','frame','Tag','Frame_cFigure', ...
	'Units','normalized','Position',[0.0298754 0.791251 0.947755 0.1], ...
	'FontUnits','normalized','FontSize',0.3);

uicontrol('Parent',a,'Style','text','Tag','StaticText_cFigure', ...
	'Units','normalized','Position',[0.13 0.81425 0.25 0.05], ...
	'FontUnits','normalized','FontSize',0.6,'FontWeight','bold', ...
	'HorizontalAlignment','center','String','plot');

uicontrol('Parent',a,'Style','edit','Tag','EditText_figName', ...
	'Units','normalized','Position',[0.39 0.815 0.4 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'HorizontalAlignment','center','Enable','inactive');

%%%%%%%%%%%%%%%%%%%% PARAMS FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','frame','Tag','Frame_params', ...
	'Units','normalized','Position',[0.0298754 0.11 0.947755 0.675], ...
	'FontUnits','normalized','FontSize',0.0444444444444444);

% scale    
uicontrol('Parent',a,'Style','frame','Tag','Frame_scale', ...
    'Units','normalized','Position',[0.04632082986976951 0.65 0.9131944444444448 0.125], ...
	'FontUnits','normalized','FontSize',0.24);

uicontrol('Parent',a,'Style','text','Tag','StaticText_scale', ...
	'Units','normalized','Position',[0.3790523690773067 0.735 0.2 0.035], ...
	'FontUnits','normalized','FontSize',0.857142857142857,'FontWeight','bold', ...
	'String','Scale');

uicontrol('Parent',a,'Style','text','Tag','StaticText_scaletype', ...
	'Units','normalized','Position',[0.2 0.675 0.14 0.042], ...
	'FontUnits','normalized','FontSize',0.714285714285714, ...
	'String','type');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_scale', ...
	'Units','normalized','Position',[0.4 0.675 0.34375 0.045], ...
	'FontUnits','normalized','FontSize',0.666666666666667, ...
	'Max',4,'Min',1, ...
	'String',{'linear','semilog X','semilog Y', 'LogLog'},'Value',1, ...
    'Callback','fl_axes(''ppm_scale'');');

% range    
uicontrol('Parent',a,'Style','frame','Tag','Frame_range', ...
	'Units','normalized','Position',[0.04632082986976951 0.435 0.9131944444444448 0.21], ...
	'FontUnits','normalized','FontSize',0.142857142857143);

uicontrol('Parent',a,'Style','text','Tag','StaticText_range', ...
	'Units','normalized','Position',[0.3819 0.595 0.2 0.038], ...
	'FontUnits','normalized','FontSize',0.789473684210526,'FontWeight','bold', ...
	'String','Range');

uicontrol('Parent',a,'Style','edit','Tag','EditText_Xmin', ...
	'Units','normalized','Position',[0.36 0.505 0.16 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','0', ...
    'Callback','fl_axes(''edit_range_Xmin'');');

uicontrol('Parent',a,'Style','edit','Tag','EditText_Xmax', ...
	'Units','normalized','Position',[0.63 0.505 0.16 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','1', ...
	'Callback','fl_axes(''edit_range_Xmax'');');
    
uicontrol('Parent',a,'Style','edit','Tag','EditText_Ymin', ...
    'Units','normalized','Position',[ 0.36 0.45 0.16    0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','3', ...
    'Callback','fl_axes(''edit_range_Ymin'');');
    
uicontrol('Parent',a,'Style','edit','Tag','EditText_Ymax', ...
	'Units','normalized','Position',[0.63 0.45 0.16 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','4', ...
	'Callback','fl_axes(''edit_range_Ymax'');');
    
uicontrol('Parent',a,'Style','text','Tag','StaticText_min', ...
	'Units','normalized','Position',[0.3431 0.56 0.2 0.035], ...
	'FontUnits','normalized','FontSize',0.857142857142857, ...
	'String','min');

uicontrol('Parent',a,'Style','text','Tag','StaticText_max', ...
	'Units','normalized','Position',[0.6161 0.56 0.2 0.035], ...
	'FontUnits','normalized','FontSize',0.857142857142857, ...
	'String','max');

uicontrol('Parent',a,'Style','text','Tag','StaticText_X', ...
	'Units','normalized','Position',[0.07 0.5 0.25 0.05], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','X range');

uicontrol('Parent',a,'Style','text','Tag','StaticText_Y', ...
	'Units','normalized','Position',[0.07 0.445 0.25 0.0504], ...
	'FontUnits','normalized','FontSize',0.595238095238095, ...
	'String','Y range');

%%%%%%%%%%%%%%%%%%%% ASPECT FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','frame','Tag','Frame_aspect', ...
	'Units','normalized','Position',[0.04632082986976951 0.12 0.9131944444444448 0.31], ...
	'FontUnits','normalized','FontSize',0.0967741935483871);

uicontrol('Parent',a,'Style','text','Tag','StaticText_aspect', ...
	'Units','normalized','Position',[0.3819 0.375 0.2292 0.04], ...
	'FontUnits','normalized','FontSize',0.75,'FontWeight','bold', ...
	'String','Aspect');

uicontrol('Parent',a,'Style','text','Tag','StaticText_mark', ...
	'Units','normalized','Position',[0.055 0.32 0.11 0.04], ...
	'FontUnits','normalized','FontSize',0.75, ...
	'String','mark');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_mark', ...
	'Units','normalized','Position',[0.19 0.325 0.3 0.045], ...
	'FontUnits','normalized','FontSize',0.555555555555556, ...
	'Max',14,'Min',1, ...
	'String',{'none','. point','o circle','x x-mark','+ plus',...
	'* star','s square', 'd diamond', ...
	'v triangle','^ triangle','< triangle','> triangle',...
	'p pentagram','h hexagram'}, ...
	'Value',1, ...
    'Callback','fl_axes(''ppm_mark'');');

uicontrol('Parent',a,'Style','text','Tag','StaticText_line', ...
	'Units','normalized','Position',[0.5 0.32 0.11 0.04], ...
	'FontUnits','normalized','FontSize',0.75, ...
	'String','line');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_line', ...
	'Units','normalized','Position',[0.635 0.325 0.29 0.045], ...
	'FontUnits','normalized','FontSize',0.611111111111111, ...
	'Max',5,'Min',1, ...
	'String',{'- solid',': dotted','-. dashdot','-- dashed','none'}, ...
	'Value',1, ...
    'Callback','fl_axes(''ppm_line'');');

uicontrol('Parent',a,'Style','text','Tag','StaticText_color', ...
	'Units','normalized','Position',[0.055 0.25 0.11 0.045], ...
	'FontUnits','normalized','FontSize',0.666666666666667, ...
	'String','color');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_color', ...
	'Units','normalized','Position',[0.19 0.255 0.34375 0.045], ...
	'FontUnits','normalized','FontSize',0.666666666666667, ...
	'Max',8,'Min',1, ...
	'String',{'yellow','magenta','cyan', 'red','green','blue','white','black'}, ...
	'Value',6, ...
    'Callback','fl_axes(''ppm_color'');');

uicontrol('Parent',a,'Style','text','Tag','StaticText_width', ...
	'Units','normalized','Position',[0.595 0.25 0.14 0.043], ...
	'FontUnits','normalized','FontSize',0.697674418604651, ...
	'String','width');

uicontrol('Parent',a,'Style','edit','Tag','EditText_width', ...
    'Units','normalized','Position',[ 0.75 0.245 0.175 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','0.5', ...
    'Callback','fl_axes(''edit_width'');');

uicontrol('Parent',a,'Style','text','Tag','StaticText_red', ...
	'Units','normalized','Position',[0.17 0.185 0.16 0.045], ...
	'FontUnits','normalized','FontSize',0.666666666666667, ...
	'String','red');

uicontrol('Parent',a,'Style','text','Tag','StaticText_green', ...
	'Units','normalized','Position',[0.4 0.185 0.2 0.045], ...
	'FontUnits','normalized','FontSize',0.666666666666667, ...
	'String','green');

uicontrol('Parent',a,'Style','text','Tag','StaticText_blue', ...
	'Units','normalized','Position',[0.67 0.185 0.16 0.045], ...
	'FontUnits','normalized','FontSize',0.666666666666667, ...
	'String','blue');

uicontrol('Parent',a,'Style','edit','Tag','EditText_red', ...
    'Units','normalized','Position',[ 0.17 0.135 0.16 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','0', ...
    'Callback','fl_axes(''edit_red'');');

uicontrol('Parent',a,'Style','edit','Tag','EditText_green', ...
	'Units','normalized','Position',[0.42 0.135 0.16 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','0', ...
    'Callback','fl_axes(''edit_green'');');

uicontrol('Parent',a,'Style','edit','Tag','EditText_blue', ...
	'Units','normalized','Position',[0.67 0.135 0.16 0.05],'BackgroundColor',[1 1 1], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','1', ...
    'Callback','fl_axes(''edit_blue'');');
    
%%%%%%%%%%%%%%%%%%%% BUTTONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Tag','button_apply', ...
	'Units','normalized','Position',[0.1 0.02 0.25 0.08], ...
	'FontUnits','normalized','FontSize',0.375,'FontWeight','bold', ...
	'String','Apply', ...
    'Callback','fl_axes(''apply'');');

uicontrol('Parent',a,'Tag','button_close', ...
	'Units','normalized','Position',[0.65 0.02 0.25 0.08], ...
	'FontUnits','normalized','FontSize',0.375,'FontWeight','bold', ...
	'String','Close', ...
    'Callback','fl_axes(''close'');');

fl_window_init(a);    
    
if nargout > 0, fig = a; end