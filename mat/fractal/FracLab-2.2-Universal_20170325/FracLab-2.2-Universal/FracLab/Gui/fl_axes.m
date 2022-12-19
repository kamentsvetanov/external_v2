function fl_axes(varargin);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% [objTmp,fig] = gcbo;
acp = gcf;
if ((isempty(acp)) | (~strcmp(get(acp,'Tag'),'gui_axes_control_panel')))
  acp = findobj ('Tag','gui_axes_control_panel');
end

switch (strtok(varargin{1}))
% --------------------
   case 'ppm_scale'
% --------------------
%  plot_handle = fl_view_functions('get_plot_handle');
%  switch (get(findobj(acp,'Tag','PopupMenu_scale'),'Value'))
%    case 1
%    % case 'linear'
%      set(plot_handle,'XScale','lin');      
%      set(plot_handle,'YScale','lin');
%      case 2
%      % case 'semilog X'
%      set(plot_handle,'XScale','log');      
%      set(plot_handle,'YScale','lin');
%      case 3
%      % case 'semilog Y'
%      set(plot_handle,'XScale','lin');      
%      set(plot_handle,'YScale','log');
%      case 4
%      % case 'LogLog'
%      set(plot_handle,'XScale','log');      
%      set(plot_handle,'YScale','log');
%  end % switch scale  

% --------------------
   case 'ppm_color'
% --------------------

  str = get(findobj(acp,'Tag','PopupMenu_color'),'String');
  val = get(findobj(acp,'Tag','PopupMenu_color'),'Value');
  switch (strtok(str{val}))
    case 'yellow'
      red = 1; green = 1; blue = 0;
    case 'magenta'
      red = 1; green = 0; blue = 1;
    case 'cyan'
      red = 0; green = 1; blue = 1;
    case 'red'
      red = 1; green = 0; blue = 0;
    case 'green'
      red = 0; green = 1; blue = 0;
    case 'blue'
      red = 0; green = 0; blue = 1;
    case 'white'
      red = 1; green = 1; blue = 1;
    case 'black'
      red = 0; green = 0; blue = 0;
  end % switch

  set(findobj(acp,'Tag','EditText_red'),'String',num2str(red));
  set(findobj(acp,'Tag','EditText_green'),'String',num2str(green));
  set(findobj(acp,'Tag','EditText_blue'),'String',num2str(blue));
  

% --------------------
  case 'edit_range_Xmin'
% --------------------
  xmin = get(findobj(acp,'Tag','EditText_Xmin'),'String');
  if isempty(str2num(xmin))
    set(findobj(acp,'Tag','EditText_Xmin'),'String','0');
    fl_error('Xmin must be a number');
  end

% --------------------
  case 'edit_range_Xmax'
% --------------------
  xmax = get(findobj(acp,'Tag','EditText_Xmax'),'String');
  if isempty(str2num(xmax))
    set(findobj(acp,'Tag','EditText_Xmax'),'String','1');
    fl_error('Xmax must be a number');
  end
  
% --------------------
  case 'edit_range_Ymin'
% --------------------
  ymin = get(findobj(acp,'Tag','EditText_Ymin'),'String');
  if isempty(str2num(ymin))
    set(findobj(acp,'Tag','EditText_Ymin'),'String','0');
    fl_error('Ymin must be a number');
  end

% --------------------
  case 'edit_range_Ymax'
% --------------------
  ymax = get(findobj(acp,'Tag','EditText_Ymax'),'String');
  if isempty(str2num(ymax))
    set(findobj(acp,'Tag','EditText_Ymax'),'String','1');
    fl_error('Ymax must be a number');
  end
  
% --------------------
  case 'apply'
% --------------------

  % Let's get the data

  xmin  = str2num(get(findobj(acp,'Tag','EditText_Xmin'),'String'));
  xmax  = str2num(get(findobj(acp,'Tag','EditText_Xmax'),'String'));
  ymin  = str2num(get(findobj(acp,'Tag','EditText_Ymin'),'String'));
  ymax  = str2num(get(findobj(acp,'Tag','EditText_Ymax'),'String'));
  
  % just check them now

  if xmin >= xmax
    fl_error('Axes Error : xmin >= xmax');
  end
  if ymin >= ymax
    fl_error('Axes Error : ymin >= ymax');
  end
  
  % if any other idea ...
  
  % now, put them in the plot
  plot_handle = fl_view_functions('get_plot_handle');
  set(plot_handle,'XLim',[xmin xmax]);
  set(plot_handle,'YLim',[ymin ymax]);

  
  % and finally consider the plot scaling
  switch (get(findobj(acp,'Tag','PopupMenu_scale'),'Value'))
    case 1
      % case 'linear'
      set(plot_handle,'XScale','lin');      
      set(plot_handle,'YScale','lin');
    case 2
      % case 'semilog X'
      set(plot_handle,'XScale','log');      
      set(plot_handle,'YScale','lin');
    case 3
      % case 'semilog Y'
      set(plot_handle,'XScale','lin');      
      set(plot_handle,'YScale','log');
    case 4
      % case 'LogLog'
      set(plot_handle,'XScale','log');      
      set(plot_handle,'YScale','log');
  end % switch scale  

  plotLine = get(plot_handle,'Children');
  if ~(strcmp(get(plotLine(1),'Type'),'image') || strcmp(get(plotLine(1),'Type'),'hggroup'))
    red   = str2num(get(findobj(acp,'Tag','EditText_red'),'String'));
    green = str2num(get(findobj(acp,'Tag','EditText_green'),'String'));
    blue  = str2num(get(findobj(acp,'Tag','EditText_blue'),'String'));
    set(plotLine(1),'Color',[red green blue]);
    set(plotLine(1),'LineWidth',str2num(get(findobj(acp,'Tag','EditText_width'),'String')));

    % line
    str = get(findobj(acp,'Tag','PopupMenu_line'),'String');
    val = get(findobj(acp,'Tag','PopupMenu_line'),'Value');
    set(plotLine(1),'LineStyle',strtok(str{val}));
    
    % mark
    str = get(findobj(acp,'Tag','PopupMenu_mark'),'String');
    val = get(findobj(acp,'Tag','PopupMenu_mark'),'Value');
    set(plotLine(1),'Marker',strtok(str{val}));

  end
  
% --------------------
  case 'edit_width'
% --------------------
  width = get(findobj(acp,'Tag','EditText_width'),'String');
  if isempty(str2num(width))
    set(findobj(acp,'Tag','EditText_width'),'String','1');
    fl_error('Width must be a number in [0,1]');
  elseif str2num(width) <= 0
    set(findobj(acp,'Tag','EditText_width'),'String','1');
    fl_error('Width must be in ]0,Infinity[');
  end
  
% --------------------
  case 'edit_blue'
% --------------------
  blue = get(findobj(acp,'Tag','EditText_blue'),'String');
  if isempty(str2num(blue))
    set(findobj(acp,'Tag','EditText_blue'),'String','1');
    fl_error('Blue component must be a number in [0,1]');
  elseif ((str2num(blue) > 1) | (str2num(blue) < 0))
    set(findobj(acp,'Tag','EditText_blue'),'String','1');
    fl_error('Blue component must be in [0,1]');
  end

% --------------------
  case 'edit_green'
% --------------------
  green = get(findobj(acp,'Tag','EditText_green'),'String');
  if isempty(str2num(green))
    set(findobj(acp,'Tag','EditText_green'),'String','0');
    fl_error('Green component must be a number in [0,1]');
  elseif ((str2num(green) > 1) | (str2num(green) < 0))
    set(findobj(acp,'Tag','EditText_green'),'String','0');
    fl_error('Green component must be in [0,1]');
  end
  
% --------------------
  case 'edit_red'
% --------------------
  red = get(findobj(acp,'Tag','EditText_red'),'String');
  if isempty(str2num(red))
    set(findobj(acp,'Tag','EditText_red'),'String','0');
    fl_error('Red component must be a number in [0,1]');
  elseif ((str2num(red) > 1) | (str2num(red) < 0))
    set(findobj(acp,'Tag','EditText_red'),'String','0');
    fl_error('Red component must be in [0,1]');
  end
  
  

% --------------------
  case 'close'
% --------------------

  close (acp);
  toolbar = findobj('Tag','gui_view_toolbar');
  b_axes = findobj(toolbar,'Tag','button_Axes');
  set(b_axes,'Enable','on');

end % switch
