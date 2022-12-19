function [varargout]=fl_dmt_compute(varargin)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

Figfmt = gcf;
if ((isempty(Figdmt)) | (~strcmp(get(Figdmt,'Tag'),'Fig_gui_fl_dmt')))
  Figdmt = findobj ('Tag','Fig_gui_fl_dmt');
end

 switch(varargin{1})
   
   case 'compute'
     
     current_cursor=fl_waiton; 
     
     fl_clearerror;
     [SigIn_name flag_error]=fl_get_input('vector');
     if flag_error
	  varargout{1}=SigIn_name;
	  fl_error('Input must be a vector !');
	  fl_waitoff(current_cursor);
	  return;
     end
     eval(['global ' SigIn_name]);
     SigIn = eval(SigIn_name) ;
     eth=findobj(Figdmt,'Tag','EditText_fmin');
     fmin = str2num(get(eth,'String')) ;
     eth=findobj(Figdmt,'Tag','EditText_fmax');
     fmax = str2num(get(eth,'String')) ;
     eth=findobj(Figdmt,'Tag','EditText_N');
     N = str2num(get(eth,'String')) ;
     
     if isempty(fmin) | isempty(fmax) | isempty(N)
       [mellin,beta] = dmt(SigIn) ;
     else
       [mellin,beta] = dmt(SigIn,fmin,fmax,N) ;
     end
     
     prefix=['Mellin_' SigIn_name];
     varname=fl_findname(prefix,varargin{2});
     varargout{1}=varname;
     eval(['global ' varname]);
     eval ([varname '= struct(''type'',''graph'',''data1'',beta,''data2'',mellin,''title'',''Mellin transform'',''xlabel'',''\beta'',''ylabel'',''M[x](\beta)'');']);
     fl_addlist(0,varname);

     fl_waitoff(current_cursor);

   case 'help'
     
     helpwin dmt
     
end
