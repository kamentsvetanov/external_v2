function varargout = fl_axes_functions(varargin);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

axesCP = gcf;
if ((isempty(axesCP)) | (~strcmp(get(axesCP,'Tag'),'gui_axes_control_panel')))
  axesCP = findobj('Tag','gui_axes_control_panel');
end


switch (varargin{1})

% ----------------------
  case 'refresh_axes_control_panel'
% ----------------------

  % refresh name
  figName = fl_view_functions('get_name');
  tmp = findobj(axesCP,'Tag','EditText_figName');
  set(tmp,'String',figName);
  
  % refresh scale
  plot_handle = fl_view_functions('get_plot_handle');
  scaleX = get(plot_handle,'XScale');
  scaleY = get(plot_handle,'YScale');
  ppm_scale = findobj(axesCP,'Tag','PopupMenu_scale');
  if ~isempty(findstr(scaleX,'lin'))
    if ~isempty(findstr(scaleY,'lin'))
      set(ppm_scale,'Value',1);
    else
      set(ppm_scale,'Value',3);
    end
  else
    if ~isempty(findstr(scaleY,'lin'))
      set(ppm_scale,'Value',2);
    else
      set(ppm_scale,'Value',4);
    end
  end
  
  % refresh range
  xlim = get(plot_handle,'XLim');
  ylim = get(plot_handle,'YLim');
  set(findobj(axesCP,'Tag','EditText_Xmin'),'String',num2str(xlim(1),'%0.5g'));
  set(findobj(axesCP,'Tag','EditText_Xmax'),'String',num2str(xlim(2),'%0.5g'));
  set(findobj(axesCP,'Tag','EditText_Ymin'),'String',num2str(ylim(1),'%0.5g'));
  set(findobj(axesCP,'Tag','EditText_Ymax'),'String',num2str(ylim(2),'%0.5g'));

  % refresh aspect

  % should get the line handle of the plot
  plotLine = get(plot_handle,'Children'); 
  if strcmp(get(plotLine(1),'Type'),'image') || strcmp(get(plotLine(1),'Type'),'hggroup')
    fl_axes_functions('disable_aspect');
  else
    if strcmp(get(findobj(axesCP,'Tag','StaticText_aspect'),'Enable'),'off')
      fl_axes_functions('enable_aspect');
    end
    
    width = get(plotLine(1),'LineWidth');
    set(findobj(axesCP,'Tag','EditText_width'),'String',width(1));
    
    color = get(plotLine(1),'Color');
    set(findobj(axesCP,'Tag','EditText_red'),'String',color(1));   % red 
    set(findobj(axesCP,'Tag','EditText_green'),'String',color(2)); % green
    set(findobj(axesCP,'Tag','EditText_blue'),'String',color(3));  % blue

    ppmColor = findobj(axesCP,'Tag','PopupMenu_color');
    if ((color(1) == 1) & (color(2) == 1) & (color(3) == 1))
      set(ppmColor,'Value',7);
    elseif ((color(1) == 0) & (color(2) == 0) & (color(3) == 0))
      set(ppmColor,'Value',8);
    elseif ((color(1) == 1) & (color(2) == 0) & (color(3) == 0))
      set(ppmColor,'Value',4);
    elseif ((color(1) == 0) & (color(2) == 1) & (color(3) == 0))
      set(ppmColor,'Value',5);
    elseif ((color(1) == 0) & (color(2) == 0) & (color(3) == 1))
      set(ppmColor,'Value',6);
    elseif ((color(1) == 1) & (color(2) == 1) & (color(3) == 0))
      set(ppmColor,'Value',1);
    elseif ((color(1) == 0) & (color(2) == 1) & (color(3) == 1))
      set(ppmColor,'Value',3);
    elseif ((color(1) == 1) & (color(2) == 1) & (color(3) == 0))
      set(ppmColor,'Value',2);
    end
    
    % Line PPM
    Line = get(plotLine(1),'LineStyle');
    ppmLine = findobj(axesCP,'Tag','PopupMenu_line');
    % switch (strtok(Line(1)))
    switch (Line)
      case '-'
	set(ppmLine,'Value',1);
      case ':' 
	set(ppmLine,'Value',2);
      case '-.' 
	set(ppmLine,'Value',3);
      case '--' 
	set(ppmLine,'Value',4);
      case 'none' 
	set(ppmLine,'Value',5);	
    end % switch
    
    % Mark PPM
    mark = get(plotLine(1),'Marker');
    ppmMark = findobj(axesCP,'Tag','PopupMenu_mark');
    switch (mark)
      case 'none' 
	set(ppmMark,'Value',1);	
      case '.' 
	set(ppmMark,'Value',2);
      case 'o' 
	set(ppmMark,'Value',3);
      case 'x' 
	set(ppmMark,'Value',4);
      case '+' 
	set(ppmMark,'Value',5);
      case '*' 
	set(ppmMark,'Value',6);
      case 's' 
	set(ppmMark,'Value',7);
      case 'd' 
	set(ppmMark,'Value',8);
      case 'v' 
	set(ppmMark,'Value',9);
      case '^' 
	set(ppmMark,'Value',10);
      case '<' 
	set(ppmMark,'Value',11);
      case '>' 
	set(ppmMark,'Value',12);
      case 'p' 
	set(ppmMark,'Value',13);
      case 'h' 
	set(ppmMark,'Value',14);
    end % switch
    
  end
  
% ----------------------
  case 'refresh_axes_range'
% ----------------------

  plot_handle = fl_view_functions('get_plot_handle');
  xlim = get(plot_handle,'XLim');
  ylim = get(plot_handle,'YLim');
  set(findobj(axesCP,'Tag','EditText_Xmin'),'String',num2str(xlim(1),'%0.5g'));
  set(findobj(axesCP,'Tag','EditText_Xmax'),'String',num2str(xlim(2),'%0.5g'));
  set(findobj(axesCP,'Tag','EditText_Ymin'),'String',num2str(ylim(1),'%0.5g'));
  set(findobj(axesCP,'Tag','EditText_Ymax'),'String',num2str(ylim(2),'%0.5g'));
  
  
% ----------------------
  case 'disable_aspect'
% ----------------------

  set(findobj(axesCP,'Tag','StaticText_aspect'),'Enable','off');
  set(findobj(axesCP,'Tag','StaticText_line'),'Enable','off');
  set(findobj(axesCP,'Tag','PopupMenu_line'),'Enable','off');
  set(findobj(axesCP,'Tag','StaticText_mark'),'Enable','off');
  set(findobj(axesCP,'Tag','PopupMenu_mark'),'Enable','off');
  set(findobj(axesCP,'Tag','StaticText_width'),'Enable','off');
  set(findobj(axesCP,'Tag','EditText_width'),'Enable','off');
  set(findobj(axesCP,'Tag','StaticText_red'),'Enable','off');
  set(findobj(axesCP,'Tag','StaticText_green'),'Enable','off');
  set(findobj(axesCP,'Tag','StaticText_blue'),'Enable','off');
  set(findobj(axesCP,'Tag','StaticText_color'),'Enable','off');
  set(findobj(axesCP,'Tag','EditText_red'),'Enable','off');
  set(findobj(axesCP,'Tag','EditText_green'),'Enable','off');
  set(findobj(axesCP,'Tag','EditText_blue'),'Enable','off');
  set(findobj(axesCP,'Tag','PopupMenu_color'),'Enable','off');
  
% ----------------------
  case 'enable_aspect'
% ----------------------

  set(findobj(axesCP,'Tag','StaticText_aspect'),'Enable','on');
  set(findobj(axesCP,'Tag','StaticText_line'),'Enable','on');
  set(findobj(axesCP,'Tag','PopupMenu_line'),'Enable','on');
  set(findobj(axesCP,'Tag','StaticText_mark'),'Enable','on');
  set(findobj(axesCP,'Tag','PopupMenu_mark'),'Enable','on');
  set(findobj(axesCP,'Tag','StaticText_width'),'Enable','on');
  set(findobj(axesCP,'Tag','EditText_width'),'Enable','on');
  set(findobj(axesCP,'Tag','StaticText_red'),'Enable','on');
  set(findobj(axesCP,'Tag','StaticText_green'),'Enable','on');
  set(findobj(axesCP,'Tag','StaticText_blue'),'Enable','on');
  set(findobj(axesCP,'Tag','StaticText_color'),'Enable','on');
  set(findobj(axesCP,'Tag','EditText_red'),'Enable','on');
  set(findobj(axesCP,'Tag','EditText_green'),'Enable','on');
  set(findobj(axesCP,'Tag','EditText_blue'),'Enable','on');
  set(findobj(axesCP,'Tag','PopupMenu_color'),'Enable','on');


end % switch


