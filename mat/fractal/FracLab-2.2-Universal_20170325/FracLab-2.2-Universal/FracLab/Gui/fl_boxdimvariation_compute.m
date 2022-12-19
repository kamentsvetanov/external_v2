function dim=fl_boxdimvariation_compute(command)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

varOutstring=[];

% [objTmp,fig] = gcbo;
boxdimvariation_fig = gcf;
if ((isempty(boxdimvariation_fig)) | (~strcmp(get(boxdimvariation_fig,'Tag'),'Fig_gui_fl_boxdimvariation')))
  boxdimvariation_fig = findobj ('Tag','Fig_gui_fl_boxdimvariation');
end

switch(command)    
case('editMinScale');
case('editMaxScale');
case('refresh');
	fl_clearerror;
	[input_sig flag_error]=fl_get_input('matrix');
    if flag_error
        [input_sig flag_error]=fl_get_input('vector');
    end
    if flag_error
        fl_warning('input signal must be a vector or a matrix !');
    else
        handles=guihandles(boxdimvariation_fig);
        set(handles.EditText_sig_nname,'String',input_sig);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute boxdimvariation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'compute_boxdimvariation'

    %%%% Get GUI handles %%%%%%% 
    handles=guihandles(boxdimvariation_fig);
    
    %%%% Clear error messages %%%%%%%
    fl_clearerror;
    
    %%%%% Get input arguments                       %%%%%%%%%
    input_sig=get(handles.EditText_sig_nname,'String');
    MinScale=get(handles.MinScale,'String');
    MaxScale=get(handles.MaxScale,'String');
    reg=get(handles.Radiobutton_reg,'Value');
    RegType=get(handles.PopupMenu_regtype,'Value');
    RegParam =fl_getregparam2(RegType);
    % Convert strings to numerical values
    MinScale=str2num(MinScale);
    MaxScale=str2num(MaxScale);

    %%%%%%%%%%%%%%%%%     Check inputs separately    %%%%%%%%%%%%%%%%%%%%%%
    % Check MinScale
    if isempty(MinScale)
        fl_warning('min scale must be a >0 number')
    elseif max(size(MinScale))>1
        fl_warning('min scale must be a >0 number')
    elseif (MinScale<=0)
        fl_warning('min scale must be a >0 number')
    end
    % Check MaxScale
    if isempty(MaxScale)
        fl_warning('max scale must be a >0 number')
    elseif max(size(MaxScale))>1
        fl_warning('max scale must be a >0 number')
    elseif (MaxScale<=0)
        fl_warning('max scale must be a >0 number')
    end
    % Check and get GLOBAL Input Signal
    if isempty(input_sig)
        fl_warning('Input signal must be initiated: Refresh!');
    else
        SignIn=evalin('base',input_sig);
        current_cursor=fl_waiton;

	    %%%%%%%%%%%%% Check relations between inputs  %%%%%%%%%%%%%%%%%%%%%%%%%
	    sth=get(findobj('Tag','StaticText_error'),'String');
	    if size(sth,1)==0                       % Every input must be correct 
	        % Check Scales
	        if MaxScale<=MinScale
	            fl_warning('Max Scale must be bigger than Min Scale')
	        end
	    end
	    
	    %%%%%%%%%%%%%%  Computes function arguments %%%%%%%%%%%%%%%%%%%%%%
	    sth=get(findobj('Tag','StaticText_error'),'String');
	    if size(sth,1)==0                       % Every input must be correct 
	        
	        %%%%% Where to display the result %%%%%
	        obj=handles.EditText_boxdimvariation;
	        %%%%% Disable close and compute %%%%%%%%
	        set(handles.Pushbutton_wclose,'enable','off');
	        set(handles.Pushbutton_boxdimvariation_compute,'enable','off');
	        %%%%% Perform the computation %%%%%
	        
	        %[dim,nb,handlefig]=boxdimvariation_binaire(SignIn,box_size,AspectRatio,reg,RegParam{:});
	        [dim,handlefig]=fl_dimfractale2(SignIn,MinScale,MaxScale,0,1,reg,RegParam{:});
	                
	        set(obj,'String',num2str(dim));
	        if reg
           		h=guidata(handlefig);
            		h.HandleOut=obj;
            		guidata(handlefig,h);
        	end
	        
	        fl_waitoff(current_cursor);
	        %%%%%% Enable close and compute %%%%%%%%
	        set(findobj(boxdimvariation_fig,'Tag','Pushbutton_wclose'),'enable','on');
	        set(findobj(boxdimvariation_fig,'Tag','Pushbutton_boxdimvariation_compute'),'enable','on');
	    end
	end

%%%%%%%%% LOCAL SCALING PARAMETERS %%%%%%%%%%%%
  case 'radiobutton_reg'
	Reg = get(gcbo,'Value') ;
	if Reg == 1 
	  set(gcbo,'String','Specify') ;
	elseif Reg == 0
	  set(gcbo,'String','Automatic') ;
	end
	
  case 'close'
    fl_clearerror;
    close (boxdimvariation_fig);
	
  case 'help'
        fl_doc help_fdim;
end