function varargout=fl_function(varargin)
% Callback functions for the FRACLAB Toolbox GUI.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch(varargin{1})


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%  Main Window %%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  case 'erase_error'
	texth=findobj('Tag','StaticText_error');
	set(texth,'String','');
 
  case 'mn_scanwks'
	fl_callwindow('Fig_gui_fl_import','gui_fl_import');
	figh=findobj('Tag','Fig_gui_fl_import');
	lbh1=findobj('Tag','Listbox_imp_name');
	lbh2=findobj('Tag','Listbox_imp_size');
	lbh3=findobj('Tag','Listbox_imp_type');
	

 	wks=varargin{2}; %% Workspace structure. %%
	temp=size(wks);
	size_wks=temp(1);
	set([lbh1 lbh2 lbh3],'Max',size_wks);
	varcell1=cell(1);
	varcell2=cell(1);
	varcell3=cell(1);
	for i=1:size_wks  
	  varcell1{i}=wks(i).name;
	  varcell2{i}=['[' num2str(wks(i).size(1)) '*' ... 
			   num2str(wks(i).size(2)) ']'];
	  varcell3{i}=wks(i).class;
	end
	set(lbh1,'String',varcell1);
	set(lbh2,'String',varcell2);
	set(lbh3,'String',varcell3);


  case 'close'
	fl_clearerror;
	% close(gcf);
	[obj fig] = gcbo;
	close(fig);
  
  case 'close_all'
	
	%Save window size and position
	if fl_getOption('SavePosition')
		fl_setOption('FracLabPosition',get(gcf,'position'));
	end
	
	
	%execute the close button of the window dimR
	%that is: close all the windows opened during the procedure
	% and clear the global variables:
	%fl_dimR_compute('close');
	
	% close the view toolbar and all depending windows 
	% like images or axes control panel and all the 
	% figure s contained in the listbox.
	%fl_view_toolbar('Close_all');
	
	%Close all opened figures
	try
		ud = get(gcf,'UserData');
		if isfield(ud,'OpenedWindows')
			seplist = [0 find(ud.OpenedWindows=='|')];
			ShowHiddenHandlesInit = get(0,'ShowHiddenHandles');
			set(0,'ShowHiddenHandles','on');
			for i=1:length(seplist)-1;
				openedWindows = ud.OpenedWindows;
				openedWindow = openedWindows(seplist(i)+1:seplist(i+1)-1);
				openedWindowHandle=findobj('Tag',openedWindow);
				if ~isempty(openedWindowHandle)
					try
						%close (openedWindowHandle);
						delete(openedWindowHandle);
					end
				end
			end
			set(0,'ShowHiddenHandles',ShowHiddenHandlesInit);
		else
			delete(gcf);
		end
    catch
		delete(findobj('Tag','FRACLAB Toolbox'))
    end

  case 'clear'
	varargout{1}='rien_du_tout';
	lbh1=findobj('Tag','Listbox_variables');
	lbh2=findobj('Tag','Listbox_details');
	values=get(lbh1,'Value');
	if isempty(values)
	  return
	end
          %% Clear the variable from the fisrt list %%%
	val=values(1);
    strings=get(lbh1,'String');
    if isempty(strings)
        return
    end
	s=size(strings);
	if s(1)==1      %%%% "strings" contains a single string
	  set(lbh1,'Value',1);
	  set(lbh1,'String','');
	  string=strtok(strings{1});
	else
	  if(val<s(1))
	    if(val>1)
	      newcell={strings{1:(val-1)} strings{(val+1):s(1)}};
	      set(lbh1,'Value',(val-1));
	    else
	      newcell={strings{2:s(1)}};
          set(lbh1,'Value',1);
	    end
	  else
	    newcell={strings{1:(s(1)-1)}};
            set(lbh1,'Value',(s(1)-1));
	  end
	  set(lbh1,'String',newcell);
	  string=strtok(strings{val});
 	end
	varargout{1}=string;
        %%% Clear the 2nd list %%%
	fl_details;
    if isempty(get(lbh1,'String'));
        set(lbh2,'String','');
    end
    
case 'mn_estim'
	fl_callwindow('Fig_gui_fl_estim_choice','gui_fl_estim_choice') ;


case 'mn_denois'
	fl_callwindow('Fig_gui_fl_denoising_choice','gui_fl_denoising_choice');
	figh = findobj('Tag','Fig_gui_fl_denoising_choice') ;

case 'mn_load_file'
	fl_callwindow('Fig_gui_fl_load','gui_fl_load') ;
	figh = findobj('Tag','Fig_gui_fl_load') ;

case 'mn_save_file'
	fl_callwindow('Fig_gui_fl_save','gui_fl_save') ;
	figh = findobj('Tag','Fig_gui_fl_save') ;
	lbh=findobj('Tag','Listbox_variables');
	strings=get(lbh,'String');
	varname=strings(get(lbh,'Value'));
	fname=strcat(varname,'.mat');
	edith=findobj(figh,'Tag','EditText_fl_save_name');
	set(edith,'String',fname);
	set(figh,'UserData',varname);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%% Viewing choice window %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'vmc_ppm'
	eth=findobj('Tag','EditText_vmc_index');
	sth=findobj('Tag','StaticText_vmc_index');
	sth2=findobj('Tag','StaticText_vmc_colormap');
	userdata=get(gcf,'UserData');
	if isstruct(userdata)
	  if (strcmp(userdata.type,'cwt'))
	    mat = userdata.coeff;
	  end  
	  if (strcmp(userdata.type,'dwt' )|strcmp(userdata.type,'dwt2d'))
	    mat = userdata.wt
	  end

	else
	  mat=userdata;
	end
	dim=size(mat);
	switch(get(gcbo,'Value'))
	  case 1
	    set(eth,'Visible','off');
	    set(sth,'Visible','off');
	    set(sth2,'Visible','on');
	   case 2
	    set(eth,'Visible','off');
	    set(sth,'Visible','off');
	    set(sth2,'Visible','on');  
	  case 6
	    set(eth,'Visible','on');
	    set(eth,'String','1');
	    set(sth,'Visible','on');
	    set(sth2,'Visible','off');
	    set(sth,'String','Line index');
  	  case 8
	    set(eth,'Visible','on');
	    set(eth,'String','1');
	    set(sth,'Visible','on');
	    set(sth2,'Visible','off');
	    set(sth,'String','Column index');
	  otherwise
	    set(eth,'Visible','off');
	    set(sth,'Visible','off');
	    set(sth2,'Visible','off');
	end
	switch(get(gcbo,'Value'))
	   case 1
	     set(findobj('Tag','Radiobutton_vmc_scaling'),'Visible','on');
	     set(findobj('Tag','PopupMenu_vmc_color'),'Visible','on');
	    case 2
	     set(findobj('Tag','Radiobutton_vmc_scaling'),'Visible','on');
	     set(findobj('Tag','PopupMenu_vmc_color'),'Visible','on');
	     
	   otherwise
	     set(findobj('Tag','Radiobutton_vmc_scaling'),'Visible','off');
	     set(findobj('Tag','PopupMenu_vmc_color'),'Visible','off');
	end

  case 'vmc_edit'
	value=str2num(get(gcbo,'String'));
	value=floor(value);
	if(value<1)
	  value=1;
	end
	mat=get(gcf,'UserData');
	dim=size(mat);
	ppmh=findobj('Tag','PopupMenu_vmc');
	viewoption=get(ppmh,'Value');
	if (viewoption==2) %% view one line
	  bsup=dim(1);
	else %% view one column %%	
	  bsup=dim(2);
	end
	if(value>bsup)
	  value=bsup;
	end
	set(gcbo,'String',num2str(value));

  case 'rb_scaling'
	if get(gcbo,'Value')
	  set(gcbo,'String','Original size');
	else
	  set(gcbo,'String','Automatic Scaling');
	end

    case 'vmc_view'
	current_axes_handle = fl_view_functions('get_handle');
	handle_type = get(current_axes_handle,'Type');
	if strcmp(handle_type,'figure')
	  current_axes_handle = get (current_axes_handle,'currentaxes');
	end
	
	eth=findobj('Tag','EditText_vmc_index');
	ppmh=findobj('Tag','PopupMenu_vmc');
	userdata=get(gcf,'UserData');
	if isstruct(userdata)
	  if (strcmp(userdata.type,'cwt'))
	    mat = userdata.coeff;
	  end  
	  if (strcmp(userdata.type,'dwt' )|strcmp(userdata.type,'dwt2d'))
	    mat = userdata.wt
	  end
	else
	  mat=userdata;
	end
	dim=size(mat);
	figh=gcf;
	value=get(ppmh,'Value');
	switch(value)
	  case 1
	    axes(current_axes_handle);
	    if all(all(imag(mat))) 
		mat = abs(mat) ;
  	    end
	    viewmat(mat);
	    if get(findobj('Tag','Radiobutton_vmc_scaling'),'Value')
	      axis image;
	    end
	    ppmh=findobj('Tag','PopupMenu_vmc_color');
	    string=get(ppmh,'String');
	    val=get(ppmh,'Value');
	    eval(['colormap(' string{val} ');']);
%	    colorbar;
	  case 2
	    axes(current_axes_handle);
	    if all(all(imag(mat))) 
		mat = abs(mat) ;
  	    end
	    imagesc(mat);
	    if get(findobj('Tag','Radiobutton_vmc_scaling'),'Value')
	      axis image;
	    end
	    ppmh=findobj('Tag','PopupMenu_vmc_color');
	    string=get(ppmh,'String');
	    val=get(ppmh,'Value');
	    eval(['colormap(' string{val} ');']);
%	    colorbar;
	  case 3
	    axes(current_axes_handle);
	    mesh(mat);
	  case 4
	    axes(current_axes_handle);
	    surf(mat);
	  case 5
	    axes(current_axes_handle);
	    plot(mat.');
	  case 6
	    axes(current_axes_handle);
	    line=str2num(get(eth,'String'));
	    mat=mat.';
	    plot(mat(:,line));
	  case 7
	    axes(current_axes_handle);
	    plot(mat);
	  case 8
	    axes(current_axes_handle);
	    column=str2num(get(eth,'String'));
	    plot(mat(:,column));
	  
	end
	close(figh);
	
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%  tfts  %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  case 'tfts_cwt'
	figh=gcf;
	fl_clearerror;
	[SigIn_name flag_error]=fl_get_input('vector');
	if flag_error
	  fl_warning('Invalid must be a vector !');
	else 
	  eval(['global ' SigIn_name]);
	  eval(['N = length(' SigIn_name ');']);
	  fl_callwindow('Fig_gui_fl_cwt','gui_fl_cwt');
	  Figcwt = findobj('Tag','Fig_gui_fl_cwt') ;
	  logN=floor(log2(N))-4 ;
	  if(logN<=1.0) logN=2; end
	  set(Figcwt,'UserData',N(1));
	  ppmh1=findobj(Figcwt,'Tag','PopupMenu_cwt_fmin');
	  ppmh2=findobj(Figcwt,'Tag','PopupMenu_cwt_fmax');
	  set([ppmh1 ppmh2],'Value',1);
	  for i=1:logN
	    varcell{i}=['2^(-' num2str(i) ')'];
	  end
	  for i=1:logN
	    varcell2{i}=['2^(-' num2str(logN-i+1) ')'];
	  end
	  set([ppmh1],'String',varcell2);
	  set([ppmh2],'String',varcell);
	  set(findobj(Figcwt,'Tag','EditText_cwt_fmin'),'String',num2str(2^(-logN)));
	  set(findobj(Figcwt,'Tag','EditText_cwt_fmax'),'String','0.5');
	  
	  set(findobj(Figcwt,'Tag','EditText_sig_nname'),'String',...
	      SigIn_name) ;
	end
	
      case 'tfts_dwt'
	figh=gcf;
	fl_clearerror;
	[SigIn_name flag_error]=fl_get_input('matrix');
    if flag_error
        [input_sig flag_error]=fl_get_input('vector');
    end
    if flag_error
        fl_warning('input signal must be a vector or matrix !');
    else
        fl_callwindow('Fig_gui_fl_dwt','gui_fl_dwt');
        Figdwt = findobj('Tag','Fig_gui_fl_dwt') ;
        string=['global ' SigIn_name];
        eval(string);
        eval(['temp=size(' SigIn_name ');']);
        if(min(min(temp))==1)
            N=max(max(temp));
        else
            N=min(min(temp));
        end
        logN=floor(log2(N));
        ppmh=findobj(Figdwt,'Tag','PopupMenu_dwt_octave');
        for i=1:(logN)
            varcell{i}=num2str(i);
        end
        set(ppmh,'String',varcell);
        set(ppmh,'Value',logN);
        set(findobj(Figdwt,'Tag','EditText_dwt_octave'),'String',num2str(logN));
        set(findobj(Figdwt,'Tag','EditText_sig_nname'),'String',...
            SigIn_name) ;
    end
	
  case 'tfts_paw'
	
	[SigIn_name error_in] = fl_get_input('vector') ;
	eval(['global ' SigIn_name]) ;
	if error_in
		fl_warning('input signal must be a vector !') ;
	else
	  N = length(eval(SigIn_name)) ;
	  fl_callwindow('Fig_gui_fl_pseudoaw','gui_fl_pseudoaw')
	  Figpseudoaw = findobj('Tag','Fig_gui_fl_pseudoaw') ;
	  set(Figpseudoaw,'UserData',N) ;
	  logN=floor(log2(N))-4 ;
	  if(logN<=1.0) logN=2; end

	  ppmh1=findobj(Figpseudoaw,'Tag','PopupMenu_pseudoaw_fmin');
	  ppmh2=findobj(Figpseudoaw,'Tag','PopupMenu_pseudoaw_fmax');
	  set([ppmh1 ppmh2],'Value',1);
	  for i=1:logN
	    varcell{i}=['2^(-' num2str(i) ')'];
	  end
	  for i=1:logN
	    varcell2{i}=['2^(-' num2str(logN-i+1) ')'];
	  end
	  set([ppmh1],'String',varcell2);
	  set([ppmh2],'String',varcell);
	  set(findobj(Figpseudoaw,'Tag','EditText_pseudoaw_fmin'),'String',num2str(2^(-logN)));
	  set(findobj(Figpseudoaw,'Tag','EditText_pseudoaw_fmax'),'String','0.5');
	  set(findobj(Figpseudoaw,'Tag','EditText_sig_nname'),'String',...
	      SigIn_name) ;	  
	end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%% Function Synthesis %%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'syf_dwei'
	fl_callwindow('Fig_gui_fl_wei','gui_fl_wei');
	figh = findobj('Tag','Fig_gui_fl_wei') ;
	set(figh,'UserData',0) ;
	rbh=findobj('Tag','StaticTextTitle');
	set(rbh,'String','Weierstrass Function Synthesis');

  case 'syf_swei'
	fl_callwindow('Fig_gui_fl_wei','gui_fl_wei');
	figh = findobj('Tag','Fig_gui_fl_wei') ;
	set(figh,'UserData',1) ;
	rbh=findobj(figh,'Tag','StaticTextTitle'); 
	set(rbh,'String','Weierstrass Process Synthesis');
	
  case 'syf_dgwei'
	fl_callwindow('Fig_gui_fl_gwei','gui_fl_gwei')
	figh = findobj('Tag','Fig_gui_fl_gwei') ;
	set(figh,'UserData',0) ;
	rbh=findobj('Tag','StaticTextTitle');
	set(rbh,'String','Generalized Weierstrass Function Synthesis');
	
  case 'syf_sgwei'
	fl_callwindow('Fig_gui_fl_gwei','gui_fl_gwei')
	figh = findobj('Tag','Fig_gui_fl_gwei') ;
	set(figh,'UserData',1) ;
	rbh=findobj(figh,'Tag','StaticTextTitle'); 
	set(rbh,'String','Generalized Weierstrass Process Synthesis');

  case 'syf_stinc2d'
	fl_callwindow('Fig_gui_fl_stinc2d','gui_fl_stinc2d')
    
    
  case 'syf_mBm2d'
	fl_callwindow('Fig_gui_fl_mBm2d','gui_fl_mbm2d')
        
  case 'syf_fbmfwt'
	fl_callwindow('Fig_gui_fl_fbmfwt','gui_fl_fbmfwt')
     
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%  Import Window %%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  case 'imp_import'
	obj=findobj('Tag','Listbox_imp_name');
	values=get(obj,'Value');
	list=get(obj,'String');
	temp=size(values);
	l=temp(2);
	for i=1:l
	  val=values(i);
	  string=list{val};
	  if ~exist(string)
	    eval(['global ' string]);
	  end
	  fl_addlist(0,string);
	end

  case 'lb_imp'
	value=get(gcbo,'Value');
	lbh1=findobj('Tag','Listbox_imp_name');
	lbh2=findobj('Tag','Listbox_imp_size');
	lbh3=findobj('Tag','Listbox_imp_type');
	set([lbh1 lbh2 lbh3],'Value',value);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  	%%%%%%%%%%%%%%%%% STABLE PROCESSES  %%%%%%%%%%%%%%%%
  	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'mn_stable_process'
	[sig_in error_in] = fl_get_input('vector') ;
	if error_in
		fl_warning('Invalid Input!') ; return ;
	end
	eval(['global ' sig_in]) ;
	SigIn = eval(sig_in) ;
	fl_callwindow('Fig_gui_fl_stable_proc','gui_fl_stable_proc') ;
	figh = findobj('Tag','Fig_gui_fl_stable_proc') ;
	set(figh,'UserData',SigIn) ;

end
