function result = fl_superpose(param);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

  result = 0;
  superposePanel = findobj('Tag','gui_superpose');
  
switch (strtok(param))

% ----------------------
  case 'slider_lutRatio'
% ----------------------

  slid_lutRatio = findobj(superposePanel,'Tag','Slider_lutRatio');
  val = get(slid_lutRatio,'Value');
  ed_lutRatio = findobj(superposePanel,'Tag','EditText_lutRatio');
  set(ed_lutRatio,'String',num2str(val));
  
  slid_threshold = findobj(superposePanel,'Tag','Slider_threshold');
  max_threshold = 1 - val;
  val = get(slid_threshold,'Value');
  if val > max_threshold
    val = max_threshold;
  end
  ed_threshold = findobj(superposePanel,'Tag','EditText_threshold');
  if max_threshold ~= 0
    set(slid_threshold,'Enable','on');
    set(slid_threshold,'Value',val);    
    set(slid_threshold,'Max',max_threshold);
    set(ed_threshold,'String',num2str(val));
  else
    set(slid_threshold,'Enable','off');
    set(ed_threshold,'Enable','off');
  end
  
  
% ----------------------
  case 'slider_threshold'
% ----------------------

  slid_threshold = findobj(superposePanel,'Tag','Slider_threshold');
  val = get(slid_threshold,'Value');
  ed_threshold = findobj(superposePanel,'Tag','EditText_threshold');
  set(ed_threshold,'String',val);

% ----------------------
  case 'edit_lutRatio'
% ----------------------

  ed_lutRatio = findobj(superposePanel,'Tag','EditText_lutRatio');
  val = str2num(get(ed_lutRatio,'String'));
  if ((isempty(val)) | (~isnumeric(val)))
    set(ed_lutRatio,'String','0.8');
    val = '0.8';
  end
  if (val>1)
    fl_error('lut ratio must be in [0.5,1]');
    set(ed_lutRatio,'String','1');
    val = 1;
  elseif (val < 0.5)
    fl_error('lut ratio must be in [0.5,1]');
    set(ed_lutRatio,'String','0.5');
    val = 0.5;
  end;
  slid_lutRatio = findobj(superposePanel,'Tag','Slider_lutRatio');
  set(slid_lutRatio,'Value',val);
  
  slid_threshold = findobj(superposePanel,'Tag','Slider_threshold');
  max_threshold = 1 - val;
  val = get(slid_threshold,'Value');
  if val > max_threshold
    val = max_threshold;
  end
  if max_threshold ~= 0
    set(slid_threshold,'Enable','on');
    set(slid_threshold,'Value',val);    
    set(slid_threshold,'Max',max_threshold);
    ed_threshold = findobj(superposePanel,'Tag','EditText_threshold');
    set(ed_threshold,'String',num2str(val));
  else
    set(slid_threshold,'Enable','off');
    set(ed_threshold,'Enable','off');
  end
  
% ----------------------
  case 'edit_threshold'
% ----------------------

  slid_threshold = findobj(superposePanel,'Tag','Slider_threshold');
  ed_threshold = findobj(superposePanel,'Tag','EditText_threshold');
  val = str2num(get(ed_threshold,'String'));
  min_threshold = get(slid_threshold,'Min');
  max_threshold = get(slid_threshold,'Max');
  if ((isempty(val)) | (~isnumeric(val)))
    val = (max_threshold-min_threshold) / 2;
  end
  if (val>max_threshold)
    fl_error(['threshold must be in [0,' num2str(max_threshold) ']']);
    set(ed_threshold,'String',num2str(max_threshold));
    val = max_threshold;
  elseif (val < min_threshold)
    fl_error(['threshold must be in [0,' num2str(max_threshold) ']']);
    set(ed_threshold,'String','0.01');
    val = 0.01;
  end;
  
  set(slid_threshold,'Value',val);

  
% ----------------------
  case 'compute_superpose'
% ----------------------

  cursor = fl_waiton;  
  
  % be sure to have a picture in fltool ...
  [otherPict pictError] = fl_get_details;
  if pictError
    return
  end
  
  if ~exist (strtok(otherPict,'.'))
    varname = strtok(otherPict,'.');
    eval (['global ' varname]);
  end
  pict = eval (otherPict); 

  % search for the data
  %toolbar = findobj('Tag','gui_view_toolbar');
  %userdata=get(toolbar,'UserData');
  %selected_cell = fl_view_functions('get_i_j');
  %i = selected_cell(1);
  %j = selected_cell(2);
  %data = userdata{i}{j}.Data;
  %if isstruct(data)
  %  if (strcmp(data.type,'cwt'))
  %    mat = data.coeff;
  %  end  
  %  if (strcmp(data.type,'dwt' ) | strcmp(data.type,'dwt2d'))
  %    mat = data.wt;
  %  end
  %else
  %  mat=data;
  %end
  %if ~isreal(mat)
  %  fl_error(['Error : SUPERPOSE : ' otherPict ' comlex : must be real']);
  %  return;
  %end
  mat = fl_view_functions('getMatrix');
  [rowsMat columnsMat] = size(mat);
  [rowsPict columnsPict] = size(pict);
  if ((rowsMat ~= rowsPict) | (columnsMat ~= columnsPict))
    fl_error('Error : SUPERPOSE : images must have the same sizes');
    return;
  end

  lutRatio=str2num(get(findobj(superposePanel,'Tag','EditText_lutRatio'),'String'));
  Zmax = max(max(mat));
  Zmin = min(min(mat));
  a = 1/(Zmax-Zmin) ;
  b = -a*Zmin ;
  mat = a.*mat + b ;
  mat = lutRatio*mat; 

  Zmax = max(max(pict));
  Zmin = min(min(pict));
  a = 1/(Zmax-Zmin) ;
  b = -a*Zmin ;
  pict = a.*pict + b ;
  pict = (1-lutRatio)*pict + lutRatio;
 threshold=str2num(get(findobj(superposePanel,'Tag','EditText_threshold'),'String'));
  seuil = lutRatio+threshold;
  mask = find(pict >= seuil);
  display = mat;
  display(mask) = pict(mask);
 
  % build new colormap
  h = gray;
  [rows lines] = size(h);
  j = jet;
  [rj lj] = size(j);
  % XXX
  newColor = round(rows/lutRatio) - rows;
  h(rows+1:rows+newColor,:) = j(rj-newColor+1:rj,:);
  
  % on la balance
  figure(fl_view_functions('get_window_handle'));
  viewmat(display);
  colormap(h);

  fl_waitoff(cursor);
  
% ----------------------
  case 'Close'
% ----------------------  
  close(superposePanel);


  
end





