function [varargout]=fl_adv_longrange_compute(varargin)
% Callback functions for advanced LRD est. GUI - Generation Parameter Window.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%warning backtrace;
Figadvlongrange = gcf;
if ((isempty(Figadvlongrange)) | (~strcmp(get(Figadvlongrange,'Tag'),'Fig_gui_fl_adv_longrange')))
  Figadvlongrange = findobj ('Tag','Fig_gui_fl_adv_longrange');
end

switch(varargin{1})

  case 'cwt_editf'
	value=str2num(get(gcbo,'String'));
	if(value<0.0)
	  SigIn_name = get(findobj(Figadvlongrange,'Tag','EditText_sig_nname'),'String') ;
	  eval(['global ' SigIn_name]) ;
	  SigIn = eval(SigIn_name) ;
	  N=length(SigIn);
	  value=1.0/N;
	else
	  if(value>0.5)
	    value=0.5;
	  end 
	end
	set(gcbo,'String',value);

  case 'cwt_ppm_fmin'
        SigIn_name = get(findobj(Figadvlongrange,'Tag','EditText_sig_nname'),'String') ;
	eval(['global ' SigIn_name]) ;
	SigIn = eval(SigIn_name);
	N = length (SigIn);
	logN=floor(log2(N))-4;
	if(logN<=1.0) logN=2; end
	value=get(gcbo,'Value');
	pow=2^(-1*(logN-value+1));
	set(findobj(Figadvlongrange,'Tag','EditText_cwt_fmin'),'String',num2str(pow));

  case 'cwt_ppm_fmax'
	value=get(gcbo,'Value');
	pow=2^(-1*value);
	set(findobj(Figadvlongrange,'Tag','EditText_cwt_fmax'),'String',num2str(pow));

  case 'cwt_edit_voices'
	value=str2num(get(gcbo,'String'));
	value=floor(value);
	if(value<=1.0) value=2.0; end
	set(gcbo,'String',value);

  case 'cwt_ppm_voices'
	value=get(gcbo,'Value');
	set(findobj(Figadvlongrange,'Tag','EditText_cwt_voices'),'String',num2str(2^value));

  case 'cwt_edit_wsize'
	value=str2num(get(gcbo,'String'));
	value=floor(value);
	if(value<=1.0) value=2.0; end
	set(gcbo,'String',value);

  case 'cwt_ppm_wtype'
	ppmh=findobj(Figadvlongrange,'Tag','PopupMenu_cwt_wtype');
	eth=findobj(Figadvlongrange,'Tag','EditText_cwt_wsize');
	if(get(ppmh,'Value')==1)
	  set(findobj(Figadvlongrange,'Tag','EditText_cwt_wsize'),'Enable','off');
	else
	  set(findobj(Figadvlongrange,'Tag','EditText_cwt_wsize'),'Enable','on');
	end

  case 'cwt_rb_mirror'
	if(get(gco,'Value')==0)
	  set(gco,'String','No mirror');
	else
	  set(gco,'String','Mirror');
	end

  case 'cwt_compute'

	current_cursor=fl_waiton;

	  %%%%% First get the input %%%%%%
	fl_clearerror;
        SigIn_name = get(findobj(Figadvlongrange,'Tag','EditText_sig_nname'),'String') ;
	eval(['global ' SigIn_name]);
	  %%%%% Now get the wavelet type %%%%%
	ppmh=findobj(Figadvlongrange,'Tag','PopupMenu_cwt_wtype');
	eth=findobj(Figadvlongrange,'Tag','EditText_cwt_wsize');
    switch(get(ppmh,'Value'))
        case 1
            wave = '''mexican''';
        case 2
            wave = ['''morletr'',',get(eth,'String')];
        case 3
            wave = ['''morleta'',',get(eth,'String')];
            % 	  case 1
            % 	    wave=0;
            % 	  case 2
            % 	    wave=str2num(get(eth,'String'));
            % 	  case 3
            % 	    wave=i*str2num(get(eth,'String'));
    end
	  %%%%% Get fmin and fmax %%%%%
	eth=findobj(Figadvlongrange,'Tag','EditText_cwt_fmin');
	fmin=str2num(get(eth,'String'));
	eth=findobj(Figadvlongrange,'Tag','EditText_cwt_fmax');
	fmax=str2num(get(eth,'String'));
	  %%%%% Get the number of voices %%%%%
	eth=findobj(Figadvlongrange,'Tag','EditText_cwt_voices');
	voices=str2num(get(eth,'String'));
	  %%%%% L2 or L1? %%%%%
	mirror=get(findobj(Figadvlongrange,'Tag','Radiobutton_cwt_mirror'),'Value');
% 	   if(mirror==0)
% 	     command='contwt';
% 	   else
% 	     command='contwtmir';
% 	   end
	%%%%% Get a name for the output var %%%%%
	prefix=['cwt_' SigIn_name];
	varname=fl_findname(prefix,varargin{2});
	varargout{1}=varname;
	eval(['global ' varname]);
	%%%%% Perform the computation %%%%%
    if ~mirror
        chaine = [varname,' = contwt(' SigIn_name ',[fmin,fmax],voices,',wave,');'];
        eval(chaine);
        chaine=[varname,'=contwt(',SigIn_name,',[',num2str(fmin),',',num2str(fmax),'],',num2str(voices),',',wave,');'];
    else
        chaine = [varname,' = contwt(' SigIn_name ',[fmin,fmax],voices,',wave,',''mirror'');'];
        eval(chaine);
        chaine=[varname,'=contwt(',SigIn_name,',[',num2str(fmin),',',num2str(fmax),'],',num2str(voices),',',wave,',''mirror'');'];
    end
% 	eval(['[wt scale f]=' command '(' SigIn_name ',fmin,fmax,voices,wave);']);
% 	eval ([varname ' = struct (''type'',''cwt'',''coeff'',wt,''scale'',scale,''frequency'',f);']);
%     chaine=['[',varname,'.coeff,',varname,'.scale,',varname,'.frequency]=',command,'(',...
%             SigIn_name,',',num2str(fmin),',',num2str(fmax),',',num2str(voices),',',...
%             num2str(wave),');'];
        
    fl_diary(chaine)
    
    
    %%%%% Update the cwt list %%%%%
	fl_addlist(0,varname);
	set(findobj(Figadvlongrange,'Tag','EditText_cwt_nname'),'String',varname) ;
	fl_waitoff(current_cursor);

%%%%%%%%% LOCAL SCALING PARAMETERS %%%%%%%%%%%%%

  case 'refresh_cwt'
      
      current_cursor=fl_waiton;
	[cwt_in_name error_in] = fl_get_input('cwt') ;
	if error_in
		fl_error('Input must be a cwt structure !') ; 
		fl_waitoff(current_cursor);
		return ;
	end        
	set(findobj(Figadvlongrange,'Tag','EditText_cwt_nname'),'String', cwt_in_name) ;     


  case 'radiobutton_findmax'
	FindMax = get(gcbo,'Value') ;
        if FindMax == 1
          obj=findobj(Figadvlongrange,'Tag','Radiobutton_adv_longrange_findmax') ;
	  set(obj,'String','Yes') ;
        elseif FindMax == 0
	  obj=findobj(Figadvlongrange,'Tag','Radiobutton_adv_longrange_findmax') ;
	  set(obj,'String','No') ;
	end


  case 'radiobutton_reg'

	Reg = get(gcbo,'Value') ;
	if Reg == 1 
	  set(gcbo,'String','Specify Regression Range') ;
	elseif Reg == 0
	  set(gcbo,'String','Full Range Regression') ;
	end


  case 'compute_H'

	current_cursor=fl_waiton;
	cwt_in = get(findobj(Figadvlongrange,'Tag','EditText_cwt_nname'),'String') ;
	eval(['global ' cwt_in]) ;
    CWTIN=cwt_in;
	cwt_in = eval(cwt_in) ;
	wt = cwt_in.coeff ;
	scale =  cwt_in.scale ;

	whichT = 0 ;

	obj=findobj(Figadvlongrange,'Tag','Radiobutton_adv_longrange_findmax') ;
	FindMax = get(obj,'Value') ;
	obj=findobj(Figadvlongrange,'Tag','Radiobutton_adv_longrange_reg') ;
	Reg = get(obj,'Value') ;
	obj=findobj(Figadvlongrange,'Tag','Radiobutton_adv_longrange_monolr') ;
	RegType = get(obj,'Value') ;
	switch RegType
	  case 1
	    RegParam{1} = 'ls' ;
	  case {2,3,4,5}
        RegParam = fl_getregparam(RegType,length(scale)) ;
     case {6,7}
        RegParam = fl_getregparam(RegType) ;   
	end
	
	[H,handlefig] = cwttrack(wt,scale,whichT,FindMax,Reg,8,1,1,RegParam{:}) ;
    
    chaine=['H=cwttrack(',CWTIN,...
                '.coeff,',CWTIN,'.scale,',num2str(whichT),',',num2str(FindMax),',',...
                num2str(Reg),',8,1,1,''',num2str(RegParam{:}),''');'];
    fl_diary(chaine)
        
    
    
    
        obj=findobj(Figadvlongrange,'Tag','EditText_adv_longrange_H') ;
	set(obj,'String',num2str(H)) ;
	if Reg
            h=guidata(handlefig);
            h.HandleOut=obj;
            guidata(handlefig,h);
        end
	
	

	fl_waitoff(current_cursor);

  case 'close'
        
	obj_reg = findobj('Tag','graph_reg') ;
	close(obj_reg) ;
	close(Figadvlongrange) ;
	
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


