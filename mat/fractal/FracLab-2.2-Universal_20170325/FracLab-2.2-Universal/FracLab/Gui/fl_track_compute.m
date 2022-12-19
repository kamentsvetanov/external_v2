function [varargout]=fl_track_compute(varargin)
% Callback functions for cwttrack GUI - Generation Parameter Window.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%warning off;
Figcwttrack=gcf;
if ((isempty(Figcwttrack)) | (~strcmp(get(Figcwttrack,'Tag'),'Fig_gui_fl_track')))
  Figcwttrack = findobj ('Tag','Fig_gui_fl_track');
end

switch(varargin{1})

  %%%%%% Time instant callbacks %%%%%%%

  case 'edit_time'

	[SigIn_name error_in] = fl_get_input('vector') ;
	eval(['global ',SigIn_name]) ;
	if error_in
	  fl_warning('input signal must be a vector !') ;
	  fl_waitoff(current_cursor);
	  return ;
	end
	SigIn = eval(SigIn_name) ;
	N = length(SigIn) ;
	time=str2num(get(gcbo,'String'));
	time = trunc(time,1,N) ;
        set(gcbo,'String',num2str(time)) ;

  %%%%%%%%% "Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

  case 'compute'

	current_cursor=fl_waiton;
	
	obj=findobj(Figcwttrack,'Tag','EditText_track_time') ;
	whichT=str2num(get(obj,'String')) ;
	[SigIn_name error_in] = fl_get_input ('vector') ;

	if error_in
	  fl_warning ('Input must be a vector !');
	else	
	  eval(['global ',SigIn_name]) ;
	  SigIn = eval(SigIn_name) ;
	  N = length(SigIn) ;
	  Nscale = max(2,round(log2(N/16))) ; 
      [wt,scale] = contwt(SigIn,[2^(-Nscale),2^(-1)],2*Nscale,'morleta',8,'mirror') ;
	  HofT = cwttrack(wt.coeff,scale,whichT,1,0) ;
      
      chaine1=['[wt,scale]= contwt(',SigIn_name,',[',...
      num2str(2^(-Nscale)),',2^(-1)],',num2str(2*Nscale),',''morleta'',8,''mirror'');'] ;
      chaine2=['HofT=cwttrack(wt.coeff,scale,',num2str(whichT),',1,0);'];
      fl_diary(chaine1);
      fl_diary(chaine2);
      
      
	  obj=findobj(Figcwttrack,'Tag','EditText_track_HofT') ;
	  set(obj,'String',num2str(HofT)) ;

	 
	end
    
	fl_waitoff(current_cursor);

	%%%%%%%%% "Advanced Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

  case 'advanced_compute'
	
	[SigIn_name error_in] = fl_get_input ('vector') ;

	if error_in
	  fl_warning ('Input must be a vector !');
	else
    
	  eval(['global ' SigIn_name]) ;
	  SigIn = eval(SigIn_name) ;
	  fl_callwindow('Fig_gui_fl_adv_track','gui_fl_adv_track') ;
	  Figadvcwttrack = findobj('Tag','Fig_gui_fl_adv_track') ;
	  
	  N = length(SigIn) ;
	  logN=floor(log2(N(1)))-4;
	  if(logN<=1.0) logN=2; end
	  ppmh1=findobj(Figadvcwttrack,'Tag','PopupMenu_cwt_fmin');
	  ppmh2=findobj(Figadvcwttrack,'Tag','PopupMenu_cwt_fmax');
	  set([ppmh1 ppmh2],'Value',1);
		for t=1:logN
		  varcell{t}=['2^(-',num2str(t),')'];
		end
		for t=1:logN
		  varcell2{t}=['2^(-',num2str(logN-t+1),')'];
		end
	  set([ppmh1],'String',varcell2);
	  set([ppmh2],'String',varcell);
	  set(findobj(Figadvcwttrack,'Tag','EditText_cwt_fmin'),'String',num2str(2^(-logN)));
	  set(findobj(Figadvcwttrack,'Tag','EditText_cwt_fmax'),'String','0.5');
	  set(findobj(Figadvcwttrack,'Tag','EditText_sig_nname'),'String',SigIn_name);
	  
	  close(Figcwttrack) ;
	  
	end
	  
  case 'close'
        
	obj_reg = findobj(Figcwttrack,'Tag','graph_reg') ;
	close(obj_reg) ;
	obj_cwt = findobj(Figcwttrack,'Tag','graph_cwt') ;
	close(obj_cwt) ;
	close(Figcwttrack) ;
	
  case 'help'	
	 
        helpwin gui_fl_track

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



