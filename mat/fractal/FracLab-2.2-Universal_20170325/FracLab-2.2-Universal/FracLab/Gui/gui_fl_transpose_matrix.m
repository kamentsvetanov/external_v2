function gui_fl_transpose_matrix()
% No help found

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a = figure('Units','pixels', ...
	'HandleVisibility','callback', ...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 80 300 140], ...
	'Tag','Transpose matrix');
    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.342857142857143, ...
	'ListboxTop',0, ...
	'Position',[0.02 0.72 0.96 0.27], ...
	'Style','frame', ...
	'Tag','Frame1');    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.779220779220779, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','center', ...
	'Position',[0.1 0.78 0.8 0.11], ...
	'String','Transpose Matrix', ...
	'Style','text', ...
	'Tag','StaticText');
    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.168067226890756, ...
	'ListboxTop',0, ...
	'Position',[0.02 0.25 0.96 0.44], ...
	'Style','frame', ...
	'Tag','Frame2');    
    
    % matrix
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.714285714285714, ...
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.4 0.18 0.12], ...
	'String','Matrix', ...
	'Style','text', ...
	'Tag','StaticText1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.7, ...
	'Position',[0.25 0.4 0.49 0.13], ...
	'Style','edit', ...
	'Tag','Text_transpose_matrix');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_transpose_matrix(''refresh'');', ...
	'FontSize',0.7, ...
	'Position',[0.79 0.4 0.16 0.13], ...
	'String','Refresh', ...
	'Tag','Pushbutton1');
   
    % general
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_function(''close'');', ...
	'FontSize',0.499999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.6 0.02 0.3 0.18], ...
	'String','Close', ...
	'Tag','Pushbutton_close');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_transpose_matrix(''transpose'',who);]);', ...
	'FontSize',0.499999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.1 0.02 0.3 0.18], ...
	'String','Transpose', ...
	'Tag','Pushbutton_Create');

fl_window_init(a);