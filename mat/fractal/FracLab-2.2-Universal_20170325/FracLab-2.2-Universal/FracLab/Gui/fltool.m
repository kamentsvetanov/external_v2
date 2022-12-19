function fltool(varargin)
% This is the machine-generated representation of a MATLAB object
% and its children.  Note that handle values may change when these
% objects are re-created. This may cause problems with some callbacks.
% The command syntax may be supported in the future, but is currently 
% incomplete and subject to change.
%
% To re-open this system, just type the name of the m-file at the MATLAB
% prompt. The M-file and its associtated MAT-file must be on your path.

% Modified by Christian Choque Cortez, November 2009
% Modified by Pierrick Legrand, November 2016
% Modified by Pierrick Legrand, March 2017

% FracLab 2.2, Copyright © 1996 - 2017 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

frac_version = '2.2'; %#ok<NASGU>

[logo_frac cmap_frac alpha_frac]=fl_getOption('Logo');
[bg_frac bg_cmap_frac]= fl_getOption('BackGround');
frac_color=fl_getOption('FrameColor');

switch(fl_getOption('Layout'))
case 1
	%LayoutHonrizontal
	LogoAxesPosition = [0.05 0.8 0.90 0.1725];
	MainFramePosition = [0.0390625 0.227045075125209 0.91796875 0.550918196994992];
	ImportFramePosition  = [0.511953125 0.247078464106845 0.4140625 0.120200333889816];
	ImportFrameTextPosition  = [0.58421875 0.318864774624374 0.26953125 0.0300500834724541];
	VariableFramePosition = [0.073984375 0.247078464106845 0.4140625 0.120200333889816];
	VariableFrameTextPosition = [0.14625 0.318864774624374 0.26953125 0.0300500834724541];
	MessageFramePosition = [0.0390625 0.118530884808013 0.919921875 0.10016694490818];
	ActionsFramePosition = [0.037109375 0.0217028380634391 0.919921875 0.0868113522537563];
	VariablesListboxPosition = [0.111328125 0.387312186978297 0.359375 0.320534223706177];
	VariablesTextPosition = [0.228515625 0.719532554257095 0.126953125 0.0317195325542571];
	DetailsListboxPosition = [0.53125 0.387312186978297 0.35546875 0.320534223706177];
	DetailsTextPosition = [0.646484375 0.719532554257095 0.126953125 0.0317195325542571];
	ViewButtonPosition = [0.10328125 0.265442404006678 0.1015625 0.0400667779632721];
	ClearButtonPosition = [0.226328125 0.265442404006678 0.109375 0.0400667779632721];
	SaveButtonPosition = [0.355234375 0.265442404006678 0.10546875 0.0400667779632721];
	FileButtonPosition = [0.547109375 0.265442404006678 0.162109375 0.0400667779632721];
	WorkspaceButtonPosition = [0.744375 0.265442404006678 0.150390625 0.0400667779632721];
	MessageTextPosition = [0.076171875 0.145258764607679 0.11546875 0.0287111853088481];
	MessageEditPosition = [0.076171875 0.146911519198664 0.7171875 0.0350584307178631];
	EraseButtonPosition = [0.830078125 0.146911519198664 0.099609375 0.0400667779632721];
	CustomizeButtonPosition = [0.060546875 0.0400667779632721 0.1875 0.0534223706176962];
	HelpButtonPosition = [0.28859375 0.0400667779632721 0.1875 0.0534223706176962];
	DemosButtonPosition = [0.5178125 0.0400667779632721 0.1875 0.0534223706176962];
	QuitButtonPosition = [0.751953125 0.0400667779632721 0.1875 0.0534223706176962];
	DetailsTextBackgroundColor = frac_color;
	VariablesTextBackgroundColor = frac_color;
	MessageTextBackgroundColor = frac_color;
% 	DetailsTextForegroundColor = frac_color;
    FileText = 'File';

case 2
	%LayoutVertical 1
	LogoAxesPosition = [0.02375 0.0433333333333333 0.1725 0.901666666666667];
	MainFramePosition = [0.21875 0.226666666666667 0.7675 0.751666666666667];
	ImportFramePosition  = [0.61375 0.246666666666667 0.35125 0.13];
	ImportFrameTextPosition  = [0.65375 0.328333333333333 0.27 0.03];
	VariableFramePosition = [0.23875 0.246666666666667 0.35125 0.13];
	VariableFrameTextPosition = [0.27875 0.328333333333333 0.27 0.03];
	DetailsListboxPosition = [0.62375 0.413333333333333 0.33 0.466666666666667];
	DetailsTextPosition = [0.725 0.913333333333334 0.1275 0.0316666666666667];
	MessageFramePosition = [0.2190625 0.118530884808013 0.769921875 0.10016694490818];
	ActionsFramePosition = [0.217109375 0.0217028380634391 0.769921875 0.0868113522537563];
	VariablesListboxPosition = [0.25125 0.413333333333333 0.325 0.47];
	VariablesTextPosition = [0.35 0.913333333333334 0.1275 0.0316666666666667];
	ViewButtonPosition = [0.25375 0.265 0.09 0.04];
	ClearButtonPosition = [0.36875 0.265 0.09 0.04];
	SaveButtonPosition = [0.485 0.265 0.09 0.04];
	FileButtonPosition = [0.63375 0.265 0.1475 0.04];
	WorkspaceButtonPosition = [0.8075 0.265 0.13375 0.04];
	MessageTextPosition = [0.2525 0.155 0.08125 0.0266666666666667];
	MessageEditPosition = [0.2525 0.146666666666667 0.5975 0.0366666666666667];
	EraseButtonPosition = [0.86375 0.146666666666667 0.1 0.04];
	CustomizeButtonPosition = [0.24625 0.038 0.15375 0.0516666666666667];
	HelpButtonPosition = [0.43 0.038 0.15375 0.0516666666666667];
	DemosButtonPosition = [0.61625 0.038 0.15375 0.0516666666666667];
	QuitButtonPosition = [0.80625 0.038 0.15375 0.0516666666666667];
	DetailsTextBackgroundColor = frac_color;
	VariablesTextBackgroundColor = frac_color;
	MessageTextBackgroundColor = frac_color;
    FileText = 'File';    
	
case 3
	%LayoutVertical 2
	LogoAxesPosition = [0.02375 0.0433333333333333 0.1725 0.901666666666667];
	MainFramePosition = [0.218781218781219 0.152097902097902 0.615384615384615 0.825174825174825];
	ImportFramePosition  = [0.534465534465534 0.190559440559441 0.28971028971029 0.129370629370629];
	ImportFrameTextPosition  = [0.544455544455544 0.277972027972028 0.26973026973027 0.0297202797202797];
	VariableFramePosition = [0.232767232767233 0.190559440559441 0.28971028971029 0.129370629370629];
	VariableFrameTextPosition = [0.242757242757243 0.277972027972028 0.26973026973027 0.0297202797202797];
	DetailsListboxPosition = [0.542457542457542 0.368881118881119 0.274725274725275 0.5];
	DetailsTextPosition = [0.615384615384615 0.902097902097902 0.127872127872128 0.0314685314685315];
	MessageFramePosition = [0.218781218781219 0.0262237762237762 0.615384615384615 0.11013986013986];
	ActionsFramePosition = [0.848151848151848 0.0262237762237762 0.138861138861139 0.951048951048951];
	VariablesListboxPosition = [0.240759240759241 0.368881118881119 0.274725274725275 0.5];
	VariablesTextPosition = [0.313686313686314 0.902097902097902 0.127872127872128 0.0314685314685315];
	ViewButtonPosition = [0.244755244755245 0.213286713286713 0.0799200799200799 0.0402097902097902];
	ClearButtonPosition = [0.337662337662338 0.215034965034965 0.0799200799200799 0.0402097902097902];
	SaveButtonPosition = [0.431568431568432 0.213286713286713 0.0799200799200799 0.0402097902097902];
	FileButtonPosition = [0.548451548451548 0.213286713286713 0.11988011988012 0.0402097902097902];
	WorkspaceButtonPosition = [0.689310689310689 0.215034965034965 0.11988011988012 0.0402097902097902];
	MessageTextPosition = [0.232767232767233 0.0646853146853147 0.0669430569430569 0.027972027972028];
	MessageEditPosition = [0.232767232767233 0.0576923076923077 0.493556443556444 0.0402097902097902];
	EraseButtonPosition = [0.746253746253746 0.0576923076923077 0.0799200799200799 0.0402097902097902];
	CustomizeButtonPosition = [0.867132867132867 0.722027972027972 0.0999000999000999 0.0594405594405594];
	HelpButtonPosition = [0.867132867132867 0.592657342657343 0.0999000999000999 0.0594405594405594];
	DemosButtonPosition = [0.867132867132867 0.45979020979021 0.0999000999000999 0.0594405594405594];
	QuitButtonPosition = [0.867132867132867 0.0594405594405594 0.0999000999000999 0.0594405594405594];
	DetailsTextBackgroundColor = frac_color;
	VariablesTextBackgroundColor = frac_color;
	MessageTextBackgroundColor = frac_color;
    FileText = 'File';
    
case 4
	%Layout Mirror
	LogoAxesPosition = [0.04 0.0433333333333333 0.12 0.81];
	MainFramePosition = [0 0 1e-10 1e-10];
	ImportFramePosition  = [0 0 1e-10 1e-10];
	ImportFrameTextPosition  = [0 0 1e-10 1e-10];
	VariableFramePosition = [0 0 1e-10 1e-10];
	VariableFrameTextPosition = [0 0 1e-10 1e-10];
	DetailsListboxPosition = [0.62375 0.533333333333333 0.325 0.38];
	DetailsTextPosition = [0.725 0.933333333333334 0.1275 0.0316666666666667];
	MessageFramePosition = [0 0 1e-10 1e-10];
	ActionsFramePosition = [0 0 1e-10 1e-10];
	VariablesListboxPosition = [0.22125 0.533333333333333 0.325 0.38];
	VariablesTextPosition = [0.32 0.933333333333334 0.1275 0.0316666666666667];
	
	ClearButtonPosition = [0.80625 0.44 0.15375 0.045];
	SaveButtonPosition = [0.60625 0.44 0.15375 0.045];
	FileButtonPosition = [0.41 0.44 0.15375 0.045];
	WorkspaceButtonPosition = [0.21625 0.44 0.15375 0.045];
	
	MessageTextPosition = [0.2225 0.185 0.09125 0.0266666666666667];
	MessageEditPosition = [0.2225 0.176666666666667 0.6275 0.045];
	EraseButtonPosition = [0.80625+0.07 0.176666666666667 0.15375-0.07 0.045];
	
	CustomizeButtonPosition = [0.80625 0.33 0.15375 0.045];
	DemosButtonPosition = [0.41 0.33 0.15375 0.045];
	ViewButtonPosition = [0.21625 0.33 0.15375 0.045];
	HelpButtonPosition = [0.60625 0.33 0.15375 0.045];
	
	QuitButtonPosition = [0.80625+0.07 0.05 0.15375-0.07 0.045];
	
	
	bgsize = size(bg_frac);
	if sum(bgsize)
		dimension = size(bgsize);
		DetailsTextBGPosition = floor(bgsize(1:2).*([1-DetailsTextPosition(2) DetailsTextPosition(1)]));
		VariablesTextBGPosition = floor(bgsize(1:2).*([1-VariablesTextPosition(2) VariablesTextPosition(1)]));
		MessageTextBGPosition = floor(bgsize(1:2).*([1-MessageTextPosition(2) MessageTextPosition(1)]));
		if dimension(2) == 3
			DetailsTextBackgroundColor = 1/255*double(bg_frac(DetailsTextBGPosition(1),DetailsTextBGPosition(2),:));
			VariablesTextBackgroundColor = 1/255*double(bg_frac(VariablesTextBGPosition(1),VariablesTextBGPosition(2),:));
			MessageTextBackgroundColor = 1/255*double(bg_frac(MessageTextBGPosition(1),MessageTextBGPosition(2),:));
		else
			DetailsTextBackgroundColor = bg_cmap_frac(bg_frac(DetailsTextBGPosition(1),DetailsTextBGPosition(2))+1,:);
			VariablesTextBackgroundColor = bg_cmap_frac(bg_frac(VariablesTextBGPosition(1),VariablesTextBGPosition(2))+1,:);
			MessageTextBackgroundColor = bg_cmap_frac(bg_frac(MessageTextBGPosition(1),MessageTextBGPosition(2))+1,:);
		end
		
	else
		DetailsTextBackgroundColor = frac_color;
		VariablesTextBackgroundColor = frac_color;
		MessageTextBackgroundColor = frac_color;		
	end

    FileText = 'Load';

case 5
	%Layout Circle
	LogoAxesPosition = [0.01375 0.0433333333333333 0.1225 0.901666666666667];
	MainFramePosition = [0 0 1e-10 1e-10];
	ImportFramePosition  = [0 0 1e-10 1e-10];
	ImportFrameTextPosition  = [0 0 1e-10 1e-10];
	VariableFramePosition = [0 0 1e-10 1e-10];
	VariableFrameTextPosition = [0 0 1e-10 1e-10];
	DetailsListboxPosition = [0.64375 0.503333333333333 0.325 0.4];
	DetailsTextPosition = [0.745 0.923333333333334 0.1275 0.0316666666666667];
	MessageFramePosition = [0 0 1e-10 1e-10];
	ActionsFramePosition = [0 0 1e-10 1e-10];
	VariablesListboxPosition = [0.27125 0.503333333333333 0.325 0.4];
	VariablesTextPosition = [0.37 0.923333333333334 0.1275 0.0316666666666667];
	
	ClearButtonPosition = [0.82625 0.39 0.15375 0.045];
	SaveButtonPosition = [0.63625 0.39 0.15375 0.045];
	FileButtonPosition = [0.45 0.39 0.15375 0.045];
	WorkspaceButtonPosition = [0.26625 0.39 0.15375 0.045];
	
	MessageTextPosition = [0.205 0.275 0.08125 0.0266666666666667];
	MessageEditPosition = [0.205 0.266666666666667 0.6775 0.045];
	EraseButtonPosition = [0.82625+0.07 0.266666666666667 0.15375-0.07 0.045];
	
	CustomizeButtonPosition = [0.82625 0.15 0.15375 0.045];
	DemosButtonPosition = [0.45 0.15 0.15375 0.045];
	ViewButtonPosition = [0.26625 0.15 0.15375 0.045];
	HelpButtonPosition = [0.63625 0.15 0.15375 0.045];
	
	QuitButtonPosition = [0.79625+0.07 0.03 0.15375-0.07 0.045];
	DetailsTextBackgroundColor = frac_color;
	VariablesTextBackgroundColor = frac_color;
	MessageTextBackgroundColor = frac_color;

    FileText = 'Load';
    
end

ShowHiddenHandlesInit = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fraclabhandle=findobj('Tag','FRACLAB Toolbox');
set(0,'ShowHiddenHandles',ShowHiddenHandlesInit);

if ~isempty(fraclabhandle)
    if strcmp(varargin,'RefreshLayout')
        axes_frac = findobj(fraclabhandle,'Tag','Axes1');
        logosize = fl_getOption('LogoSize');
        if sum(logosize)
            set(axes_frac,'XLim',[1 logosize(2)]);
            set(axes_frac,'YLim',[1 logosize(1)]);
        end
        image_frac = findobj(fraclabhandle,'Tag','Image1');
        [logo_frac cmap_frac alpha_frac]=fl_getOption('Logo');
        set(image_frac,'CData',logo_frac);
        set(image_frac,'AlphaData',alpha_frac);

        axes_frac = findobj(fraclabhandle,'Tag','Axes2');
        bgsize = fl_getOption('BackGroundSize');
        if sum(bgsize)
            set(axes_frac,'XLim',[1 bgsize(2)]);
            set(axes_frac,'YLim',[1 bgsize(1)]);
        end
        image_frac = findobj(fraclabhandle,'Tag','Image2');
        set(image_frac,'CData',fl_getOption('BackGround'));

        set(findobj(fraclabhandle,'Tag','Axes1'),'Position',LogoAxesPosition);
        set(findobj(fraclabhandle,'Tag','Frame_List'),'Position',MainFramePosition);
        set(findobj(fraclabhandle,'Tag','frame8'),'Position',ImportFramePosition);
        set(findobj(fraclabhandle,'Tag','text2'),'Position',ImportFrameTextPosition);
        set(findobj(fraclabhandle,'Tag','frame11'),'Position',VariableFramePosition);
        set(findobj(fraclabhandle,'Tag','text4'),'Position',VariableFrameTextPosition);
        set(findobj(fraclabhandle,'Tag','Listbox_details'),'Position',DetailsListboxPosition);
        set(findobj(fraclabhandle,'Tag','StaticText_Details'),'Position',DetailsTextPosition);
        set(findobj(fraclabhandle,'Tag','Frame_Message'),'Position',MessageFramePosition);
        set(findobj(fraclabhandle,'Tag','frame7'),'Position',ActionsFramePosition);
        set(findobj(fraclabhandle,'Tag','Listbox_variables'),'Position',VariablesListboxPosition);
        set(findobj(fraclabhandle,'Tag','StaticText_Variables'),'Position',VariablesTextPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_inview'),'Position',ViewButtonPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_inclear'),'Position',ClearButtonPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_insave'),'Position',SaveButtonPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_inload'),'Position',FileButtonPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_scanwks'),'Position',WorkspaceButtonPosition);
        set(findobj(fraclabhandle,'Tag','StaticText_mes_error'),'Position',MessageTextPosition);
        set(findobj(fraclabhandle,'Tag','StaticText_error'),'Position',MessageEditPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_erase_error'),'Position',EraseButtonPosition);
        set(findobj(fraclabhandle,'Tag','Customize_Button'),'Position',CustomizeButtonPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_help'),'Position',HelpButtonPosition);
        set(findobj(fraclabhandle,'Tag','Pushbutton_tuto'),'Position',DemosButtonPosition);
        set(findobj(fraclabhandle,'Tag','Quit_Button'),'Position',QuitButtonPosition);

        set(findobj(fraclabhandle,'Tag','StaticText_Details'),'BackgroundColor',DetailsTextBackgroundColor);
        set(findobj(fraclabhandle,'Tag','StaticText_Variables'),'BackgroundColor',VariablesTextBackgroundColor);
        set(findobj(fraclabhandle,'Tag','StaticText_mes_error'),'BackgroundColor',MessageTextBackgroundColor);

        set(findobj(fraclabhandle,'Tag','Pushbutton_inload'),'String',FileText);

        switch(fl_getOption('Layout'))
            case 1
                ratio34 = 1.1;
            case 2
                ratio34 = 0.8;
            case 3
                ratio34 = 0.65;
            case 4
                ratio34 = 0.75;
            case 5
                ratio34 = 0.8;
        end

        FigurePosition = get(fraclabhandle,'Position');
        FigurePosition(4) = ratio34*FigurePosition(3);
        set(fraclabhandle,'Position',FigurePosition);

        if fl_getOption('Layout') == 4
            set(findobj(fraclabhandle,'Tag','StaticText_Details'),'ForegroundColor',MessageTextBackgroundColor);
            set(findobj(fraclabhandle,'Tag','StaticText_Variables'),'ForegroundColor',MessageTextBackgroundColor);
        end

    else
        figure(fraclabhandle);
        disp('Fraclab 2.2 is already started');
    end
    return
end

WindowsScreenSize = get(0,'ScreenSize');
if fl_getOption('SavePosition')
	frac_position = fl_getOption('FracLabPosition');
else
	frac_position = [0.15*WindowsScreenSize(3) 0.10*WindowsScreenSize(4) 640 690];
end

a = figure('Color',fl_getOption('BackGroundColor'), ...
    'colormap',cmap_frac,'HandleVisibility','callback','MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
    'CloseRequestFcn','fl_function(''close_all'');','IntegerHandle','off','NumberTitle','off', ...
    'Name','FRACLAB Toolbox','Units','pixels','Position',frac_position,'Tag','FRACLAB Toolbox');

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],...
    'Position',MainFramePosition ,'Style','frame','Tag','Frame_List');

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels',...
    'Callback','fl_clearerror;fl_details;',...
    'Position',VariablesListboxPosition,'Style','listbox',...
    'BackgroundColor',fl_getOption('Fill_inColor'),'Tag','Listbox_variables');

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],...
    'Position',VariableFramePosition,'Style','frame','Tag','frame11');

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],...
    'Position',ImportFramePosition,'Style','frame','Tag','frame8');

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],...
    'Position',ActionsFramePosition,'Style','frame','Tag','frame7');

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],...
    'Position',MessageFramePosition,'Style','frame','Tag','Frame_Message');

uicontrol('Parent',a,'Units','normalized',...
    'BackgroundColor',fl_getOption('Fill_inColor'),...
    'FontUnits','pixels','Enable','inactive','FontSize',12,'FontWeight','bold',...
    'Position',MessageEditPosition,'Style','edit','Tag','StaticText_error');

uicontrol('Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontWeight','bold','FontSize',12,...
    'Callback','fl_function(''erase_error'');',...
    'Position',EraseButtonPosition,'String','Erase','Tag','Pushbutton_erase_error');

uicontrol('Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontSize',12,'FontWeight','bold',...
    'Callback','fl_doc fraclab_demos',...
    'Position',DemosButtonPosition,'String','Demos','Tag','Pushbutton_tuto');

uicontrol('Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontSize',12,'FontWeight','bold',...
    'Callback','fl_doc  fraclab_product_page;',...
    'Position',HelpButtonPosition,'String','Help','Tag','Pushbutton_help');

uicontrol('Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontSize',12,'FontWeight','bold',...
    'Callback','fl_callwindow(''gui_view_toolbar'',''gui_view_toolbar'');',...
    'Position',ViewButtonPosition,'String','View','Tag','Pushbutton_inview');

uicontrol('Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontSize',12,'FontWeight','bold',...
    'Callback','fl_function(''mn_save_file'');',...
    'Position',SaveButtonPosition,'String','Save','Tag','Pushbutton_insave');

uicontrol('Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontSize',12,'FontWeight','bold',...
    'Callback','fl_function(''mn_load_file'');',...
    'Position',FileButtonPosition,'String',FileText,'Tag','Pushbutton_inload','UserData',[]);

uicontrol('Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontSize',12,'FontWeight','bold',...
    'Callback','eval([''clear global '' fl_function(''clear'',0)]);',...
    'Position',ClearButtonPosition,'String','Clear','Tag','Pushbutton_inclear');

uicontrol(...
    'Parent',a,'Units','normalized',...
    'FontUnits','pixels','BackgroundColor',[0.8 0.8 0.8],'FontSize',12,'FontWeight','bold',...
    'Callback','fl_function(''mn_scanwks'',whos);',...
    'Position',WorkspaceButtonPosition,'String','Workspace','Tag','Pushbutton_scanwks','UserData',[]);

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels','BackgroundColor',fl_getOption('Fill_inColor'),...
    'Position',DetailsListboxPosition,'Style','listbox','Tag','Listbox_details');

uicontrol('Parent',a,'Units','normalized','FontUnits','pixels','FontSize',12,'FontWeight','bold',...
    'BackgroundColor',DetailsTextBackgroundColor,...
    'Position',DetailsTextPosition,'String','Details','Style','text','Tag','StaticText_Details');

uicontrol('Parent',a,'Units','normalized','BackgroundColor',VariablesTextBackgroundColor,...
    'FontUnits','pixels','FontSize',12,'FontWeight','bold',...
    'Position',VariablesTextPosition,'String','Variables','Style','text','Tag','StaticText_Variables');

uicontrol('Parent',a,'Units','normalized','BackgroundColor',fl_getOption('FrameColor'),...
    'FontUnits','pixels','FontSize',12,'FontWeight','bold',...
    'Position',ImportFrameTextPosition,'String','Import data from :','Style','text','Tag','text2');

uicontrol('Parent',a,'Units','normalized','BackgroundColor',fl_getOption('FrameColor'),...
    'FontUnits','pixels','FontWeight','bold','FontSize',12,...
    'Position',VariableFrameTextPosition,'String','Variable :','Style','text','Tag','text4');

uicontrol('Parent',a,'Units','normalized','BackgroundColor',[0.8 0.8 0.8],...
    'Callback','fl_callwindow(''Fig_gui_fl_options'',''gui_fl_options'') ;', ...
    'FontUnits','pixels','FontSize',12,'FontWeight','bold',...
    'Position',CustomizeButtonPosition,'String','Customize','Tag','Customize_Button');

uicontrol('Parent',a,'Units','normalized','BackgroundColor',[0.8 0.8 0.8],...
    'Callback','fl_function(''close_all'');',...
    'FontUnits','pixels','FontSize',12,'FontWeight','bold',...
    'Position',QuitButtonPosition,'String','Quit','Tag','Quit_Button');

b = axes('Parent',a,'Units','normalized','Position',[0 0 1 1], ...
    'Tag','Axes2','YDir','reverse','Visible','off');

image('Parent',b,'CData',bg_frac,'Interruptible','off','Tag','Image2');

bgsize = fl_getOption('BackGroundSize');
if sum(bgsize)
    set(b,'XLim',[1 bgsize(2)]);
    set(b,'YLim',[1 bgsize(1)]);
end

b = axes('Parent',a,'Layer','top','Units','normalized','Position',LogoAxesPosition, ...
    'Tag','Axes1','Layer','top','YDir','reverse','Visible','off');

image('Parent',b,'CData',logo_frac,'AlphaData', alpha_frac,'Interruptible','off','Tag','Image1');

logosize = fl_getOption('LogoSize');
if sum(logosize)
    set(b,'XLim',[1 logosize(2)]);
    set(b,'YLim',[1 logosize(1)]);
end

%%%%%%%%%%%%%%%%%%%%%% SYNTHESIS MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Synthesis','Tag','Synthesis');

c = uimenu('Parent',b,'Label','Functions','Tag','Functions');

d = uimenu('Parent',c,'Label','Stochastic','Tag','Stochastic');

e = uimenu('Parent',d,'Label','Fractional Brownian Motion','Tag','fBm');

uimenu('Parent',e, ...
    'Callback','fl_callwindow(''Fig_gui_fl_fbmsynthesis'',''gui_fl_fbmsynthesis'');', ...
	'Label','1D','Tag','fbm1D');

uimenu('Parent',e, ...
    'Callback','fl_callwindow(''Fig_gui_fl_fbmsynthesis2d'',''gui_fl_fbm2d'');', ...
	'Label','2D','Tag','fbm2D');

e = uimenu('Parent',d,'Label','Multifractional Brownian Motion','Tag','mBm');

uimenu('Parent',e, ...
	'Callback', 'fl_callwindow(''Fig_gui_fl_mbmsynthesis'',''gui_fl_mbmsynthesis'');', ...
    'Label','1D','Tag','mbm1D');

uimenu('Parent',e, ...
    'Callback','fl_callwindow(''Fig_gui_fl_mbmsynthesis2d'',''gui_fl_mbm2d'');', ...
	'Label','2D','Tag','mbm2D');

e = uimenu('Parent',d,'Label','Self Regulating Multifractional Process','Tag','srmp');

uimenu('Parent',e, ...
	'Callback', 'fl_callwindow(''Fig_gui_fl_srmpsynthesis'',''gui_fl_srmpsynthesis'');', ...
    'Label','1D','Tag','srmp1D');

uimenu('Parent',e, ...
    'Callback','fl_callwindow(''Fig_gui_fl_srmpsynthesis2d'',''gui_fl_srmpsynthesis2d'');', ...
	'Label','2D','Tag','srmp2D');

uimenu('Parent',d, ...
    'Callback','fl_callwindow(''Fig_gui_fl_asmsynthesis'',''gui_fl_asmsynthesis'');', ...
	'Label','Alpha-Stable Process','Tag','asm1D');

uimenu('Parent',d, ...
    'Callback','fl_callwindow(''Fig_gui_fl_CGMY'',''gui_fl_CGMY'');', ...
	'Label','Tempered Alpha-Stable Process','Tag','tas1D');

uimenu('Parent',d, ...
    'Callback','fl_callwindow(''Fig_gui_fl_msmsynthesis'',''gui_fl_msmsynthesis'');', ...
	'Label','MultiStable Process','Tag','msm1D');

uimenu('Parent',d, ...
    'Callback','fl_callwindow(''Fig_gui_fl_MST'',''gui_fl_MST'');', ...
	'Label','Tempered MultiStable Process','Tag','mst1D');

uimenu('Parent',d, ...
	'Callback','fl_callwindow(''Fig_gui_fl_ebpsynthesis'',''gui_fl_ebpsynthesis'');', ...
	'Label','Embedded Branching Process','Tag','ebp');

uimenu('Parent',d, ...
	'Callback','fl_callwindow(''Fig_gui_fl_wbpsynthesis'',''gui_fl_wbpsynthesis'');', ...
	'Label','Wavelet-Based Process','Tag','wbp');

uimenu('Parent',d, ...
	'Callback','fl_callwindow(''Fig_gui_fl_weisynthesis'',''gui_fl_weisynthesis'');', ...
	'Label','Weierstrass Function','Tag','wei');

uimenu('Parent',d, ...
	'Callback','fl_callwindow(''Fig_gui_fl_ifsbsynthesis'',''gui_fl_ifsbsynthesis'');', ...
	'Label','IFS-Based Function','Tag','ifsb');

d = uimenu('Parent',c,'Label','Deterministic','Tag','Deterministic');

e = uimenu('Parent',d,'Label','IFS-Based Function','Tag','IFS-based');

uimenu('Parent',e, ...
	'Callback','fl_callwindow(''Fig_gui_fl_ifsbdsynthesis'',''gui_fl_ifsbdsynthesis'');', ...
	'Label','Fractal Interpolation Function','Tag','ifsbd');

uimenu('Parent',e, ...
	'Callback','fl_callwindow(''Fig_gui_fl_ifsgbdsynthesis'',''gui_fl_ifsgbdsynthesis'');', ...
	'Label','Generalized IFS','Tag','ifsgbd');

uimenu('Parent',d, ...
	'Callback','fl_callwindow(''Fig_gui_fl_weidsynthesis'',''gui_fl_weidsynthesis'');', ...
	'Label','Weierstrass Function','Tag','wei');

c = uimenu('Parent',b,'Label','Measures','Tag','Measures');

d = uimenu('Parent',c,'Label','Multinomial Measures','Tag','MuMeasures');

uimenu('Parent',d, ...
	'Callback', 'fl_callwindow(''Fig_gui_fl_mmssynthesis'',''gui_fl_mmssynthesis'');', ...
    'Label','1D','Tag','mms1D');

uimenu('Parent',d, ...
    'Callback','fl_callwindow(''Fig_gui_fl_mmssynthesis2d'',''gui_fl_mmssynthesis2d'');', ...
	'Label','2D','Tag','mms2D');

uimenu('Parent',b, ...
	'Callback','fl_callwindow(''Fig_gui_fl_dlasynthesis'',''gui_fl_dlasynthesis'');', ...
	'Label','Diffusion-Limited Aggregation','Tag','dla');

uimenu('Parent',b, ...
	'Callback','fl_callwindow(''Fig_gui_fl_percolation'',''gui_fl_percolation'');', ...
    'Label','Percolation','Tag','percolation');

uimenu('Parent',b, ...
	'Callback','fl_doc help_synthesis;', ...
	'Label','Help on Synthesis','Separator','on','Tag','help_synth');

uimenu('Parent',b, ...
    'Callback','fl_doc tuto_synthesis', ...
    'Label','Tutorial on Synthesis','Tag','tutorial_synth');

%%%%%%%%%%%%%%%%%%% FRACTAL DIMENSION MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Dimensions','Tag','Fractal Dimension');

c = uimenu('Parent',b,'Label','Regularization Dimension','Tag','Regularization Dimension');

uimenu('Parent',c,...
    'Callback','fl_callwindow(''Fig_gui_fl_regdim1d'',''gui_fl_regdim1d'');',...
	'Label','1D','Tag','Regdim 1D');

uimenu('Parent',c,...
    'Callback','fl_callwindow(''Fig_gui_fl_regdim2d'',''gui_fl_regdim2d'');',...
	'Label','2D','Tag','Regdim 2D');

d = uimenu('Parent',b,'Label','Box dimension : Box method','Tag','Box dimension : Box method');

uimenu('Parent',d,...
    'Callback','fl_boxdim_init(''Signal'')',...
	'Label','Signal or Grayscale Image','Tag','SBD');

uimenu('Parent',d,...
    'Callback','fl_boxdim_init(''Binary'')',...
	'Label','Binary Data','Tag','BBD');

uimenu('Parent',d,...
    'Callback','fl_boxdim_init(''List'')',...
	'Label','List of Points','Tag','GBD');

uimenu('Parent',b,...
	'Callback','fl_callwindow(''Fig_gui_fl_boxdimvariation'',''gui_fl_boxdimvariation'');',...
	'Label','Box Dimension : Variation Method','Tag','Box dimension : Variation method');

uimenu('Parent',b,...
	'Callback','fl_callwindow(''Fig_gui_fl_lacunarity'',''gui_fl_lacunarity'');',...
	'Label','Lacunarity','Tag','Lacunarity');
        
uimenu('Parent',b,...
	'Callback','fl_doc help_fdim;',...
	'Label','Help on Dimensions','Separator','on','Tag','help_dim');

uimenu('Parent',b, ...
    'Callback','fl_doc tuto_dimension', ...
    'Label','Tutorial on Dimensions','Tag','tutorial_dim');
        
%%%%%%%%%%%%%%%%%%%%%%%% EXPONENT MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Exponents','Tag','Estimation');

c = uimenu('Parent',b,'Label','Pointwise Holder Exponent','Tag','Pointwise Holder Exponent');

d = uimenu('Parent',c,'Label','GQV Based Estimation','Tag','GQV Based Estimation');

uimenu('Parent',d, ...
	'Callback','fl_callwindow(''Fig_gui_fl_estimGQV1DH'',''gui_fl_estimGQV1DH'') ;',...	
	'Label','1D','Tag','GQV 1D');

uimenu('Parent',d,...
	'Callback','fl_callwindow(''Fig_gui_fl_estimGQV2DH'',''gui_fl_estimGQV2DH'') ;',...	
	'Label','2D','Tag','GQV 2D');

d = uimenu('Parent',c,'Label','Oscillation Based Estimation','Tag','Oscillation Based Estimation');

uimenu('Parent',d,...
	'Callback','fl_callwindow(''Fig_gui_fl_estimOSC1DH'',''gui_fl_estimOSC1DH'') ;',...
	'Label','1D','Tag','Osc 1D');

uimenu('Parent',d,...
	'Callback','fl_callwindow(''Fig_gui_fl_estimOSC2DH'',''gui_fl_estimOSC2DH'') ;',...
	'Label','2D','Tag','Osc 2D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_track'',''gui_fl_adv_track'') ;',...
	'Label','CWT Based Estimation','Tag','CWT based estimation');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_DWTestim'',''gui_fl_adv_DWTestim'') ;',...
	'Label','DWT Based Estimation','Tag','DWT based estimation');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_alphagifs'',''gui_fl_alphagifs'') ;',...
	'Label','GIFS Based Estimation','Tag','GIFS based estimation');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_variaIR'',''gui_fl_variaIR'') ;',...
	'Label','Increment Ratio Statistic','Tag','Increment Ratio Statistic');

c = uimenu('Parent',b,'Label','Local Holder Exponent','Tag','Local Holder Exponent');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_oscL'',''gui_fl_oscL'') ;',...
	'Label','Oscillation Based Method','Tag','oscillation based estimation 1D');

c = uimenu('Parent',b,'Label','Global Scaling Exponent','Tag','Global Scaling Exponent');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_estimirs'',''gui_fl_estimirs'');',...
	'Label','Increment Ratio Statistic','Tag','Increment ratio statistic');	

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_longrange'',''gui_fl_longrange'') ;',...
	'Label','CWT Based Estimation','Tag','CWT based estimation');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_estimcrossingtree'',''gui_fl_estimcrossingtree'');',...
	'Label','Crossing Tree','Tag','crossingtree');	

c = uimenu('Parent',b,'Label','Stable Processes','Tag','Stable Processes');

uimenu('Parent',c,...
	'Callback','fl_stable_function(''mn_culloch'');',...
	'Label','Mc Culloch Method','Tag','Mc Culloch Method');

uimenu('Parent',c,...
	'Callback','fl_stable_function(''mn_koutrouvelis'');',...
	'Label','Koutrouvelis Method','Tag','Koutrouvelis Method');

uimenu('Parent',c, ...
	'Callback','fl_stable_function(''mn_test_stab'');', ...
	'Label','Test of Stability','Tag','Test of stability');

uimenu('Parent',b,...
    'Callback','call_CGMY_Estimation_Wid;',...
    'Label','Tempered Alpha-Stable Process','Tag','Etas1D');

c = uimenu('Parent',b,'Label','2-Microlocal Frontier','Tag','2-microlocal Exponent');

uimenu('Parent',c,...
    'Callback','fl_callwindow(''gui_fl_tml'',''gui_fl_tml'');',...
	'Label','Oscillation Based (1)','Tag','Oscillation');

d = uimenu('Parent',c,'Label','Oscillation Based (2)','Tag','Oscillation based (2)');

uimenu('Parent',d,...
    'Callback','fl_callwindow(''gui_fl_ml2frontier'',''gui_fl_ml2frontier'');',...
	'Label','One Point Estimation','Tag','Oscml2frontier');

uimenu('Parent',d,...
    'Callback','fl_callwindow(''gui_fl_ml2spectrum'',''gui_fl_ml2spectrum'');',...
	'Label','Interval Estimation','Tag','Oscml2spectrum');

uimenu('Parent',b,'Callback','gui_fl_besov;','Label','Besov Norms','Tag','Besov Norms');

uimenu('Parent',b,...
    'Callback','fl_callwindow(''Fig_gui_estimg'',''gui_fl_estimg'');',...
    'Label','Self Regulating Function','Tag','Estimation of g');

uimenu('Parent',b,...
	'Callback','fl_doc help_1D_exponents;',...
	'Label','Help on Estimation','Separator','on','Tag','help_expo');

uimenu('Parent',b, ...
    'Callback','fl_doc tuto_estimation', ...
    'Label','Tutorial on Estimation','Tag','tutorial_expo');

%%%%%%%%%%%%%%%%% MULTIFRACTAL SPECTRA MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Multifractal Spectra','Tag','Multifractal Spectra');

c = uimenu('Parent',b,'Label','Functions','Tag','MS_Functions');

d = uimenu('Parent',c,'Label','Legendre Spectrum','Tag','F_Legendre Spectrum');

uimenu('Parent',d, ...
    'Callback','fl_dwtspec_compute(''SpecFunc'') ; ', ...
    'Label','DWT Based','Tag','DWT based');

uimenu('Parent',d, ...
    'Callback','fl_cwtspec_compute(''SpecFunc'') ; ', ...
    'Label','CWT Based','Tag','CWT based');

uimenu('Parent',d, ...
    'Callback','eval([''global '' fl_lse(''fbasic'',who)]);', ...
    'Label','Box Method Basic Parameters','Tag','F_Box Method');

d = uimenu('Parent',c,'Label','Continuous Large Deviation Spectrum','Tag','F_Large deviation Spectrum');

uimenu('Parent',d, ...
    'Callback','eval([''global '' fl_ldse(''fbasic'',who)]);', ...
    'Label','Basic Parameters','Tag','FLDSE_Basic');

uimenu('Parent',d, ...
    'Callback','fl_ldse(''fadvanced'',who);', ...
    'Label','Advanced Parameters','Tag','FLDSE_Advanced');

d = uimenu('Parent',c,'Label','Lim Sup Dimension Spectrum','Tag','M_Dimension spectrum');

uimenu('Parent',d, ...
    'Callback','eval([''global '' fl_dse(''fbasic'',who)]);', ...
    'Label','1D Basic Parameters','Tag','MDSE_Basic');

uimenu('Parent',d, ...
    'Callback','fl_dse(''fadvanced'',who);', ...
    'Label','1D Advanced Parameters','Tag','MDSE_Advanced');

uimenu('Parent',d, ...
    'Callback','eval([''global '' fl_dse2d(''fbasic'',who)]);', ...
    'Label','2D Basic Parameters','Tag','MDSE_Basic');

uimenu('Parent',d,...
    'Callback','eval([''global '' fl_dse2d(''fadvanced'',who)]);', ...
    'Label','2D Advanced Parameters','Tag','MDSE_Advanced');

c = uimenu('Parent',b,'Label','Measures','Tag','MS_Measures');

d = uimenu('Parent',c,'Label','Legendre Spectrum','Tag','M_Legendre Spectrum');

uimenu('Parent',d, ...
    'Callback','fl_dwtspec_compute(''SpecMeas'') ; ', ...
    'Label','DWT Based','Tag','DWT based');

% uimenu('Parent',d, ...
%     'Callback','fl_cwtspec_compute(''SpecMeas'') ; ', ...
%     'Label','CWT Based','Tag','CWT based');

uimenu('Parent',d, ...
    'Callback','eval([''global '' fl_lse(''mbasic'',who)]);', ...
    'Label','Box Method Basic Parameters','Tag','M_Box Method');

% d = uimenu('Parent',c,'Label','Continuous Large Deviation Spectrum','Tag','M_Large Deviation Spectrum');
% 
% uimenu('Parent',d, ...
%     'Callback','eval([''global '' fl_ldse(''mbasic'',who)]);', ...
%     'Label','Basic Parameters','Tag','MLDSE_Basic');
% 
% uimenu('Parent',d, ...
%     'Callback','fl_ldse(''madvanced'',who);', ...
%     'Label','Advanced Parameters','Tag','MLDSE_Advanced');

d = uimenu('Parent',c,'Label','Lim Sup Dimension Spectrum','Tag','M_Dimension spectrum');

uimenu('Parent',d, ...
    'Callback','eval([''global '' fl_dse(''mbasic'',who)]);', ...
    'Label','1D Basic Parameters','Tag','MDSE_Basic');

uimenu('Parent',d, ...
    'Callback','fl_dse(''madvanced'',who);', ...
    'Label','1D Advanced Parameters','Tag','MDSE_Advanced');

uimenu('Parent',d, ...
    'Callback','eval([''global '' fl_dse2d(''mbasic'',who)]);', ...
    'Label','2D Basic Parameters','Tag','MDSE_Basic');

uimenu('Parent',d,...
    'Callback','eval([fl_dse2d(''madvanced'',who)]);', ...
    'Label','2D Advanced Parameters','Tag','MDSE_Advanced');

uimenu('Parent',b, ...
    'Callback','fl_doc  help_1D_spectra;', ...
    'Label','Help on Multifractal Spectra','Separator','on','Tag','help_spec');

% uimenu('Parent',b,'Label','Tutorial on Multifractal Spectra','Tag','tutorial_spec');

%%%%%%%%%%%%%%%%%%%%%% SEGMENTATION MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Segmentation','Tag','Segmentation');

% uimenu('Parent',b, ...
%     'Callback','fl_callwindow(''Fig_gui_fl_wsamod'',''gui_fl_wsamod'');', ...
%     'Label','1D Signals WSA-Based Segmentation','Tag','WSA Segmentation');

uimenu('Parent',b, ...
    'Callback','fl_callwindow(''gui_segmentation_control_panel'',''gui_segmentation'');', ...
    'Label','Image Multifractal Segmentation','Tag','SpectrumSegmentation');

uimenu('Parent',b, ...
    'Callback','fl_callwindow(''Fig_gui_fl_mfianalysis'',''gui_fl_mfianalysis'');', ...
    'Label','Small Objects Detection','Tag','MFIanalysis');

uimenu('Parent',b, ...
    'Callback','fl_doc  help_segmentation;', ...
    'Label','Help on Segmentation','Separator','on','Tag','help_segmentation');

uimenu('Parent',b, ...
    'Callback','fl_doc tuto_segmentation', ...
    'Label','Tutorial on Segmentation','Tag','tutorial_segmentation');

%%%%%%%%%%%%%%%%%%%%%%%% DENOISING MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Denoising','Tag','Denoising');

c = uimenu('Parent',b,'Label','Multifractal Pumping','Tag','Multifractal Pumping');

uimenu('Parent',c, ...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdpumping1d'',''gui_fl_mfdpumping1d'') ;',...	
	'Label','1D','Tag','mfp 1D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdpumping2d'',''gui_fl_mfdpumping2d'') ;',...	
	'Label','2D','Tag','mfp 2D');

c = uimenu('Parent',b,'Label','Multifractal Bayesian Denoising','Tag','Multifractal Bayesian Denoising');

uimenu('Parent',c, ...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdbayesian1d'',''gui_fl_mfdbayesian1d'') ;',...	
	'Label','1D','Tag','mfb 1D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdbayesian2d'',''gui_fl_mfdbayesian2d'') ;',...	
	'Label','2D','Tag','mfb 2D');

c = uimenu('Parent',b,'Label','Multifractal Regularization','Tag','Multifractal Regularization');

uimenu('Parent',c, ...
	'Callback','fl_callwindow(''Fig_gui_fl_wavereg1d'',''gui_fl_wavereg1d'') ;',...	
	'Label','1D','Tag','wreg 1D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_wavereg2d'',''gui_fl_wavereg2d'') ;',...	
	'Label','2D','Tag','wreg 2D');

c = uimenu('Parent',b,'Label','Non Linear Multifractal Pumping','Tag','Non Linear Multifractal Pumping');

uimenu('Parent',c, ...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdnolinear1d'',''gui_fl_mfdnolinear1d'') ;',...	
	'Label','1D','Tag','mfdnl 1D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdnolinear2d'',''gui_fl_mfdnolinear2d'') ;',...	
	'Label','2D','Tag','mfdnl 2D');

c = uimenu('Parent',b,'Label','Multifractal Denoising (L2 norm)','Tag','Multifractal Denoising L2 norm');

uimenu('Parent',c, ...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdnorm1d'',''gui_fl_mfdnorm1d'') ;',...	
	'Label','1D','Tag','mfdn 1D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_mfdnorm2d'',''gui_fl_mfdnorm2d'') ;',...	
	'Label','2D','Tag','mfdn 2D');

c = uimenu('Parent',b,'Label','Wavelet Shrinkage','Tag','Wavelet Shrinkage');

uimenu('Parent',c, ...
	'Callback','fl_callwindow(''Fig_gui_fl_waveshrink1d'',''gui_fl_waveshrink1d'') ;',...	
	'Label','1D','Tag','wshrink 1D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_waveshrink2d'',''gui_fl_waveshrink2d'') ;',...	
	'Label','2D','Tag','wshrink 2D');

uimenu('Parent',b, ...
    'Callback','ud = get(findobj(''Tag'',''FRACLAB Toolbox''),''UserData''); ud.Opened_by_fraclab = 1; set(findobj(''Tag'',''FRACLAB Toolbox''),''UserData'',ud);clear(''ud'');fl_callwindow(''Fig_gui_fl_bayes_IAE'',''gui_fl_bayes_IAE(who)'');', ...
    'Label','Interactive Evolutionary Multifractal Bayesian Denoising','Tag','Multifractal Bayesian Denoising IAE');

uimenu('Parent',b, ...
    'Callback','fl_doc  help_denoising;', ...
    'Label','Help on Denoising','Separator','on','Tag','help_den');

uimenu('Parent',b, ...
    'Callback','fl_doc tuto_denoising', ...
    'Label','Tutorial on Denoising','Tag','tutorial_den');

%%%%%%%%%%%%%%%%%%%%%% INTERPOLATION MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Interpolation','Tag','Interppolation');

c = uimenu('Parent',b,'Label','Hölderian Interpolation','Tag','Holdinterpolation');

uimenu('Parent',c, ...
	'Callback','fl_callwindow(''Fig_gui_fl_fracinterp1d'',''gui_fl_fracinterp1d'') ;',...	
	'Label','1D','Tag','Holderian 1D');

uimenu('Parent',c,...
	'Callback','fl_callwindow(''Fig_gui_fl_fracinterp2d'',''gui_fl_fracinterp2d'') ;',...	
	'Label','2D','Tag','Holderian 2D');

uimenu('Parent',b,'Label','Help on Interpolation','Separator','on','Tag','help_interp');

uimenu('Parent',b, ...
    'Callback','fl_doc tuto_interpolation', ...
    'Label','Tutorial on Interpolation','Tag','tutorial_interp');

%%%%%%%%%%%%%%%%%%%%%%%%%% TF/TS MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','TF / TS','Tag','TFTS');

uimenu('Parent',b, ...
    'Callback','fl_callwindow(''Fig_gui_fl_contwt'',''gui_fl_contwt'') ;',...
    'Label','Continuous Wavelet Transform','Tag','Continuous WT');

c = uimenu('Parent',b,'Label','Discrete Wavelet Transform','Tag','Discrete WT');

uimenu('Parent',c, ...
    'Callback','fl_callwindow(''Fig_gui_fl_dwt1d'',''gui_fl_dwt1d'') ;',...
    'Label','1D','Tag','DWT 1D');

uimenu('Parent',c, ...
    'Callback','fl_callwindow(''Fig_gui_fl_dwt2d'',''gui_fl_dwt2d'') ;',...
    'Label','2D','Tag','DWT 2D');

uimenu('Parent',b, ...
    'Callback','fl_callwindow(''Fig_gui_fl_pseudoaw'',''gui_fl_pseudoaw'') ;',...
    'Label','Pseudo Affine Wigner','Tag','Pseudo Affine Wigner');

uimenu('Parent',b, ...
    'Callback','fl_doc  help_TFTS;', ...
    'Label','Help on TF/TS','Separator','on','Tag','help_TFTS');

uimenu('Parent',b, ...
    'Callback','fl_doc tuto_tfts', ...
    'Label','Tutorial on TF/TS','Tag','tutorial_TFTS');

%%%%%%%%%%%%%%%%%%%%% MISCELLANEOUS MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b = uimenu('Parent',a,'Label','Miscellaneous','Tag','Misc');

uimenu('Parent',b, ...
	'Callback','gui_fl_create_dwt;', ...
	'Label','Create DWT','Tag','Create_dwt');

uimenu('Parent',b, ...
	'Callback','gui_fl_create_graph;', ...
	'Label','Create Graph  ','Tag','Create_graph');

uimenu('Parent',b, ...
	'Callback','gui_fl_create_matrix;', ...
	'Label','Create Matrix  ','Tag','Create_matrix');

uimenu('Parent',b, ...
	'Callback','gui_fl_extract_matrix;', ...
	'Label','Extract Matrix  ','Tag','Extract_matrix');

uimenu('Parent',b, ...
	'Callback','gui_oper_matrix;', ...
	'Label','Matrix Computation','Tag','oper_matrix');

uimenu('Parent',b, ...
	'Callback','fl_callwindow(''Fig_gui_fl_signal2measure'',''gui_fl_signal2measure'');',...
	'Label','Signal to Measure','Tag','sig2measure');

uimenu('Parent',b, ...
	'Callback','fl_callwindow(''Fig_gui_fl_normalize'',''gui_fl_normalize'')', ...
	'Label','Normalization','Tag','normalization');

uimenu('Parent',b, ...
    'Callback','fl_doc  help_misc;', ...
	'Label','Help on Misc','Separator','on','Tag','help_misc');

uimenu('Parent',b, ...
    'Callback','fl_doc_web', ...
    'Label','Check for Update','Separator','on','Tag','checkforupdate');

ud = get(a,'UserData');
ud.OpenedWindows = [];
set(a,'UserData',ud);

try
    fl_window_init(a);
catch %#ok<CTCH>
    delete(a);
    error('Failure of the Fraclab window initialization. ''\Gui\fltool.mat'' file may be corrupted. Please reinitialize it.');
end
set(findobj(a,'Tag','StaticText_Details'),'BackgroundColor',DetailsTextBackgroundColor);
set(findobj(a,'Tag','StaticText_Variables'),'BackgroundColor',VariablesTextBackgroundColor);
set(findobj(a,'Tag','StaticText_mes_error'),'BackgroundColor',MessageTextBackgroundColor);
if fl_getOption('Layout') == 4
	set(findobj(a,'Tag','StaticText_Details'),'ForegroundColor',MessageTextBackgroundColor);
	set(findobj(a,'Tag','StaticText_Variables'),'ForegroundColor',MessageTextBackgroundColor);
end