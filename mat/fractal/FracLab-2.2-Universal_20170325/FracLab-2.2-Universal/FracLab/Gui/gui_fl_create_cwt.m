function gui_fl_create_cwt()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a = figure('MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[20 50 330 250], ...
	'Tag','Fig2');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.32, ...
	'ListboxTop',0, ...
	'Position',[0.02 0.84 0.96 0.15], ...
	'Style','frame', ...
	'Tag','Frame1');    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.842105263157895, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','center', ...
	'Position',[0.1 0.88 0.8 0.057], ...
	'String','Create CWT Structure', ...
	'Style','text', ...
	'Tag','StaticText');
    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.0761904761904762, ...
	'ListboxTop',0, ...
	'Position',[0.02 0.2 0.96 0.63], ...
	'Style','frame', ...
	'Tag','Frame2');    
    
    %  name
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.842105263157895, ...
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.73 0.18 0.057], ...
	'String','Name', ...
	'Style','text', ...
	'Tag','StaticText1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.6, ...
	'Position',[0.27 0.73 0.49 0.07], ...
	'Style','edit', ...
	'Tag','Text_name');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_create_structures(''get_cwt_name'');', ...
	'FontSize',0.6, ...
	'Position',[0.79 0.73 0.16 0.07], ...
	'String','Refresh', ...
	'Tag','Pushbutton1');


    % coeff
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.842105263157895, ...
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.64 0.18 0.057], ...
	'String','Coeff', ...
	'Style','text', ...
	'Tag','StaticText1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.6, ...
	'Position',[0.27 0.64 0.49 0.07], ...
	'Style','edit', ...
	'Tag','Text_coeff');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_create_structures(''get_cwt_coeff'');', ...
	'FontSize',0.6, ...
	'Position',[0.79 0.64 0.16 0.07], ...
	'String','Refresh', ...
	'Tag','Pushbutton1');
    
    % Scale
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.842105263157895, ...
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.55 0.18 0.057], ...
	'String','Scale', ...
	'Style','text', ...
	'Tag','StaticText1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_create_structures(''get_cwt_scale'');', ...
	'FontSize',0.6, ...
	'Position',[0.79 0.55 0.16 0.07], ...
	'String','Refresh', ...
	'Tag','Pushbutton1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.6, ...
	'Position',[0.27 0.55 0.49 0.07], ...
	'Style','edit', ...
	'Tag','Text_scale');
    
    % Frequency
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.842105263157895, ...
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.46 0.18 0.057], ...
	'String','Frequency', ...
	'Style','text', ...
	'Tag','StaticText1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.6, ...
	'Position',[0.27 0.46 0.49 0.07], ...
	'Style','edit', ...
	'Tag','Text_frequency');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_create_structures(''get_cwt_frequency'');', ...
	'FontSize',0.6, ...
	'Position',[0.79 0.46 0.16 0.07], ...
	'String','Refresh', ...
	'Tag','Pushbutton1');

    
    % wavelet
%b = uicontrol('Parent',a, ...
%	'Units','normalized', ...
%	'FontUnits','normalized', ...
%	'FontSize',0.842105263157895, ...
%	'HorizontalAlignment','left', ...
%	'Position',[0.05 0.37 0.18 0.057], ...
%	'String','Wavelet', ...
%	'Style','text', ...
%	'Tag','StaticText1');
%b = uicontrol('Parent',a, ...
%	'Units','normalized', ...
%	'FontUnits','normalized', ...
%	'BackgroundColor',[1 1 1], ...
%	'FontSize',0.6, ...
%	'Position',[0.27 0.37 0.49 0.07], ...
%	'Style','edit', ...
%	'Tag','Text_wavelet');
%b = uicontrol('Parent',a, ...
%	'Units','normalized', ...
%	'FontUnits','normalized', ...
%	'Callback','fl_create_structures(''get_cwt_wavelet'');', ...
%	'FontSize',0.6, ...
%	'Position',[0.81 0.37 0.12 0.07], ...
%	'String','Refresh', ...
%	'Tag','Pushbutton1');
    
    % general
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_create_structures(''get_all'');', ...
	'FontSize',0.5, ...
	'Position',[0.38 0.24 0.24 0.09], ...
	'String','Refresh all', ...
	'Tag','Pushbutton2');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_function(''close'');', ...
	'FontSize',0.499999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.6 0.05 0.3 0.1], ...
	'String','Close', ...
	'Tag','Pushbutton_close');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_create_structures(''create_cwt'');]);', ...
	'FontSize',0.499999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.1 0.05 0.3 0.1], ...
	'String','Create', ...
	'Tag','Pushbutton_Create');


fl_window_init(a);