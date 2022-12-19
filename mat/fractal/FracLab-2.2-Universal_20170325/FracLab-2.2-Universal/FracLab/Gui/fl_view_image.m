function fl_view_image(param)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,fig] = gcbo;
if ((isempty(fig)) | (~strcmp(get(fig,'Tag'),'gui_image_control_panel')))
  fig = findobj('Tag','gui_image_control_panel');
end

switch(param)

% --------------------
  case 'cbAxis'
% --------------------

  cursor = fl_waiton;
  cbaxis = findobj(fig,'Tag','cbAxis'); 
  if get(cbaxis,'Value') == 1
    set(cbaxis,'String','image');
  else
    set(cbaxis,'String','rescaled');
  end
  fl_waitoff(cursor);
  
% --------------------
  case 'cbReverse'
% --------------------

  cursor = fl_waiton;
  obj = findobj(fig,'Tag','cbReverse'); 
  if get(obj,'Value') == 1
    set(obj,'String','on');    
  else
    set(obj,'String','off');
  end  
  fl_waitoff(cursor);
  
% --------------------
  case 'cbBinary'
% --------------------

  cursor = fl_waiton;
  obj = findobj(fig,'Tag','cbBinary'); 
  if get(obj,'Value') == 1
    set(obj,'String','on');
    str = 'off';
  else
    set(obj,'String','off');
    str = 'on';
  end
  set(findobj(fig,'Tag','StaticText_display'),'Enable',str);
  set(findobj(fig,'Tag','cbDisplay'),'Enable',str);
  fl_waitoff(cursor);

% --------------------
  case 'cbDisplay'
% --------------------

  cursor = fl_waiton;
  obj = findobj(fig,'Tag','cbDisplay'); 
  if get(obj,'Value') == 1
    set(obj,'String','true');
  else
    set(obj,'String','normalized');
  end
  fl_waitoff(cursor);
  
% --------------------
  case 'cbValue'
% --------------------

  cursor = fl_waiton;
  cbvalue = findobj(fig,'Tag','cbValue');
  scaleMethod = findobj(fig,'Tag','cbScaleMethod');
  if get(cbvalue,'Value') == 1 %true values
    set(cbvalue,'String','true');
  else %normalized values
    set(cbvalue,'String','normalized');
    
  end
  setBounds(fig);
  fl_waitoff(cursor);
  
% --------------------
  case 'cbScaleMethod'
% --------------------

  cursor = fl_waiton;
  scaleMethod = findobj(fig,'Tag','cbScaleMethod');
  if (get(scaleMethod,'Value') == get(scaleMethod,'Max'))
    set(scaleMethod,'String','log');
  else
    set(scaleMethod,'String','linear');
  end
  setBounds(fig);
  fl_waitoff(cursor);
  
% --------------------
  case 'cbGetPoint'
% --------------------

  getPointMode = findobj(fig,'Tag','cbGetPoint');
  etPoint = findobj(fig,'Tag','EditText_getPoint');
  wh = fl_view_functions('get_window_handle');
  figure(wh);
  state = uisuspend(gcf);

  sth=findobj('Tag','StaticText_error');
  

  if get(getPointMode,'Value') == 1
    set(getPointMode,'String','on');
    set(etPoint,'Enable','on');
    set(sth,'String','Hit ENTER in the image window to finish');
    c=0;
    set(gcf,'pointer','fullcrosshair');
    ph = get(gca,'Children');
    while c~=13  %char 13 == enter
      keydown = waitforbuttonpress;
      figure(wh);
      obj = get(gcf,'CurrentObject');
      if obj == gca
	obj = get(gca,'Children');
      end
      if (obj == ph)
	if keydown
	  c = get(gcf, 'CurrentCharacter');
	  set(sth,'String','');
	else
	  p = get(gca,'CurrentPoint');
	  xlim = get(gca,'xlim');
	  ylim = get(gca,'ylim');

	  x = round(p(1,1));
	  y = round(p(1,2));
	  d = get(get(gca,'Children'),'CData');
	  [sx sy] = size(d);
	  if x<xlim(1), x = xlim(1); end
	  if y<ylim(1), y = ylim(1); end
	  if x>xlim(2), x = xlim(2); end
	  if y>ylim(2), y = ylim(2); end
	  %x = round(1+(sx-1)*(x-xlim(1))/(xlim(2)-xlim(1)));
	  if x<1,  x = 1; end
	  if x>sx, x = sx; end
	  %y = round(1+(sy-1)*(y-ylim(1))/(ylim(2)-ylim(1)));
	  if y<1,  y = 1; end
	  if y>sy, y = sx; end
	  val = d(y,x); %The image is rotated ...
	  if get(findobj(fig,'Tag','cbValue'),'Value') == 1  %true value asked
	    minIm = min(min(d));
	    maxIm = max(max(d));
	    mat = fl_view_functions('getMatrix');
	    minMat = min(min(mat));
	    maxMat = max(max(mat));
	    val = minMat+(maxMat-minMat)*(val-minIm)/(maxIm-minIm);
	  end
	  set(findobj(fig,'Tag','EditText_getPoint'),'String',[num2str(x,3) '  ' num2str(y,3) '  ' num2str(val,3)]);
	end
      end
    end % while
  else
    set(sth,'String','');
  end %if

  uirestore(state)
  set(gcf,'pointer','arrow');

  set(getPointMode,'Value',0);
  set(getPointMode,'String','off');
  
% --------------------
  case 'valid_minlevel'
% --------------------

  obj = findobj(fig,'Tag','EditText_minlevel');
  val = str2num(get(obj,'String'));
  % if get(findobj(fig,'Tag','ppm_scaleMethod'),'Value')  == 2 % log
  cbScaleMethod = findobj(fig,'Tag','cbScaleMethod');
  if get(cbScaleMethod,'Value')  == get(cbScaleMethod,'Max') % log
    mindB = get(cbScaleMethod,'Max');
    maxdB = get(cbScaleMethod,'Min');
    if ( (~isnumeric(val)) | (isempty(val)) | (val>mindB) | (val<maxdB))
      fl_error([ 'Wrong min log level : must be in [' num2str(maxdB)  ',' num2str(mindB) '] dB.']);
      set(obj,'String',num2str(mindB));
    end
  else  % linear
    minLin = get(cbScaleMethod,'Min'); 
    maxLin = get(cbScaleMethod,'Max');
    if ( (~isnumeric(val)) | (isempty(val)) | (val<minLin) | (val>maxLin))
      fl_error([ 'Wrong min linear level : must be in [' num2str(minLin) ',' num2str(maxLin) '].']);
      set(obj,'String',num2str(minLin));
    end
  end
  
  
% --------------------
  case 'valid_maxlevel'
% --------------------

  obj = findobj(fig,'Tag','EditText_maxlevel');
  val = str2num(get(obj,'String'));
  % if get(findobj(fig,'Tag','ppm_scaleMethod'),'Value')  == 2% log
  cbScaleMethod = findobj(fig,'Tag','cbScaleMethod');
  if get(cbScaleMethod,'Value')  == get(cbScaleMethod,'Max') % log
    mindB = get(cbScaleMethod,'Max');
    maxdB = get(cbScaleMethod,'Min');
    if ( (~isnumeric(val)) | (isempty(val)) | (val>mindB) | (val<maxdB))
      fl_error([ 'Wrong max log level : must be in [' num2str(maxdB)  ',' num2str(mindB) '] dB.']);
      set(obj,'String',num2str(mindB));
    end
  else  % linear
    minLin = get(cbScaleMethod,'Min'); 
    maxLin = get(cbScaleMethod,'Max');
    if ( (~isnumeric(val)) | (isempty(val)) | (val<minLin) | (val>maxLin))
      fl_error([ 'Wrong max linear level : must be in [' num2str(minLin) ',' num2str(maxLin) '].']);
      set(obj,'String',num2str(maxLin));
    end
  end
  
    
% --------------------
  case 'close'
% --------------------

  fl_clearerror;
  close (fig);
  fl_view_toolbar('click_listbox');
  % toolbar = findobj('Tag','gui_view_toolbar');
  % b_img = findobj(toolbar,'Tag','button_Image_Matrix');
  % set(b_img,'Enable','on');
    
% --------------------
  case 'ppm_viewMode'
% --------------------

  st_axis = findobj(fig,'Tag','StaticText_axis');
  cbAxis = findobj(fig,'Tag','cbAxis'); 
  et_linecol = findobj(fig,'Tag','EditText_linecol');
  st_level   = findobj(fig,'Tag','StaticText_level');
  mode = findobj(fig,'Tag','PopupMenu_viewMode');
  st_xaxe    = findobj(fig,'Tag','StaticText_xaxe');
  et_xaxe    = findobj(fig,'Tag','EditText_xaxe');
  b_xrefresh = findobj(fig,'Tag','button_Xrefresh');
  st_yaxe    = findobj(fig,'Tag','StaticText_yaxe');
  et_yaxe    = findobj(fig,'Tag','EditText_yaxe');
  b_yrefresh = findobj(fig,'Tag','button_Yrefresh');

  stGetPoint = findobj(fig,'Tag','StaticText_getPoint');
  cbGetPoint = findobj(fig,'Tag','cbGetPoint');
  etGetPoint = findobj(fig,'Tag','EditText_getPoint');

  val = get(mode,'Value');
  list = get(mode,'String');
  choice = list(val);
  switch choice{1}
    case 'image'
    % case 1
      setColorFrame(fig,'on');
      set(et_linecol,'Visible','off');
      set(et_linecol,'Enable','off');
      set(st_axis,'Enable','on');
      % set(ppm_axis,'Enable','on');
      set(cbAxis,'Enable','on');
      set(st_xaxe,'Enable','off');
      set(et_xaxe,'Enable','off');
      set(b_xrefresh,'Enable','off');
      set(st_yaxe,'Enable','off');
      set(et_yaxe,'Enable','off');
      set(b_yrefresh,'Enable','off');
    case 'pcolor'
    % case 2
      set(et_linecol,'Visible','off');
      set(et_linecol,'Enable','off');
      setColorFrame(fig,'on');
      set(st_axis,'Enable','on');
      % set(ppm_axis,'Enable','on');
      set(cbAxis,'Enable','on');
      set(st_xaxe,'Enable','on');
      set(et_xaxe,'Enable','on');
      set(b_xrefresh,'Enable','on');
      set(st_yaxe,'Enable','on');
      set(et_yaxe,'Enable','on');
      set(b_yrefresh,'Enable','on');
    case 'contour'
    % case 3
      set(et_linecol,'Visible','off');
      set(et_linecol,'Enable','off');
      setColorFrame(fig,'on');
      set(st_axis,'Enable','on');
      % set(ppm_axis,'Enable','on');
      set(cbAxis,'Enable','on');
      set(st_xaxe,'Enable','on');
      set(et_xaxe,'Enable','on');
      set(b_xrefresh,'Enable','on');
      set(st_yaxe,'Enable','on');
      set(et_yaxe,'Enable','on');
      set(b_yrefresh,'Enable','on');

      set(stGetPoint,'Enable','off');
      set(cbGetPoint,'Enable','off');
      set(etGetPoint,'Enable','off');
      
    case 'mesh'
    % case 4
      set(et_linecol,'Visible','off');
      set(et_linecol,'Enable','off');
      setColorFrame(fig,'on');
      set(st_axis,'Enable','off');
      % set(ppm_axis,'Enable','off');
      set(cbAxis,'Enable','off');
      set(st_xaxe,'Enable','on');
      set(et_xaxe,'Enable','on');
      set(b_xrefresh,'Enable','on');
      set(st_yaxe,'Enable','on');
      set(et_yaxe,'Enable','on');
      set(b_yrefresh,'Enable','on');
    case 'surface'
    % case 5
      set(et_linecol,'Visible','off');
      set(et_linecol,'Enable','off');
      setColorFrame(fig,'on');
      set(st_axis,'Enable','off');
      % set(ppm_axis,'Enable','off');
      set(cbAxis,'Enable','off');
      set(st_xaxe,'Enable','on');
      set(et_xaxe,'Enable','on');
      set(b_xrefresh,'Enable','on');
      set(st_yaxe,'Enable','on');
      set(et_yaxe,'Enable','on');
      set(b_yrefresh,'Enable','on');
      
      set(stGetPoint,'Enable','off');
      set(cbGetPoint,'Enable','off');
      set(etGetPoint,'Enable','off');
      
    case 'one line'
    % case 6
      setColorFrame(fig,'off');
      set(et_linecol,'Visible','on');
      set(et_linecol,'Enable','on');
      set(et_linecol,'String','1');
      set(st_axis,'Enable','off');
      % set(ppm_axis,'Enable','off');
      set(cbAxis,'Enable','off');
      set(st_xaxe,'Enable','on');
      set(et_xaxe,'Enable','on');
      set(b_xrefresh,'Enable','on');
      set(st_yaxe,'Enable','off');
      set(et_yaxe,'Enable','off');
      set(b_yrefresh,'Enable','off');
    case 'one column'
    % case 9
      setColorFrame(fig,'off');
      set(et_linecol,'Visible','on');
      set(et_linecol,'Enable','on');
      set(et_linecol,'String','1');
      set(st_axis,'Enable','off');
      % set(ppm_axis,'Enable','off');
      set(cbAxis,'Enable','off');
      set(st_xaxe,'Enable','off');
      set(et_xaxe,'Enable','off');
      set(b_xrefresh,'Enable','off');
      set(st_yaxe,'Enable','on');
      set(et_yaxe,'Enable','on');
      set(b_yrefresh,'Enable','on');
    case 'all lines'
    % case 8
      setColorFrame(fig,'off');
      set(et_linecol,'Visible','off');
      set(et_linecol,'Enable','off');
      set(st_axis,'Enable','off');
      % set(ppm_axis,'Enable','off');
      set(cbAxis,'Enable','off');
      set(st_xaxe,'Enable','on');
      set(et_xaxe,'Enable','on');
      set(b_xrefresh,'Enable','on');
      set(st_yaxe,'Enable','off');
      set(et_yaxe,'Enable','off');
      set(b_yrefresh,'Enable','off');
    case 'all columns'
    % case 7
      setColorFrame(fig,'off');
      set(et_linecol,'Visible','off');
      set(et_linecol,'Enable','off');
      set(st_axis,'Enable','off');
      % set(ppm_axis,'Enable','off');
      set(cbAxis,'Enable','off');
      set(st_xaxe,'Enable','off');
      set(et_xaxe,'Enable','off');
      set(b_xrefresh,'Enable','off');
      set(st_yaxe,'Enable','on');
      set(et_yaxe,'Enable','on');
      set(b_yrefresh,'Enable','on');
  end

% --------------------
  case 'Xrefresh'
% --------------------

  [axe_name axe_error] = fl_get_details;
  if axe_error
    return
  end
  
  if ~exist (strtok(axe_name,'.'))
    varname = strtok(axe_name,'.');
    eval (['global ' varname]);
  end
  axe = eval (axe_name); 

  mat = fl_view_functions('getMatrix');
  if ~isreal(mat)
    fl_error(['Error : ICP : ' axe_name ' comlex : must be real']);
  else
    [rowsMat columnsMat] = size(mat);
    [rowsAxe columnsAxe] = size(axe);
    if ~(    ( (columnsMat == columnsAxe) & (rowsMat == rowsAxe) ) ...
	  | ( (columnsMat == rowsAxe) & (rowsMat == columnsAxe) ) ...
	  | ( (rowsAxe == 1) & (columnsMat == columnsAxe) )...
	  | ( (columnsAxe == 1) & (rowsAxe == columnsMat) ) ...
	  )
      fl_error(['Error : ICP : Bad X axis -> should be ' ...
	    num2str(rowsMat) 'x' num2str(columnsMat) ...
	    ' or 1x' num2str(columnsMat)]);
    else
      et_xaxe = findobj(fig,'Tag','EditText_xaxe');
      set(et_xaxe,'String',axe_name);
    end
  end
  

% --------------------
  case 'Yrefresh'
% --------------------

  [axe_name axe_error] = fl_get_details;
  if axe_error
    return
  end
  
  if ~exist (strtok(axe_name,'.'))
    varname = strtok(axe_name,'.');
    eval (['global ' varname]);
  end
  axe = eval (axe_name); 

  mat = fl_view_functions('getMatrix');
  if ~isreal(mat)
    fl_error(['Error : ICP : ' axe_name ' comlex : must be real']);
  else
    [rowsMat columnsMat] = size(mat);
    [rowsAxe columnsAxe] = size(axe);
    if ~(    ( (columnsMat == columnsAxe) & (rowsMat == rowsAxe) ) ...
	  | ( (columnsMat == rowsAxe) & (rowsMat == columnsAxe) ) ...
	  | ( (rowsAxe == 1) & (rowsMat == columnsAxe) )...
	  | ( (columnsAxe == 1) & (rowsAxe == rowsMat) ) ...
	  )
      fl_error(['Error : ICP : Bad Y axis -> should be ' ...
	    num2str(rowsMat) 'x' num2str(columnsMat) ...
	    ' or 1x' num2str(rowsMat)]);
    else
      et_yaxe = findobj(fig,'Tag','EditText_yaxe');
      set(et_yaxe,'String',axe_name);
    end
  end
  

% --------------------
  case 'apply'
% --------------------

  cursor = fl_waiton;
  
  % get all possible useful handles
  viewMode = findobj(fig,'Tag','PopupMenu_viewMode');
  color = findobj(fig,'Tag','PopupMenu_colormap');
  cbScale = findobj(fig,'Tag','cbScaleMethod'); 
  cbValue = findobj(fig,'Tag','cbValue'); 
  cbDisplay = findobj(fig,'Tag','cbDisplay');
  cbReverse = findobj(fig,'Tag','cbReverse'); 
  cbBinary = findobj(fig,'Tag','cbBinary'); 
  cbAxis = findobj(fig,'Tag','cbAxis'); 
  et_xaxe    = findobj(fig,'Tag','EditText_xaxe');
  et_yaxe    = findobj(fig,'Tag','EditText_yaxe');
  et_linecol = findobj(fig,'Tag','EditText_linecol');
  et_minLvl = findobj(fig,'Tag','EditText_minlevel');
  et_maxLvl = findobj(fig,'Tag','EditText_maxlevel');
  
  plotHandle = fl_view_functions('get_plot_handle');
  plotType = get(plotHandle,'Type');
  if strcmp(plotType,'figure')
    plotHandle = get (plotHandle,'currentaxes');
  end
  
  % search for what we have to draw
  [mat,onlydata] = fl_view_functions('getMatrix');
  if ~onlydata
  	try
  		mat=WT2DVisu(mat);
  	end
  end
  [rows columns] = size(mat);
  
  % axes jobs
  str_xaxe = get(et_xaxe,'String');
  if (strcmp(str_xaxe,'default'))  % default ... nothing to do :)
    X = 1:columns;
    str_xaxe = '\default';
  else
    if ~exist (strtok(str_xaxe,'.'))
      varname = strtok(str_xaxe,'.');
      eval (['global ' varname]);
    end
    X = eval (str_xaxe); 
  end
  
  [rowsX colX] = size(X);
  if ( (columns == rowsX) & (rows == columnsX) ) 
    X = X.';
  end
  
  str_yaxe = get(et_yaxe,'String');
  if (strcmp(str_yaxe,'default'))  % default ... nothing to do :)
    Y = 1:rows;
    str_yaxe = '\default';
  else
    if ~exist (strtok(str_yaxe,'.'))
      varname = strtok(str_yaxe,'.');
      eval (['global ' varname]);
    end
    Y = eval (str_yaxe); 
  end
  
  [rowsY colY] = size(Y);
  if ( (columns == rowsY) & (rows == columnsY) ) 
    Y = Y.';
  end
  
  
  % see like ...
  mode = get(viewMode,'Value');
  axes(plotHandle);
  cmd = size(1,5);
  cmd(1) = mode - 1;
  dyn = get(cbScale,'Value') == get(cbScale,'Max');
  rev = get(cbReverse,'Value');
  bin = get(cbBinary,'Value');
  cmd(2) = dyn+2*rev+4*bin;
  % dyn rev bin cmd
  %  0   0   0   0   linear 
  %  1   0   0   1   log
  %  0   1   0   2   linear reverse
  %  1   1   0   3   log reverse
  %  0   0   1   4   linear binary
  %  1   0   1   5   log binary
  %  0   1   1   6   linear reverse binary
  %  1   1   1   7   log reverse binary
  minLvl = str2num(get(et_minLvl,'String'));
  maxLvl = str2num(get(et_maxLvl,'String'));

  if get(cbValue,'Value') == 0
    %disp('000000000000');
    cmd(3) = minLvl;
    cmd(4) = maxLvl;
  else % I have to normalize levels
    %disp('1111111111111111');
    Zmin = min(min(mat)) ;
    Zmax = max(max(mat)) ;
    a = 1/(Zmax-Zmin) ;
    b = -a*Zmin ;
    cmd(3) = a*minLvl+b;
    cmd(4) = a.*maxLvl+b;
  end
  
  %cmd %xxx
  
  if (abs(cmd(3)) <0.0001)
    cmd(3) = 0;
  end
  if (cmd(4) > 1)
    cmd(4) = 1;
  end

  % xxx horrible and tricky ...  DISPLAY
  if get(cbDisplay,'Value') == 1 % true levels
    cmd(5) = 0;
  end

  % cmd %xxx
  
  list = get(viewMode,'String');
  choice = list(mode);
  switch choice{1}
    case 'image'
      if all(all(imag(mat))) 
	mat = abs(mat) ;
      end
      %cmd
      viewmat(mat,cmd);
      % if get(ppm_axis,'Value') == 2
      %  axis image;
      % end
      if get(cbAxis,'Value') == 1
	axis image;
      end
      str_xaxe = '\default';
      str_yaxe = '\default';
      
    case 'pcolor'  
      if all(all(imag(mat))) 
	mat = abs(mat) ;
      end
      viewmat(mat,X,Y,cmd);
      % if get(ppm_axis,'Value') == 2
      %  axis image;
      % end
      if get(cbAxis,'Value') == 1
	axis image;
      end
      
    case 'contour'
      % contour(mat);
      viewmat(mat,X,Y,cmd);
      % if get(ppm_axis,'Value') == 2
      %  axis image;
      % end
      if get(cbAxis,'Value') == 1
	axis image;
      end
      
    case 'mesh'
      % mesh (mat);
      viewmat(mat,X,Y,cmd);
      
    case 'surface'
      % surf(mat);
      viewmat(mat,X,Y,cmd);
      
    case 'one line'
      line = str2num(get(et_linecol,'String'));
      mat = mat.';
      plot(mat(:,line),X);
      str_yaxe = '\default';
      
    case 'one column'
      col = str2num(get(et_linecol,'String'));
      plot(mat(:,col),Y);
      str_xaxe = '\default';
      
    case 'all lines'
      plot(mat.');
      % str_xaxe = '\default';
      str_yaxe = '\default';
      
    case 'all columns' 
      plot(mat);
      str_xaxe = '\default';
      % str_yaxe = '\default';
      
  end % switch (choice)
  
  % colormap job (not useful for everything but ...
  col = get(color,'String');
  val = get(color,'Value');
  eval(['colormap(' col{val} ');']);
  
  toolbar = findobj('Tag','gui_view_toolbar');
  userdata=get(toolbar,'UserData');
  selected_cell = fl_view_functions('get_i_j');
  i = selected_cell(1);
  j = selected_cell(2);
  userdata{i}{j}.Image = ...
  struct('mode',mode,...
  'colormap',get(color,'Value'),...
  'axis',get(cbAxis,'Value'),...
  'linecol',get(et_linecol,'String'),...
  'scale',cmd(2),...
  'value',get(cbValue, 'Value'),...
  'display',get(cbDisplay, 'Value'),...
  'reverse',get(cbReverse, 'Value'),...
  'binary',get(cbBinary, 'Value'),...
  'minlevel',num2str(minLvl),...
  'maxlevel',num2str(maxLvl),...
  'xaxis',str_xaxe,...
  'yaxis',str_yaxe);
  set(toolbar,'UserData',userdata);

  if (~strcmp(choice{1},'image'))
    set(findobj(toolbar,'Tag','Checkbox_rotate'),'Enable','on');
  else  
    set(findobj(toolbar,'Tag','Checkbox_rotate'),'Enable','off');
  end
  axesCP = findobj('Tag','gui_axes_control_panel');
  if ~isempty(axesCP)
    fl_axes_functions('refresh_axes_control_panel');
  end
  fl_waitoff(cursor);
    
    
% --------------------
  case 'linecol'
% --------------------
  
  mode = findobj(fig,'Tag','PopupMenu_viewMode');
  et_linecol = findobj(fig,'Tag','EditText_linecol');
  val = get(mode,'Value');
  list = get(mode,'String');
  choice = list(val);
  mat = fl_view_functions('getMatrix');
  if (strcmp(choice{1}, 'one line'))
    nbLine = size(mat,1);
    val = str2num(get(et_linecol,'String'));    
    if ( (nbLine < val) | (val < 1) )
      fl_error( ['Image Control Panel : number of lines not in range :[1,' num2str(nbLine) ']'])
      set(et_linecol,'String','1');
    end
  elseif (strcmp(choice{1}, 'one column'))
    nbCol = size(mat,2);
    val = str2num(get(et_linecol,'String'));
    if ( (nbCol < val) | (val < 1) )
      fl_error( ['Image Control Panel : number of columns not in range :[1,' num2str(nbCol) ']'])
      set(et_linecol,'String','1');
    end
  else
    fl_error('fl_view_image : case linecol : PLANTAGE PAS NORMAL :(');
  end
  
end

function setColorFrame(fig, str)

  st_scaleMethod = findobj(fig,'Tag','StaticText_scaleMethod'); 
  % ppm_scaleMethod = findobj(fig,'Tag','ppm_scaleMethod'); 
  cbScaleMethod = findobj(fig,'Tag','cbScaleMethod'); 
  stValue = findobj(fig,'Tag','StaticText_value'); 
  cbValue = findobj(fig,'Tag','cbValue');
  stDisplay = findobj(fig,'Tag','StaticText_display'); 
  cbDisplay = findobj(fig,'Tag','cbDisplay'); 
  st_maxlevel   = findobj(fig,'Tag','StaticText_maxlevel');
  st_minlevel   = findobj(fig,'Tag','StaticText_minlevel');
  et_minlevel   = findobj(fig,'Tag','EditText_minlevel');
  et_maxlevel   = findobj(fig,'Tag','EditText_maxlevel');
  st_level   = findobj(fig,'Tag','StaticText_level');
  stBinary = findobj(fig,'Tag','StaticText_binary');   
  cbBinary = findobj(fig,'Tag','cbBinary');   
  stReverse = findobj(fig,'Tag','StaticText_reverse');   
  cbReverse = findobj(fig,'Tag','cbReverse');   
  stGetPoint = findobj(fig,'Tag','StaticText_getPoint');
  cbGetPoint = findobj(fig,'Tag','cbGetPoint');
  etGetPoint = findobj(fig,'Tag','EditText_getPoint');
  
  set(stValue,'Enable',str);
  set(cbValue,'Enable',str);
  set(stDisplay,'Enable',str);
  set(cbDisplay,'Enable',str);
  set(stBinary,'Enable',str);
  set(cbBinary,'Enable',str);
  set(stReverse,'Enable',str);
  set(cbReverse,'Enable',str);
  set(st_scaleMethod,'Enable',str);
  set(cbScaleMethod,'Enable',str);
  set(st_level,'Enable',str);
  set(st_minlevel,'Enable',str);
  set(et_minlevel,'Enable',str);
  set(st_maxlevel,'Enable',str);
  set(et_maxlevel,'Enable',str);
  set(stGetPoint ,'Enable',str);
  set(cbGetPoint ,'Enable',str);
  set(etGetPoint ,'Enable',str);
  
function setBounds(fig)
  cbScaleMethod = findobj(fig,'Tag','cbScaleMethod'); 
  et_minlevel   = findobj(fig,'Tag','EditText_minlevel');
  et_maxlevel   = findobj(fig,'Tag','EditText_maxlevel');
  
  if (get (cbScaleMethod,'Value') == get (cbScaleMethod,'Max')) %log dynamic
    zmin = 24;
    zmax = 0;
    set(cbScaleMethod,'Min',0);
    set(cbScaleMethod,'Max',24);
    set(cbScaleMethod,'Value',24);
  else
    cbValue = findobj(fig,'Tag','cbValue');
    if (get (cbValue,'Value') == 1) %true values
      mat = fl_view_functions('getMatrix');
      zmin = min(min(mat));
      zmax = max(max(mat));
    else
      zmin = 0;
      zmax = 1;
    end
    set(cbScaleMethod,'Min',zmin);
    set(cbScaleMethod,'Max',zmax);
    set(cbScaleMethod,'Value',zmin);
  end

  set(et_minlevel,'String',num2str(zmin,4));
  set(et_maxlevel,'String',num2str(zmax,4));
