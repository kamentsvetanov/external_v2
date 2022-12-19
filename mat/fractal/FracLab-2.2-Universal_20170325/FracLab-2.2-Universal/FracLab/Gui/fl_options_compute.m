function [varargout]=fl_options_compute(varargin);
% No help found

% Modified by Pierrick Legrand, January 2017

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,options_fig] = gcbo;

if ((isempty(options_fig)) | (~strcmp(get(options_fig,'Tag'),'Fig_gui_fl_options')))
  options_fig = findobj ('Tag','Fig_gui_fl_options');
end;

ud = get(options_fig,'UserData');
returnString = '';

ShowHiddenHandlesInit = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');


switch(varargin{1});

    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'init'
    %%%%%%%%%%%%%%%%%%%%%%%%%%

	ud.logo_frac = fl_getOption('LogoFileName');
	ud.bgcolor = fl_getOption('BackGroundColor');
	ud.bgimage = fl_getOption('BackGroundFileName');
	ud.framecolor = fl_getOption('FrameColor');
	ud.buttoncolor = fl_getOption('ButtonColor');
	ud.fill_incolor = fl_getOption('Fill_inColor');
	ud.fontcolor = fl_getOption('FontColor');
	ud.ChangeLayout = 0;
	ud.layout = fl_getOption('Layout');
	set(findobj('Tag','Fig_gui_fl_options'),'UserData',ud);
	

    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'popupmenu_theme'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	index_predefinedvalue = get(gcbo,'Value');
	switch (index_predefinedvalue)
	case 1 % Current
		ud.logo_frac = fl_getOption('LogoFileName');
		ud.bgcolor = fl_getOption('BackGroundColor');
		ud.bgimage = fl_getOption('BackGroundFileName');
		ud.framecolor = fl_getOption('FrameColor');
		ud.buttoncolor = fl_getOption('ButtonColor');
		ud.fill_incolor = fl_getOption('Fill_inColor');
		ud.fontcolor = fl_getOption('FontColor');
		ud.ChangeLayout = 1;
		ud.layout = fl_getOption('Layout');		
	
	case 2 % Mirror Violet Gris
		ud.logo_frac = 'logo_fraclab2_white.png';
		ud.bgcolor = [0.32157    0.062745     0.32157];
		ud.bgimage = 'violetgris.bmp';
		ud.framecolor = [0.90588     0.90588     0.90588];
		ud.buttoncolor = [0.95        0.95        0.95]; 
		ud.fill_incolor = [1 1 1];
		ud.fontcolor = [0 0 0];
		ud.ChangeLayout = 1;
		ud.layout = 4;
	
	case 3 % Circle RgeBlcRonds 
		ud.logo_frac = 'logo_fraclab2_white.png';
		ud.bgcolor = [0.7098    0.062745     0.12941];
		ud.bgimage = 'FondRgeBlcBoutonsRonds.png';
		ud.framecolor = [1  1  1];
		ud.buttoncolor = [1  1  1]; 
		ud.fill_incolor = [1 1 1];
		ud.fontcolor = [0 0 0];
		ud.ChangeLayout = 1;
		ud.layout = 5;
		
	case 4 % Gray
		ud.logo_frac = 'logo_fraclab2.png';
		ud.bgcolor = [0.62353 0.62353 0.62353];
		ud.bgimage = '';
		ud.framecolor = [0.8 0.8 0.8];
		ud.buttoncolor = [0.8 0.8 0.8]; 
		ud.fill_incolor = [1 1 1];
		ud.fontcolor = [0 0 0];
		ud.ChangeLayout = 1;
		ud.layout = 1;


	case 3+2 % Red
		ud.logo_frac = 'logo_fraclab2.png';
		ud.bgcolor = [1 0 0];
		ud.bgimage = '';
		ud.framecolor = [1 .5 .5];
		ud.buttoncolor = [.7992 .1341 .0653]; 
		ud.fill_incolor = [1 1 1];
		ud.fontcolor = [0 0 0];
		ud.ChangeLayout = 1;
		ud.layout = 1;
	
	case 4+2 % Green
		ud.logo_frac = 'logo_fraclab2.png';
		ud.bgcolor = [0 1 0] ;
		ud.bgimage = '';
		ud.framecolor = [0.50196           1           1];
		ud.buttoncolor = [1     0.50196           1];
		ud.fill_incolor = [1     1           0.50196];
		ud.fontcolor = [0.1           0        0.95];
		ud.ChangeLayout = 1;
		ud.layout = 1;

	case 5+2 % Blue
		ud.logo_frac = 'logo_fraclab2.png';
		ud.bgcolor = [0 0 1];
		ud.bgimage = '';
		ud.framecolor = [0.3525 .7221 .9685];
		ud.buttoncolor = [.85 .85 .87]; 
		ud.fill_incolor = [1 1 1];
		ud.fontcolor = [0 0 0];
		ud.ChangeLayout = 1;
		ud.layout = 1;

	case 6+2 % White
		ud.logo_frac = 'logo_fraclab2.png';
		ud.bgcolor = [1 1 1];
		ud.bgimage = '';
		ud.framecolor = [1 1 1];
		ud.buttoncolor = [1 1 1]; 
		ud.fill_incolor = [1 1 1];
		ud.fontcolor = [0 0 0];
		ud.ChangeLayout = 1;
		ud.layout = 1;

	case 7+2 % Black
		ud.logo_frac = 'logo_fraclab2.png';
		ud.bgcolor = [0 0 0];
		ud.bgimage = '';
		ud.framecolor = [0 0 0];
		ud.buttoncolor = [0 0 0]; 
		ud.fill_incolor = [0.4 0.4 0.4];
		ud.fontcolor = [1 1 1];
		ud.ChangeLayout = 1;
		ud.layout = 1;
	
	case 8+2 % Classic Vertical
		ud.logo_frac = 'logo_fraclab2_vertical.png';
		ud.bgcolor = [0.62353 0.62353 0.62353];
		ud.bgimage = '';
		ud.framecolor = [0.8 0.8 0.8];
		ud.buttoncolor = [0.8 0.8 0.8]; 
		ud.fill_incolor = [1 1 1];
		ud.fontcolor = [0 0 0];
		ud.ChangeLayout = 1;
		ud.layout = 2;
	
	case 11 % '---------------'
	otherwise
		fltool_list = get(findobj(options_fig,'Tag','Popupmenu_theme'),'String');
		fltool_perso = fltool_list{index_predefinedvalue};
		load(['fltool_' fltool_perso '.mat'],'LogoFileName');
		load(['fltool_' fltool_perso '.mat'],'BackGroundColor');
		load(['fltool_' fltool_perso '.mat'],'BackGroundFileName');
		load(['fltool_' fltool_perso '.mat'],'FrameColor');
		load(['fltool_' fltool_perso '.mat'],'ButtonColor'); 
		load(['fltool_' fltool_perso '.mat'],'Fill_inColor');
		load(['fltool_' fltool_perso '.mat'],'FontColor');
		load(['fltool_' fltool_perso '.mat'],'Layout');
		ud.logo_frac = LogoFileName;
		ud.bgcolor = BackGroundColor;
		ud.bgimage = BackGroundFileName;
		ud.framecolor = FrameColor;
		ud.buttoncolor = ButtonColor; 
		ud.fill_incolor = Fill_inColor;
		ud.fontcolor = FontColor;
		ud.ChangeLayout = 1;
		ud.layout = Layout;
	end
	
	set(options_fig,'UserData',ud);
	fl_options_compute('apply_changes');


    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'popupmenu_layout'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	ud.layout = get(gcbo,'Value');
	ud.ChangeLayout = 1;
	set(options_fig,'UserData',ud);
	fl_options_compute('apply_changes');


    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'apply_changes'
    %%%%%%%%%%%%%%%%%%%%%%%%%%

	if isfield(ud,'ChangeLayout')
		if ud.ChangeLayout
			switch(ud.layout)
			case 1 % Honrizontal
				ud.FigurePosition = [0 0 360 550];
				ud.TitreFramePosition = [0.0289473684210526 0.93 0.947368421052632 0.0652941176470588];
				ud.TitreTextePosition = [0.139473684210526 0.930647058823529 0.726315789473684 0.056];
				ud.ThemeFramePosition = [0.0289473684210526 0.855294117647059 0.944736842105263 0.068529411764706];
				ud.ThemeTextePosition = [0.08 0.86 0.16 0.045];
				ud.ThemePopupPosition = [0.28  0.865 0.5 0.04];
				ud.ThemeManageButtonPosition = [0.80 0.865 0.15 0.04];
				ud.LogoAxesPosition = [0.08 0.69 0.85 0.16];
				ud.OptionFramePosition = [0.0289473684210526 0.088294117647059 0.944736842105263 0.593529411764706];
				ud.layoutTextPosition = [0.08 0.62 0.24 0.04];
				ud.layoutEditPosition = [0.34 0.62 0.465 0.04];
				ud.layoutGetButtonPosition = [0.85 0.62 0.1 0.04];
				ud.DecalageBasPosition = [0 0.06 0 0];
				ud.LogoTextPosition = ud.layoutTextPosition - ud.DecalageBasPosition;
				ud.LogoEditPosition = ud.layoutEditPosition - ud.DecalageBasPosition;
				ud.LogoGetButtonPosition = ud.layoutGetButtonPosition - ud.DecalageBasPosition;
				ud.BGcolorTextPosition = ud.layoutTextPosition - 2*ud.DecalageBasPosition;
				ud.BGcolorEditPosition = ud.layoutEditPosition - 2*ud.DecalageBasPosition;
				ud.BGcolorGetButtonPosition = ud.layoutGetButtonPosition - 2*ud.DecalageBasPosition;
				ud.BGimageTextPosition = ud.layoutTextPosition - 3*ud.DecalageBasPosition;
				ud.BGimageEditPosition = ud.layoutEditPosition - 3*ud.DecalageBasPosition;
				ud.BGimageGetButtonPosition = ud.layoutGetButtonPosition - 3*ud.DecalageBasPosition;
				ud.FramecolorTextPosition = ud.layoutTextPosition - 4*ud.DecalageBasPosition;
				ud.FramecolorEditPosition = ud.layoutEditPosition - 4*ud.DecalageBasPosition;
				ud.FramecolorGetButtonPosition = ud.layoutGetButtonPosition - 4*ud.DecalageBasPosition;
				ud.ButtoncolorTextPosition = ud.layoutTextPosition - 5*ud.DecalageBasPosition;
				ud.ButtoncolorEditPosition = ud.layoutEditPosition - 5*ud.DecalageBasPosition;
				ud.ButtoncolorGetButtonPosition = ud.layoutGetButtonPosition - 5*ud.DecalageBasPosition;
				ud.Fill_incolorTextPosition = ud.layoutTextPosition - 6*ud.DecalageBasPosition;
				ud.Fill_incolorEditPosition = ud.layoutEditPosition - 6*ud.DecalageBasPosition;
				ud.Fill_incolorGetButtonPosition = ud.layoutGetButtonPosition - 6*ud.DecalageBasPosition;
				ud.FontcolorTextPosition = ud.layoutTextPosition - 7*ud.DecalageBasPosition;
				ud.FontcolorEditPosition = ud.layoutEditPosition - 7*ud.DecalageBasPosition;
				ud.FontcolorGetButtonPosition = ud.layoutGetButtonPosition - 7*ud.DecalageBasPosition;
				ud.SavelogCheckboxPosition = [0.08 0.15 0.26 0.04];
				ud.ShowsplashscreenCheckboxPosition = [0.08 0.10 0.46 0.04];
				ud.SavepositionCheckboxPosition = [0.38 0.15 0.56 0.04];
				ud.ShowwaitbarsCheckboxPosition = [0.58 0.10 0.36 0.04];
				ud.SaveButtonPosition = [0.0547368421052632 0.019705882352941 0.273684210526316 0.0535294117647059];
				ud.CloseButtonPosition = [0.360421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
				ud.ApplyButtonPosition = [0.678421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
			otherwise % vertical
				ud.FigurePosition = [0 0 460 450];
				ud.TitreFramePosition = [0.0289473684210526 0.92 0.947368421052632 0.0752941176470588];
				ud.TitreTextePosition = [0.139473684210526 0.923647058823529 0.726315789473684 0.07];
				ud.ThemeFramePosition = [0.0289473684210526 0.825294117647059 0.944736842105263 0.088529411764706];
				ud.ThemeTextePosition = [0.08 0.84 0.16 0.05];
				ud.ThemePopupPosition = [0.22 0.845 0.55 0.05];
				ud.ThemeManageButtonPosition = [0.8 0.845 0.15 0.05];
				ud.LogoAxesPosition = [0.02 0.12 0.2 0.66];
				ud.OptionFramePosition = [0.2289473684210526 0.088294117647059 0.744736842105263 0.725529411764706];
				ud.layoutTextPosition = [0.25 0.73 0.24 0.05];
				ud.layoutEditPosition = [0.44 0.73 0.365 0.05];
				ud.layoutGetButtonPosition = [0.85 0.73 0.1 0.05];
				ud.DecalageBasPosition = [0 0.073 0 0];
				ud.LogoTextPosition = ud.layoutTextPosition - ud.DecalageBasPosition;
				ud.LogoEditPosition = ud.layoutEditPosition - ud.DecalageBasPosition;
				ud.LogoGetButtonPosition = ud.layoutGetButtonPosition - ud.DecalageBasPosition;
				ud.BGcolorTextPosition = ud.layoutTextPosition - 2*ud.DecalageBasPosition;
				ud.BGcolorEditPosition = ud.layoutEditPosition - 2*ud.DecalageBasPosition;
				ud.BGcolorGetButtonPosition = ud.layoutGetButtonPosition - 2*ud.DecalageBasPosition;
				ud.BGimageTextPosition = ud.layoutTextPosition - 3*ud.DecalageBasPosition;
				ud.BGimageEditPosition = ud.layoutEditPosition - 3*ud.DecalageBasPosition;
				ud.BGimageGetButtonPosition = ud.layoutGetButtonPosition - 3*ud.DecalageBasPosition;
				ud.FramecolorTextPosition = ud.layoutTextPosition - 4*ud.DecalageBasPosition;
				ud.FramecolorEditPosition = ud.layoutEditPosition - 4*ud.DecalageBasPosition;
				ud.FramecolorGetButtonPosition = ud.layoutGetButtonPosition - 4*ud.DecalageBasPosition;
				ud.ButtoncolorTextPosition = ud.layoutTextPosition - 5*ud.DecalageBasPosition;
				ud.ButtoncolorEditPosition = ud.layoutEditPosition - 5*ud.DecalageBasPosition;
				ud.ButtoncolorGetButtonPosition = ud.layoutGetButtonPosition - 5*ud.DecalageBasPosition;
				ud.Fill_incolorTextPosition = ud.layoutTextPosition - 6*ud.DecalageBasPosition;
				ud.Fill_incolorEditPosition = ud.layoutEditPosition - 6*ud.DecalageBasPosition;
				ud.Fill_incolorGetButtonPosition = ud.layoutGetButtonPosition - 6*ud.DecalageBasPosition;
				ud.FontcolorTextPosition = ud.layoutTextPosition - 7*ud.DecalageBasPosition;
				ud.FontcolorEditPosition = ud.layoutEditPosition - 7*ud.DecalageBasPosition;
				ud.FontcolorGetButtonPosition = ud.layoutGetButtonPosition - 7*ud.DecalageBasPosition;
				ud.SavelogCheckboxPosition = [0.25 0.15 0.26 0.05];
				ud.ShowsplashscreenCheckboxPosition = [0.25 0.10 0.36 0.05];
				ud.SavepositionCheckboxPosition = [0.46 0.15 0.46 0.05];
				ud.ShowwaitbarsCheckboxPosition = [0.65 0.10 0.26 0.05];
				ud.SaveButtonPosition = [0.0547368421052632 0.019705882352941 0.273684210526316 0.0535294117647059];
				ud.CloseButtonPosition = [0.360421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
				ud.ApplyButtonPosition = [0.678421052631579 0.019705882352941 0.273684210526316 0.0535294117647059];
			
			end
			FigurePositionOld = get(findobj(options_fig,'Tag','Fig_gui_fl_options'),'Position');
			FigurePositionNew(1:2) = FigurePositionOld(1:2);
			FigurePositionNew(3:4) = ud.FigurePosition(3:4);
			set(findobj(options_fig,'Tag','Fig_gui_fl_options'),'Position',FigurePositionNew);
			set(findobj(options_fig,'Tag','Frame_title'),'Position',ud.TitreFramePosition);
			set(findobj(options_fig,'Tag','StaticText6'),'Position',ud.TitreTextePosition);
			set(findobj(options_fig,'Tag','Frame_theme'),'Position',ud.ThemeFramePosition);
			set(findobj(options_fig,'Tag','StaticText_theme'),'Position',ud.ThemeTextePosition);
			set(findobj(options_fig,'Tag','Popupmenu_theme'),'Position',ud.ThemePopupPosition);
			set(findobj(options_fig,'Tag','Pushbutton_manage_theme'),'Position',ud.ThemeManageButtonPosition);
			set(findobj(options_fig,'Tag','Axes1'),'Position',ud.LogoAxesPosition);
			set(findobj(options_fig,'Tag','Frame_options'),'Position',ud.OptionFramePosition);
			set(findobj(options_fig,'Tag','StaticText_layout'),'Position',ud.layoutTextPosition);
			set(findobj(options_fig,'Tag','Popupmenu_layout'),'Position',ud.layoutEditPosition);
			set(findobj(options_fig,'Tag','StaticText_logo'),'Position',ud.LogoTextPosition);
			set(findobj(options_fig,'Tag','EditText_logo'),'Position',ud.LogoEditPosition);
			set(findobj(options_fig,'Tag','Pushbutton_get_logo'),'Position',ud.LogoGetButtonPosition);
			set(findobj(options_fig,'Tag','StaticText_BGcolor'),'Position',ud.BGcolorTextPosition);
			set(findobj(options_fig,'Tag','EditText_BGcolor'),'Position',ud.BGcolorEditPosition);
			set(findobj(options_fig,'Tag','Pushbutton_get_BGcolor'),'Position',ud.BGcolorGetButtonPosition);
			set(findobj(options_fig,'Tag','StaticText_BGimage'),'Position',ud.BGimageTextPosition);
			set(findobj(options_fig,'Tag','EditText_BGimage'),'Position',ud.BGimageEditPosition);
			set(findobj(options_fig,'Tag','Pushbutton_get_BGimage'),'Position',ud.BGimageGetButtonPosition);
			set(findobj(options_fig,'Tag','text_Framecolor'),'Position',ud.FramecolorTextPosition);
			set(findobj(options_fig,'Tag','EditText_Framecolor'),'Position',ud.FramecolorEditPosition);
			set(findobj(options_fig,'Tag','Pushbutton_get_Framecolor'),'Position',ud.FramecolorGetButtonPosition);
			set(findobj(options_fig,'Tag','text_buttoncolor'),'Position',ud.ButtoncolorTextPosition);
			set(findobj(options_fig,'Tag','EditText_Buttoncolor'),'Position',ud.ButtoncolorEditPosition);
			set(findobj(options_fig,'Tag','Pushbutton_get_Buttoncolor'),'Position',ud.ButtoncolorGetButtonPosition);
			set(findobj(options_fig,'Tag','text_fill_incolor'),'Position',ud.Fill_incolorTextPosition);
			set(findobj(options_fig,'Tag','EditText_Fill_incolor'),'Position',ud.Fill_incolorEditPosition);
			set(findobj(options_fig,'Tag','Pushbutton_get_Fill_incolor'),'Position',ud.Fill_incolorGetButtonPosition);
			set(findobj(options_fig,'Tag','text_fontcolor'),'Position',ud.FontcolorTextPosition);
			set(findobj(options_fig,'Tag','EditText_Fontcolor'),'Position',ud.FontcolorEditPosition);
			set(findobj(options_fig,'Tag','Pushbutton_get_Fontcolor'),'Position',ud.FontcolorGetButtonPosition);
			set(findobj(options_fig,'Tag','StaticText_save_log'),'Position',ud.SavelogCheckboxPosition);
			set(findobj(options_fig,'Tag','StaticText_splash'),'Position',ud.ShowsplashscreenCheckboxPosition);
			set(findobj(options_fig,'Tag','StaticText_waitbars'),'Position',ud.ShowwaitbarsCheckboxPosition);
			set(findobj(options_fig,'Tag','StaticText_save_position'),'Position',ud.SavepositionCheckboxPosition);
			set(findobj(options_fig,'Tag','Pushbutton_options_save'),'Position',ud.SaveButtonPosition);
			set(findobj(options_fig,'Tag','Pushbutton_options_close'),'Position',ud.CloseButtonPosition);
			set(findobj(options_fig,'Tag','Pushbutton_options_apply'),'Position',ud.ApplyButtonPosition);
			set(findobj(options_fig,'Tag','Popupmenu_layout'),'Value',ud.layout);
			
			ud.ChangeLayout = 0;
			set(options_fig,'UserData',ud);
		end
		
	end

	if isfield(ud,'logo_frac')  & isfield(ud,'bgcolor') & isfield(ud,'layout')
		set(findobj(options_fig,'Tag','EditText_logo'),'String',ud.logo_frac);
		set(findobj(options_fig,'Tag','Fig_gui_fl_options'),'Color',ud.bgcolor);
		set(findobj(options_fig,'Tag','EditText_BGcolor'),'String',num2str(ud.bgcolor));
		set(findobj(options_fig,'Tag','Fig_gui_fl_options'),'Color',ud.bgcolor);
		[logo_frac cmap_frac alpha_frac]=fl_getOption('Logo',ud.logo_frac,ud.bgcolor,ud.layout);
		set(findobj(options_fig,'Tag','Image1'),'CData',fliplr(flipud(logo_frac)));
		set(findobj(options_fig,'Tag','Image1'),'AlphaData',rot90(alpha_frac,2));
		set(findobj(options_fig,'Tag','Fig_gui_fl_options'),'Colormap',cmap_frac);
		size_logo = size(logo_frac);
		dimension = size(size_logo);
		if dimension(2) == 3
			logosize = size_logo(1:2);
		else
			logosize = size_logo;
		end
		if sum(logosize)
			set(findobj(options_fig,'Tag','Axes1'),'XLim',[1 logosize(2)]);
			set(findobj(options_fig,'Tag','Axes1'),'YLim',[1 logosize(1)]);
		end
        end
        
        if isfield(ud,'bgimage')
        	set(findobj(options_fig,'Tag','EditText_BGimage'),'String',ud.bgimage);
        end

	if isfield(ud,'framecolor')
		set(findobj(options_fig,'Tag','EditText_Framecolor'),'String',num2str(ud.framecolor));
		set(findobj(options_fig,'Tag','Frame_title'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','Frame_theme'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','Frame_options'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','StaticText6'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','StaticText_theme'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','StaticText_logo'),'BackgroundColor',ud.framecolor);	
		set(findobj(options_fig,'Tag','StaticText_layout'),'BackgroundColor',ud.framecolor);	
		set(findobj(options_fig,'Tag','StaticText_BGcolor'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','StaticText_BGimage'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','text_Framecolor'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','text_buttoncolor'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','text_fill_incolor'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','text_fontcolor'),'BackgroundColor',ud.framecolor);				
		set(findobj(options_fig,'Tag','StaticText_save_log'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','StaticText_save_position'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','StaticText_splash'),'BackgroundColor',ud.framecolor);
		set(findobj(options_fig,'Tag','StaticText_waitbars'),'BackgroundColor',ud.framecolor);
	end
	
	if isfield(ud,'buttoncolor')
		set(findobj(options_fig,'Tag','EditText_Buttoncolor'),'String',num2str(ud.buttoncolor));
		set(findobj(options_fig,'Tag','Pushbutton_get_logo'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_BGcolor'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_BGimage'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Framecolor'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Buttoncolor'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Fill_incolor'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Fontcolor'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_options_close'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_options_save'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_options_apply'),'BackgroundColor',ud.buttoncolor);
		set(findobj(options_fig,'Tag','Pushbutton_manage_theme'),'BackgroundColor',ud.buttoncolor);
	end
	
	if isfield(ud,'fill_incolor')
		set(findobj(options_fig,'Tag','EditText_Fill_incolor'),'String',num2str(ud.fill_incolor));
		set(findobj(options_fig,'Tag','EditText_logo'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','Popupmenu_layout'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','EditText_BGcolor'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','EditText_BGimage'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','EditText_Framecolor'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','EditText_Buttoncolor'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','EditText_Fill_incolor'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','EditText_Fontcolor'),'BackgroundColor',ud.fill_incolor);
		set(findobj(options_fig,'Tag','Popupmenu_theme'),'BackgroundColor',ud.fill_incolor);
	end
	
	if isfield(ud,'fontcolor')
		set(findobj(options_fig,'Tag','EditText_Fontcolor'),'String',num2str(ud.fontcolor));
		set(findobj(options_fig,'Tag','StaticText6'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_theme'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Popupmenu_theme'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_logo'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_layout'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_logo'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Popupmenu_layout'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_logo'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_BGcolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_BGimage'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_BGcolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_BGimage'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_BGcolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_BGimage'),'ForegroundColor',ud.fontcolor);		
		set(findobj(options_fig,'Tag','text_Framecolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_Framecolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Framecolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','text_buttoncolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_Buttoncolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Buttoncolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','text_fill_incolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_Fill_incolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Fill_incolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','text_fontcolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_Fontcolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','EditText_Fontcolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_get_Fontcolor'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_save_log'),'ForegroundColor',ud.fontcolor);		
		set(findobj(options_fig,'Tag','StaticText_save_position'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_splash'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','StaticText_waitbars'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_options_close'),'ForegroundColor',ud.fontcolor);		
		set(findobj(options_fig,'Tag','Pushbutton_options_save'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_options_apply'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Pushbutton_manage_theme'),'ForegroundColor',ud.fontcolor);	
		set(findobj(options_fig,'Tag','Frame_title'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Frame_theme'),'ForegroundColor',ud.fontcolor);
		set(findobj(options_fig,'Tag','Frame_options'),'ForegroundColor',ud.fontcolor);	
	end	

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'manage_themes'
    %%%%%%%%%%%%%%%%%%%%%%%%%%	
	
	gui_fl_managethemes

    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_logo'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
     
	flroot = fl_getOption('FracLabRoot');
	dataroot = fullfile(flroot,'data',filesep);
	
	LogoFileName = uigetfile( ...
       {'*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.tif', 'Common graphic Files'; ...
        '*.*',                   'All Files (*.*)'}, ...
        'Choose FracLab logo',...
        dataroot);
        
        if LogoFileName ~= 0
	        set(findobj(options_fig,'Tag','EditText_logo'),'String',LogoFileName);
	    
	        [logo_frac cmap_frac] = imread(LogoFileName);
		bgcolor = fl_getOption('BackGroundColor',LogoFileName);
		
		set(findobj(options_fig,'Tag','EditText_BGcolor'),'String',num2str(bgcolor));
		
		ud.logo_frac = LogoFileName;
		ud.bgcolor = bgcolor;
		ud.cmap_frac = cmap_frac;
		set(options_fig,'UserData',ud);
		fl_options_compute('apply_changes');
	end


    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'edittext_logo'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	
	LogoFileName = get(findobj(options_fig,'Tag','EditText_logo'),'String');
        
        if ~isempty(LogoFileName)    
	        [logo_frac cmap_frac] = imread(LogoFileName);
		bgcolor = fl_getOption('BackGroundColor',LogoFileName);
		ud.logo_frac = LogoFileName;
		ud.bgcolor = bgcolor;
		set(options_fig,'UserData',ud);
		fl_options_compute('apply_changes');
	end

    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_BGcolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	BGcolor = uisetcolor;
	if length(BGcolor) ~= 1
		ud.bgcolor = BGcolor;
		set(options_fig,'UserData',ud);	
		fl_options_compute('apply_changes');
	end

	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'edittext_BGcolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	BGcolor = str2num(get(findobj(options_fig,'Tag','EditText_BGcolor'),'String'));
	ud.bgcolor = BGcolor;
	set(options_fig,'UserData',ud);	
	fl_options_compute('apply_changes');

    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_BGimage'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	flroot = fl_getOption('FracLabRoot');
	dataroot = fullfile(flroot,'data',filesep);
	
	BGimageFileName = uigetfile( ...
       {'*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.tif', 'Common graphic Files'; ...
        '*.*',                   'All Files (*.*)'}, ...
        'Choose Background image',...
        dataroot);
        
        if BGimageFileName ~= 0
	        set(findobj(options_fig,'Tag','EditText_BGimage'),'String',BGimageFileName);
		ud.bgimage = BGimageFileName;
		set(options_fig,'UserData',ud);
		fl_options_compute('apply_changes');
	end

	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'edittext_BGimage'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	BGimage = get(findobj(options_fig,'Tag','EditText_BGimage'),'String');
	ud.bgimage = BGimage;
	set(options_fig,'UserData',ud);	
	fl_options_compute('apply_changes');
	

    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_Framecolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	framecolor = uisetcolor;
	if length(framecolor) ~= 1
		%set(findobj(options_fig,'Tag','EditText_Framecolor'),'String',num2str(framecolor));

		ud.framecolor = framecolor;
		set(options_fig,'UserData',ud);	
		fl_options_compute('apply_changes');
	end
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'edittext_Framecolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	framecolor = str2num(get(findobj(options_fig,'Tag','EditText_Framecolor'),'String'));
	
	ud.framecolor = framecolor;
	set(options_fig,'UserData',ud);	
	fl_options_compute('apply_changes');		
	
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_Buttoncolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	buttoncolor = uisetcolor;
	if length(buttoncolor) ~= 1
		%set(findobj(options_fig,'Tag','EditText_Buttoncolor'),'String',num2str(buttoncolor));
		
		ud.buttoncolor = buttoncolor;
		set(options_fig,'UserData',ud);	
		fl_options_compute('apply_changes');
	end


    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'edittext_Buttoncolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	buttoncolor = str2num(get(findobj(options_fig,'Tag','EditText_Buttoncolor'),'String'));
	
	ud.buttoncolor = buttoncolor;
	set(options_fig,'UserData',ud);	
	fl_options_compute('apply_changes');	



    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_Fill_incolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	fill_incolor = uisetcolor;
	if length(fill_incolor) ~= 1

		ud.fill_incolor = fill_incolor;
		set(options_fig,'UserData',ud);	
		fl_options_compute('apply_changes');
	end
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'edittext_Fill_incolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	fill_incolor = str2num(get(findobj(options_fig,'Tag','EditText_Fill_incolor'),'String'));
	
	ud.fill_incolor = fill_incolor;
	set(options_fig,'UserData',ud);	
	fl_options_compute('apply_changes');	
	
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_Fontcolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	fontcolor = uisetcolor;
	if length(fontcolor) ~= 1

		ud.fontcolor = fontcolor;
		set(options_fig,'UserData',ud);	
		fl_options_compute('apply_changes');
	end
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'edittext_Fontcolor'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	fontcolor = str2num(get(findobj(options_fig,'Tag','EditText_Fontcolor'),'String'));
	
	ud.fontcolor = fontcolor;
	set(options_fig,'UserData',ud);	
	fl_options_compute('apply_changes');		


	
    %%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'save'
    %%%%%%%%%%%%%%%%%%%%%%%%%%

	Layout = get(findobj(options_fig,'Tag','Popupmenu_layout'),'Value');
	LogoFileName = get(findobj(options_fig,'Tag','EditText_logo'),'String');
	BackGroundColor = str2num(get(findobj(options_fig,'Tag','EditText_BGcolor'),'String'));
	BackGroundFileName = get(findobj(options_fig,'Tag','EditText_BGimage'),'String');
	LogoColorMap = fl_getOption('LogoColorMap',LogoFileName);
	FrameColor = str2num(get(findobj(options_fig,'Tag','EditText_Framecolor'),'String'));
	ButtonColor = str2num(get(findobj(options_fig,'Tag','EditText_Buttoncolor'),'String'));
	Fill_inColor = str2num(get(findobj(options_fig,'Tag','EditText_Fill_incolor'),'String'));
	FontColor = str2num(get(findobj(options_fig,'Tag','EditText_Fontcolor'),'String'));
	SaveLog = get(findobj(options_fig,'Tag','StaticText_save_log'),'Value');
	SavePosition = get(findobj(options_fig,'Tag','StaticText_save_position'),'Value');
	ShowSplashScreen = get(findobj(options_fig,'Tag','StaticText_splash'),'Value');
	ShowWaitBars = get(findobj(options_fig,'Tag','StaticText_waitbars'),'Value');
	%ForceBackGroundColor = get(findobj(options_fig,'Tag','StaticText_force_bgcolor'),'Value');
	ForceBackGroundColor = 0;
	
	flroot = fl_getOption('FracLabRoot');
	fltoolmat = fullfile(flroot,'Gui','fltool.mat');
	p=version;
	try
		if str2num(p(1))>=7
			save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','SaveLog','ShowSplashScreen','ShowWaitBars','ForceBackGroundColor','Fill_inColor','FontColor','SavePosition','-v6','-append');
		else
			save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','SaveLog','ShowSplashScreen','ShowWaitBars','ForceBackGroundColor','Fill_inColor','FontColor','SavePosition','-append');
		end
	catch
		if str2num(p(1))>=7
			save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','SaveLog','ShowSplashScreen','ShowWaitBars','ForceBackGroundColor','Fill_inColor','FontColor','SavePosition','-v6');
		else
			save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','SaveLog','ShowSplashScreen','ShowWaitBars','ForceBackGroundColor','Fill_inColor','FontColor','SavePosition');
		end
	end


    %%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'close'
    %%%%%%%%%%%%%%%%%%%%%%%%%%

   	close (options_fig);
   	managethemes_fig = findobj ('Tag','Fig_gui_fl_managethemes');
   	if ~isempty(managethemes_fig)
   		close(managethemes_fig);
   	end
    
       %%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'apply'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
	fl_options_compute('save');
	fraclabhandle=findobj('Tag','FRACLAB Toolbox');
	if ~isempty(fraclabhandle)
		%Mise à jour des autres fenêtres
		ud = get(fraclabhandle,'UserData');
		if isfield(ud,'OpenedWindows')
			seplist = [0 find(ud.OpenedWindows=='|')];
			for i=1:length(seplist)-1;
				openedWindows = ud.OpenedWindows;
				openedWindow = openedWindows(seplist(i)+1:seplist(i+1)-1);
				openedWindowHandle=findobj('Tag',openedWindow);
				if ~isempty(openedWindowHandle)
					try
						fl_window_init(openedWindowHandle,'ApplyTheme');
					end
				end
				
			end
		end
		%Cas particulier de la Fenêtre FracLab, mise à jour du logo et refresh du layout
		fltool('RefreshLayout');
	end
  
end

set(0,'ShowHiddenHandles',ShowHiddenHandlesInit);