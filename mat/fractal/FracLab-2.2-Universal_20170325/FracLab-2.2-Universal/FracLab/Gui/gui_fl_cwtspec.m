function gui_fl_cwtspec()
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

a = figure('HandleVisibility','callback', ...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 50 300 250], ...
	'Name','cwt-based Spectrum','Tag','Fig_gui_fl_cwtspec');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_cwtspec_compute(''advanced_compute'') ;', ...
	'FontSize',0.399999999999999, ...
	'Position',[0.246667 0.416 0.466667 0.12], ...
	'String','Advanced compute', ...
	'Tag','Pushbutton_cwtspec_advanced');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_cwtspec_compute(''compute'',who)]) ;', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.0633333 0.216 0.233333 0.12], ...
	'String','Compute', ...
	'Tag','Pushbutton_cwtspec_compute');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_cwtspec_compute(''help'')', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.363333 0.216 0.233333 0.12], ...
	'String','Help', ...
	'Tag','Pushbutton1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_cwtspec_compute(''close'')', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.663333 0.216 0.233333 0.12], ...
	'String','Close', ...
	'Tag','Pushbutton_cwtspec_close');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.231883999999999, ...
	'FontWeight','bold', ...
	'Position',[0.0586797 0.686364 0.855747 0.236364], ...
	'Style','frame', ...
	'Tag','Frame1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.499999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.102689 0.740908 0.748167 0.0909092], ...
	'String','CWT Based Legendre Spectrum', ...
	'Style','text', ...
	'Tag','StaticText1');


fl_window_init(a);