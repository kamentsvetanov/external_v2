function [varargout]=fl_longrange_compute(varargin)
% Callback functions for Global cwttrack GUI - Generation Parameter Window.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%warning off;
Figlongrange = gcf;
if ((isempty(Figlongrange)) || (~strcmp(get(Figlongrange,'Tag'),'Fig_gui_fl_longrange')))
  Figlongrange = findobj ('Tag','Fig_gui_fl_longrange');
end

switch(varargin{1})


  %%%%%%%%% "Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

  case 'compute'

	current_cursor=fl_waiton;

    whichT = 0 ;
    [SigIn_name flag_error] = fl_get_input('vector');
    if flag_error
        fl_warning('input signal must be a vector !');
        fl_waitoff(current_cursor);
    else
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N = length(SigIn) ;
        Nscale = max(2,round(log2(N/16))) ;
        wt = contwt(SigIn,[2^(-Nscale),2^(-1)],2*Nscale,'morleta',8,'mirror');
        H = cwttrack(wt.coeff,wt.scale,whichT,1,0) ;
        obj=findobj(Figlongrange,'Tag','EditText_longrange_H') ;
        set(obj,'String',num2str(H)) ;
        fl_waitoff(current_cursor);
    end
	
  %%%%%%%%% "Advanced Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

  case 'advanced_compute'

      [SigIn_name flag_error] = fl_get_input('vector');
      if flag_error
          fl_warning('input signal must be a vector !');
      else
          eval(['global ' SigIn_name]) ;
          SigIn = eval(SigIn_name) ;
          fl_callwindow('Fig_gui_fl_adv_longrange','gui_fl_adv_longrange') ;
          Figadvlongrange = findobj('Tag','Fig_gui_fl_adv_longrange') ;
          N = length(SigIn) ;
          logN=floor(log2(N(1)))-4;
          if(logN<=1.0), logN=2; end
          ppmh1=findobj(Figadvlongrange,'Tag','PopupMenu_cwt_fmin');
          ppmh2=findobj(Figadvlongrange,'Tag','PopupMenu_cwt_fmax');
          set([ppmh1 ppmh2],'Value',1);
          for t=1:logN
              varcell{t}=['2^(-' num2str(t) ')'];
          end
          for t=1:logN
              varcell2{t}=['2^(-' num2str(logN-t+1) ')'];
          end
          set([ppmh1],'String',varcell2);
          set([ppmh2],'String',varcell);
          set(findobj(Figadvlongrange,'Tag','EditText_cwt_fmin'),'String',num2str(2^(-logN)));
          set(findobj(Figadvlongrange,'Tag','EditText_cwt_fmax'),'String','0.5');
          set(findobj(Figadvlongrange,'Tag','EditText_sig_nname'),'String',SigIn_name);

          close(Figlongrange)

      end
	
  case 'close'
        
	obj_reg = findobj('Tag','graph_reg') ;
	close(obj_reg) ;
	obj_cwt = findobj('Tag','graph_cwt') ;
	close(obj_cwt) ;
	close(Figlongrange) ;
	
  case 'help'
	
        helpwin gui_fl_longrange


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% trunc %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function o=trunc(i,a,b)
if(i<a)
  o=a;
else
  if(i>b)
    o=b;
  else
    o=i;
  end 
end
