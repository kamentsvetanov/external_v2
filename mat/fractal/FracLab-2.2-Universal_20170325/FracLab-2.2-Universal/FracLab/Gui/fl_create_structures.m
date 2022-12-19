function outputName = fl_create_structures(string)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch (string)
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%% cwt %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  case 'get_cwt_name'
    [name error] =  fl_get_input;
    if ~error
      sth = findobj ('Tag','Text_name');
      set (sth,'String',name);
    end
    
  case 'get_cwt_coeff'
    [name error] =  fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_coeff');
      set (sth,'String',name);
    end
    
  case 'get_cwt_scale'
    [name error] = fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_scale');
      set (sth,'String',name);
    end
    
  case 'get_cwt_frequency'
    [name error]= fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_frequency');
      set (sth,'String',name);    
    end
    
  case 'get_cwt_wavelet'
    [name error] = fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_wavelet');
      set (sth,'String',name);
    end
    
  case 'get_all'
     [name error] = fl_get_input ('cwt');
     if ~exist (name)
       eval (['global ' name ';' ]);
     end
     if error
       fl_warning('Input signal must be a cwt structure');
     else
        sth = findobj ('Tag','Text_name');
	set (sth,'String',name);
	fields = fieldnames (eval(name));
	for i = 1:(length(fields))
	  if strcmp(fields{i},'coeff')
	    sth = findobj ('Tag','Text_coeff');
	    set (sth,'String',[name '.coeff']) ;
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'scale')
	    sth = findobj ('Tag','Text_scale');
	    set (sth,'String',[name '.scale']);
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'frequency')	
	    sth = findobj ('Tag','Text_frequency');
	    set (sth,'String',[name '.frequency']);
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'wavelet')
	    sth = findobj ('Tag','Text_wavelet');
	    set (sth,'String',[name '.wavelet']);
	  end
	end
      end

case 'create_cwt'

% get the name of the new structure
  
  sth = findobj ('Tag','Text_name');
  name = get (sth , 'String');
  if isempty(name)
    fl_warning (' field ''name'' missing .');
    return
  end
  eval(['global ' name]);
  
  
% get its "coeff" field  

  sth = findobj ('Tag','Text_coeff');
  coeff = get (sth , 'String');
  if ~exist (strtok(coeff,'.'))
    varname = strtok(coeff,'.');
    eval (['global ' varname]);
  end
  if isempty(coeff)
    fl_warning (' field ''coeff'' missing .');
    return
  end  
  coeff = eval (coeff);
  
% get its "scale" field
 
  sth = findobj ('Tag','Text_scale');
  scale = get (sth , 'String');
  if isempty (scale)
    fl_warning (' field ''scale'' missing .');
    return
  end    
  if ~exist (strtok(scale,'.'))
    varname = strtok(scale,'.');
    eval (['global ' varname]);
  end
  scale = eval (scale);
  
% get its "frequency field" 
 
  sth = findobj ('Tag','Text_frequency');
  frequency = get (sth , 'String');
  if isempty (frequency)
    fl_warning (' field ''frequency'' missing .');
    return
  end   
  if ~exist (strtok(frequency,'.'))
    varname = strtok(frequency,'.');
    eval (['global ' varname]);
  end
  frequency = eval (frequency);  
  
  
% depending on the existence of the "wavelet" field, create the
%  structure with or without it (it is an optionnal field) 
  
  sth = findobj ('Tag','Text_wavelet');
  wavelet = get (sth , 'String');
  if isempty(wavelet)
    eval([name '= struct(''type'',''cwt'',''coeff'',coeff,''scale'',scale,''frequency'',frequency);']);
  else
    if ~exist (strtok(wavelet,'.'))
      varname = strtok(wavelet,'.');
      eval (['global ' varname]);
    end
    eval (['wavelet =' wavelet ';']);
    eval([name '=struct(''type'',''cwt'',''coeff'',coeff,''scale'',scale,''frequency'',frequency,''wavelet'',wavelet);']); 
  end
  eval(['global ' name]);
  fl_addlist(0,name);
  outputName = name;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%% graph %%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

case 'get_graph_name'
    [name error] =  fl_get_input;
    if ~error
      sth = findobj ('Tag','Text_graph_name');
      set (sth,'String',name);
    end
    
  case 'get_graph_data1'
    [name error] =  fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_graph_data1');
      set (sth,'String',name);
    end
    
  case 'get_graph_data2'
    [name error] = fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_graph_data2');
      set (sth,'String',name);
    end
    
  case 'get_graph_title'
    [name error]= fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_graph_title');
      set (sth,'String',name);    
    end
    
  case 'get_graph_xlabel'
    [name error]= fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_graph_xlabel');
      set (sth,'String',name);    
    end    
    
  case 'get_graph_ylabel'
    [name error]= fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_graph_ylabel');
      set (sth,'String',name);    
    end    
    
   case 'get_graph_all'
     [name error] = fl_get_input ('graph');
     if ~exist (name)
       eval (['global ' name ';' ]);
     end
     if error
       fl_warning('Input signal must be a graph structure');
     else
        sth = findobj ('Tag','Text_graph_name');
	set (sth,'String',name);
	fields = fieldnames (eval(name));
	for i = 1:(length(fields))
	  if strcmp(fields{i},'data1')
	    sth = findobj ('Tag','Text_graph_data1');
	    set (sth,'String',[name '.data1']) ;
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'data2')
	    sth = findobj ('Tag','Text_graph_data2');
	    set (sth,'String',[name '.data2']);
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'title')	
	    sth = findobj ('Tag','Text_graph_title');
	    set (sth,'String',[name '.title']);
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'xlabel')	
	    sth = findobj ('Tag','Text_graph_xlabel');
	    set (sth,'String',[name '.xlabel']);
	  end
	end	
	for i = 1:(length(fields))
	  if strcmp(fields{i},'title')	
	    sth = findobj ('Tag','Text_graph_ylabel');
	    set (sth,'String',[name '.ylabel']);
	  end
	end	
      end

case 'create_graph'

% get the name of the new structure
  
  sth = findobj ('Tag','Text_graph_name');
  name = get (sth , 'String');
  if isempty(name)
    fl_warning (' field ''name'' missing .');
    return
  end
  eval(['global ' name]);
  
  
% get its "data1" field  

  sth = findobj ('Tag','Text_graph_data1');
  data1 = get (sth , 'String');
  if isempty(data1)
    fl_warning (' field ''data 1'' missing .');
    return
  end    
  if ~exist (strtok(data1,'.'))
    varname = strtok(data1,'.');
    eval (['global ' varname]);
  end
  data1 = eval (data1);
  
% get its "data2" field
 
  sth = findobj ('Tag','Text_graph_data2');
  data2 = get (sth , 'String');
  if isempty (data2)
    fl_warning (' field ''data 2'' missing .');
    return
  end    
  if ~exist (strtok(data2,'.'))
    varname = strtok(data2,'.');
    eval (['global ' varname]);
  end
  data2 = eval (data2);
  
% get its "title" field 
 
  sth = findobj ('Tag','Text_graph_title');
  temp_title = get (sth , 'String');
%  if ~isempty (temp_title)
%    if ~exist (strtok(temp_title,'.'))
%      varname = strtok(temp_title,'.');
%      eval (['global ' varname]);
%    end
%    temp_title = eval (temp_title);
%  end

% get its "xlabel" field 
 
  sth = findobj ('Tag','Text_graph_xlabel');
  temp_xlabel = get (sth , 'String');
%  if ~isempty (temp_xlabel)
%    if ~exist (strtok(temp_xlabel,'.'))
%      varname = strtok(temp_xlabel,'.');
%      eval (['global ' varname]);
%    end
%    temp_xlabel = eval (temp_xlabel);
%  end  
  
% get its "ylabel" field 
 
  sth = findobj ('Tag','Text_graph_ylabel');
  temp_ylabel = get (sth , 'String');
%  if ~isempty (temp_ylabel)
%    if ~exist (strtok(temp_ylabel,'.'))
%      varname = strtok(temp_ylabel,'.');
%      eval (['global ' varname]);
%    end
%    temp_ylabel = eval (temp_ylabel);
%  end  
  
  
% create the structure :

  eval([name '=struct(''type'',''graph'',''data1'',data1,''data2'',data2,''title'',temp_title,''xlabel'',temp_xlabel,''ylabel'',temp_ylabel);']);
  
  eval(['global ' name ';']);
  fl_addlist(0,name);
  outputName = name;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%% dwt %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

case 'get_dwt_name'
    [name error] =  fl_get_input;
    if ~error
      sth = findobj ('Tag','Text_name');
      set (sth,'String',name);
    end
    
  case 'get_dwt_wt'
    [name error] =  fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_wt');
      set (sth,'String',name);
    end
    
  case 'get_dwt_index'
    [name error] = fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_index');
      set (sth,'String',name);
    end
    
  case 'get_dwt_length'
    [name error]= fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_length');
      set (sth,'String',name);    
    end
    
   case 'get_all_dwt'
     [name error] = fl_get_input ('dwt');
     if ~exist (name)
       eval (['global ' name ';' ]);
     end
     if error
       fl_warning('Input signal must be a dwt structure');
     else
        sth = findobj ('Tag','Text_name');
	set (sth,'String',name);
	fields = fieldnames (eval(name));
	for i = 1:(length(fields))
	  if strcmp(fields{i},'wt')
	    sth = findobj ('Tag','Text_wt');
	    set (sth,'String',[name '.wt']) ;
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'index')
	    sth = findobj ('Tag','Text_index');
	    set (sth,'String',[name '.index']);
	  end
	end
	for i = 1:(length(fields))
	  if strcmp(fields{i},'length')	
	    sth = findobj ('Tag','Text_length');
	    set (sth,'String',[name '.length']);
	  end
	end
      end

case 'create_dwt'

% get the name of the new structure
  
  sth = findobj ('Tag','Text_name');
  name = get (sth , 'String');
  if isempty(name)
    fl_warning (' field ''name'' missing .');
    return
  end
  eval(['global ' name]);
  
  
% get its "wt" field  

  sth = findobj ('Tag','Text_wt');
  wt = get (sth , 'String');
  if ~exist (strtok(wt,'.'))
    varname = strtok(wt,'.');
    eval (['global ' varname]);
  end
  if isempty(wt)
    fl_warning (' field ''wt'' missing .');
    return
  end  
  wt = eval (wt);
  
% get its "index" field
 
  sth = findobj ('Tag','Text_index');
  index = get (sth , 'String');
  if isempty (index)
    fl_warning (' field ''index'' missing .');
    return
  end    
  if ~exist (strtok(index,'.'))
    varname = strtok(index,'.');
    eval (['global ' varname]);
  end
  index = eval (index);
  
% get its "length" field 
 
  sth = findobj ('Tag','Text_length');
  temp_length = get (sth , 'String');
  if isempty (temp_length)
    fl_warning (' field ''length'' missing .');
    return
  end   
  if ~exist (strtok(temp_length,'.'))
    varname = strtok(temp_length,'.');
    eval (['global ' varname]);
  end
  temp_length = eval (temp_length);  
  
% create the structure :

    eval([name '= struct(''type'',''dwt'',''wt'',wt,''index'',index,''length'',temp_length,''size'',sum(temp_length)-1);']);

  fl_addlist(0,name);
  eval(['global ' name]);
  outputName = name;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%% matrix %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 case 'get_matrix_name'
    [name error] =  fl_get_input;
    if ~error
      sth = findobj ('Tag','Text_mat_name');
      set (sth,'String',name);
    end
    
  case 'get_matrix'
    [name error] =  fl_get_details;
    if ~error
      sth = findobj ('Tag','Text_matrix');
      set (sth,'String',name);
    end 

  case 'create_matrix'  
    
% get the name of the new structure
  
  sth = findobj ('Tag','Text_mat_name');
  name = get (sth,'String');
  if isempty(name)
    fl_warning (' field ''name'' missing .');
    return
  end
  eval(['global ' name]);
  
% get its "matrix" field 
 
  sth = findobj ('Tag','Text_matrix');
  temp_matrix = get (sth , 'String');
  if isempty (temp_matrix)
    fl_warning (' field ''matrix'' missing .');
    return
  end   
  if ~exist (strtok(temp_matrix,'.'))
    varname = strtok(temp_matrix,'.');
    eval (['global ' varname]);
  end
  temp_matrix = eval (temp_matrix);  
  
% create the structure :

    eval([name '= temp_matrix;']);

  fl_addlist(0,name);
  eval(['global ' name]);
  outputName = name;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%% SUB-matrix %%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  case 'get_input_name'
    [name error] =  fl_get_details;
    if error
      return
    end
    extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
    sth = findobj (extractHdl,'Tag','EditText_input');
    set (sth,'String',name);
    
    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval (['global ' varname]);
    end
    var = eval (name);
    set(extractHdl,'UserData',var);
    [lines rows] = size(var);
    set(findobj(extractHdl,'Tag','EditText_firstline'),'String','1');
    set(findobj(extractHdl,'Tag','EditText_lastline'),'String',num2str(lines));
    set(findobj(extractHdl,'Tag','EditText_firstrow'),'String','1');
    set(findobj(extractHdl,'Tag','EditText_lastrow'),'String',num2str(rows));
    
  case 'get_output_name'
    [name error] =  fl_get_details;
    if error
      return
    end
    extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
    sth = findobj (extractHdl,'Tag','EditText_output');
    set (sth,'String',name);
  
  case 'numerical_option'
      if ~get(findobj('Tag','RadioButton_numerical'),'Value')
            set(findobj('Tag','RadioButton_numerical'),'Value',1);
      end
      set(findobj('Tag','RadioButton_graphical'),'Value',0);
      extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
      set(findobj(extractHdl,'Tag','EditText_firstline'),'enable','on');
      set(findobj(extractHdl,'Tag','EditText_lastline'),'enable','on');
      set(findobj(extractHdl,'Tag','EditText_firstrow'),'enable','on');
      set(findobj(extractHdl,'Tag','EditText_lastrow'),'enable','on');
        
  case 'graphical_option'
      if ~get(findobj('Tag','RadioButton_graphical'),'Value')
            set(findobj('Tag','RadioButton_graphical'),'Value',1);
      end
      set(findobj('Tag','RadioButton_numerical'),'Value',0);
      extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
      set(findobj(extractHdl,'Tag','EditText_firstline'),'enable','off');
      set(findobj(extractHdl,'Tag','EditText_lastline'),'enable','off');
      set(findobj(extractHdl,'Tag','EditText_firstrow'),'enable','off');
      set(findobj(extractHdl,'Tag','EditText_lastrow'),'enable','off');
        
  case 'edit_firstLine'
    extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
    hdl = findobj(extractHdl,'Tag','EditText_firstline');
    minVal = str2num(get(hdl,'String'));

    if isempty(minVal)
      fl_error('First line should be numeric');
      set(hdl,'String','1');
    end
    maxVal = str2num(get(findobj(extractHdl,'Tag','EditText_lastline'),'String'));
    if minVal > maxVal
      fl_error('First line should be less than or equal to last line');
      set(hdl,'String','1');
    end

    if minVal < 1
      fl_error('First line should be greater than or equal to 1');
      set(hdl,'String','1');
    end
    
  case 'edit_lastLine'
    extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
    hdl = findobj(extractHdl,'Tag','EditText_lastline');
    maxVal = str2num(get(hdl,'String'));
    ud = get(extractHdl,'UserData');
    [lines rows] = size(ud);
 
    if isempty (maxVal)
      fl_error('last line should be numeric');
      set(hdl,'String',num2str(lines));
    end
    minVal = str2num(get(findobj(extractHdl,'Tag','EditText_firstline'),'String'));
    if maxVal < minVal
      fl_error('Last line should be greater than or equal to first line');
      set(hdl,'String',num2str(lines));
    end
    
    if maxVal > lines
      fl_error(['last line should be less than or equal to ' num2str(lines)]);
      set(hdl,'String',num2str(lines));
    end
        
  case 'edit_firstRow'
    extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
    hdl = findobj(extractHdl,'Tag','EditText_firstrow');
    minVal = str2num(get(hdl,'String'));

    if isempty(minVal)
      fl_error('First row should be numeric');
      set(hdl,'String','1');
    end

    maxVal = str2num(get(findobj(extractHdl,'Tag','EditText_lastrow'),'String'));
    if minVal > maxVal
      fl_error('First row should be less than or equal to last row');
      set(hdl,'String','1');
    end

    if minVal < 1
      fl_error('First row should be greater than or equal to 1');
      set(hdl,'String','1');
    end

  case 'edit_lastrow'
    extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
    hdl = findobj(extractHdl,'Tag','EditText_lastrow');
    maxVal = str2num(get(hdl,'String'));
    ud = get(extractHdl,'UserData');
    [lines rows] = size(ud);

    if isempty (maxVal)
      fl_error('last row should be numeric');
      set(hdl,'String',num2str(rows));
    end

    minVal = str2num(get(findobj(extractHdl,'Tag','EditText_firstrow'),'String'));
    if maxVal < minVal
      fl_error('Last row should be greater than or equal to first row');
      set(hdl,'String',num2str(rows));
    end

    if maxVal > rows
      fl_error(['last row should be less than or equal to ' num2str(rows)]);
      set(hdl,'String',num2str(rows));
    end
    
  case 'create_SUB_matrix'
    extractHdl = findobj('Tag','Fig_gui_fl_extract_matrix');
    numerical = get(findobj(extractHdl,'Tag','RadioButton_numerical'),'Value');
    if numerical
        fr = findobj(extractHdl,'Tag','EditText_firstrow');
        fl = findobj(extractHdl,'Tag','EditText_firstline');
        lr = findobj(extractHdl,'Tag','EditText_lastrow');
        ll = findobj(extractHdl,'Tag','EditText_lastline');
        minr = str2num(get(fr,'String'));
        minl = str2num(get(fl,'String'));
        maxr = str2num(get(lr,'String'));
        maxl = str2num(get(ll,'String'));

        % output field
        out = findobj ('Tag','EditText_output');
        name = get (out,'String');
        if isempty(name)
            fl_error (' field ''output'' missing .');
            return
        end
        eval(['global ' name]);

        ud = get(extractHdl,'UserData');
        eval([name '= ud(minl:maxl,minr:maxr);']);
        fl_addlist(0,name);
        outputName = name;
    else
        name_in = get(findobj(extractHdl,'Tag','EditText_input'),'String');
        name = get(findobj(extractHdl,'Tag','EditText_output'),'String');
        eval(['global ' name_in]);
        eval(['cropormask(', name_in ,',''', name, ''');'])
        waitfor(gcf);
        outputName = name;
    end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%% matrix oper %%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  case 'edit_isnum'

    editHdl = gcbo;
    val = str2num(get(editHdl,'String'));
    tag = get(editHdl,'Tag');
    if isempty(val)
      fl_error([tag ' should be numeric.']);
      
      if strncmp(tag,'scale',5)
	set(editHdl,'String','1');
      else
	set(editHdl,'String','0');
      end
    end
    
  case 'text_input1' 
    operHdl = findobj('Tag','Fig_gui_oper_matrix');
    sth = findobj (operHdl,'Tag','Text_input1');
    set(sth,'String','');
    % if isempty(get(sth,'String')) 
      set(findobj(operHdl,'Tag','StaticText_input2'),'Enable','off');
      set(findobj(operHdl,'Tag','Text_input2'),'Enable','off');
      set(findobj(operHdl,'Tag','Pushbutton_get2'),'Enable','off');
      set(findobj(operHdl,'Tag','StaticText_scale2'),'Enable','off');
      set(findobj(operHdl,'Tag','StaticText_offset2'),'Enable','off');
      set(findobj(operHdl,'Tag','scale2'),'Enable','off');
      set(findobj(operHdl,'Tag','offset2'),'Enable','off');
      set(findobj(operHdl,'Tag','StaticText_output'),'Enable','off');
      set(findobj(operHdl,'Tag','Text_output'),'Enable','off');
      set(findobj(operHdl,'Tag','Pushbutton_output'),'Enable','off');
    % else
    %   fl_create_structures('get_input1');
    % end
    
   case 'text_input2' 
    operHdl = findobj('Tag','Fig_gui_oper_matrix');
    sth = findobj (operHdl,'Tag','Text_input2');
    set(sth,'String', '');
    % if isempty(get(sth,'String'))
      set(findobj(operHdl,'Tag','StaticText_oper'),'Enable','off');
      set(findobj(operHdl,'Tag','PopupMenu_oper'),'Enable','off');
    % else
    %  fl_create_structures('get_input2');
    % end
    
  case 'text_output' 
    operHdl = findobj('Tag','Fig_gui_oper_matrix');
    sth = findobj (operHdl,'Tag','Text_output');
    if isempty(get(sth,'String')) 
      set(findobj(operHdl,'Tag','Pushbutton_Apply'),'Enable','off');
    else
      set(findobj(operHdl,'Tag','Pushbutton_Apply'),'Enable','on');
    end
  
      
      
  case 'get_input1'
   
    [name error] =  fl_get_details;
    if error
      return
    end    
    
    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval (['global ' varname]);
    end
    var = eval (name);
    operHdl = findobj('Tag','Fig_gui_oper_matrix');
    sth = findobj (operHdl,'Tag','Text_input1');
    set(operHdl,'UserData',var);
 
    % if isempty(get(sth,'String')) 
      % Active different things ...
      
      % INPUT 2
      set(findobj(operHdl,'Tag','StaticText_input2'),'Enable','on');
      set(findobj(operHdl,'Tag','Text_input2'),'Enable','on');
      set(findobj(operHdl,'Tag','Pushbutton_get2'),'Enable','on');
      set(findobj(operHdl,'Tag','StaticText_scale2'),'Enable','on');
      set(findobj(operHdl,'Tag','StaticText_offset2'),'Enable','on');
      set(findobj(operHdl,'Tag','scale2'),'Enable','on');
      set(findobj(operHdl,'Tag','offset2'),'Enable','on');
      
      % OUTPUT
      set(findobj(operHdl,'Tag','StaticText_output'),'Enable','on');
      set(findobj(operHdl,'Tag','Text_output'),'Enable','on');
      set(findobj(operHdl,'Tag','Pushbutton_output'),'Enable','on');
       
    % end
    set (sth,'String',name);
    
  case 'get_input2'
    [name error] =  fl_get_details;
    if error
      return
    end

    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval (['global ' varname]);
    end
    
    % Testing for dimensions ...
    operHdl = findobj('Tag','Fig_gui_oper_matrix');
    if ~isempty(find(size(eval (name)) ~= size(get(operHdl,'UserData'))))
      name1 = get(findobj(operHdl,'Tag','Text_input1'),'String');
      fl_error([name1 ' and ' name ' must have same dimensions.']);
      return;
    end

    sth = findobj (operHdl,'Tag','Text_input2');
      
    set(findobj(operHdl,'Tag','StaticText_oper'),'Enable','on');
    set(findobj(operHdl,'Tag','PopupMenu_oper'),'Enable','on');
    set (sth,'String',name);
  
  case 'get_output'
    [name error] =  fl_get_details;
    if error
      return
    end
    
    operHdl = findobj('Tag','Fig_gui_oper_matrix');
    sth = findobj (operHdl,'Tag','Text_output');
      
    % if isempty(get(sth,'String')) 
      set(findobj(operHdl,'Tag','Pushbutton_Apply'),'Enable','on');
    % end
    set (sth,'String',name);
    
    
  case 'oper_matrix'    
    
    operHdl = findobj('Tag','Fig_gui_oper_matrix');

    val1 = get(operHdl,'UserData');
    scale1  = str2num(get(findobj(operHdl,'Tag','scale1'),'String'));
    offset1 = str2num(get(findobj(operHdl,'Tag','offset1'),'String'));

    name2 = get(findobj(operHdl,'Tag','Text_input2'),'String');
    if isempty(name2)
      res = scale1 * val1 + offset1;
    else
      % getting input2
      if ~exist (strtok(name2,'.'))
	varname = strtok(name2,'.');
	eval (['global ' varname]);
      end
      val2 = eval (name2);
      scale2  = str2num(get(findobj(operHdl,'Tag','scale2'),'String'));
      offset2 = str2num(get(findobj(operHdl,'Tag','offset2'),'String'));
      
      % What are we doing now ?
      ppm = findobj (operHdl,'Tag','PopupMenu_oper');
      str = get(ppm,'String');
      switch (str{get(ppm,'Value')})
	case 'add'
	  res = (scale1 * val1 + offset1) + (scale2 * val2 + offset2);
	case 'sub'
	  res = (scale1 * val1 + offset1) - (scale2 * val2 + offset2);
	case 'mul'
	  res = (scale1 * val1 + offset1) .* (scale2 * val2 + offset2);
	case 'div'
	  if ~isempty(find(val2 == 0))
	    fl_error(['Can not divide : ' name2 ' contains zeros.']);
	    return;
	  end
	  res = (scale1 * val1 + offset1) ./ (scale2 * val2 + offset2);
      end % switch
    end % if isempty(name2)

    % output section ...
    output = get(findobj(operHdl,'Tag','Text_output'),'String');
    eval(['global ' output]);
    eval([output '= res;']);
    fl_addlist(0,output);
    outputName = output;

    
end

