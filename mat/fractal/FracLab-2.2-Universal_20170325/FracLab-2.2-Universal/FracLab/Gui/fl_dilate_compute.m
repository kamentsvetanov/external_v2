function [varargout]=fl_dilate_compute(varargin)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

Figdilate = gcf;
if ((isempty(Figdilate)) | (~strcmp(get(Figdilate,'Tag'),'Fig_gui_fl_dilate')))
  Figdilate = findobj ('Tag','Fig_gui_fl_dilate');
end

switch(varargin{1})
  
  case 'edit_scale'
    
    scale = str2num(get(gcbo,'String')) ;
    if scale <= 0 
      fl_error('Zero or negative scaling factors not allowed!')
      scale = 1 ;
      set(gcbo,'String',num2str(scale)) ;
    end
    
  case 'compute'
    
    current_cursor=fl_waiton; 
    
    fl_clearerror;
    [SigIn_name flag_error]=fl_get_input('vector');
    if flag_error
      varargout{1}=SigIn_name;
      fl_waitoff(current_cursor);	  
      fl_error('Input must be a vector !');
      return;
    end
    eval(['global ' SigIn_name]);
    SigIn = eval(SigIn_name) ;
    eth=findobj(Figdilate,'Tag','EditText_fmin');
    fmin = str2num(get(eth,'String')) ;
    eth=findobj(Figdilate,'Tag','EditText_fmax');
    fmax = str2num(get(eth,'String')) ;
    eth=findobj(Figdilate,'Tag','EditText_N');
    N = str2num(get(eth,'String')) ;
    eth=findobj(Figdilate,'Tag','EditText_scale');
    scale = str2num(get(eth,'String')) ;
    
    if isempty(fmin) | isempty(fmax) | isempty(N)
      [SigScaled] = Frac_dilate(SigIn,scale) ;
      SigScaled = SigScaled(2:SigScaled(1)) ;
    else
      [SigScaled] = Frac_dilate(SigIn,scale,fmin,fmax,N) ;
      SigScaled = SigScaled(2:SigScaled(1)) ;
    end
    
    prefix=['Scaled_' SigIn_name];
    varname=fl_findname(prefix,varargin{2});
    varargout{1}=varname;
    eval(['global ' varname]);
    eval([varname '= SigScaled ; ']);
    fl_addlist(0,varname);
    
    fl_waitoff(current_cursor);
    
  case 'help'
    
    helpwin Frac_dilate
    
end
