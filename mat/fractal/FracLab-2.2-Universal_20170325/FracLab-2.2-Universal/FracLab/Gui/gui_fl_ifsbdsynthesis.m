function fig = gui_fl_ifsbdsynthesis()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

% Author Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a = figure( 'Name','ifsb Synthesis - deterministic','Tag','Fig_gui_fl_ifsbdsynthesis',...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 50 350 270]);

%%%%%%%%%%%%%%%%%%% CREATE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','frame','Tag','Frame_title', ...
	'Units','normalized','Position',[0.023 0.83 0.96 0.12]);

uicontrol('Parent',a,'Style','frame','Tag','Frame_input', ...
	'Units','normalized','Position',[0.023 0.17 0.96 0.64]);

%%%%%%%%%%%%%%%%%%% TITLE FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_title', ...
	'Units','normalized','Position',[0.06 0.84 0.9 0.08], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.6, ...
	'String','Iterated Function System based');

%%%%%%%%%%%%%%%%%%%% GLOBAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Style','text','Tag','StaticText_interpoints1', ...
	'Units','normalized','Position',[0.04 0.68 0.75 0.075], ...
	'FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left', ...
	'String','Interpolation points [X1 Y1;X2 Y2;...;Xk Yk]');

uicontrol('Parent',a,'Style','edit','Tag','EditText_point', ...
	'Units','normalized','Position',[0.3 0.6 0.66 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','[0 0;0.5 1;1 0]', ...
    'Callback','fl_ifsbdsynthesis_compute(''edit_interpoint'')');

uicontrol('Parent',a,'Style','checkbox','Tag','Checkbox_law', ...
	'Units','normalized','Position',[0.3 0.5 0.44 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','Affine interpolation', ...
    'Value',0, ...
    'Callback','fl_ifsbdsynthesis_compute(''check_law'')');

uicontrol('Parent',a,'Style','text','Tag','StaticText_contraction1', ...
	'Units','normalized','Position',[0.04 0.4 0.75 0.075], ...
	'FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left', ...
	'String','Contraction coefs [C1;C2;...;Ck-1]');

uicontrol('Parent',a,'Style','edit','Tag','EditText_contraction', ...
	'Units','normalized','Position',[0.3 0.32 0.66 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','[0.5;-0.9]', ...
    'Callback','fl_ifsbdsynthesis_compute(''edit_contraction'')');

uicontrol('Parent',a,'Style','text','Tag','StaticText_sample', ...
	'Units','normalized','Position',[0.04 0.18 0.25 0.075], ...
	'FontUnits','normalized','FontSize',0.6,'HorizontalAlignment','left', ...
	'String','Sample Size');

uicontrol('Parent',a,'Style','popupmenu','Tag','PopupMenu_sample', ...
	'Units','normalized','Position',[0.4 0.21 0.3 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String',{'8 points','16 points','32 points','64 points','128 points',...
              '256 points','512 points','1024 points','2048 points', ...
              '4096 points','8192 points','16384 points'}, ...
	'Value',8, ...
    'Callback','fl_ifsbdsynthesis_compute(''popmenu_sample'')');

uicontrol('Parent',a,'Style','edit','Tag','EditText_sample', ...
	'Units','normalized','Position',[0.81 0.2 0.15 0.075], ...
	'FontUnits','normalized','FontSize',0.6, ...
	'String','1024', ...
    'Callback','fl_ifsbdsynthesis_compute(''edit_sample'')');

%%%%%%%%%%%%%%%%%%%% COMPUTE/HELP/CLOSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol('Parent',a,'Tag','Button_compute', ...
	'Units','normalized','Position',[0.025 0.02 0.23 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Compute', ...
    'Callback','eval([''global '' fl_ifsbdsynthesis_compute(''compute'',who)])');

uicontrol('Parent',a,'Tag','Button_help', ...
	'Units','normalized','Position',[0.4 0.02 0.23 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Help', ...
	'Callback','fl_ifsbdsynthesis_compute(''help'')');

uicontrol('Parent',a,'Tag','Button_close', ...
	'Units','normalized','Position',[0.75 0.02 0.23 0.12], ...
	'FontUnits','normalized','FontWeight','bold','FontSize',0.4, ...
    'String','Close', ...
	'Callback','fl_ifsbdsynthesis_compute(''close'')');

fl_window_init(a);	
	
if nargout > 0, fig = a; end