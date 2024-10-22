function gui_fl_besov()
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
	'Name','Besov Norms', ...
	'Position',[20 50 320 320], ...
	'Tag','Fig_gui_fl_besov', ...
	'UserData','a');
b = uicontrol('Parent',a, ...%frame 1
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.273971999999999, ...
	'Position',[0.0533333 0.88 0.9 0.105], ...
	'Style','frame', ...
	'Tag','Frame_gui_fl_besov1');
b = uicontrol('Parent',a, ...%frame2
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.256410666666666, ...
	'Position',[0.0533333 0.326 0.9 0.399038], ...
	'Style','frame', ...
	'Tag','Frame_gui_fl_besov2');
%titre
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.556321333333332, ...
	'FontWeight','bold', ...
	'Position',[0.213333 0.885 0.56 0.076], ...
	'String','Besov Norms', ...
	'Style','text', ...
	'Tag','StaticText_besov_title1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% s %%%%%%%%%%%%%%%%%%%%%%%%%%
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'Position',[0.073333 0.615 0.183333 0.076], ...
	'String','s :', ...
	'Style','text', ...
	'Tag','StaticText_besov_param1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_besov_compute(''edit_param1'');', ...
	'FontSize',0.533333333333332, ...
	'Position',[0.48 0.635 0.166667 0.06], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','EditText_besov_param1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''slider_param1'');', ...
	'FontSize',0.551723999999999, ...
    'Min',0.1,...
	'Max',20.1, ...
	'Position',[0.23 0.635 0.2 0.06], ...
	'Style','slider', ...
	'Tag','Slider_besov_param1', ...
	'Value',1);

% %%%%%%%%%%%%%% p %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'Position',[0.07333 0.535 0.183333 0.076], ...
	'String','p :', ...
	'Style','text', ...
	'Tag','StaticText_besov_param2');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_besov_compute(''edit_param2'');', ...
	'FontSize',0.533333333333332, ...
	'Position',[0.48 0.555 0.166667 0.06], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','EditText_besov_param2');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''mode2'');', ...
	'FontSize',0.533333333333332, ...
	'Position',[0.7 0.547 0.2 0.08], ...
	'String','Infinity', ...
	'Style','Checkbox', ...
    'Value',0, ...
	'Tag','Check_besov_mode2');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''slider_param2'');', ...
	'FontSize',0.551723999999999,...
    'Min',0.1,...
	'Max',20.1, ...
	'Position',[0.23 0.555 0.2 0.06], ...
	'Style','slider', ...
	'Tag','Slider_besov_param2', ...
	'Value',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% q %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'Position',[0.073333 0.455 0.183333 0.076], ...
	'String','q :', ...
	'Style','text', ...
	'Tag','StaticText_besov_param3');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_besov_compute(''edit_param3'');', ...
	'FontSize',0.533333333333332, ...
	'Position',[0.48 0.475 0.166667 0.06], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','EditText_besov_param3');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''mode3'');', ...
	'FontSize',0.533333333333332, ...
	'Position',[0.7 0.467 0.2 0.08], ...
	'String','Infinity', ...
	'Style','Checkbox', ...
    'Value',0, ...
	'Tag','Check_besov_mode3');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''slider_param3'');', ...
	'FontSize',0.551723999999999, ...
    'Min',0.1,...
	'Max',20.1, ...
	'Position',[0.23 0.475 0.2 0.06], ...
	'Style','slider', ...
	'Tag','Slider_besov_param3', ...
   'Value',1);

%***************************level*****************************************

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'Position',[0.068333 0.342 0.183333 0.076], ...
	'String','level :', ...
	'Style','text', ...
	'Tag','StaticText_besov_param4');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_besov_compute(''edit_level'');', ...
	'FontSize',0.533333333333332, ...
	'Position',[0.23 0.365 0.166667 0.06], ...
   'String','1',...%'ceil(log2(N))', ...
	'Style','edit', ...
   'Tag','EditText_besov_level');



%%%%%%%%%%%%%%%%%%%%%%%%%%%wavelets%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matond{1}='daubechies  2';
matond{2}='daubechies  4';
matond{3}='daubechies  6';
matond{4}='daubechies  8';
matond{5}='daubechies 10';
matond{6}='daubechies 12';
matond{7}='daubechies 14';
matond{8}='daubechies 16';
matond{9}='daubechies 18';
matond{10}='daubechies 20';
matond{11}='coiflet  6';
matond{12}='coiflet 12';
matond{13}='coiflet 18';
matond{14}='coiflet 24';
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''ondelette'');', ...
	'FontSize',0.716129333333332, ...
	'Max',3, ...
	'Min',1, ...
	'Position',[0.56 0.382 0.3425 0.042], ...
	'String',matond, ...
	'Style','popupmenu', ...
	'Tag','PopupMenu_besov_wtype', ...
	'Value',5);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Vertical%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'FontWeight','bold', ...
	'Position',[0.045 0.12 0.22 0.06], ...
	'String','Vertical =', ...
	'Style','text', ...
	'Tag','StaticText_besov_result1');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'Position',[0.28 0.12 0.2 0.06], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','EditText_besov_result1');

%%%%%%%%%%%%%%%%%%%%Horizontal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'FontWeight','bold', ...
	'Position',[0.045 0.032 0.22 0.06], ...
	'String','Horizontal =', ...
	'Style','text', ...
	'Tag','StaticText_besov_result2');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'Position',[0.28 0.032 0.2 0.06], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','EditText_besov_result2');

% %%%%%%%%%%%%%%%%%%%%Diagonal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'FontWeight','bold', ...
	'Position',[0.525 0.12 0.22 0.06], ...
	'String','Diagonal =', ...
	'Style','text', ...
	'Tag','StaticText_besov_result3');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'Position',[0.7567 0.12 0.2 0.06], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','EditText_besov_result3');
% 
% %%%%%%%%%%%%%%%%%%%%%%%Total%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551723999999999, ...
	'FontWeight','bold', ...
	'Position',[0.525 0.032 0.22 0.06], ...
	'String','Total =', ...
	'Style','text', ...
	'Tag','StaticText_besov_result4');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.533333333333332, ...
	'Position',[0.7567 0.032 0.2 0.06], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','EditText_besov_result4');

% b = uicontrol('Parent',a, ...
% 	'Units','normalized', ...
% 	'FontUnits','normalized', ...
% 	'BackgroundColor',[1 1 1], ...
% 	'FontSize',0.451127819548872, ...
% 	'HorizontalAlignment','left', ...
% 	'Position',[0.43 0.769 0.28 0.07], ...
% 	'String','', ...
% 	'Style','text', ...
% 	'Tag','EditText_sig_nname_besov');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_besov_compute(''compute'',who);]);', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.0833333 0.205 0.233333 0.10], ...
	'String','Compute', ...
	'Tag','Pushbutton_besov_compute');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''help'');', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.38 0.205 0.213333 0.10], ...
	'String','Help', ...
	'Tag','Pushbutton_besov_help');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','close(findobj(''Tag'',''Fig_gui_fl_besov''));fl_clearerror;', ...
	'FontSize',0.399999999999999, ...
	'FontWeight','bold', ...
	'Position',[0.676667 0.205 0.233333 0.10], ...
	'String','Close', ...
	'Tag','Pushbutton_close');

% refresh Frame
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.263157894736842, ...
   'Position',[0.0533333 0.742 0.9 0.12], ...
	'Style','frame', ...
	'Tag','Frame_input_besov');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.551127819548872, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'Position',[0.11 0.755 0.4 0.07], ...
	'String','Analysed signal', ...
	'Style','text', ...
	'Tag','StaticText_input_besov');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_besov_compute(''refresh'');', ...
	'FontSize',0.494736842105263, ...
	'FontWeight','bold', ...
	'Position',[0.75 0.762 0.175 0.08], ...
	'String','Refresh', ...
	'Tag','Pushbutton_refresh_besov');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.551127819548872, ...
	'HorizontalAlignment','left', ...
	'Position',[0.43 0.769 0.28 0.07], ...
	'String','', ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','EditText_sig_nname_besov');

fl_window_init(a);
set(findobj(a,'Tag','StaticText_besov_result1'),'BackgroundColor',fl_getOption('BackGroundColor'));
set(findobj(a,'Tag','StaticText_besov_result2'),'BackgroundColor',fl_getOption('BackGroundColor'));
set(findobj(a,'Tag','StaticText_besov_result3'),'BackgroundColor',fl_getOption('BackGroundColor'));
set(findobj(a,'Tag','StaticText_besov_result4'),'BackgroundColor',fl_getOption('BackGroundColor'));

set(findobj(a,'Tag','StaticText_besov_result1'),'ForegroundColor',fl_getOption('AltFontColor'));
set(findobj(a,'Tag','StaticText_besov_result2'),'ForegroundColor',fl_getOption('AltFontColor'));
set(findobj(a,'Tag','StaticText_besov_result3'),'ForegroundColor',fl_getOption('AltFontColor'));
set(findobj(a,'Tag','StaticText_besov_result4'),'ForegroundColor',fl_getOption('AltFontColor'));

fl_besov_compute('refresh');
