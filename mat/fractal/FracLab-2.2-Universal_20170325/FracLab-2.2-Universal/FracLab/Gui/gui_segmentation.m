function fig = gui_segmentation()
% No help found

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% MAIN WINDOW
a = figure( ...
	'HandleVisibility','callback', ...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[165 50 360 500], ...
	'Units','pixels', ...
	'UserData',struct('Image',0,'Reference',0,'Hoelder',0,'Spectrum',0,'Segmentation',0), ...
	'Name','mfi Holder Segmentation','Tag','gui_segmentation_control_panel');

% TITLE FRAME    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.436363636363636, ...
	'ListboxTop',0, ...
	'Position',[0.02 0.935 0.96 0.055], ...
	'Style','frame', ...
	'Tag','Frame_title');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'HorizontalAlignment','center', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.1 0.94 0.8 0.035], ...
	'String','Multifractal Image Segmentation', ...
	'Style','text', ...
	'Tag','StaticText_Title');

% INPUT FRAME
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.12, ...
	'Position',[0.02 0.73 0.96 0.2], ...
	'Style','frame', ...
	'Tag','Frame_input');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'FontWeight','bold', ...	
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.875 0.25 0.035], ...
	'String','Analysed Image', ...
	'Style','text', ...
	'Tag','StaticText_input');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.685714285714286, ...
	'HorizontalAlignment','center', ...
	'Position',[0.32 0.88 0.4 0.035], ...
	'String','', ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','EditText_input');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''refresh_input'');', ...
	'FontSize',0.533333333333333, ...
	'FontWeight','bold', ...
	'Position',[0.75 0.875 0.175 0.045], ...
	'String','Refresh', ...
	'Tag','Pushbutton_refreshInput');
    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'FontWeight','bold', ...	
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.83 0.25 0.035], ...
	'String','Reference Image', ...
	'Style','text', ...
	'Enable','off',...
	'Tag','StaticText_reference');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.685714285714286, ...
	'HorizontalAlignment','center', ...
	'Position',[0.32 0.835 0.4 0.035], ...
	'String','', ...
	'Style','edit', ...
	'Enable','inactive',...
	'Enable','off',...
	'Tag','EditText_reference');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''refresh_reference'');', ...
	'FontSize',0.533333333333333, ...
	'FontWeight','bold', ...
	'Position',[0.75 0.83 0.175 0.045], ...
	'String','Refresh', ...
	'Enable','off',...
	'Tag','Pushbutton_refreshReference');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'FontWeight','bold', ...	
	'Enable','off',...
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.785 0.25 0.035], ...
	'String','Hoelder Image', ...
	'Style','text', ...
	'Tag','StaticText_hoelderImg');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.685714285714286, ...
	'HorizontalAlignment','center', ...
	'Position',[0.32 0.79 0.4 0.035], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Enable','off',...
	'String','', ...
	'Tag','EditText_hoelderImg');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''refresh_hoelderImg'');', ...
	'FontSize',0.533333333333333, ...
	'FontWeight','bold', ...
	'Position',[0.75 0.785 0.175 0.045], ...
	'String','Refresh', ...
	'Enable','off',...
	'Tag','Pushbutton_refreshHoelderImg');
    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'FontWeight','bold', ...	
	'HorizontalAlignment','left', ...
	'Position',[0.05 0.74 0.25 0.035], ...
	'String','Spectrum', ...
	'Style','text', ...
	'Enable','off',...
	'Tag','StaticText_spectrumImg');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.685714285714286, ...
	'HorizontalAlignment','center', ...
	'Position',[0.32 0.745 0.4 0.035], ...
	'Style','edit', ...
	'Enable','inactive',...
	'String','', ...
	'Enable','off',...
	'Tag','EditText_spectrumImg');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''refresh_spectrumImg'');', ...
	'FontSize',0.533333333333333, ...
	'FontWeight','bold', ...
	'Position',[0.75 0.74 0.175 0.045], ...
	'String','Refresh', ...
	'Enable','off',...
	'Tag','Pushbutton_refreshSpectrumImg');

% Hoelder FRAME
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.096, ...
	'Position',[0.02 0.475 0.96 0.25], ...
	'Style','frame', ...
	'Tag','Frame_Hoelder');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'HorizontalAlignment','center', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.1 0.68 0.8 0.035], ...
	'String','Pointwise Hoelder exponents', ...
	'Style','text', ...
	'Tag','StaticText_HoelderCoef');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_segmentation(''computeHoelder'',who);]);', ...
	'FontSize',0.48, ...
	'ListboxTop',0, ...
	'Enable','off',...
	'Position',[0.33 0.485 0.34 0.05], ...
	'String','Compute Hoelder', ...
	'Tag','computeHoelder');    
  % min
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Position',[0.05    0.585    0.15    0.035], ...
	'String','min size', ...
	'Style','text', ...
	'HorizontalAlignment','center', ...
	'Tag','text_HoelderMin');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''ppm_HoelderMin'');', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Max',6, ...
	'Min',1, ...
	'Position',[0.3    0.59    0.15    0.035], ...
	'String',{'1','3','5','7','9','11'}, ...
	'Style','popupmenu', ...
	'Tag','ppm_HoelderMin', ...
	'Value',1);

  % max size
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Position',[0.05   0.54    0.15  0.035], ...
	'String','max size', ...
	'Style','text', ...
	'HorizontalAlignment','center', ...
	'Tag','text_HoelderMax');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''ppm_HoelderMax'');', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Max',9, ...
	'Min',1, ...
	'Position',[0.3    0.545    0.15    0.035], ...
	'String',{'1','3','5','7','9','11','13','15','17'}, ...
	'Style','popupmenu', ...
	'Tag','ppm_HoelderMax', ...
	'Value',3);

% empty frame ...
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.3, ...
	'Position',[0.54 0.55 0.009 0.08], ...
	'Style','frame', ...
	'Tag','Frame_sep');

% reference checkbox
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Position',[0.6   0.59    0.3  0.035], ...
	'String','Reference image', ...
	'Style','text', ...
	'Enable','off',...
	'HorizontalAlignment','center', ...
	'Tag','text_useReferenceImage');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.499999999999999, ...
	'Position',[0.6 0.545 0.3 0.04], ...
	'Callback','fl_segmentation(''cb_reference'');', ...
	'String','used', ...
	'Value',1,...
	'Enable','off',...
	'Style','checkbox', ...
	'Tag','cb_reference');
    
 % capacity
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.2    0.635    0.2    0.04], ...
	'String','Capacity', ...
	'Style','text', ...
	'HorizontalAlignment','center', ...
	'Tag','StaticText_HoelderCapacity');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''ppm_scale'');', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Max',6, ...
	'Min',1, ...
	'Position',[0.48    0.64    0.34    0.04], ...
	'String',{'sum','l2sum','min','max','iso','adaptive iso'}, ...
	'Style','popupmenu', ...
	'Tag','ppm_HoelderCapacity', ...
	'Value',4);

% SPECTRUM FRAME
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.0941176470588235, ...
	'Position',[0.02 0.215 0.96 0.255], ...
	'Style','frame', ...
	'Tag','Frame_spectrum');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'HorizontalAlignment','center', ...
	'FontUnits','normalized', ...
	'FontSize',0.8, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.1 0.43 0.8 0.03], ...
	'String','Multifractal spectrum', ...
	'Style','text', ...
	'Tag','StaticText_spectrum');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_segmentation(''computeSpectrum'',who);]);', ...
	'FontSize',0.48, ...
	'Enable','off',...
	'ListboxTop',0, ...
	'Position',[0.33 0.225 0.34 0.05], ...
	'String','Compute spectrum', ...
	'Tag','computeSpectrum');    

    % spectrum
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.2    0.38    0.2    0.04], ...
	'String','Spectrum', ...
	'Style','text', ...
	'HorizontalAlignment','center', ...
	'Tag','StaticText_Spectrum');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''ppmSpectrum'');', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Max',3, ...
	'Min',1, ...
	'Position',[0.48    0.385    0.34    0.04], ...
	'String',{'Hausdorff','Legendre'},...,'large deviation'}, ...
	'Style','popupmenu', ...
	'Tag','ppm_Spectrum', ...
	'Value',1);

    % Hausdorff
    % min boxes
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.2    0.33    0.2    0.04], ...
	'String','min boxes', ...
	'Style','text', ...
	'HorizontalAlignment','center', ...
	'Tag','hText_minBoxes');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_segmentation(''hEdit_minBoxes'');', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.6    0.335    0.1    0.04], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','hEdit_minBoxes');
    % max boxes
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.2    0.28    0.2  0.04], ...
	'String','max boxes', ...
	'Style','text', ...
	'HorizontalAlignment','center', ...
	'Tag','hText_maxBoxes');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_segmentation(''hEdit_maxBoxes'');', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.6    0.285    0.1    0.04], ...
	'String','7', ...
	'Style','edit', ...
	'Tag','hEdit_maxBoxes');

  % grd deviation
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'HorizontalAlignment','center', ...
	'Position',[0.03 0.325 0.18 0.035], ...
	'String','adaptation', ...
	'Style','text', ...
	'Enable','off',...
	'Visible','off',...
	'Tag','ldText_adaptation');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''ldPpm_adaptation'');', ...
	'FontSize',0.6, ...
	'Max',4, ...
	'Min',1, ...
	'Position',[0.21 0.33 0.2905 0.04], ...
	'String',{'diagonal','double kernel','manual','maxdev'}, ...
	'Style','popupmenu', ...
	'Tag','ldPpm_adaptation', ...
	'Enable','off',...
	'Visible','off',...
	'Value',4);
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'HorizontalAlignment','center', ...
	'Position',[0.51 0.325 0.15 0.035], ...
	'String','kernel', ...
	'Style','text', ...
	'Enable','off',...
	'Visible','off',...
	'Tag','ldText_kernel');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''ldPpm_kernel'');', ...
	'FontSize',0.6, ...
	'Max',5, ...
	'Min',1, ...
	'Position',[0.66 0.33 0.2905 0.04], ...
	'String',{'boxcar','epanechnikov','gaussian','mollifier','triangle'}, ...
	'Style','popupmenu', ...
	'Tag','ldPpm_kernel', ...
	'Enable','off',...
	'Visible','off',...
	'Value',3);
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Position',[0.1    0.28    0.45  0.035], ...
	'String','coarse graining resolution', ...
	'Style','text', ...
	'HorizontalAlignment','center', ...
	'Enable','off',...
	'Visible','off',...
	'Tag','ldText_grainResolution');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_segmentation(''ldEdit_grainResolution'');', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.6    0.285    0.1    0.04], ...
	'String','1', ...
	'Enable','off',...
	'Visible','off',...
	'Style','edit', ...
	'Tag','ldEdit_grainResolution');

    % Legendre
%b = uicontrol('Parent',a, ...
%	'Units','normalized', ...
%	'HorizontalAlignment','center', ...
%	'FontUnits','normalized', ...
%	'FontSize',0.6, ...
%	'FontWeight','bold', ...
%	'ListboxTop',0, ...
%	'Position',[0.2 0.33 0.6 0.04], ...
%	'String','No parameter', ...
%	'Style','text', ...
%	'Enable','off',...
%	'Visible','off',...
%	'Tag','lText');
%b = uicontrol('Parent',a, ...
%	'Units','normalized', ...
%	'FontUnits','normalized', ...
%	'BackgroundColor',[1 1 1], ...
%	'Callback','fl_segmentation(''ledit_p1'');', ...
%	'FontSize',0.6, ...
%	'ListboxTop',0, ...
%	'Position',[0.4 0.29 0.2 0.04], ...
%	'String','3', ...
%	'Style','edit', ...
%	'Enable','off',...
%	'Visible','off',...
%	'Tag','lEdit');



% SEGMENTATION FRAME
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.16551724137931, ...
	'Position',[0.02 0.065 0.96 0.145], ...
	'Style','frame', ...
	'Tag','Frame_seg');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'HorizontalAlignment','center', ...
	'FontUnits','normalized', ...
	'FontSize',0.8, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.1 0.17 0.8 0.03], ...
	'String','Segmentation', ...
	'Style','text', ...
	'Tag','StaticText_segmentation');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Position',[0.05    0.13    0.19    0.035], ...
	'String','min dim.', ...
	'Style','text', ...
	'HorizontalAlignment','left', ...
	'Tag','StaticText_minDim');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_segmentation(''edit_minmaxDim'');', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.25    0.135    0.2    0.04], ...
	'String','0.7', ...
	'Style','edit', ...
	'Tag','EditText_minDim');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.685714285714286, ...
	'ListboxTop',0, ...
	'Position',[0.5    0.13    0.15    0.035], ...
	'String','max dim.', ...
	'Style','text', ...
	'HorizontalAlignment','left', ...
	'Tag','StaticText_maxDim');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','fl_segmentation(''edit_minmaxDim'');', ...
	'FontSize',0.6, ...
	'ListboxTop',0, ...
	'Position',[0.66    0.135    0.2   0.04], ...
	'String','1.3', ...
	'Style','edit', ...
	'Tag','EditText_maxDim');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global '' fl_segmentation(''computeSegmentation'',who);]);', ...
	'FontSize',0.48, ...
	'Enable','off',...
	'ListboxTop',0, ...
	'Position',[0.33 0.075 0.34 0.05], ...
	'String','Compute seg.', ...
	'Tag','computeSeg');    


% GENERAL BUTTONS
%b = uicontrol('Parent',a, ...
%	'Units','normalized', ...
%	'FontUnits','normalized', ...
%	'Callback','eval([''global '' fl_segmentation(''computeAll'',who);]);', ...
%	'FontSize',0.48, ...
%	'Enable','off',...
%	'FontWeight','bold', ...
%	'ListboxTop',0, ...
%	'Position',[0.03 0.01 0.24 0.05], ...
%	'String','Compute all', ...
%	'Tag','computeAll');    
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''help'');', ...
	'FontSize',0.48, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.03 0.01 0.24 0.05], ...
	'String','Help', ...
	'Tag','button_help');   %0.38 
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_segmentation(''close'');', ...
	'FontSize',0.48, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.73 0.01 0.24 0.05], ...
	'String','Close', ...
	'Tag','button_close');

fl_window_init(a);    
    
if nargout > 0, fig = a; end

fl_segmentation('refresh_input');