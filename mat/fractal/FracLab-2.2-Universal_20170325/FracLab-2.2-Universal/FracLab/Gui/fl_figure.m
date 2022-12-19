function fl_figure(string)
% No help found

% Modified by Christian Choque Cortez October 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch (string)
    
% ------------
  case 'close'
% ------------

  % in this case, we refresh the content of the Listbox when a window
  % is closed by updating the 'UserData' field and call the refresh 

  toolbar = findobj('Tag','gui_view_toolbar');
  listbox_handle = findobj(toolbar,'Tag','Listbox_figures');
  graph_handle = gcf;
  closereq;
  UserData = get (toolbar,'UserData');
  temp_UserData = [];
  temp_compteur = 1 ;
  for i = 1 : length(UserData)
    if UserData{i}{1}(1).Win_Handle ~= graph_handle
      temp_UserData{temp_compteur} = UserData {i};
      temp_compteur = temp_compteur + 1 ;
    end
  end
  set (toolbar,'UserData',temp_UserData);
  set (listbox_handle,'Value',1);
  fl_view_functions ('refresh_listbox');
  
  if isempty(temp_UserData)
    temp_handle = findobj ('Tag','button_view');
    set(temp_handle,'Enable','off');
    temp_handle = findobj ('Tag','button_close_figure');
    set(temp_handle,'Enable','off');    
    temp_handle = findobj ('Tag','Checkbox_rotate');
    set(temp_handle,'Enable','off');
    set(temp_handle,'Value',0);
    % rotate3d off;
    temp_handle = findobj ('Tag','Checkbox_zoom');
    set(temp_handle,'Enable','off');
    set(temp_handle,'Value',0);
    % zoom off;
    temp_handle = findobj ('Tag','Checkbox_hold');
    set(temp_handle,'Enable','off');
    set(temp_handle,'Value',0);
    temp_handle = findobj ('Tag','Checkbox_superpose');
    set(temp_handle,'Enable','off');
    set(temp_handle,'Value',0);
    % ne SURTOUT pas le mettre => trace dans la gcf un axe ... 
    % et gcf == toolbar :(
    % hold off;
    temp_handle = findobj ('Tag','button_print');
    set(temp_handle,'Enable','off');
    temp_handle = findobj ('Tag','StaticText_Vsplit');
    set(temp_handle,'Enable','off');
    temp_handle = findobj ('Tag','EditText_Vsplit');
    set(temp_handle,'String','1');
    set(temp_handle,'Enable','off');
    temp_handle = findobj ('Tag','StaticText_Hsplit');
    set(temp_handle,'Enable','off');
    temp_handle = findobj ('Tag','EditText_Hsplit');
    set(temp_handle,'String','1');
    set(temp_handle,'Enable','off');
  
    % Axes job ...
    temp_handle = findobj ('Tag','button_Axes');
    set(temp_handle,'Enable','off');
    axesCP = findobj('Tag','gui_axes_control_panel');
    if ~isempty(axesCP)
      close(axesCP);
    end
    
    % Images job ...
    temp_handle = findobj ('Tag','button_Image_Matrix');
    set(temp_handle,'Enable','off');
    img = findobj('Tag','gui_image_control_panel');
    if ~isempty(img)
      close(img);
    end
    % else
    %  fl_view_functions ('refresh_split');
    %  fl_view_functions ('refresh_zoom');
    %  fl_view_functions ('refresh_rotate');
    %  fl_view_functions ('refresh_hold');
    %  fl_axes_functions('refresh_axes_control_panel');
  end

% ------------
  case 'refresh_userData'
% ------------

  % refresh the UD of a figure.
  % ud is buit this way : [splitV splitH rotate zoom hold] 

  toolbar = findobj ('Tag','gui_view_toolbar');
  Divide_V = str2num(get (findobj(toolbar,'Tag','EditText_Vsplit'),'String'));
  Divide_H = str2num(get (findobj(toolbar,'Tag','EditText_Hsplit'),'String'));
  rotateFlag = get(findobj(toolbar,'Tag','Checkbox_rotate'),'Value');
  zoomFlag = get(findobj(toolbar,'Tag','Checkbox_zoom'),'Value');
  holdFlag = get(findobj(toolbar,'Tag','Checkbox_hold'),'Value');
  superposeFlag  = get(findobj(toolbar,'Tag','Checkbox_superpose'),'Value');
  Window_handle = fl_view_functions('get_window_handle');
  set(Window_handle,'UserData',[Divide_V,Divide_H,rotateFlag,zoomFlag,holdFlag,superposeFlag]);
  
  
end % SWITCH
