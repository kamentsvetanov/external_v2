function varargout=fl_view_toolbar(varargin);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

toolbar = gcf;
if ((isempty(toolbar)) | (~strcmp(get(toolbar,'Tag'),'gui_view_toolbar')))
  toolbar = findobj ('Tag','gui_view_toolbar');
end

switch (strtok(varargin{1}))

% --------------------
  case 'Help'
% --------------------
  helpwin({'FracLab' help('fl_contents')});
  
% --------------------
  case 'Close_all'
% --------------------

  cursor = fl_waiton;
  
  UserData = get (toolbar,'UserData');
  if iscell(UserData)
    for i = 1:length(UserData)
      close(fl_view_functions('get_window_handle'));
    end
  end
  
  axesCP = findobj('Tag','gui_axes_control_panel');
  if ~isempty(axesCP)
    close(axesCP);
  end

  img = findobj('Tag','gui_image_control_panel');
  if ~isempty(img)
    close(img);
  end
  
  % at the end, close the control panel (view_toolbar itself)
  fl_waitoff(cursor);
  close(toolbar);

% --------------------
  case 'Print'
% --------------------

  printdlg(fl_view_functions('get_window_handle'));

% --------------------
  case 'click_listbox'
% --------------------

  UserData = get (toolbar,'UserData');

  % if iscell(UserData)
  if ~isempty(UserData)
    figure(fl_view_functions('get_window_handle'));
    fl_view_functions('load_userData');
    
    % ACP
    axesCP = findobj('Tag','gui_axes_control_panel');
    if ~isempty(axesCP)
      fl_axes_functions('refresh_axes_control_panel');
    end
    
    % ICP
    img = findobj('Tag','gui_image_control_panel');
    selected_cell = fl_view_functions('get_i_j');
    i = selected_cell(1);
    j = selected_cell(2);
    handle = fl_view_functions('get_handle');
    if ~isempty(img)
      if ((strcmp(get(handle,'Type'),'figure')) | (UserData{i}{j}(1).Image.mode == -1))  % not an image :(
	fl_image_functions('disable');
	set(findobj(toolbar,'Tag','button_Image_Matrix'),'Enable','off');
      elseif strcmp(get(findobj(img,'Tag','StaticText_Title'),'Enable'),'off')
	% set(findobj(toolbar,'Tag','button_Image_Matrix'),'Enable','on');
	fl_image_functions('enable');
      else
	fl_image_functions('refresh_image_control_panel');
      end
    else
      if ((strcmp(get(handle,'Type'),'figure')) | (UserData{i}{j}(1).Image.mode == -1))  % not an image :(
	set(findobj(toolbar,'Tag','button_Image_Matrix'),'Enable','off');
      else
	set(findobj(toolbar,'Tag','button_Image_Matrix'),'Enable','on');
      end
    end
    
    % Just disable the 'rotate' button for images
    rotateHandle = findobj(toolbar,'Tag','Checkbox_rotate');
    if ((strcmp(get(handle,'Type'),'figure')) | (UserData{i}{j}(1).Image.mode == 1))
      set(rotateHandle,'Enable','off');
    else
      set(rotateHandle,'Enable','on');
    end
    
    % Just turn off the 'zoom' button
    zoomHandle = findobj(toolbar,'Tag','Checkbox_zoom');
    if (strcmp(get(handle,'Type'),'figure'))
      set(zoomHandle,'Enable','off');
    else
      set(zoomHandle,'Enable','on');
    end
    
    % Just turn off the 'hold' button
    holdHandle = findobj(toolbar,'Tag','Checkbox_hold');
    set(findobj(toolbar,'Tag','button_view'),'Enable','on');
    if (strcmp(get(handle,'Type'),'figure'))
      set(holdHandle,'Enable','off');
      if get(holdHandle,'Value')
	set(findobj(toolbar,'Tag','button_view'),'Enable','off');
      end
    else
      set(holdHandle,'Enable','on');
    end

    % for the superpose, it depends of the type of the picture
    superposeHandle = findobj(toolbar,'Tag','Checkbox_superpose');
    if ((strcmp(get(handle,'Type'),'figure')) | (UserData{i}{j}(1).Image.mode == -1)) % not a 'picture'
      set(superposeHandle,'Enable','off');
    else
      set(superposeHandle,'Enable','on');
    end
  end
  
  
% ---------------
  case 'View'
% ---------------


  % get the highlighted var in "fltool" window
  var_name = fl_get_input('');
  eval (['global ' var_name]);
  var=eval(var_name);

  % find the handle where we want to plot the view      
  handle = fl_view_functions('get_handle');
  
  % depending on the kind of plot, creates different structures.
  type = fl_view_functions('get_plot_type');
  if (strcmp(type,'wavelet'))
    img_struct = fl_image_functions('defaultWaveletStruct');
  elseif (strcmp(type,'image'))
    img_struct = fl_image_functions('defaultImageStruct');
  else
    img_struct = struct('mode',-1);
  end
  UserData = get (toolbar,'UserData');
  selected_cell = fl_view_functions('get_i_j');

  
  % then we have several cases :

  % first case : a figure is selected (ex : View 3)
  % -----------------------------------------------
       
  if strcmp(get(handle,'Type'),'figure')
    
    % how many possible subplots are there here ?
    childrens = get(handle,'Children');
    EditText_Vsplit_handle = findobj(toolbar,'Tag','EditText_Vsplit');
    EditText_Hsplit_handle = findobj(toolbar,'Tag','EditText_Hsplit');
    X_value = str2num(get(EditText_Vsplit_handle,'string'));
    Y_value = str2num(get(EditText_Hsplit_handle,'string'));

    num_of_possible_subplots = X_value * Y_value;
    
    % and how many are used ?
    num_of_subplots = length (childrens);
    
    % just one possible ? ok, let's plot in that one ...
    
    if (num_of_subplots < num_of_possible_subplots)|(num_of_possible_subplots == 1)
      figure (handle);
      i = selected_cell(1);
      if num_of_possible_subplots > 1
	plot_handle = subplot (X_value,Y_value,(num_of_subplots+1));
	j = length(UserData{i})+1;
	oldStructImage = -1;
      else  
	plot_handle = fl_view_functions('get_plot_handle');
	j = 1;
	oldStructImage = UserData{i}{j}(1).Image.mode;
      end 
      UserData{i}{j}(1).Name = [var_name ' ' num2str(double(handle)) '.' num2str(j) ];
      UserData{i}{j}(1).Win_Handle = handle;
      UserData{i}{j}(1).Plot_Handle = plot_handle;
      UserData{i}{j}(1).Image = img_struct;
      UserData{i}{j}(1).Data = var;

    else 
      fl_warning ('Window full, please select a subplot');
      return ;
    end
  else
    % second case : a subplot is selected 
    % -----------------------------------
    
    % all we have to do is to plot there ...
    % and replace the information in the listbox
    Win_Handle = get (handle,'parent'); 
    figure(Win_Handle);
    subplot (handle);
    i = selected_cell(1);
    j = selected_cell(2);
    oldStructImage = UserData{i}{j}(1).Image.mode;
    UserData{i}{j}(1).Name = [var_name ' ' num2str(double(Win_Handle)) '.' num2str(i) ];
    UserData{i}{j}(1).Image = img_struct;
    UserData{i}{j}(1).Data = var;
  end
  

  alreadyDrawn = 0;
  
  % Here are some special jobs to do before drawing
  if get(findobj(toolbar,'Tag','Checkbox_superpose'),'Value')
    % superpose is on
    % we keep the old UserData because it will be the main part 
    % of the picture
    alreadyDrawn = 1;
    gui_superpose;
    % if fl_view_functions('create_superpose') ~= 0
    % set (toolbar,'UserData',UserData);
    fl_view_functions ('refresh_listbox');
    % end
  elseif get(findobj(toolbar,'Tag','Checkbox_hold'),'Value')
    set (toolbar,'UserData',UserData);
    fl_view_functions ('refresh_listbox');
    hold on;
    if ( (img_struct.mode ~= -1) & (oldStructImage ~= -1))
      icp = findobj('Tag','gui_image_control_panel');
      if (isempty(icp))
	gui_view_image;
	% a priori inutile ... car fait dans le 'click_listbox' a la fin
	% fl_image_functions('refresh_image_control_panel');
	imageButton = findobj(toolbar,'Tag','button_Image_Matrix');
	set(imageButton,'Enable','off');
      end;
      alreadyDrawn = 1;
    elseif ( (img_struct.mode == -1) & (oldStructImage == -1))
      fl_view_functions('view_call');
      plot_handle = fl_view_functions('get_plot_handle');
      plotLine = get(plot_handle,'Children');
      set(plotLine(1),'Color',[1 0 0]);
      acp = findobj('Tag','gui_axes_control_panel');
      if (isempty(acp))
	gui_axes;
	axesButton = findobj(toolbar,'Tag','button_Axes');
	set(axesButton,'Enable','off');
      end
      % a priori inutile ... car fait dans le 'click_listbox' a la fin
      % fl_axes_functions('refresh_axes_control_panel');
      alreadyDrawn = 1;
    end
  else
    set (toolbar,'UserData',UserData);
    fl_view_functions ('refresh_listbox');
    hold off;
  end

  % And now, we just have to draw
  if ~alreadyDrawn
    fl_view_functions('view_call');
  end
  fl_view_toolbar('click_listbox'); 
  fl_window_init(fl_view_functions('get_handle'),'Figure');
      
% -----------------------
  case ('View_in_new')      
% -----------------------

  UserData = get(toolbar,'UserData');
  
  % in this case, we must create a new window and a new name for this
  % window 
  if ~iscell(UserData)
    
    % to prevent errors, the button "View" is disabled when we open the
    % toolbar the first time. Pushing the button "View in new" enables it
  
    lbh = findobj(toolbar,'Tag','button_view');
    set(lbh,'Enable','on');
  
    %  same job is done for the "close figure" button.
  
    lbh = findobj(toolbar,'Tag','button_close_figure');
    set(lbh,'Enable','on');

    %  same job is done for the "Print" button.
  
    lbh = findobj(toolbar,'Tag','button_print');
    set(lbh,'Enable','on');

    %  same job is done for the "Axes" button.
  
    lbh = findobj(toolbar,'Tag','button_Axes');
    set(lbh,'Enable','on');

    %  same job is done for the "Image/Matrix" button.
  
    % lbh = findobj(toolbar,'Tag','button_Image_Matrix');
    % set(lbh,'Enable','on');

    %  same job is done for the "zoom" & "rotate" & "hold" checkboxes.
  
    % lbh = findobj(toolbar,'Tag','Checkbox_zoom');
    % set(lbh,'Enable','on');
    % lbh = findobj(toolbar,'Tag','Checkbox_rotate');
    % set(lbh,'Enable','on');
    % lbh = findobj(toolbar,'Tag','Checkbox_hold');
    % set(lbh,'Enable','on');

    %  same job is done for the split texts and textBoxes
    lbh = findobj(toolbar,'Tag','StaticText_Vsplit');
    set(lbh,'Enable','on');
    lbh = findobj(toolbar,'Tag','EditText_Vsplit');
    set(lbh,'Enable','on');
    set(lbh,'String','1');
  
    lbh = findobj(toolbar,'Tag','StaticText_Hsplit');
    set(lbh,'Enable','on');
    lbh = findobj(toolbar,'Tag','EditText_Hsplit');
    set(lbh,'Enable','on');
    set(lbh,'String','1');  
  else
    lbh = findobj(toolbar,'Tag','EditText_Vsplit');
    set(lbh,'String','1');
    lbh = findobj(toolbar,'Tag','EditText_Hsplit');
    set(lbh,'String','1');
    lbh = findobj(toolbar,'Tag','Checkbox_zoom');
    % set(lbh,'Enable','on');
    set(lbh,'Value',0);
    lbh = findobj(toolbar,'Tag','Checkbox_rotate');
    set(lbh,'Value',0);
    lbh = findobj(toolbar,'Tag','Checkbox_hold');
    set(lbh,'Value',0);
    lbh = findobj(toolbar,'Tag','Checkbox_superpose');
    set(lbh,'Value',0);
  end

  % then we plot the highlighted var in "fltool" window 
  var_name = fl_get_input('');
  eval (['global ' var_name]);
  var = eval(var_name);
  gui_figure;
  Win_handle = gcf;
  
  plot_handle = subplot (1,1,1);
  set (Win_handle,'MenuBar','figure');
  
  if iscell(UserData)
    nb_opened_windows = length (UserData) + 1;
  else
    nb_opened_windows = 1;
    UserData = cell(1);
  end
  
  [str_var flag_error] = fl_get_input;
  if ~exist(str_var)
    eval(['global ' str_var]);
  end
  eval (['data = ' str_var ';']);
  if flag_error
    fl_waitoff(cursor);
    return
  end

  if isstruct(data)
    if strcmp(data.type,'graph') % graph
      img_struct = struct('mode',-1);
    else % Wavelet 
      img_struct = fl_image_functions('defaultWaveletStruct');
    end
  else
    temp=size(data);
    if ( (temp(1)==1) | (temp(2)==1) )  % plot
      img_struct = struct('mode',-1);
    else  % image
      img_struct = fl_image_functions('defaultImageStruct');
    end
  end
  
  Window_properties = struct('Name',[var_name ' ' num2str(double(Win_handle)) '.1'],'Win_Handle',Win_handle,'Plot_Handle' , plot_handle,'Image',img_struct,'Data',data);
  sub_plot = cell(1);
  sub_plot{1} = Window_properties;
  UserData{nb_opened_windows} = sub_plot;
  set (toolbar,'UserData',UserData);
  
  % when this is done, we must put the name of the new figure in the listbox 
  % and update the highlighted variable

  fl_view_functions('refresh_listbox');
  listbox_handle = findobj(toolbar,'Tag','Listbox_figures');
  temp = length(get (listbox_handle,'String')) -1;
  set (listbox_handle,'Value',temp);
      
  % update the 'Name' of the graph window
  
  %set (Win_handle,'Name', ['View ' num2str(Win_handle)]);
  
  % and plot ...
  fl_view_functions('view_call');
  fl_view_toolbar('click_listbox');
  fl_window_init(fl_view_functions('get_handle'),'Figure');

  
% -----------------------
   case ('Close_figure')
% -----------------------

  % get the highlighted var in "fltool" window

  close(fl_view_functions('get_window_handle'));
  fl_view_toolbar('click_listbox');
  
  
% -----------------------
   case ('axes')
% -----------------------

  gui_axes;
  fl_axes_functions('refresh_axes_control_panel');
  axesButton = findobj(toolbar,'Tag','button_Axes');
  set(axesButton,'Enable','off');
 
  
% ---------------
  case ('rotate')
% ---------------

  figure(fl_view_functions('get_window_handle'));
  superposeHandle = findobj(toolbar,'Tag','Checkbox_superpose');
  set(superposeHandle,'Value',0);
  zoomHandle = findobj(toolbar,'Tag','Checkbox_zoom');
  if get(zoomHandle,'Value') == 1
    zoom off;
  end  
  set(zoomHandle,'Value',0);
  holdHandle = findobj(toolbar,'Tag','Checkbox_hold');
  if get(holdHandle,'Value') == 1
    hold off;
  end  
  set(holdHandle,'Value',0);

  fl_figure('refresh_userData');
  rotate3d;
  % if axes control panel is here, refresh it ...
  axesCP = findobj('Tag','gui_axes_control_panel');
  if ~isempty(axesCP)
    fl_axes_functions('refresh_axes_control_panel');
  end


% ---------------
  case ('zoom')
% ---------------

  % le zoom fonctionne sur une figure entiere, meme si elle est
  % divisee en plusieurs subplots.
  figure(fl_view_functions('get_window_handle'));
  superposeHandle = findobj(toolbar,'Tag','Checkbox_superpose');
  set(superposeHandle,'Value',0);
  
  rotateHandle = findobj(toolbar,'Tag','Checkbox_rotate');
  if get(rotateHandle,'Value') == 1
    rotate3d off;
  end  
  set(rotateHandle,'Value',0);
  
  holdHandle = findobj(toolbar,'Tag','Checkbox_hold');
  if get(holdHandle,'Value') == 1
    hold off;
  end  
  set(holdHandle,'Value',0);

  fl_figure('refresh_userData');
  zoom;

  % if axes control panel is here, refresh it ...
  axesCP = findobj('Tag','gui_axes_control_panel');
  if ~isempty(axesCP)
    fl_axes_functions('refresh_axes_control_panel');
  end
  
% ---------------
  case ('hold')
% ---------------

  figure(fl_view_functions('get_window_handle'));
  
  zoomHandle = findobj(toolbar,'Tag','Checkbox_zoom');
  superposeHandle = findobj(toolbar,'Tag','Checkbox_superpose');

  set(superposeHandle,'Value',0);
  if get(zoomHandle,'Value') == 1
    zoom off;
  end  
  set(zoomHandle,'Value',0);
  rotateHandle = findobj(toolbar,'Tag','Checkbox_rotate');
  if get(rotateHandle,'Value') == 1
    rotate3d off;
  end  
  set(rotateHandle,'Value',0);

  fl_figure('refresh_userData');
  hold;

  % if axes control panel is here, refresh it ...
  axesCP = findobj('Tag','gui_axes_control_panel');
  if ~isempty(axesCP)
    fl_axes_functions('refresh_axes_control_panel');
  end
  
% ---------------
  case ('superpose_image')
% ---------------

  figure(fl_view_functions('get_window_handle'));
  zoomHandle = findobj(toolbar,'Tag','Checkbox_zoom');
  if get(zoomHandle,'Value') == 1
    zoom off;
  end  
  set(zoomHandle,'Value',0);
  holdHandle = findobj(toolbar,'Tag','Checkbox_hold');
  if get(holdHandle,'Value') == 1
    hold off;
  end  
  set(holdHandle,'Value',0);
  rotateHandle = findobj(toolbar,'Tag','Checkbox_rotate');
  if get(rotateHandle,'Value') == 1
    rotate3d off;
  end  
  set(rotateHandle,'Value',0);

  fl_figure('refresh_userData');
  % ici appelez ce qu'il faut xxx

  
  axesCP = findobj('Tag','gui_axes_control_panel');
  if ~isempty(axesCP)
    fl_axes_functions('refresh_axes_control_panel');
  end

% ---------------
  case ('divide')
% ---------------

  % in this case we want to divide the screen depending on the values
  % of the two edittext fields 
  Handle_V = findobj(toolbar,'Tag','EditText_Vsplit');
  Handle_H = findobj(toolbar,'Tag','EditText_Hsplit');
  Divide_V = str2num(get (Handle_V,'String'));
  Divide_H = str2num(get (Handle_H,'String'));
  if (~isnumeric(Divide_V)) | (~isnumeric(Divide_H)) | (isempty (Divide_V)) | (isempty (Divide_H)) | (Divide_V < 1) | (Divide_H < 1)
    fl_warning('Please enter valid values');
  else
    Window_handle = fl_view_functions('get_window_handle');
    fl_figure('refresh_userData');
    Window_childrens = get(Window_handle,'Children');

    % first, build a temporary window with the wanted resultat 
    gui_figure;
    temp_window = gcf;
    set (temp_window,'Visible','off');
    if (length(Window_childrens)) > (Divide_V * Divide_H)
      nb_of_subplots = Divide_V * Divide_H;
    else
      nb_of_subplots = length(Window_childrens);
    end
    
    for i = 1 : nb_of_subplots
      current_axes_handle = Window_childrens(length(Window_childrens) - i + 1);
      temp_subplot = subplot(Divide_V,Divide_H,i);
      position_subplot = get (temp_subplot,'position');
      temp_axes(i) = copyobj (current_axes_handle,temp_window);
      set (temp_axes(i),'position',position_subplot);
    end
    
    % erase the original window
    figure (Window_handle);
    clf;
    
    % then copy the temp window in the original one
    new_plot_handles = copyobj (temp_axes,Window_handle);
    set (0,'CurrentFigure',temp_window);
    closereq;
    
    % now, just update the toolbar properties to fit the new handles
    % and update the listbox
    listbox_handle = findobj(toolbar,'Tag','Listbox_figures');
    UserData = get (toolbar,'UserData');
    name_of_window = gcf;
    strings = get (listbox_handle,'String');
    for i = 1 : length (strings)
      if strcmp(strings{i},name_of_window)
	set (listbox_handle,'Value',i);
      end
    end    
    for i = 1 : length(UserData) 
      if UserData{i}{1}.Win_Handle == gcf
	index = i;
      end
    end
    temp_cell = cell(1);
    for k = 1 : nb_of_subplots
      temp_cell{k} = UserData{index}{k};
      temp_cell{k}.Plot_Handle = new_plot_handles(k);
    end
    UserData{index} = temp_cell;
    set (toolbar,'UserData',UserData);
    fl_view_functions ('refresh_listbox');
  end

% ---------------
  case ('image')
% ---------------

  gui_view_image;
  % fl_view_toolbar('click_listbox');
  fl_image_functions('refresh_image_control_panel');
  imageButton = findobj(toolbar,'Tag','button_Image_Matrix');
  set(imageButton,'Enable','off');

end % switch








