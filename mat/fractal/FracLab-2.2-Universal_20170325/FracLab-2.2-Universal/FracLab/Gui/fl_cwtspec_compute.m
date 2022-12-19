function [varargout]=fl_cwtspec_compute(varargin)
% Callback functions for Global cwtspec GUI - Generation Parameter Window.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%warning off;
Figcwtspec = gcf;
if ((isempty(Figcwtspec)) | (~strcmp(get(Figcwtspec,'Tag'),'Fig_gui_fl_cwtspec')))
  Figcwtspec = findobj ('Tag','Fig_gui_fl_cwtspec');
end

switch(varargin{1})


  %%%%%%%%% "Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%
  
  case 'SpecFunc'
    
        fl_callwindow('Fig_gui_fl_cwtspec','gui_fl_cwtspec') ;
	figh = findobj('Tag','Fig_gui_fl_cwtspec') ;
	set(figh,'UserData','SpecFunc') ;
	
  case 'SpecMeas'
	
        fl_callwindow('Fig_gui_fl_cwtspec','gui_fl_cwtspec') ;
	figh = findobj('Tag','Fig_gui_fl_cwtspec') ;
	set(figh,'UserData','SpecMeas') ;

  case 'compute'

	current_cursor=fl_waiton;

	fl_clearerror
	[SigIn_name error_in] = fl_get_input('vector') ;
	eval(['global ' SigIn_name]) ;
	if error_in
	  fl_warning('input signal must be a vector !') ;
	  fl_waitoff(current_cursor);
	  return ;
	end
	eval(['global ' SigIn_name]) ;
	FuncMeas = get(Figcwtspec,'UserData') ;
	if FuncMeas == 'SpecFunc'
	  SigIn = eval(SigIn_name) ;
	elseif FuncMeas == 'SpecMeas'
	  SigIn = eval(SigIn_name) ;
	  SigIn = cumsum(SigIn) ;
	end
	
	N = length(SigIn) ;
        Nscale = max(2,round(log2(N/16))) ;
    wt = contwt(SigIn,[2^(-Nscale),2^(-1)],2*Nscale,'morleta',8,'mirror');    
	Q = linspace(-4,4,11) ;
        [alpha,f_alpha] = contwtspec(wt.coeff,wt.scale,Q,1,0) ;
	Xlabel = 'Singularity \alpha' ; Ylabel = ' ' ;
	Title = 'Singularity Spectrum' ;
	varname = fl_findname([SigIn_name,'_LegSpec'],varargin{2});
	varargout{1}=varname;
	eval(['global ' varname]);
	eval ([varname ' = struct (''type'',''graph'',''data1'',alpha,''data2'',f_alpha'',''title'',Title,''xlabel'',Xlabel,''ylabel'',Ylabel);']);
	
    chaine1=['[wt,scale] = contwt(',SigIn_name,',[',num2str(2^(-Nscale)),',2^(-1)],',num2str(2*Nscale),',''morleta'',8,''mirror'');'];
    
    chaine2=['[',varname,'.data1,',varname,'.data2]=contwtspec(wt.coeff,wt.scale,',mat2str(Q),',1,0);'];
    
    fl_diary(chaine1)
    fl_diary(chaine2);
    
    fl_addlist(0,varname);

	fl_waitoff(current_cursor);


  %%%%%%%%% "Advanced Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

  case 'advanced_compute'
	current_cursor=fl_waiton;
	[SigIn_name error_in] = fl_get_input('vector') ;
	eval(['global ' SigIn_name]) ;
	if error_in
	  fl_warning('input signal must be a vector !') ;
	  fl_waitoff(current_cursor);
	  return ;
	end
	
	SigIn = eval(SigIn_name) ;

	if ~isempty(findobj('Tag','Fig_gui_fl_cwtspec')) % lancement via cwtspec
	  FuncMeas = get(Figcwtspec,'UserData') ;
	else % lancement via refresh adv_cwtspec
	  Figadvcwtspec = findobj('Tag','Fig_gui_fl_adv_cwtspec') ;
	  FuncMeas = get(Figadvcwtspec,'UserData') ;
	end
	
	fl_callwindow('Fig_gui_fl_adv_cwtspec','gui_fl_adv_cwtspec') ;
	Figadvcwtspec = findobj('Tag','Fig_gui_fl_adv_cwtspec') ;
	set(Figadvcwtspec,'UserData',FuncMeas) ;

	N = length(SigIn) ;
	logN=floor(log2(N(1)))-4;
	if(logN<=1.0) logN=2; end
	ppmh1=findobj(Figadvcwtspec,'Tag','PopupMenu_cwt_fmin');
	ppmh2=findobj(Figadvcwtspec,'Tag','PopupMenu_cwt_fmax');
	set([ppmh1 ppmh2],'Value',1);
	for t=1:logN
          varcell{t}=['2^(-' num2str(t) ')'];
	end
	for t=1:logN
          varcell2{t}=['2^(-' num2str(logN-t+1) ')'];
	end
	set([ppmh1],'String',varcell2);
	set([ppmh2],'String',varcell);
	set(findobj(Figadvcwtspec,'Tag','EditText_cwt_fmin'),'String',num2str(2^(-logN)));
	set(findobj(Figadvcwtspec,'Tag','EditText_cwt_fmax'),'String','0.5');
	set(findobj(Figadvcwtspec,'Tag','EditText_sig_nname'),'String',SigIn_name);
	
	close(Figcwtspec) 
	
  case 'close'
        
	obj_reg = findobj('Tag','graph_reg') ;
	close(obj_reg) ;
	obj_cwt = findobj('Tag','graph_cwt') ;
	close(obj_cwt) ;
	close(Figcwtspec) ;
	
  case 'help'
	
        helpwin gui_fl_cwtspec

end



