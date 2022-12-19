function outputname = fl_signal2measure_compute(string)
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
    signal2measureHdl = gcf;
    sth = findobj (signal2measureHdl,'Tag','Text_input');
    set (sth,'String',name);
    
    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval (['global ' varname]);
    end
    var = eval (name);
    set(findobj(signal2measureHdl,'Tag','Text_output'),'String',[name '_measure']);
    
    
  case 'get_output_name'
    [name error] =  fl_get_details;
    if error
      return
    end
    signal2measureHdl = gcf;
    sth = findobj (signal2measureHdl,'Tag','Text_output');
    set (sth,'String',name);
    
    % if ~exist (strtok(name,'.'))
    %   varname = strtok(name,'.');
    %   eval (['global ' varname]);
    % end
    % var = eval (name);
    
    
  case 'compute_signal2measure'
    signal2measureHdl = gcf;
    
    sth = findobj (signal2measureHdl,'Tag','Text_input');
    inputname =  get (sth,'String');
    eval ([ 'global ' inputname]);
    imputsignal = eval(inputname);
    
    
    out = findobj ('Tag','Text_output');
    outputname = get (out,'String');
    if isempty(outputname)
      fl_error (' field ''output'' missing .');
      return
    end
    eval(['global ' outputname]);
    
    imputsignal_measure = (imputsignal-nanmin(imputsignal))/sum(imputsignal-nanmin(imputsignal));
    
    
    eval([outputname '= imputsignal_measure;']);
    fl_addlist(0,outputname);

    
end












