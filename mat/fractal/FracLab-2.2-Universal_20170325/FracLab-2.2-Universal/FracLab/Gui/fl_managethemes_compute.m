function [varargout]=fl_managethemes_compute(varargin);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,managethemes_fig] = gcbo;

if ((isempty(managethemes_fig)) | (~strcmp(get(managethemes_fig,'Tag'),'Fig_gui_fl_managethemes')))
  managethemes_fig = findobj ('Tag','Fig_gui_fl_managethemes');
end;

options_fig=findobj('Tag','Fig_gui_fl_options');
if isempty(options_fig)
	fl_error('FracLab Options window not found');
	return;
end
flroot = fl_getOption('FracLabRoot');


switch(varargin{1});

	case 'add_theme'
		Layout = get(findobj(options_fig,'Tag','Popupmenu_layout'),'Value');
		LogoFileName = get(findobj(options_fig,'Tag','EditText_logo'),'String');
		BackGroundColor = str2num(get(findobj(options_fig,'Tag','EditText_BGcolor'),'String'));
		BackGroundFileName = get(findobj(options_fig,'Tag','EditText_BGimage'),'String');
		LogoColorMap = fl_getOption('LogoColorMap',LogoFileName);
		FrameColor = str2num(get(findobj(options_fig,'Tag','EditText_Framecolor'),'String'));
		ButtonColor = str2num(get(findobj(options_fig,'Tag','EditText_Buttoncolor'),'String'));
		Fill_inColor = str2num(get(findobj(options_fig,'Tag','EditText_Fill_incolor'),'String'));
		FontColor = str2num(get(findobj(options_fig,'Tag','EditText_Fontcolor'),'String'));
		
		SaveAs = get(findobj(managethemes_fig,'Tag','Text_saveas'),'String');
		SaveAs(find(SaveAs == ' '))='_';
		
		fltoolmat = fullfile(flroot,'Gui',['fltool_' SaveAs '.mat']);
		p=version;
		try
		if str2num(p(1))>=7
				save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','Fill_inColor','FontColor','-v6','-append');
			else
				save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','Fill_inColor','FontColor','-append');
			end
		catch
			if str2num(p(1))>=7
				save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','Fill_inColor','FontColor','-v6');
			else
				save(fltoolmat,'Layout','LogoFileName','BackGroundColor','BackGroundFileName','LogoColorMap','FrameColor','ButtonColor','Fill_inColor','FontColor');
			end
		end
		
		Themes_List = get(findobj(options_fig,'Tag','Popupmenu_theme'),'String');
		
		Themes_List_size = size(Themes_List);
		Themes_List_size = max(Themes_List_size);
		Themes_List{Themes_List_size+1} =  SaveAs;
		set(findobj(options_fig,'Tag','Popupmenu_theme'),'String',Themes_List);
		
		fl_managethemes_compute('update_list');
	
	case'select_theme'
		
		Themes_List_available = get(findobj(managethemes_fig,'Tag','list_themes'),'String');
		Themes_value = get(findobj(managethemes_fig,'Tag','list_themes'),'Value');
		set(findobj(managethemes_fig,'Tag','Text_rename'),'String',Themes_List_available{Themes_value});
	
	
	case 'rename_theme'
		
		Themes_List_available = get(findobj(managethemes_fig,'Tag','list_themes'),'String');
		Themes_value = get(findobj(managethemes_fig,'Tag','list_themes'),'Value');
		LastName = Themes_List_available{Themes_value};
		NewName = get(findobj(managethemes_fig,'Tag','Text_rename'),'String');
		NewName(find(NewName == ' '))='_';
		
		lastfltoolmat = fullfile(flroot,'Gui',['fltool_' LastName '.mat']);
		newfltoolmat = fullfile(flroot,'Gui',['fltool_' NewName '.mat']);
		movefile(lastfltoolmat,newfltoolmat,'f');
	
		fl_managethemes_compute('update_list');
	
	case 'delete_theme'
	
		ThemeName = get(findobj(managethemes_fig,'Tag','Text_rename'),'String');
		if ~isempty(ThemeName)
			fltoolmat = fullfile(flroot,'Gui',['fltool_' ThemeName '.mat']);
			delete(fltoolmat);
			fl_managethemes_compute('update_list');
		end
		

	
	case 'update_list'
	
		Themes_List_fltool_init  = get(findobj(options_fig,'Tag','Popupmenu_theme'),'String');
		index_static = find(strcmp(Themes_List_fltool_init,'---------------------------------------'));
		for i=1:index_static
			Themes_List_fltool{i} = Themes_List_fltool_init{i};
		end
		
		fltool_list = ls(fullfile(flroot,'Gui','fltool_*.mat'));
		fltool_list_size = size(fltool_list);
		for i = 1:fltool_list_size(1)
			fltool_perso = fltool_list(i,:);
			espaces = find(fltool_perso == ' ');
			if ~isempty(espaces)
				fltool_perso = fltool_perso(1:espaces(1)-1);
			end
			fltool_perso = fltool_perso(8:end-4);
			Themes_List_available{i} =  fltool_perso;
			Themes_List_fltool{index_static+i} = fltool_perso;
			
		end
		
		set(findobj(managethemes_fig,'Tag','list_themes'),'String',Themes_List_available);
		set(findobj(managethemes_fig,'Tag','list_themes'),'Value',1);
		set(findobj(managethemes_fig,'Tag','Text_rename'),'String',Themes_List_available{1});
		
		set(findobj(options_fig,'Tag','Popupmenu_theme'),'String',Themes_List_fltool);
end