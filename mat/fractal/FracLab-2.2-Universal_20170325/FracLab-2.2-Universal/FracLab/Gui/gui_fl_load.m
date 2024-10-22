function gui_fl_load()
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

a = figure('MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Name','Load file dialog', ...
	'Position',[20 50 400 500], ...
	'Tag','Fig_gui_fl_load');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.0362318666666666, ...
	'Position',[0.05 0.0775376 0.694156 0.845865], ...
	'Style','frame', ...
	'Tag','Frame_load_choose');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.0362318666666666, ...
	'Position',[0.75 0.0775376 0.189935 0.845865], ...
	'Style','frame', ...
	'Tag','Frame_fl_load_command');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_load_compute(''name_edit'');', ...
	'FontSize',0.520833333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.27 0.832707 0.355519 0.0413534], ...
	'String','No file selected', ...
	'Style','edit', ...
	'Tag','EditText_fl_load_name');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_load_compute(''name_choose'');', ...
	'FontSize',0.0585870666666665, ...
	'Position',[0.075 0.25188 0.34 0.43797], ...
	'String',[], ...
	'Style','listbox', ...
	'Tag','Listbox_fl_load_name', ...
	'Value',1);
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_load_compute(''dir_choose'');', ...
	'FontSize',0.0591562666666665, ...
	'Position',[0.427273 0.25 0.29 0.43797], ...
	'String',[], ...
	'Style','listbox', ...
	'Tag','Listbox_fl_load_dir', ...
	'Value',1);
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_load_compute(''dir_edit'');', ...
	'FontSize',0.462962666666665, ...
	'HorizontalAlignment','left', ...
	'Position',[0.302273 0.163534 0.277597 0.0488722], ...
	'String','.', ...
	'Style','edit', ...
	'Tag','EditText_fl_load_dir');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_load_compute(''filter'');', ...
	'FontSize',0.476190666666665, ...
	'HorizontalAlignment','left', ...
	'Position',[0.302273 0.112782 0.277597 0.0469925], ...
	'String','*', ...
	'Style','edit', ...
	'Tag','EditText_fl_load_filter');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.520833333333332, ...
	'Max',2, ...
	'Min',1, ...
	'Position',[0.27 0.753759 0.355 0.0413534], ...
	'String',{'image','mat file','ASCII'}, ...
	'Style','popupmenu', ...
	'Tag','PopupMenu_fl_load_type', ...
	'Value',1);
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.555555999999999, ...
	'Position',[0.107468 0.825188 0.0974026 0.037594], ...
	'String','Name :', ...
	'Style','text', ...
	'Tag','StaticText_fl_load_name');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.555555999999999, ...
	'Position',[0.138312 0.164474 0.162338 0.037594], ...
	'String','Directory :', ...
	'Style','text', ...
	'Tag','StaticText_lf_load_dir');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.555555999999999, ...
	'Position',[0.122078 0.114662 0.162338 0.037594], ...
	'String','Filter :', ...
	'Style','text', ...
	'Tag','StaticText_fl_load_filter');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_load_compute(''load'',who);], '' ;'');', ...
	'FontSize',0.308641333333333, ...
	'Enable','off', ...
	'FontWeight','bold', ...
	'Position',[0.770373 0.759398 0.15 0.0822368], ...
	'String','Load', ...
	'Tag','Pushbutton1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_load_compute(''filter'');', ...
	'CreateFcn','fl_load_compute(''filter'');', ...
	'FontSize',0.308641333333333, ...
	'FontWeight','bold', ...
	'Position',[0.770373 0.462406 0.15 0.0822368], ...
	'String','Filter', ...
	'Tag','Pushbutton2');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_load_compute(''close'');', ...
	'FontSize',0.308641333333333, ...
	'FontWeight','bold', ...
	'Position',[0.770373 0.197368 0.15 0.0822368], ...
	'String','Close', ...
	'Tag','Pushbutton3');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.555555999999999, ...
	'Position',[0.097208 0.744361 0.15 0.037594], ...
	'String','Load as :', ...
	'Style','text', ...
	'Tag','StaticText1');

fl_window_init(a);