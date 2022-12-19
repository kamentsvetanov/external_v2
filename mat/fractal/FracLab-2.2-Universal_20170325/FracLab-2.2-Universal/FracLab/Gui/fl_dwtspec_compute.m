function [varargout]=fl_dwtspec_compute(varargin);
% Callback functions for DWT based Legendre Spec. GUI - Generation Parameter Window.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%warning off;
Figdwtspec = gcf;
if ((isempty(Figdwtspec)) | (~strcmp(get(Figdwtspec,'Tag'),'Fig_gui_fl_dwtspec')))
  Figdwtspec = findobj ('Tag','Fig_gui_fl_dwtspec');
end
fl_clearerror;
	[SigIn_name flag_error]=fl_get_input('vector');
	if flag_error
	  %varargout{1}=SigIn_name;
	  fl_warning('input signal must be a vector!');
	  %fl_waitoff(current_cursor);
	  return;
   end
  eval(['global ' SigIn_name]);
  SigIn = eval(SigIn_name) ;
  N = length(SigIn) ;
  if log2(N)~=floor(log2(N))
	  varargout{1}=SigIn_name;
	  fl_warning('Input vector length must be a power of 2 !');
	  %fl_waitoff(current_cursor);
	  return;
  end
  
  
switch(varargin{1})


  %%%%%%%%% "Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

  case 'SpecFunc'
    
        fl_callwindow('Fig_gui_fl_dwtspec','gui_fl_dwtspec') ;
	figh = findobj('Tag','Fig_gui_fl_dwtspec') ;
	set(figh,'UserData','SpecFunc') ;
	
  case 'SpecMeas'
	
        fl_callwindow('Fig_gui_fl_dwtspec','gui_fl_dwtspec') ;
	figh = findobj('Tag','Fig_gui_fl_dwtspec') ;
	set(figh,'UserData','SpecMeas') ;

  case 'compute_dwtspec'

	current_cursor=fl_waiton;

 	fl_clearerror;
	[SigIn_name flag_error]=fl_get_input('vector');
	if flag_error
	  %varargout{1}=SigIn_name;
	  fl_warning('input signal must be a vector!');
	  fl_waitoff(current_cursor);
	  return;
	end
	  eval(['global ' SigIn_name]);
	  FuncMeas = get(Figdwtspec,'UserData') ;
	  if FuncMeas == 'SpecFunc'
	    SigIn = eval(SigIn_name) ;
	  elseif FuncMeas == 'SpecMeas'
	    SigIn = eval(SigIn_name) ;
	    SigIn = cumsum(SigIn) ;
	  end

	  %%%%% Get a name for the output var %%%%%

	  prefix=['dwt_' SigIn_name];
	  varname=fl_findname(prefix,varargin{2});
	  varargout{1}=varname;
	  eval(['global ' varname]);

	  N = length(SigIn) ;

	  qmf = MakeQMF('daubechies',2) ;
	  [wt] = FWT(SigIn,log2(N),qmf) ;
	  Q = linspace(-4,4,11) ;
	  [alpha,f_alpha,logpart,tau] = dwtspec(wt,Q,0) ;
	  Xlabel = 'Singularity \alpha' ; Ylabel = ' ' ;
	  Title = 'Singularity Spectrum' ;
	  varname = fl_findname(['dwt_',SigIn_name,'_LegSpec'],varargin{2});
	  varargout{1}=varname;
	  eval(['global ' varname]);
	  eval ([varname '= struct (''type'',''graph'',''data1'',alpha,''data2'',f_alpha,''title'',Title,''xlabel'',Xlabel,''ylabel'',Ylabel);']);
	  
      chaine1=['[wt]=FWT(',SigIn_name,',',num2str(log2(N)),',[',num2str(qmf),']);'];
      
      
      chaine2=['[',varname,'.data1,',varname,'.data2]=dwtspec(wt,[',num2str(Q),'],0);'];
      
      chaine=[chaine1,chaine2];
      
      fl_diary(chaine);
      
      
      fl_addlist(0,varname);
       
	  fl_waitoff(current_cursor);

  %%%%%%%%% "Advanced Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

  case 'advanced_compute'
	fl_clearerror;
	[varname flag_error]=fl_get_input('vector');
	if flag_error
	  fl_warning('input signal must be a vector !');
	  fl_waitoff(current_cursor);
	  return ;	  
	else
	  
	  if ~isempty(findobj('Tag','Fig_gui_fl_dwtspec')) % lancement via dwtspec
	    FuncMeas = get(Figdwtspec,'UserData') ;
	  else % lancement via refresh adv_dwtspec
	    Figadvdwtspec = findobj('Tag','Fig_gui_fl_adv_dwtspec') ;
	    FuncMeas = get(Figadvdwtspec,'UserData') ;
	  end
	  fl_callwindow('Fig_gui_fl_adv_dwtspec','gui_fl_adv_dwtspec') ;
	  Figadvdwtspec = findobj('Tag','Fig_gui_fl_adv_dwtspec') ;
	  set(Figadvdwtspec,'UserData',FuncMeas) ;
  
	  string=['global ' varname];
	  eval(string);
	  eval(['temp=size(' varname ');']);
	  if(min(min(temp))==1)
	    N=max(max(temp));
	  else
	    N=min(min(temp));
	  end
	  logN=floor(log2(N));
	  ppmh=findobj(Figadvdwtspec,'Tag','PopupMenu_dwt_octave');
	  for i=1:(logN)
	    varcell{i}=num2str(i);
	  end
	  set(ppmh,'String',varcell);
	  set(ppmh,'Value',logN);
	  set(findobj(Figadvdwtspec,'Tag','EditText_dwt_octave'),'String',num2str(logN));
	  set(findobj(Figadvdwtspec,'Tag','EditText_sig_nname'),'String',varname);
	  
	  close(Figdwtspec) 
	  
	end
	
  case 'close'
        
	obj_reg = findobj('Tag','graph_reg') ;
	close(obj_reg) ;
	close(Figdwtspecgcf) ;
      
  case 'help'
	
        helpwin gui_fl_dwtspec

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


