function outputname = fl_normalize_compute(string)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch (string)

  case 'get_input_name'
    [name error] =  fl_get_details;
    if error
      return
    end
    normalizeHdl = gcf;
    sth = findobj (normalizeHdl,'Tag','Text_input');
    set (sth,'String',name);
    
    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval (['global ' varname]);
    end
    var = eval (name);
    set(findobj(normalizeHdl,'Tag','Text_output'),'String',[name '_normalized']);
    
    
  case 'get_output_name'
    [name error] =  fl_get_details;
    if error
      return
    end
    normalizeHdl = gcf;
    sth = findobj (normalizeHdl,'Tag','Text_output');
    set (sth,'String',name);
    
    % if ~exist (strtok(name,'.'))
    %   varname = strtok(name,'.');
    %   eval (['global ' varname]);
    % end
    % var = eval (name);
    
  case 'edit_min'
    normalizeHdl = gcf;
    hdl = findobj(normalizeHdl,'Tag','EditText_min');
    minVal = str2num(get(hdl,'String'));

    if isempty(minVal)
      fl_error('Min value should be numeric');
      set(hdl,'String','0');
    end
    
  case 'edit_max'
    normalizeHdl = gcf;
    hdl = findobj(normalizeHdl,'Tag','EditText_max');
    maxVal = str2num(get(hdl,'String'));
 
    if isempty (maxVal)
      fl_error('Max value should be numeric');
      set(hdl,'String',num2str(lines));
    end
    
    
  case 'compute_normalize'
    normalizeHdl = gcf;
    hdl = findobj(normalizeHdl,'Tag','EditText_min');
    minVal = str2num(get(hdl,'String'));
    hdl = findobj(normalizeHdl,'Tag','EditText_max');
    maxVal = str2num(get(hdl,'String'));
    
    
    % output field
    sth = findobj (normalizeHdl,'Tag','Text_input');
    inputname =  get (sth,'String');
    eval ([ 'global ' inputname]);
    inputsignal = eval(inputname);
    
    
    out = findobj ('Tag','Text_output');
    outputname = get (out,'String');
    if isempty(outputname)
      fl_error (' field ''output'' missing .');
      return
    end
    eval(['global ' outputname]);
    
    inputsignal_normalized = frac_normalize (inputsignal, minVal, maxVal);
    
    
    eval([outputname '= inputsignal_normalized;']);
    
    chaine=[outputname,'=frac_normalize(',inputname,',',num2str(minVal),',',...
        num2str(maxVal),');'];
    fl_diary(chaine);
    
    
    fl_addlist(0,outputname);

    
end












