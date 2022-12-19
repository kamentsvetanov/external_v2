function [varargout]=fl_hexposc_compute(varargin)
% FILE:	  fl_hexposc_compute.m
% DESCRIPTON:	This file handles the callbacks for the gui_fl_hexposc module

% NOTES: 1.  a lot of the popup functionality depends on the index of the popup
%            selection - not very robust

% Author Jon C. Weil, Cambridge CB1 2NU, June 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

varOutstring=[];

% [objTmp,fig] = gcbo;
hexposc_fig = gcf;
if ((isempty(hexposc_fig)) | (~strcmp(get(hexposc_fig,'Tag'),'Fig_gui_fl_hexposc')))
  hexposc_fig = findobj ('Tag','Fig_gui_fl_hexposc');
end



switch(varargin{1})


  case 'editNmin'
	value=str2num(get(gcbo,'String'));
	value=floor(value);
	fl_clearerror;
	inputName=get(findobj(hexposc_fig,'Tag','txt_inputSignal'),'String');
	if isempty(inputName)
	  fl_warning('Input signal must be initiated: Refresh!');
	else 
	  if(value<2)
	    value=2;
	  else
	    eval(['global ' inputName]);
	    eval(['N = max(size(' inputName '));']);
	    if(value>N/3)
	      value=floor(N/3);
	    end 
	  end
	  set(gcbo,'String',num2str(value));
	end
	
  %% Handle popup callbacks  NOTE:  dependent on INDEX not STRING...	
  case 'ppm_oscest'
	index=get(gcbo,'Value');
	values=get(gcbo,'String');
	ppm_ballseq_hndl=findobj(hexposc_fig,'Tag','popmen_ballseq');
	popmen_ballseq_val=get(ppm_ballseq_hndl,'Value');
	% Disabled till it is implemented in the computation
	%if(index == 1)	   
	%   if(popmen_ballseq_val ~= 1)
	%        set(ppm_ballseq_hndl,'Value',1);
	%        ToggleRegSeqParams( hexposc_fig,'on' );
	%   end;
	%else
	%   if(popmen_ballseq_val == 1)
	%        set(ppm_ballseq_hndl,'Value',2);
	%        ToggleRegSeqParams( hexposc_fig,'off' );
	%   end;	   
	%end;
	
  case 'ppm_ballseq'
	index=get(gcbo,'Value');
	values=get(gcbo,'String');
	ppm_oscest_hndl=findobj(hexposc_fig,'Tag','popmen_oscest');
	popmen_oscest_val=get(ppm_oscest_hndl,'Value');
	if( index == 1)	   
	   if(popmen_oscest_val ~= 1)
	        set(ppm_oscest_hndl,'Value',1);
	        ToggleRegSeqParams( hexposc_fig,'on' );
	   end;
	else
	   if(popmen_oscest_val == 1)
	        set(ppm_oscest_hndl,'Value',2);
	        ToggleRegSeqParams( hexposc_fig,'off' );
	   end;	   
	end;
	
%  case 'ppm_Nmin'
%	index=get(gcbo,'Value');
%	values=get(gcbo,'String');
%	set(findobj(hexposc_fig,'Tag','EditText_Nmin_oscP'),'String',values{index});
	  
  case 'editNmax'
	value=str2num(get(gcbo,'String'));
	value=floor(value);
	fl_clearerror;
	inputName=get(findobj(hexposc_fig,'Tag','txt_inputSignal'),'String');
	if isempty(inputName)
	  fl_warning('Input signal must be initiated: Refresh!');
	else 
	  eval(['global ' inputName]);
	  eval(['N = max(size(' inputName '));']);
	  valuemin=str2num(get(findobj(hexposc_fig,'Tag','edt_minrad'),'String'));
	  if(value<valuemin)
	    value=valuemin;
	  else
	    if(value>2*N/3)
	      value=floor(2*N/3);
	    end 
	  end
	  set(gcbo,'String',num2str(value));
	end
      
%  case 'ppm_Nmax'
%	index=get(gcbo,'Value');
%	values=get(gcbo,'String');
%	set(findobj(hexposc_fig,'Tag','edt_maxrad'),'String',values{index});

	
case 'refresh'
	fl_clearerror;
	[inputName flag_error]=fl_get_input('matrix');
	
	if flag_error
	  fl_warning('input signal must be a matrix !');
	else 
	  eval(['global ' inputName]);
	  eval(['[n,p] = size(' inputName ');']);
	  
	  %%%%%%%%%%%%%%% input frame %%%%%%%%%%%
	  %set(findobj(hexposc_fig,'Tag','EditText_size_oscP'), ... 
	  %    'String',[num2str(n),'x',num2str(p)]);
	  set(findobj(hexposc_fig,'Tag','txt_inputSignal'), 'String', inputName);
	  
  
	  
	  %%%%%%%%%%%%%%% regression frame %%%%%%%%%%%
	  %set(findobj(hexposc_fig,'Tag','PopupMenu_regtype_oscP'), ... 
	  %    'Value',1);
	  
  
	end
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'compute'

	current_cursor=fl_waiton;
	
	%%%%% First get the input %%%%%%
	fl_clearerror;
	inputName=get(findobj(hexposc_fig,'Tag','txt_inputSignal'),'String');

	if isempty(inputName)
	  fl_warning('Input signal must be initiated: Refresh!');
	  fl_waitoff(current_cursor);
	else
	  eval(['global ' inputName]);
	  
	  %%%%%% Disable close and compute %%%%%%%%
	  set(findobj(hexposc_fig,'Tag','pshbut_close'),'enable','off');
	  set(findobj(hexposc_fig,'Tag','pshbut_compute'),'enable','off');
	  
	  %% get method 
	  name_method_strings =	  get(findobj(hexposc_fig,'Tag','popmen_oscest'),'String');
	  name_method_index   =	  get(findobj(hexposc_fig,'Tag','popmen_oscest'),'Value');
	  name_method = name_method_strings{name_method_index};

	  switch(name_method)
	    case 'P(Osc_cont | Osc_disc)',
	      est_type = 'CgivenD';
	    case 'Osc. Uniform Prior',
	      est_type = 'UniOscPri';
	    case 'Local Time Prior',
	       est_type = 'LocTimPri';
	   end
	   
	  %% Load windows file. Has to be customized later
	  %%winvector = load('TestRegSeq');
	  %% Load the vector from a file is a Bad Idea (tm), it would
	  %% be very difficult to distribute with FracLab.
	  winvector = [5, 3; 7, 3; 9, 5; 17, 9; 19, 7; 21, 11; 25, 13; 29, 15; 31, 11; 33, 17; 37, 19; 41, 21; 43, 15; 49, 25; 55, 19; 65, 33];
	  
	  %% Set bin width. Has to be customized later
	  binwidth = 0.001;
	  
	  
	  %%%%% regression argument %%%%%
	  RegType=get(findobj(hexposc_fig,'Tag','popmen_regression'),'Value');
	  %RegParam = fl_getregparam(RegType,voices);
	  %RegParam = fl_getregparam('ls');
	  RegParam{1} = 'ls';
	  %%%%% Perform the computation %%%%%
	  OutputName=['hxo_' inputName];
	  varname = fl_findname(OutputName,varargin{2});
	  eval(['global ' varname]);
	  varargout{1}=varname;
	  %	  eval([varname '=oscpholder(', inputName, ',Nmin,Nmax,RegParam{:});']);
	  eval([varname ' = hexposc (', inputName, ', winvector, binwidth, est_type, RegParam{:});']);
	  fl_addlist(0,varname) ;	  
	  	  	  
	  fl_waitoff(current_cursor);
	  %%%%%% Enable close and compute %%%%%%%%
	  set(findobj(hexposc_fig,'Tag','pshbut_close'),'enable','on');
	  set(findobj(hexposc_fig,'Tag','pshbut_compute'),'enable','on');
	  
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
	h=findobj('tag', 'Fig_gui_fl_hexposc');
	close(h);
	
  case 'help'
        helpwin gui_fl_hexposc_help

        
end



function ToggleRegSeqParams( hexposc_fig, RegVis )
	if( strcmp(RegVis, 'on') )
		FancyVis = 'off';
	else
		FancyVis = 'on';
	end
        set( findobj(hexposc_fig,'Tag','pshbut_loadradii'),'Visible',FancyVis); 
    	set( findobj(hexposc_fig,'Tag','pshbut_editradii'),'Visible',FancyVis); 
 	set( findobj(hexposc_fig,'Tag','edt_radii'),'Visible',FancyVis); 
 	set( findobj(hexposc_fig,'Tag','txt_maxrad'),'Visible',RegVis); 
 	set( findobj(hexposc_fig,'Tag','txt_minrad'),'Visible',RegVis); 
   	set( findobj(hexposc_fig,'Tag','edt_maxrad'),'Visible',RegVis); 
 	set( findobj(hexposc_fig,'Tag','edt_minrad'),'Visible',RegVis); 












