function fig = gui_fl_options()
% No help found

% Modified by Pierrick Legrand, January 2017

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch(fl_getOption('Layout'))
case 1
	%LayoutHorizontal
	FigurePosition = [39 51 360 550];
	TitreFramePosition = [0.0289473684210526 0.93 0.947368421052632 0.0652941176470588];
	TitreTextePosition = [0.139473684210526 0.930647058823529 0.726315789473684 0.056];
	ThemeFramePosition = [0.0289473684210526 0.855294117647059 0.944736842105263 0.068529411764706];
	ThemeTextePosition = [0.08 0.86 0.16 0.045];
	ThemePopupPosition = [0.28  0.865 0.5 0.04];
	ThemeManageButtonPosition = [0.80 0.865 0.15 0.04];
	LogoAxesPosition = [0.08 0.69 0.85 0.16];
	OptionFramePosition = [0.0289473684210526 0.088294117647059 0.944736842105263 0.593529411764706];
	LayoutTextPosition = [0.08 0.62 0.24 0.04];
	LayoutEditPosition = [0.34 0.62 0.465 0.04];
	LayoutGetButtonPosition = [0.85 0.62 0.1 0.04];
	DecalageBasPosition = [0 0.06 0 0];
	LogoTextPosition = LayoutTextPosition - DecalageBasPosition;
	LogoEditPosition = LayoutEditPosition - DecalageBasPosition;
	LogoGetButtonPosition = LayoutGetButtonPosition - DecalageBasPosition;
	BGcolorTextPosition = LayoutTextPosition - 2*DecalageBasPosition;
	BGcolorEditPosition = LayoutEditPosition - 2*DecalageBasPosition;
	BGcolorGetButtonPosition = LayoutGetButtonPosition - 2*DecalageBasPosition;
	BGimageTextPosition = LayoutTextPosition - 3*DecalageBasPosition;
	BGimageEditPosition = LayoutEditPosition - 3*DecalageBasPosition;
	BGimageGetButtonPosition = LayoutGetButtonPosition - 3*DecalageBasPosition;
	FramecolorTextPosition = LayoutTextPosition - 4*DecalageBasPosition;
	FramecolorEditPosition = LayoutEditPosition - 4*DecalageBasPosition;
	FramecolorGetButtonPosition = LayoutGetButtonPosition - 4*DecalageBasPosition;
	ButtoncolorTextPosition = LayoutTextPosition - 5*DecalageBasPosition;
	ButtoncolorEditPosition = LayoutEditPosition - 5*DecalageBasPosition;
	ButtoncolorGetButtonPosition = LayoutGetButtonPosition - 5*DecalageBasPosition;
	Fill_incolorTextPosition = LayoutTextPosition - 6*DecalageBasPosition;
	Fill_incolorEditPosition = LayoutEditPosition - 6*DecalageBasPosition;
	Fill_incolorGetButtonPosition = LayoutGetButtonPosition - 6*DecalageBasPosition;
	FontcolorTextPosition = LayoutTextPosition - 7*DecalageBasPosition;
	FontcolorEditPosition = LayoutEditPosition - 7*DecalageBasPosition;
	FontcolorGetButtonPosition = LayoutGetButtonPosition - 7*DecalageBasPosition;
	SavelogCheckboxPosition = [0.08 0.15 0.26 0.04];
	SavepositionCheckboxPosition = [0.38 0.15 0.56 0.04];
	ShowsplashscreenCheckboxPosition = [0.08 0.10 0.46 0.04];
	ShowwaitbarsCheckboxPosition = [0.58 0.10 0.36 0.04];
	SaveButtonPosition = [0.0547368421052632 0.019705882352941 0.273684210526316 0.0535294117647059];
	CloseButtonPosition = [0.360421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
	ApplyButtonPosition = [0.678421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
	
otherwise
	%LayoutVertical
	FigurePosition = [39 51 460 450];
	TitreFramePosition = [0.0289473684210526 0.92 0.947368421052632 0.0752941176470588];
	TitreTextePosition = [0.139473684210526 0.923647058823529 0.726315789473684 0.07];
	ThemeFramePosition = [0.0289473684210526 0.825294117647059 0.944736842105263 0.088529411764706];
	ThemeTextePosition = [0.08 0.84 0.16 0.05];
	ThemePopupPosition = [0.22 0.845 0.55 0.05];
	ThemeManageButtonPosition = [0.8 0.845 0.15 0.05];
	LogoAxesPosition = [0.02 0.12 0.2 0.66];
	OptionFramePosition = [0.2289473684210526 0.088294117647059 0.744736842105263 0.725529411764706];
	LayoutTextPosition = [0.25 0.73 0.24 0.05];
	LayoutEditPosition = [0.44 0.73 0.365 0.05];
	LayoutGetButtonPosition = [0.85 0.73 0.1 0.05];
	DecalageBasPosition = [0 0.073 0 0];
	LogoTextPosition = LayoutTextPosition - DecalageBasPosition;
	LogoEditPosition = LayoutEditPosition - DecalageBasPosition;
	LogoGetButtonPosition = LayoutGetButtonPosition - DecalageBasPosition;
	BGcolorTextPosition = LayoutTextPosition - 2*DecalageBasPosition;
	BGcolorEditPosition = LayoutEditPosition - 2*DecalageBasPosition;
	BGcolorGetButtonPosition = LayoutGetButtonPosition - 2*DecalageBasPosition;
	BGimageTextPosition = LayoutTextPosition - 3*DecalageBasPosition;
	BGimageEditPosition = LayoutEditPosition - 3*DecalageBasPosition;
	BGimageGetButtonPosition = LayoutGetButtonPosition - 3*DecalageBasPosition;
	FramecolorTextPosition = LayoutTextPosition - 4*DecalageBasPosition;
	FramecolorEditPosition = LayoutEditPosition - 4*DecalageBasPosition;
	FramecolorGetButtonPosition = LayoutGetButtonPosition - 4*DecalageBasPosition;
	ButtoncolorTextPosition = LayoutTextPosition - 5*DecalageBasPosition;
	ButtoncolorEditPosition = LayoutEditPosition - 5*DecalageBasPosition;
	ButtoncolorGetButtonPosition = LayoutGetButtonPosition - 5*DecalageBasPosition;
	Fill_incolorTextPosition = LayoutTextPosition - 6*DecalageBasPosition;
	Fill_incolorEditPosition = LayoutEditPosition - 6*DecalageBasPosition;
	Fill_incolorGetButtonPosition = LayoutGetButtonPosition - 6*DecalageBasPosition;
	FontcolorTextPosition = LayoutTextPosition - 7*DecalageBasPosition;
	FontcolorEditPosition = LayoutEditPosition - 7*DecalageBasPosition;
	FontcolorGetButtonPosition = LayoutGetButtonPosition - 7*DecalageBasPosition;
	SavelogCheckboxPosition = [0.25 0.15 0.26 0.05];
	SavepositionCheckboxPosition = [0.46 0.15 0.46 0.05];
	ShowsplashscreenCheckboxPosition = [0.25 0.10 0.36 0.05];
	ShowwaitbarsCheckboxPosition = [0.65 0.10 0.26 0.05];
	SaveButtonPosition = [0.0547368421052632 0.019705882352941 0.273684210526316 0.0535294117647059];
	CloseButtonPosition = [0.360421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
	ApplyButtonPosition = [0.678421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
end



a = figure( ...
	'PaperUnits',get(0,'defaultfigurePaperUnits'),...
	'Colormap',[],...
	'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
	'PaperPosition',[0.6345175 6.345175 20.30456 15.22842],...
	'PaperSize',[20.98404194812 29.67743169791],...
	'PaperType',get(0,'defaultfigurePaperType'),...
	'Position',FigurePosition,...
	'HandleVisibility','callback', ...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Name','customize Toolbar','Tag','Fig_gui_fl_options');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'FontSize',0.299295774647887,...
	'Position',TitreFramePosition,...
	'Style','frame',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','Frame_title' );

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'FontSize',0.081783194355356,...
	'Position',ThemeFramePosition,...
	'Style','frame',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','Frame_theme');
	
	
b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'FontSize',0.081783194355356,...
	'Position',OptionFramePosition,...
	'Style','frame',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','Frame_options');	

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'FontSize',0.625,...
	'FontWeight','bold',...
	'Position',TitreTextePosition,...
	'String','FracLab Options',...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText6');




%themes

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',ThemeTextePosition, ...
	'String','Theme', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_theme');
	

Themes_List = { 'Current', 'Default' 'Circle' 'Classic Gray', 'Classic Red' 'Classic Green' 'Classic Blue' 'Classic White', 'Classic Black','Vertical'};

p=version;
if str2num(p(1))>=7
    Themes_List_size = size(Themes_List);
    Themes_List_size = max(Themes_List_size);
    Themes_List{Themes_List_size+1} = '---------------------------------------';
    Themes_List_size = Themes_List_size+1;
    
    flroot = fl_getOption('FracLabRoot');
    fltool_list = ls(fullfile(flroot,'Gui','fltool_*.mat'));
    fltool_list_size = size(fltool_list);
    for i = 1:fltool_list_size(1)
        fltool_perso = fltool_list(i,:);
        espaces = find(fltool_perso == ' ');
        if ~isempty(espaces)
            fltool_perso = fltool_perso(1:espaces(1)-1);
        end
        fltool_perso = fltool_perso(8:end-4);
        Themes_List{Themes_List_size+i} =  fltool_perso;
    end
end
	
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',ThemePopupPosition, ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'String',Themes_List,...
	'Callback','fl_options_compute(''popupmenu_theme'');', ...
	'Style','popupmenu', ...
	'Tag','Popupmenu_theme');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''manage_themes'');',...
	'FontSize',0.51,...
	'Position',ThemeManageButtonPosition,...
	'String','Manage',...
	'Tag','Pushbutton_manage_theme');	

%Logo

[logo_frac cmap_frac alpha_frac]=fl_getOption('Logo');
K=sum(logo_frac,3);
b = axes('Parent',a, ...
	'Box','on', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'HandleVisibility','callback', ...
	'Layer','top', ...
	'Units','normalized', ...
	'Position',LogoAxesPosition,...
	'Tag','Axes1', ...
	'Visible','off', ...
	'XColor',[0 0 0], ...
	'XLimMode','manual', ...
	'YColor',[0 0 0], ...
	'YDir','reverse', ...
	'YLimMode','manual', ...
	'ZColor',[0 0 0]);
c = image('Parent',b, ...
	'CData',rot90(K,2), ...
	'AlphaData', rot90(alpha_frac,2),...
	'Interruptible','off', ...
	'Tag','Image1');


logosize = fl_getOption('LogoSize');
if sum(logosize)
	set(b,'XLim',[1 logosize(2)]);
	set(b,'YLim',[1 logosize(1)]);
end

%Options

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',LayoutTextPosition, ...
	'String','Layout', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_layout');
	
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',LayoutEditPosition, ...
	'Value',fl_getOption('Layout'),...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'String',{ 'Horizontal', 'Vertical 1','Vertical 2','Mirror','Circle'},...
	'Style','popupmenu', ...
	'Callback','fl_options_compute(''popupmenu_layout'');', ...		
	'Tag','Popupmenu_layout');



b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',LogoTextPosition, ...
	'String','Logo', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_logo');
	
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',LogoEditPosition, ...
	'String',fl_getOption('LogoFileName'), ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'Style','edit', ...
	'Callback','fl_options_compute(''edittext_logo'');', ...		
	'Tag','EditText_logo');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''get_logo'');',...
	'FontSize',0.51,...
	'Position',LogoGetButtonPosition,...
	'String','Get',...
	'Tag','Pushbutton_get_logo');	

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',BGcolorTextPosition, ...
	'String','BG Color', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_BGcolor');
	
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',BGcolorEditPosition, ...
	'String',num2str(fl_getOption('BackGroundColor')), ...
	'Style','edit', ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'Callback','fl_options_compute(''edittext_BGcolor'');', ...		
	'Tag','EditText_BGcolor');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''get_BGcolor'');',...
	'FontSize',0.51,...
	'Position',BGcolorGetButtonPosition,...
	'String','Get',...
	'Tag','Pushbutton_get_BGcolor');
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',BGimageTextPosition, ...
	'String','BG Image', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_BGimage');
	
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',BGimageEditPosition, ...
	'String',num2str(fl_getOption('BackGroundFileName')), ...
	'Style','edit', ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'Callback','fl_options_compute(''edittext_BGimage'');', ...		
	'Tag','EditText_BGimage');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''get_BGimage'');',...
	'FontSize',0.51,...
	'Position',BGimageGetButtonPosition,...
	'String','Get',...
	'Tag','Pushbutton_get_BGimage');		
	


b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'HorizontalAlignment','left', ...
	'FontSize',0.525, ...
	'Position',FramecolorTextPosition , ...
	'String','Frame Color', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','text_Framecolor');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',FramecolorEditPosition , ...
	'String',num2str(fl_getOption('FrameColor')), ...
	'Style','edit', ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'Callback','fl_options_compute(''edittext_Framecolor'');', ...		
	'Tag','EditText_Framecolor');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''get_Framecolor'');',...
	'FontSize',0.51,...
	'Position',FramecolorGetButtonPosition,...
	'String','Get',...
	'Tag','Pushbutton_get_Framecolor');	


b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',ButtoncolorTextPosition , ...
	'String','Button Color', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','text_buttoncolor');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',ButtoncolorEditPosition , ...
	'String',num2str(fl_getOption('ButtonColor')), ...
	'Style','edit', ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'Callback','fl_options_compute(''edittext_Buttoncolor'');', ...	
	'Tag','EditText_Buttoncolor');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''get_Buttoncolor'');',...
	'FontSize',0.51,...
	'Position',ButtoncolorGetButtonPosition ,...
	'String','Get',...
	'Tag','Pushbutton_get_Buttoncolor');	


b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',Fill_incolorTextPosition , ...
	'String','Fill-in Color', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','text_fill_incolor');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',Fill_incolorEditPosition , ...
	'String',num2str(fl_getOption('Fill_inColor')), ...
	'Style','edit', ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'Callback','fl_options_compute(''edittext_Fill_incolor'');', ...	
	'Tag','EditText_Fill_incolor');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''get_Fill_incolor'');',...
	'FontSize',0.51,...
	'Position',Fill_incolorGetButtonPosition ,...
	'String','Get',...
	'Tag','Pushbutton_get_Fill_incolor');



b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',FontcolorTextPosition , ...
	'String','Font Color', ...
	'Style','text',...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','text_fontcolor');

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'Enable','on', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'Position',FontcolorEditPosition , ...
	'String',num2str(fl_getOption('FontColor')), ...
	'Style','edit', ...
	'BackgroundColor',fl_getOption('Fill_inColor'),...
	'Callback','fl_options_compute(''edittext_Fontcolor'');', ...	
	'Tag','EditText_Fontcolor');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''get_Fontcolor'');',...
	'FontSize',0.51,...
	'Position',FontcolorGetButtonPosition ,...
	'String','Get',...
	'Tag','Pushbutton_get_Fontcolor');
	
	

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',SavelogCheckboxPosition , ...
	'String','Save log', ...
	'Style','checkbox', ...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_save_log',...
	'Value', fl_getOption('SaveLog'));

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',SavepositionCheckboxPosition , ...
	'String','Save window size and position', ...
	'Style','checkbox', ...
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_save_position',...
	'Value', fl_getOption('SavePosition'));


b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',ShowsplashscreenCheckboxPosition , ...
	'String','Show splash screen', ...
	'Style','checkbox', ...	
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_splash',...
	'Value', fl_getOption('ShowSplashScreen'));
	
	

b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.525, ...
	'HorizontalAlignment','left', ...
	'Position',ShowwaitbarsCheckboxPosition , ...
	'String','Show waitbars', ...
	'Style','checkbox', ...	
	'BackgroundColor',fl_getOption('FrameColor'),...
	'Tag','StaticText_waitbars',...
	'Value', fl_getOption('ShowWaitBars'));	


%Buttons

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''save'');',...
	'FontSize',0.47,...
	'FontWeight','bold',...
	'Position',SaveButtonPosition ,...
	'String','Save',...
	'Tag','Pushbutton_options_save');


b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''close'');',...
	'FontSize',0.47,...
	'FontWeight','bold',...
	'Position',CloseButtonPosition,...
	'String','Close',...
	'Tag','Pushbutton_options_close');

b = uicontrol(...
	'Parent',a,...
	'Units','normalized',...
	'FontUnits','normalized',...
	'Callback','fl_options_compute(''apply'');',...
	'FontSize',0.47,...
	'FontWeight','bold',...
	'Position',ApplyButtonPosition,...
	'String','Apply',...
	'Tag','Pushbutton_options_apply');



fl_window_init(a);
fl_options_compute('init');