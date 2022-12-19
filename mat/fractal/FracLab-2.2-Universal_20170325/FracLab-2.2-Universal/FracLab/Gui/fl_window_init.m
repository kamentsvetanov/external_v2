function []=fl_window_init(figurehandle,figuretype)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin == 1 figuretype = 'Gui'; end

ShowHiddenHandlesInit = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
BackGroundColor = fl_getOption('BackGroundColor');
LogoColorMap = fl_getOption('LogoColorMap');
FrameColor = fl_getOption('FrameColor');
FontColor = fl_getOption('FontColor');
ButtonColor = fl_getOption('ButtonColor');
Fill_inColor = fl_getOption('Fill_inColor');


if ~strcmp(figuretype,'NoTheme')

	%Couleurs définies dans le thème courant
	
	%figure
	if ~strcmp(figuretype,'Figure')
		set(figurehandle,'Color',BackGroundColor);
		set(figurehandle,'Colormap',LogoColorMap);
	else
		set(figurehandle,'Color',FrameColor);
    end
    
	%panel
	set(findobj(figurehandle,'Type','uipanel'),'BackgroundColor',FrameColor);
	set(findobj(figurehandle,'Type','uipanel'),'ForegroundColor',FontColor);
	
	%frame
	set(findobj(figurehandle,'Style','frame'),'BackgroundColor',FrameColor);
	set(findobj(figurehandle,'Style','frame'),'ForegroundColor',FontColor);
	
	%pushbutton
	set(findobj(figurehandle,'Style','pushbutton'),'BackgroundColor',ButtonColor);
	set(findobj(figurehandle,'Style','pushbutton'),'ForegroundColor',FontColor);
	
	
	%togglebutton
	set(findobj(figurehandle,'Style','togglebutton'),'BackgroundColor',ButtonColor);
	set(findobj(figurehandle,'Style','togglebutton'),'ForegroundColor',FontColor);
	
	
	%radiobutton
	set(findobj(figurehandle,'Style','radiobutton'),'BackgroundColor',FrameColor);
	set(findobj(figurehandle,'Style','radiobutton'),'ForegroundColor',FontColor);
	
	
	%checkbox
	set(findobj(figurehandle,'Style','checkbox'),'BackgroundColor',FrameColor);
	set(findobj(figurehandle,'Style','checkbox'),'ForegroundColor',FontColor);
	
	
	%edit
	set(findobj(figurehandle,'Style','edit'),'BackgroundColor',Fill_inColor);
	set(findobj(figurehandle,'Style','edit'),'ForegroundColor',FontColor);
	
	%text
	set(findobj(figurehandle,'Style','text'),'BackgroundColor',FrameColor);
	set(findobj(figurehandle,'Style','text'),'ForegroundColor',FontColor);
	
	%slider
	set(findobj(figurehandle,'Style','slider'),'BackgroundColor',FrameColor);
	set(findobj(figurehandle,'Style','slider'),'ForegroundColor',FontColor);
	
	
	%listbox
	set(findobj(figurehandle,'Style','listbox'),'BackgroundColor',Fill_inColor);
	set(findobj(figurehandle,'Style','listbox'),'ForegroundColor',FontColor);
	
	%popupmenu
	set(findobj(figurehandle,'Style','popupmenu'),'BackgroundColor',Fill_inColor);
	set(findobj(figurehandle,'Style','popupmenu'),'ForegroundColor',FontColor);
	
	
	%axes
	figureaxeshandles = findobj(figurehandle,'Type','axes');
	set(figureaxeshandles,'Color',Fill_inColor);
	set(figureaxeshandles,'XColor',FontColor);
	set(figureaxeshandles,'YColor',FontColor);
	set(figureaxeshandles,'ZColor',FontColor);
	for i = 1:length(figureaxeshandles)
		set(get(figureaxeshandles(i),'Title'),'Color',FontColor);
	end
	
	
	%images
	if fl_getOption('ForceBackGroundColor')
		[logo_frac cmap_frac]=fl_getOption('Logo');
		figureimageshandles = findobj(figurehandle,'Type','image');
		for i = 1:length(figureimageshandles)
			img = get(figureimageshandles(i),'CData');
			img_size = size(img);
			dimension = size(img_size);
			if dimension(2) == 3
				for j = 1:img_size(1)
					for k = 1:img_size(2)
						if img(j,k,:) == logo_frac(2,2,:)
							img(j,k,:) = BackGroundColor*255;
	                    end
					end
				end
				set(figureimageshandles(i),'CData',img);
			else
				cmap_frac(logo_frac(2,2)+1,:) = BackGroundColor;
				set(figurehandle,'Colormap',cmap_frac);
			end	
		end
		
	end
end



%Ajout de la fenêtre en tant que fenêtre ouverte dans FracLab
if ~strcmp(figuretype,'ApplyTheme')	
	fraclabhandle=findobj('Tag','FRACLAB Toolbox');
	if ~isempty(fraclabhandle)
		ud = get(fraclabhandle,'UserData');
		if isfield(ud,'OpenedWindows')
			tag = get(figurehandle,'Tag');
			if isempty(tag)
				tag = 'Opened_by_FracLab';
				set(figurehandle,'Tag',tag);
			end
			ud.OpenedWindows = [tag '|'  ud.OpenedWindows];
			set(fraclabhandle,'UserData',ud);
		end
	end
end


set(0,'ShowHiddenHandles',ShowHiddenHandlesInit);
