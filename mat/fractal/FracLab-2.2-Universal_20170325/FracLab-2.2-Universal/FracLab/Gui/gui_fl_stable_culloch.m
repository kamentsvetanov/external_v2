function gui_fl_stable_culloch()
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

a = figure( ...
	'Colormap',[], ...
	'HandleVisibility','callback', ...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 50 400 350], ...
	'Name','sp McCulloch Estimation','Tag','Fig_gui_fl_stable_culloch', ...
	'UserData',0.00390625);

    %'Name','McCulloch Method for Parameters Estimation', ...
    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.213333333333333, ...
	'Position',[0.0298754 0.898052 0.947755 0.0884558], ...
	'Style','frame', ...
	'Tag','Frame_gui_fl_stable_culloch');
    %'Position',[0.2375 0.73434 0.48393 0.185745], ...
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.902255639097745, ...
	'FontWeight','bold', ...
	'Position',[0.142762 0.920001 0.726625 0.038], ...
	'String','McCulloch Estimation', ...
	'Style','text', ...
	'Tag','StaticText_gui_fl_stable_culloch');
    %'Position',[0.28 0.797143 0.425 0.0542857], ...
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.103225866666666, ...
	'Position',[0.0298754 0.241901 0.947755 0.414286], ...
	'Style','frame', ...
	'Tag','Frame_gui_fl_stable_culloch_output');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.615383999999998, ...
	'FontWeight','bold', ...
	'Position',[0.42 0.578834 0.15 0.045], ...
	'String','Outputs', ...
	'Style','text', ...
	'Tag','StaticText_culloch_output_param_text');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'Position',[0.5475 0.53 0.175 0.0542857], ...
	'String','Value', ...
	'Style','text', ...
	'Tag','StaticText_culloch_output_param_text');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'Position',[0.735 0.53 0.175 0.0542857], ...
	'String','std', ...
	'Style','text', ...
	'Tag','StaticText_culloch_output_param_text');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'HorizontalAlignment','left', ...
	'Position',[0.0975 0.477143 0.375 0.0542857], ...
	'String','Characteristic Exponent', ...
	'Style','text', ...
	'Tag','StaticText_culloch_output_alpha_text');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'HorizontalAlignment','left', ...
	'Position',[0.0975 0.411429 0.375 0.0542857], ...
	'String','Skewness Parameter', ...
	'Style','text', ...
	'Tag','StaticText_culloch_output_beta_text');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'HorizontalAlignment','left', ...
	'Position',[0.0975 0.345714 0.375 0.0542857], ...
	'String','Location Parameter', ...
	'Style','text', ...
	'Tag','StaticText_culloch_output_mu_text');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'HorizontalAlignment','left', ...
	'Position',[0.0975 0.28 0.375 0.0542857], ...
	'String','Scale Parameter', ...
	'Style','text', ...
	'Tag','StaticText_culloch_output_gamma_text');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.5475 0.48 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_alpha');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.5475 0.41 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_beta');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.5475 0.34 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_mu');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.5475 0.27 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_gamma');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.735 0.48 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_sd_alpha');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.735 0.41 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_sd_beta');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.735 0.34 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_sd_mu');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'HorizontalAlignment','left', ...
	'Position',[0.735 0.27 0.175 0.055], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','StaticText_culloch_output_sd_gamma');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','close(gcf);', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.6625 0.0828571 0.175 0.0857143], ...
	'String','Close', ...
	'Tag','Pushbutton_stable_culloch_close');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_stable_function(''bushbutton_stable_culloch_help'');', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.398215 0.0828571 0.175 0.0857143], ...
	'String','Help', ...
	'Tag','Pushbutton_stable_culloch_help');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_stable_function(''pushbutton_stable_culloch_compute'',who)]);', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.1375 0.0828571 0.175 0.0857143], ...
	'String','Compute', ...
	'Tag','Pushbutton_stable_culloch_compute');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.311688311688312, ...
	'Position',[0.0298754 0.771251 0.947755 0.11], ...
	'Style','frame', ...
	'Tag','Frame_input');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'Position',[0.08 0.79425 0.15 0.05], ...
	'String','Input', ...
	'Style','text', ...
	'Tag','StaticText_input');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_stable_function(''refresh_culloch'');', ...
	'FontSize',0.457142857142857, ...
	'FontWeight','bold', ...
	'Position',[0.7 0.78625 0.245 0.075], ...
	'String','Refresh', ...
	'Tag','Pushbutton_refresh');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.685714285714286, ...
	'HorizontalAlignment','left', ...
	'Position',[0.23 0.79925 0.4 0.05], ...
	'String','', ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','EditText_sig_nname');

fl_window_init(a);
