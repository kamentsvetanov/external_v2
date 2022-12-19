function res = fl_image_functions(param);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

res = 0;

switch (param)
  
% ----------------------
  case 'refresh_image_control_panel'
% ----------------------

  img = findobj('Tag','gui_image_control_panel');

  % refresh name
  figName = fl_view_functions('get_name');
  tmp = findobj(img,'Tag','EditText_figName');
  set(tmp,'String',figName);
  
  % get userdata.data to refresh the window
  selected_cell = fl_view_functions('get_i_j');
  i = selected_cell(1);
  j = selected_cell(2);
  userdata = get(findobj('Tag','gui_view_toolbar'),'UserData');
  data = userdata{i}{j}.Image;

  set(findobj(img,'Tag','PopupMenu_viewMode'),'Value',data.mode);
  fl_view_image('ppm_viewMode');
  set(findobj(img,'Tag','PopupMenu_colormap'),'Value',data.colormap);
  % set(findobj(img,'Tag','ppm_axis'),'Value',data.axis);
  set(findobj(img,'Tag','cbAxis'),'Value',data.axis);
  fl_view_image('cbAxis');  
  % set(findobj(img,'Tag','ppm_scaleMethod'),'Value',data.scale);
  set(findobj(img,'Tag','cbValue'),'Value',data.value);
  fl_view_image('cbValue');
  set(findobj(img,'Tag','cbDisplay'),'Value',data.display);
  fl_view_image('cbDisplay');
  set(findobj(img,'Tag','cbScaleMethod'),'Value',data.scale);
  fl_view_image('cbScaleMethod'); % appelle aussi fl_view_image('cbValue')
  set(findobj(img,'Tag','cbReverse'),'Value',data.reverse);
  fl_view_image('cbReverse');
  set(findobj(img,'Tag','cbBinary'),'Value',data.binary);
  fl_view_image('cbBinary');
  set(findobj(img,'Tag','EditText_linecol'),'String',data.linecol);
  set(findobj(img,'Tag','EditText_minlevel'),'String',data.minlevel)
  set(findobj(img,'Tag','EditText_maxlevel'),'String',data.maxlevel)
  set(findobj(img,'Tag','EditText_xaxe'),'String',data.xaxis);
  set(findobj(img,'Tag','EditText_yaxe'),'String',data.yaxis);
  set(findobj(img,'Tag','EditText_getPoint'),'String','none');
  
  
% ----------------------
  case 'disable'
% ----------------------

  img = findobj('Tag','gui_image_control_panel');
  childrens = get(img,'Children');
  nb_childrens = length (childrens);
  for i=1:nb_childrens
    set(childrens(i),'Enable','off');
  end
  set(findobj(img,'Tag','button_close'),'Enable','on');
  
% ----------------------
  case 'enable'
% ----------------------

  img = findobj('Tag','gui_image_control_panel');
  childrens = get(img,'Children');
  nb_childrens = length (childrens);
  for i=1:nb_childrens
    set(childrens(i),'Enable','on');
  end
  fl_image_functions('refresh_image_control_panel');
  
  
% ----------------------
  case 'defaultWaveletStruct'
% ----------------------
  res  = struct(...
      'mode',1,...
      'colormap',1,...
      'axis',0,...
      'linecol','1',...
      'scale',0,...
      'value',0,...
      'display',0,...
      'reverse',0,...
      'binary',0,...
      'minlevel','0',...
      'maxlevel','1',...
      'xaxis','\default',...
      'yaxis','\default');
  
% ----------------------
  case 'defaultImageStruct'
% ----------------------
  res  = struct(...
      'mode',1,...
      'colormap',2,...
      'axis',1,...
      'linecol','1',...
      'scale',0,...
      'value',0,...
      'display',0,...
      'reverse',0,...
      'binary',0,...
      'minlevel','0',...
      'maxlevel','1',...
      'xaxis','\default',...
      'yaxis','\default');
  
 
end % SWITCH





