function fig = gui_fl_extract_matrix()
% This is the machine-generated representation of a MATLAB object
% and its children.  Note that handle values may change when these
% objects are re-created. This may cause problems with some callbacks.
% The command syntax may be supported in the future, but is currently 
% incomplete and subject to change.
%
% To re-open this system, just type the name of the m-file at the MATLAB
% prompt. The M-file and its associtated MAT-file must be on your path.

% Modified by Christian Choque Cortez, February 2009

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a = figure( 'Name','Matrix Extraction','Tag','Fig_gui_fl_extract_matrix',...
    'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 80 300 250]);

%%%%%%%%%%%%%%%%%%% CREATE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','frame','Tag','Frame_title', ...
	'Units','normalized','Position',[0.02 0.84 0.96 0.14]);

uicontrol('Parent',a,'Style','frame','Tag','Frame_input', ...
	'Units','normalized','Position',[0.02 0.15 0.96 0.67]);    

%%%%%%%%%%%%%%%%%%% TITLE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_title', ...
	'Units','normalized','Position',[0.1 0.87 0.8 0.07], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.7, ...
	'String','Matrix Extraction');

%%%%%%%%%%%%%%% INPUT/OUTPUT SIGNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_input', ...
	'Units','normalized','Position',[0.05 0.7 0.22 0.07], ...
	'FontUnits','normalized','FontSize',0.7, ...
	'String','Input matrix');

uicontrol('Parent',a,'Style','edit','Tag','EditText_input', ...
	'Units','normalized','Position',[0.31 0.71 0.45 0.07], ...
	'FontUnits','normalized','FontSize',0.7);

uicontrol('Parent',a,'Tag','Button_refresh_in', ...
	'Units','normalized','Position',[0.79 0.71 0.16 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Refresh', ...
    'Callback','fl_create_structures(''get_input_name'')');

uicontrol('Parent',a,'Style','text','Tag','StaticText_output', ...
	'Units','normalized','Position',[0.05 0.59 0.25 0.07], ...
	'FontUnits','normalized','FontSize',0.7, ...
	'String','Output matrix');

uicontrol('Parent',a,'Tag','EditText_output', ...
	'Units','normalized','Position',[0.31 0.6 0.45 0.07], ...
	'FontUnits','normalized','FontSize',0.7, ...
	'Style','edit');

uicontrol('Parent',a,'Tag','Button_refresh_out', ...
	'Units','normalized','Position',[0.79 0.6 0.16 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Refresh', ...
    'Callback','fl_create_structures(''get_output_name'')');

%%%%%%%%%%%%%%%%%%%% GLOBAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','radiobutton','Tag','RadioButton_numerical', ...
    'Units','normalized','Position',[0.05 0.48 0.26 0.08], ...
    'FontUnits','normalized','FontSize',0.6, ...
    'String','Numerical', ...
    'Value',1, ...
    'Callback','fl_create_structures(''numerical_option'')');

uicontrol('Parent',a,'Style','radiobutton','Tag','RadioButton_graphical', ...
    'Units','normalized','Position',[0.35 0.48 0.26 0.08], ...
    'FontUnits','normalized','FontSize',0.6, ...
    'String','Graphical', ...
    'Value',0,...
    'Callback','fl_create_structures(''graphical_option'')');

uicontrol('Parent',a,'Style','text','Tag','StaticText_first', ...
	'Units','normalized','Position',[0.39 0.4 0.1 0.07], ...
	'FontUnits','normalized','FontSize',0.7, ...
	'String','first');

uicontrol('Parent',a,'Style','text','Tag','StaticText_last', ...
	'Units','normalized','Position',[0.66 0.4 0.1 0.07], ...
	'FontUnits','normalized','FontSize',0.7, ...
	'String','last');

uicontrol('Parent',a,'Style','text','Tag','StaticText_lines', ...
	'Units','normalized','Position',[0.07 0.32 0.25 0.07], ...
	'FontUnits','normalized','FontSize',0.7, ...
	'String','lines');

uicontrol('Parent',a,'Style','text','Tag','StaticText_rows', ...
	'Units','normalized','Position',[0.07 0.21 0.25 0.07], ...
	'FontUnits','normalized','FontSize',0.7, ...
	'String','rows');

uicontrol('Parent',a,'Style','edit','Tag','EditText_firstline', ...
	'Units','normalized','Position',[0.36 0.33 0.16 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','1', ...
    'Callback','fl_create_structures(''edit_firstline'')');

uicontrol('Parent',a,'Style','edit','Tag','EditText_lastline', ...
	'Units','normalized','Position',[0.63 0.33 0.16 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'Callback','fl_create_structures(''edit_lastline'')');
    
uicontrol('Parent',a,'Style','edit','Tag','EditText_firstrow', ...
    'Units','normalized','Position',[ 0.36 0.22 0.16 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','1', ...
	'Callback','fl_create_structures(''edit_firstrow'')');

uicontrol('Parent',a,'Style','edit','Tag','EditText_lastrow', ...
	'Units','normalized','Position',[0.63 0.22 0.16 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'Callback','fl_create_structures(''edit_range_lastrow'')');
    
%%%%%%%%%%%%%%%%%%%%%% CREATE/CLOSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
uicontrol('Parent',a,'Tag','Button_create', ...
	'Units','normalized','Position',[0.1 0.01 0.3 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
	'String','Create', ...
	'Callback','fl_create_structures(''create_SUB_matrix'');');

uicontrol('Parent',a,'Tag','Button_close', ...
	'Units','normalized','Position',[0.6 0.01 0.3 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
	'String','Close', ...
	'Callback','fl_function(''close'')');
	
fl_window_init(a);

if nargout > 0, fig = a; end