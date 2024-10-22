function fig = gui_fl_dwt2d()
% This is the machine-generated representation of a MATLAB object
% and its children.  Note that handle values may change when these
% objects are re-created. This may cause problems with some callbacks.
% The command syntax may be supported in the future, but is currently 
% incomplete and subject to change.
%
% To re-open this system, just type the name of the m-file at the MATLAB
% prompt. The M-file and its associtated MAT-file must be on your path. 

% Modified by Christian Choque Cortez, May 2010

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a = figure( 'Name','Discrete Wavelet Transform 2D','Tag','Fig_gui_fl_dwt2d',...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 50 320 290]);

%%%%%%%%%%%%%%%%%%% CREATE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','frame','Tag','Frame_title', ...
	'Units','normalized','Position',[0.04 0.85 0.92 0.11]);

uicontrol('Parent',a,'Style','frame','Tag','Frame_input', ...
	'Units','normalized','Position',[0.04 0.66 0.92 0.15]);

uicontrol('Parent',a,'Style','frame','Tag','Frame_parameters', ...
	'Units','normalized','Position',[0.04 0.22 0.92 0.4]);

%%%%%%%%%%%%%%%%%%% TITLE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_title', ...
	'Units','normalized','Position',[0.21 0.86 0.6 0.07], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.6, ...
	'String','Discrete Wavelet Transform 2D');

%%%%%%%%%%%%%%%%%%% INPUT SIGNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_input', ...
	'Units','normalized','Position',[0.06 0.67 0.25 0.07], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.6, ...
	'String','Input signal','HorizontalAlignment','left');

uicontrol('Parent',a,'Style','edit','Tag','EditText_input', ...
	'Units','normalized','Position',[0.3 0.69 0.42 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','', ...
	'Enable','inactive');

uicontrol('Parent',a,'Tag','Button_refresh', ...
	'Units','normalized','Position',[0.76 0.68 0.175 0.1], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
	'String','Refresh', ...
    'Callback','fl_dwt2d_compute(''refresh'')');

%%%%%%%%%%%%%%%%%%%% GLOBAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_octaves', ...
	'Units','normalized','Position',[0.2 0.5 0.3 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','# octaves','HorizontalAlignment','left');

uicontrol('Parent',a,'Style','edit','Tag','EditText_octaves', ...
	'Units','normalized','Position',[0.55 0.52 0.15 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','10', ...
    'Callback','fl_dwt2d_compute(''edit_octaves'')');

uicontrol('Parent',a,'Style','text','Tag','StaticText_wavelet', ...
	'Units','normalized','Position',[0.2 0.37 0.17 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Wavelet','HorizontalAlignment','left');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_wavelet', ...
	'Units','normalized','Position',[0.45 0.39 0.4 0.07], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String',{'Daubechies 2','Daubechies 4','Daubechies 6','Daubechies 8', ...
              'Daubechies 10','Daubechies 12','Daubechies 14','Daubechies 16', ...
              'Daubechies 18','Daubechies 20','Coiflet 6','Coiflet 12','Coiflet 18','Coiflet 24'}, ...
	'Value',5);

uicontrol('Parent',a,'Style','checkbox','Tag','Check_modulus', ...
    'Units','normalized','Position',[0.2 0.25 0.4 0.07], ...
    'FontUnits','normalized','FontSize',0.6, ... 
    'String','Compute modulus', ...
    'Value',0);

%%%%%%%%%%%%%%%%%%%% COMPUTE/HELP/CLOSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Tag','Button_compute', ...
    'Units','normalized','Position',[0.046 0.07 0.23 0.11], ...
    'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Compute', ...
    'Callback','eval([''global '' fl_dwt2d_compute(''compute'',who)])');

uicontrol('Parent',a,'Tag','Button_help', ...
    'Units','normalized','Position',[0.4 0.07 0.23 0.11], ...
    'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Help', ...
    'Callback','fl_dwt2d_compute(''help'')');

uicontrol('Parent',a,'Tag','Button_close', ...
    'Units','normalized','Position',[0.73 0.07 0.23 0.11], ...
    'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ... 
    'String','Close', ...
    'Callback','fl_dwt2d_compute(''close'')');
	
fl_window_init(a);	

if nargout > 0, fig = a; end

fl_dwt2d_compute('refresh');
