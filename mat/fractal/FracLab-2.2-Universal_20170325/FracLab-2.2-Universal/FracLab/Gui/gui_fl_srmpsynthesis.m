function fig = gui_fl_srmpsynthesis()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

% Authors Christian Choque Cortez & Antoine Echelard, June 2009

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a = figure( 'Name','srmp Synthesis - 1D','Tag','Fig_gui_fl_srmpsynthesis',...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 50 350 270]);

%%%%%%%%%%%%%%%%%%% CREATE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','frame','Tag','Frame_title', ...
	'Units','normalized','Position',[0.023 0.83 0.96 0.12]);

uicontrol('Parent',a,'Style','frame','Tag','Frame_input', ...
	'Units','normalized','Position',[0.023 0.178 0.96 0.63]);

%%%%%%%%%%%%%%%%%%% TITLE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_title', ...
	'Units','normalized','Position',[0.1 0.84 0.8 0.08], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.6, ...
	'String','Self-Regulating Multifractional Process 1D');

%%%%%%%%%%%%%%%%%%%% GLOBAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','radiobutton','Tag','RadioButton_fbmbased', ...
    'Units','normalized','Position',[0.045 0.7 0.26 0.075], ...
    'FontUnits','normalized','FontSize',0.6, ...
    'String','Fbm based', ...
    'Value',1, ...
    'Callback','fl_srmpsynthesis_compute(''fbmbased_option'');');

uicontrol('Parent',a,'Style','radiobutton','Tag','RadioButton_midpoint', ...
    'Units','normalized','Position',[0.32 0.7 0.44 0.075], ...
    'FontUnits','normalized','FontSize',0.6, ...
    'String','Midpoint displacement', ...
    'Value',0, ...
    'Callback','fl_srmpsynthesis_compute(''midpoint_option'');');

uicontrol('Parent',a,'Style','text','Tag','StaticText_zfunction', ...
	'Units','normalized','Position',[0.03 0.59 0.23 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','g(Z) function');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_zfunction', ...
	'Units','normalized','Position',[0.61 0.61 0.35 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
    'String',{'1./(1+5*z.^2)','(1-z).^2','user defined'}, ...
	'Value',1, ...
    'Callback','fl_srmpsynthesis_compute(''popmenu_zfunction'')');

uicontrol('Parent',a,'Style','edit','Tag','EditText_zfunction', ...
	'Units','normalized','Position',[0.36 0.505 0.6 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','1./(1+5*z.^2)', ...
	'Callback','fl_srmpsynthesis_compute(''edit_zfunction'')');

uicontrol('Parent',a,'Style','text','Tag','StaticText_sample', ...
	'Units','normalized','Position',[0.045 0.38 0.21 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Sample Size');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_sample', ...
	'Units','normalized','Position',[0.36 0.405 0.3 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String',{'16 points', '32 points', '64 points', '128 points','256 points', ...
              '512 points', '1024 points', '2048 points', '4096 points', ...
              '8192 points','16384 points'}, ...
	'Value',8, ...
    'Callback','fl_srmpsynthesis_compute(''popmenu_sample'')');

uicontrol('Parent',a,'Style','edit','Tag','EditText_sample', ...
	'Units','normalized','Position',[0.81 0.395 0.15 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','2048', ...
    'Callback','fl_srmpsynthesis_compute(''edit_sample'')');

uicontrol('Parent',a,'Style','checkbox','Tag','Checkbox_prescription', ...
	'Units','normalized','Position',[0.05 0.29 0.36 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Prescribed shape', ...
    'Value',0, ...
    'Callback','fl_srmpsynthesis_compute(''check_shape'')');

uicontrol('Parent',a,'Style','edit','Tag','EditText_prescription', ...
	'Units','normalized','Position',[0.5 0.295 0.46 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','cos(2*pi*t)','Enable','off', ...
	'Callback','fl_srmpsynthesis_compute(''edit_prescription'')');
    
uicontrol('Parent',a,'Style','text','Tag','StaticText_mix', ...
	'Units','normalized','Position',[0.05 0.18 0.32 0.075],'Horizontalalignment','left', ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Mixing parameter','Enable','off');

uicontrol('Parent',a,'Style','edit','Tag','EditText_mix', ...
	'Units','normalized','Position',[0.36 0.2 0.15 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
    'String','2','Enable','off', ...
    'Callback','fl_srmpsynthesis_compute(''edit_mix'')');

uicontrol('Parent',a,'Style','text','Tag','StaticText_seed', ...
	'Units','normalized','Position',[0.53 0.18 0.25 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Random Seed');

uicontrol('Parent',a,'Style','edit','Tag','EditText_seed', ...
	'Units','normalized','Position',[0.81 0.2 0.15 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
    'Callback','fl_srmpsynthesis_compute(''edit_seed'')');

%%%%%%%%%%%%%%%%%%%% COMPUTE/HELP/CLOSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Tag','Button_compute', ...
	'Units','normalized','Position',[0.025 0.034 0.23 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Compute', ...
    'Callback','eval([''global '' fl_srmpsynthesis_compute(''compute'',who)])');

uicontrol('Parent',a,'Tag','Button_help', ...
	'Units','normalized','Position',[0.4 0.034 0.23 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Help', ...
	'Callback','fl_srmpsynthesis_compute(''help'')');

uicontrol('Parent',a,'Tag','Button_close', ...
	'Units','normalized','Position',[0.75 0.034 0.23 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Close', ...
	'Callback','fl_srmpsynthesis_compute(''close'')');

fl_window_init(a);	
	
if nargout > 0, fig = a; end
