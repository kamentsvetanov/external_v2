function [varargout]=fl_oscL_compute(varargin)
% Callback functions for oscL GUI

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

varOutstring=[];
%warning off;
% [objTmp,fig] = gcbo;
oscL_fig = gcf;
if ((isempty(oscL_fig)) | (~strcmp(get(oscL_fig,'Tag'),'Fig_gui_fl_oscL')))
  oscL_fig = findobj ('Tag','Fig_gui_fl_oscL');
end

% oscL_fig

switch(varargin{1})


%   case 'editNmin'
% 	value=str2num(get(gcbo,'String'));
% 	value=floor(value);
%     valueMax=str2num(get(findobj(oscL_fig,'Tag','EditText_Nmax_oscL'),'String'));
%     if value>valueMax
%         value=valueMax-1;
%         set(gcbo,'String',num2str(value));
%     end;    
% 	fl_clearerror;
% 	inputName=get(findobj(oscL_fig,'Tag','EditText_sig_nname_oscL'),'String');
% 	if isempty(inputName)
% 	  fl_warning('Input signal must be initiated: Refresh!');
% 	else 
% 	  if(value<2)
% 	    value=2;
% 	  else
% 	    eval(['global ',inputName]);
% 	    eval(['N = max(size(',inputName,'));']);
% 	    if(value>N/3)
% 	      value=floor(N/3);
% 	    end 
% 	  end
% 	  set(gcbo,'String',num2str(value));
% 	end
	
  case 'ppm_Nmin'
	index=get(gcbo,'Value');
	values=get(gcbo,'String');
    indexMax=get(findobj(oscL_fig,'Tag','PopupMenu_Nmax_oscL'),'Value');
	valuesMax=get(findobj(oscL_fig,'Tag','PopupMenu_Nmax_oscL'),'String');
    if index > indexMax
        index = indexMax;
        set(gcbo,'Value',index);
    end    
    set(findobj(oscL_fig,'Tag','EditText_Nmin_oscL'),'String',values{index});
	  
%   case 'editNmax'
% 	value=str2num(get(gcbo,'String'));
% 	value=floor(value);
%     valueMin=str2num(get(findobj(oscL_fig,'Tag','EditText_Nmin_oscL'),'String'));
%     if value<valueMin
%         value=valueMin+1;
%         set(gcbo,'String',num2str(value));
%     end;
% 	fl_clearerror;
% 	inputName=get(findobj(oscL_fig,'Tag','EditText_sig_nname_oscL'),'String');
% 	if isempty(inputName)
% 	  fl_warning('Input signal must be initiated: Refresh!');
% 	else 
% 	  eval(['global ' inputName]);
% 	  eval(['N = max(size(',inputName,'));']);
% 	  valuemin=str2num(get(findobj(oscL_fig,'Tag','EditText_Nmin_oscL'),'String'));
% 	  if(value<valuemin)
% 	    value=valuemin;
% 	  else
% 	    if(value>2*N/3)
% 	      value=floor(2*N/3);
% 	    end 
% 	  end
% 	  set(gcbo,'String',num2str(value));
% 	end
      
      case 'ppm_Nmax'
	index=get(gcbo,'Value');
	values=get(gcbo,'String');
    indexMin=get(findobj(oscL_fig,'Tag','PopupMenu_Nmin_oscL'),'Value');
	valuesMax=get(findobj(oscL_fig,'Tag','PopupMenu_Nmin_oscL'),'String');
    if index < indexMin
        index = indexMin;
        set(gcbo,'Value',index);
    end 
	set(findobj(oscL_fig,'Tag','EditText_Nmax_oscL'),'String',values{index});
    
    case 'voices'
	index=str2num(get(gcbo,'String'));
	indexMin=get(findobj(oscL_fig,'Tag','PopupMenu_Nmin_oscL'),'Value');
	indexMax=get(findobj(oscL_fig,'Tag','PopupMenu_Nmax_oscL'),'Value');
    if index > 2^(indexMax)-2^(indexMin-1)+1
        index = 2^(indexMax)-2^(indexMin-1)+1;
        set(gcbo,'String',num2str(index));
    end 
	%set(findobj(oscL_fig,'Tag','EditText_voices_oscL'),'String',num2str(index));

	% %%%%%%%%%%%%%%%%
      case 'editRho'
    fl_clearerror;      
	value=str2num(get(gcbo,'String'));
    if isempty(value) | value<1 
        fl_warning('Neighbourhood size is an integer >1');
        pause(.3);
        value=64;
        set(gcbo,'String',num2str(value));
    else    
	value=floor(value);
    set(gcbo,'String',num2str(value));
    end;
% 	fl_clearerror;
% 	valuemin=str2num(get(findobj(oscL_fig,'Tag','EditText_Rho_oscL'),'String'));
    
%     fl_clearerror;
%       level=str2num(get(gcbo,'String'));
%        if isempty(level) | level<1 | level > log2(N)
%          fl_warning('Level is an integer >1 and <log2(length(signal))!');
%          pause(.3);
%          level=(ceil(log2(N)/3));
%          set(gcbo,'String',num2str(level));
%        else 
%        level=floor(level);
%        set(gcbo,'String',num2str(level));
    
      
      case 'ppm_Rho'
	index=get(gcbo,'Value');
	values=get(gcbo,'String');
	set(findobj(oscL_fig,'Tag','EditText_Rho_oscL'),'String',values{index});
    
    
   case 'edit_time'
      [SigIn_name error_in] = fl_get_input ('vector') ;
      eval(['global ' SigIn_name]) ;
      SigIn = eval(SigIn_name) ;
      N = length(SigIn) ;
      fl_clearerror;      
	  value=str2num(get(gcbo,'String'));
      if isempty(value) | value<1 | value>N
        fl_warning('Time is an integer');
        pause(.3);
        value=floor(N/2);
        set(gcbo,'String',num2str(value));
     else    
	 value=floor(value);
     set(gcbo,'String',num2str(value));
     end; 
           
	% %%%%%%%%%%%%%


	
   case 'refresh'
	fl_clearerror;
	[inputName flag_error]=fl_get_input('vector');
    if flag_error
        fl_warning('input signal must be a vector !');
    else
        eval(['global ' inputName]);
        eval(['[n,p] = size(',inputName,');']);

        %%%%%%%%%%%%%%% input frame %%%%%%%%%%%
        set(findobj(oscL_fig,'Tag','EditText_size_oscL'), ...
            'String',[num2str(n),'x',num2str(p)]);
        set(findobj(oscL_fig,'Tag','EditText_sig_nname_oscL'), ...
            'String',inputName);




        %%%%%%%%%%%%%%% regression frame %%%%%%%%%%%
        set(findobj(oscL_fig,'Tag','PopupMenu_regtype_oscL'), ...
            'Value',6);

        %%%%%%%%%%%%% radiobuttons %%%%%%%%%%%%%%%
        %	  set(findobj(oscL_fig,'Tag','Radiobutton_reg_oscL'),'String','Specify');
        %	  set(findobj(oscL_fig,'Tag','Radiobutton_reg_oscL'),'Value',1);
        %	  set(findobj(oscL_fig,'Tag','Radiobutton_graphs_oscL'),'String','No regularized graphs');
        %	  set(findobj(oscL_fig,'Tag','Radiobutton_graphs_oscL'),'Value',0);

    end
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute oscL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'compute_oscL'

	current_cursor=fl_waiton;
	
	%%%%% First get the input %%%%%%
	fl_clearerror;
	inputName=get(findobj(oscL_fig,'Tag','EditText_sig_nname_oscL'),'String');
	if isempty(inputName)
	  fl_warning('Input signal must be initiated: Refresh!');
	  fl_waitoff(current_cursor);
	else
	  eval(['global ' inputName]);
	  
	  %%%%%% Disable close and compute %%%%%%%%
	  set(findobj(oscL_fig,'Tag','Pushbutton_wclose_oscL'),'enable','off');
	  set(findobj(oscL_fig,'Tag','Pushbutton_oscL_compute_oscL'),'enable','off');
	  
	  
	  %%%%% Get Nmin and Nmax %%%%%
	  eth=findobj(oscL_fig,'Tag','EditText_Nmin_oscL');
	  Nmin=str2num(get(eth,'String'));
	  eth=findobj(oscL_fig,'Tag','EditText_Nmax_oscL');
	  Nmax=str2num(get(eth,'String'));
	  %voices=Nmax-Nmin+1;
	  
	  eth = findobj(oscL_fig,'Tag','EditText_Rho_oscL');
	  rho=str2num(get(eth,'String'));
	  rho=floor(rho);
      
      %%%%% Get # of balls %%%%%%%%%%
      eth=findobj(oscL_fig,'Tag','EditText_voices_oscL');
      voices=str2num(get(eth,'String'));
	  
	  %%%%% regression argument %%%%%
	  RegType=get(findobj(oscL_fig,'Tag','PopupMenu_regtype_oscL'),'Value');
	  RegParam = fl_getregparam(RegType,voices);
	  
	  
     %%%%% Perform the computation %%%%%
     Hldfct=get(findobj(oscL_fig,'Tag','Radiobutton_adv_track_time'),'Value');
     Temps=get(findobj(oscL_fig,'Tag','EditText_adv_oscL_time'),'String');
     temps=str2num(Temps);
     if Hldfct==1  
	     OutputName=['phtL_' inputName];
	     varname = fl_findname(OutputName,varargin{2});
	     eval(['global ' varname]);
	     varargout{1}=varname;
	     eval([varname '=osclholder(', inputName, ',Nmin,Nmax,rho,voices, RegParam{:});']);
        
         chaine=[varname '=osclholder(', inputName,...
              ',',num2str(Nmin),',',num2str(Nmax),',',num2str(rho),',',num2str(voices),...
              ',''',num2str(RegParam{:}),''');'];
         fl_diary(chaine);
         
         fl_addlist(0,varname) ;
     else
	     OutputName=['phtL_' inputName];
	     varname = fl_findname(OutputName,varargin{2});
	     eval(['global ' varname]);
	     varargout{1}=varname;
         eval([varname '=osclholder2(', inputName, ',Nmin,Nmax,rho,temps,voices,RegParam{:});']); 
     
         chaine=[varname '=osclholder2(', inputName,...
              ',',num2str(Nmin),',',num2str(Nmax),',',num2str(rho),',',num2str(voices),...
              ',''',num2str(RegParam{:}),''');'];
         fl_diary(chaine);
     end;
	  %%%%% store the figure handles %%%%%
	  %global handlefig_oscL
	  %handlefig_oscL=[handlefig_oscL,handlefig];
	  
	  %%%%% Enable to print the new figures %%%%%
	  %if ~isempty(handlefig)
	  %  set(findobj(oscL_fig,'Tag','Pushbutton_wprint_oscL'),'enable','on');
	  %  set(findobj(oscL_fig,'Tag','EditFigHandle_oscL'),'enable','on');
	  %  set(findobj(oscL_fig,'Tag','EditFigHandle_oscL'),'String',num2str(handlefig(1)));
	  %end
	  
	  %%%%% Display the result %%%%%%%%%
	  %set(obj,'String',num2str(dim)) ;
	  
	  fl_waitoff(current_cursor);
	  %%%%%% Enable close and compute %%%%%%%%
	  set(findobj(oscL_fig,'Tag','Pushbutton_wclose_oscL'),'enable','on');
	  set(findobj(oscL_fig,'Tag','Pushbutton_oscL_compute_oscL'),'enable','on');
	  
	end
   
%%%%%%%%% LOCAL SCALING PARAMETERS %%%%%%%%%%%%

  case 'radiobutton_reg'
	Reg = get(gcbo,'Value') ;
	if Reg == 1 
	  set(gcbo,'String','Specify') ;
	elseif Reg == 0
	  set(gcbo,'String','Automatic') ;
	end
   
   case 'radiobutton_time'
	Reg = get(gcbo,'Value') ;
	if Reg == 1 
      set(gcbo,'String','Holder Function') ;
      set(findobj(oscL_fig,'Tag','StaticText1'),'enable','off');
      set(findobj(oscL_fig,'Tag','EditText_adv_oscL_time'),'enable','off');
	elseif Reg == 0
      set(gcbo,'String','Single time exponent') ;
      set(findobj(oscL_fig,'Tag','StaticText1'),'enable','on');
      set(findobj(oscL_fig,'Tag','EditText_adv_oscL_time'),'enable','on');
	end
 
	
  case 'close'
	h=findobj('tag', 'Fig_gui_fl_oscL');
	close(h);%warning backtrace;
	
  case 'help'
        helpwin gui_fl_oscL_help

        
end













