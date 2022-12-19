function [result,varargout] = fl_view_functions(param)
% No help found

% Modified by Christian Choque Cortez October 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

result = 0;

switch (param)

% ----------------------
  case 'refresh_listbox'
% ----------------------

  % in this case, we use the information contained in the 
  % 'UserData' propertie of the toolbar to redraw the content
  % of the listbox.

  toolbar_handle = findobj('Tag','gui_view_toolbar');
  UserData = get(toolbar_handle,'UserData');

  % if iscell(UserData)
  if ~isempty(UserData)
    % disp('not empty');
    Strings = cell(1);
    compteur = 1;
    for i=1:(length(UserData))
        Strings{compteur}=['View ' num2str(double(UserData{i}{1}(1).Win_Handle))];
        compteur = compteur +1;
        for j=1:(length(UserData{i}))
            Strings{compteur}=['  ' UserData{i}{j}(1).Name];
            compteur = compteur +1;
        end
    end
  else
    Strings = ' ';
  end
  listbox_handle = findobj(toolbar_handle,'Tag','Listbox_figures');
  set (listbox_handle,'String',Strings);

% ----------------------
  case 'load_userData'
% ----------------------

  window = fl_view_functions('get_window_handle');
  UserData = get(window,'UserData');

  toolbar = findobj('Tag','gui_view_toolbar');
  handle_V = findobj(toolbar,'Tag','EditText_Vsplit');
  set(handle_V,'String',UserData(1));
  handle_H = findobj(toolbar,'Tag','EditText_Hsplit');
  set(handle_H,'String',UserData(2));
  rotateHandle = findobj(toolbar,'Tag','Checkbox_rotate');
  set(rotateHandle,'Value',UserData(3));
  zoomHandle = findobj(toolbar,'Tag','Checkbox_zoom');
  set(zoomHandle,'Value',UserData(4));
  zoomHandle = findobj(toolbar,'Tag','Checkbox_hold');
  set(zoomHandle,'Value',UserData(5));
  superposeHandle = findobj(toolbar,'Tag','Checkbox_superpose');
  set(superposeHandle,'Value',UserData(6));
    
% ----------------------
  case 'refresh_split'
% ----------------------

  window = fl_view_functions('get_window_handle');
  UserData = get(window,'UserData');

  toolbar = findobj('Tag','gui_view_toolbar');
  handle_V = findobj(toolbar,'Tag','EditText_Vsplit');
  set(handle_V,'String',UserData(1));
  handle_H = findobj(toolbar,'Tag','EditText_Hsplit');
  set(handle_H,'String',UserData(2));
  
% ----------------------
  case 'refresh_rotate'
% ----------------------

  window = fl_view_functions('get_window_handle');
  UserData = get(window,'UserData');

  toolbar = findobj('Tag','gui_view_toolbar');
  rotateHandle = findobj(toolbar,'Tag','Checkbox_rotate');
  set(rotateHandle,'Value',UserData(3));
  
% ----------------------
  case 'refresh_zoom'
% ----------------------

  window = fl_view_functions('get_window_handle');
  UserData = get(window,'UserData');

  toolbar = findobj('Tag','gui_view_toolbar');
  zoomHandle = findobj(toolbar,'Tag','Checkbox_zoom');
  set(zoomHandle,'Value',UserData(4));
  
% ----------------------
  case 'refresh_hold'
% ----------------------

  window = fl_view_functions('get_window_handle');
  UserData = get(window,'UserData');

  toolbar = findobj('Tag','gui_view_toolbar');
  zoomHandle = findobj(toolbar,'Tag','Checkbox_hold');
  set(zoomHandle,'Value',UserData(5));
  
% ----------------------
  case 'refresh_superpose'
% ----------------------

  window = fl_view_functions('get_window_handle');
  UserData = get(window,'UserData');

  toolbar = findobj('Tag','gui_view_toolbar');
  superposeHandle = findobj(toolbar,'Tag','Checkbox_superpose');
  set(superposeHandle,'Value',UserData(6));

% ----------------------
  case 'create_superpose'
% ----------------------

  gui_superpose;
  
% ----------------------
  case 'get_handle'
% ----------------------

  % in this case, we want to return the handle conresponding
  % to the highlighted variable in the 'lisbox' of the toolbar

  toolbar_handle = findobj ('Tag','gui_view_toolbar');
  listbox_handle = findobj(toolbar_handle,'Tag','Listbox_figures');
  UserData = get (toolbar_handle,'UserData');
  strings = get (listbox_handle,'String');
  values = get (listbox_handle,'Value');
  val = values(1);
  
  current_val = 1;
  current_window = 1;
  
  for i = 1:length(UserData)
    if current_val == val 
      result = UserData{current_window}{1}.Win_Handle;
      return;
    end
    current_val = current_val +1;
    for j = 1:length(UserData {current_window})
      if current_val == val 
	result = UserData{current_window}{j}.Plot_Handle;
	return;
      end
      current_val = current_val +1;
    end
    current_window = current_window +1;	
  end 

% ----------------------
  case 'get_name'
% ----------------------

  % in this case, we want to return the name conresponding
  % to the highlighted variable in the 'lisbox' of the toolbar
  % if  it's a view (ans not a plot) we return the first plot

  toolbar_handle = findobj ('Tag','gui_view_toolbar');
  listbox_handle = findobj(toolbar_handle,'Tag','Listbox_figures');
  UserData = get (toolbar_handle,'UserData');
  strings = get (listbox_handle,'String');
  values = get (listbox_handle,'Value');
  val = values(1);
  
  current_val = 1;
  current_window = 1;
  
  for i = 1:length(UserData)
    if current_val == val 
      result = UserData{current_window}{1}.Name;
      return;
    end
    current_val = current_val +1;
    for j = 1:length(UserData {current_window})
      if current_val == val 
	result = UserData{current_window}{j}.Name;
	return;
      end
      current_val = current_val +1;
    end
    current_window = current_window +1;	
  end 

% ----------------------
  case 'get_plot_handle'
% ----------------------

  % in this case, we want to return the plot handle conresponding
  % to the highlighted variable in the 'lisbox' of the toolbar
  % if  it's a view (ans not a plot) we return the first plot

  toolbar_handle = findobj ('Tag','gui_view_toolbar');
  listbox_handle = findobj(toolbar_handle,'Tag','Listbox_figures');
  UserData = get (toolbar_handle,'UserData');
  strings = get (listbox_handle,'String');
  values = get (listbox_handle,'Value');
  val = values(1);
  
  current_val = 1;
  current_window = 1;
  
  for i = 1:length(UserData)
    if current_val == val 
      result = UserData{current_window}{1}.Plot_Handle;
      return;
    end
    current_val = current_val +1;
    for j = 1:length(UserData {current_window})
      if current_val == val 
	result = UserData{current_window}{j}.Plot_Handle;
	return;
      end
      current_val = current_val +1;
    end
    current_window = current_window +1;	
  end 


% ----------------------
  case 'get_window_handle'
% ----------------------

  % in this case, we want to return the handle conresponding
  % to the highlighted variable in the 'lisbox' of the toolbar

  toolbar_handle = findobj ('Tag','gui_view_toolbar');
  listbox_handle = findobj(toolbar_handle,'Tag','Listbox_figures');
  UserData = get (toolbar_handle,'UserData');
  strings = get (listbox_handle,'String');
  values = get (listbox_handle,'Value');
  val = values(1);
  
  current_val = 1;
  current_window = 1;
  
  for i = 1:length(UserData)
    result = UserData{current_window}{1}.Win_Handle;
    if current_val == val      
      return;
    end
    current_val = current_val +1;
    for j = 1:length(UserData {current_window})
      if current_val == val 
	return;
      end
      current_val = current_val +1;
    end
    current_window = current_window +1;	
  end 

  
% ----------------------
case 'get_i_j'
% ----------------------

% in this case, we want to return the i and j corresponding
% to the highlighted variable in the 'lisbox' (UserData{i}{j}) 


      toolbar_handle = findobj ('Tag','gui_view_toolbar');
      listbox_handle = findobj(toolbar_handle,'Tag','Listbox_figures');
      UserData = get (toolbar_handle,'UserData');
      strings = get (listbox_handle,'String');
      values = get (listbox_handle,'Value');
      val = values(1);
	  
      current_val = 1;
      current_window = 1;
      
      for i = 1:length(UserData)
	if current_val == val 
	  result = [i 0];
	  return;
	end
	current_val = current_val +1;
	
	for j = 1:length(UserData {current_window})
	  if current_val == val 
	    result = [i j];
	    return;
	  end
	  current_val = current_val +1;
	end
	
	current_window = current_window +1;
      end 
      
% ----------------------
case 'getMatrix'
% ----------------------
  
  % search for the data
  toolbar = findobj('Tag','gui_view_toolbar');
  userdata=get(toolbar,'UserData');
  selected_cell = fl_view_functions('get_i_j');
  i = selected_cell(1);
  j = selected_cell(2);
  data = userdata{i}{j}.Data;
  if isstruct(data)
    if (strcmp(data.type,'cwt'))
      mat = data.coeff;
    end  
    if (strcmp(data.type,'dwt' ) | strcmp(data.type,'dwt2d'))
      mat = data.wt;
    end
    onlydata = 0;
  else
    mat=data;
    onlydata = 1;
  end
  result = mat;
  varargout(1) = {onlydata};
  
% ----------------------
case 'get_plot_type'
% ----------------------

  current_axes_handle = fl_view_functions('get_handle');
  handle_type = get(current_axes_handle,'Type');
  if strcmp(handle_type,'figure')
    current_axes_handle = get (current_axes_handle,'currentaxes');
  end
  [varName flag_error] = fl_get_input;
  if ~exist(varName)
    eval(['global ' varName]);
  end
  eval (['inputData = ' varName ';']);
  if flag_error
    return
  end
  if isstruct(inputData)
    switch(inputData.type)
      case 'graph'
	result = 'graph';
	return
      
      case 'cwt'
	result = 'wavelet';
	return
	
      case 'dwt2d'
	result = 'wavelet';
	return
      
      case 'dwt'
	result = 'wavelet';
	return
	
      otherwise
	fl_warning ('I don''t know this kind of plot !');
	return
    end
  else
    mat=inputData;
    temp=size(mat);
    if ( (temp(1)==1) | (temp(2)==1) )
      result = 'plot';
      dim=1;
    else
      result = 'image';
      dim=2;
    end
    return
  end
  
% ----------------------
case 'view_call'
% ----------------------


  current_axes_handle = fl_view_functions('get_handle');
  handle_type = get(current_axes_handle,'Type');
  if strcmp(handle_type,'figure')
    current_axes_handle = get (current_axes_handle,'currentaxes');
  end
  [varName flag_error] = fl_get_input;
  if ~exist(varName)
    eval(['global ' varName]);
  end
  eval (['inputData = ' varName ';']);
  if flag_error
    return
  end
  if isstruct(inputData)
    switch(inputData.type)
      case 'graph'
	grid on;
    datanames = fieldnames(inputData);
    data1 = eval(['inputData.',datanames{2}]);
    data2 = eval(['inputData.',datanames{3}]);
    plot(data1,data2);
    try %#ok<TRYNC>
        title(inputData.title);
        xlabel(inputData.xlabel);
        ylabel(inputData.ylabel);
    end
	result = 'graph';
	return
      
      case 'cwt'
	mat = inputData.coeff;
	if ~isreal(mat)
	  mat = abs(mat) ;
	end 
	viewmat(mat,[1 0 0 1]);
	result = 'wavelet';
	colormap(jet);
	return
	
      case 'dwt2d'
	mat=WT2DVisu(inputData.wt);
	viewmat(mat);
	result = 'wavelet';
	colormap(gray); %colormap(jet);
	return
      
      case 'dwt'
          mat=DWT1D_display1(inputData.wt);
          imagesc(mat);colorbar;
          result = 'wavelet';
          colormap(jet);
          
          
%          mat=WTMultires(inputData.wt);
%          %index=inputData.index;
%          %if length(index)>2
%             %mat = abs(mat) ;
% 	         viewmat(mat(:,1:(inputData.size)),[1 0 0 1]);
% 	         result = 'wavelet';
%             colormap(jet);
%          %else
%             %plot(mat(1:(inputData.size)));
%             %result = 'wavelet';
%             %colormap(jet);
%          %end;   
	return
	
      otherwise
	fl_warning ('I don''t know how to plot that !');
	return
    end
  elseif iscell(inputData)
      mat = inputData;
      temp = max(size(mat));
      for ii = 1:temp
          contour(mat{ii});hold on;
      end
      result = 'graph';
      return
  else
    mat=inputData;
    temp=size(mat);
    if ( (temp(1)==1) | (temp(2)==1) )
      result = 'plot';
      dim=1;
    else
      result = 'image';
      dim=2;
    end
    if dim==1
      axes(current_axes_handle);
      plot(mat);
      return;
    end
    try
        viewmat(mat,[0 0 0 1]);
        colormap(gray);
        axis image;
        return
    catch %#ok<CTCH>
        imagesc(mat);
        axis image;
    end

  end

end











