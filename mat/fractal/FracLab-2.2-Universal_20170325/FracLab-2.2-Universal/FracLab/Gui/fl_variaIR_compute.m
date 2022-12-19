function [varargout]=fl_variaIR_compute(varargin)
% Callback functions for estimGQV1DH GUI Environment.

% Modified by Christian Choque Cortez, December 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,variaIR_fig] = gcbo;

if ((isempty(variaIR_fig)) || (~strcmp(get(variaIR_fig,'Tag'),'Fig_gui_fl_variaIR')))
    variaIR_fig = findobj ('Tag','Fig_gui_fl_variaIR');
end;

fl_clearerror;
switch(varargin{1});
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('input signal must be a vector !') ;
            return
        end
        eval(['global ' SigIn_name]);
        set(findobj(variaIR_fig,'Tag','Edit_input'),'String',SigIn_name);

    case 'edit_winsize'
        winsize_value = str2double(get(gcbo,'String'));
        if isnan(winsize_value)
            fl_warning('Window size must be real !'); pause(.3);
            set(gcbo,'String',0.35);
        else
            winsize_value = max(0.05,winsize_value);
            winsize_value = min(0.95,winsize_value);
            set(gcbo,'String',winsize_value);
        end    
        set(findobj(variaIR_fig,'Tag','Slide_winsize'),'Value',winsize_value);
        
    case 'slider_winsize'
        winsize_value = get(gcbo,'Value');
        set(findobj(variaIR_fig,'Tag','Edit_winsize'),'String',winsize_value);
    
    case 'compute'
        current_cursor=fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(variaIR_fig,'Tag','Edit_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(variaIR_fig,'Tag','Button_close'),'enable','off');
            set(findobj(variaIR_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Winsize %%%%%
            winsize = get(findobj(variaIR_fig,'Tag','Slide_winsize'),'Value');
        
            %%%%% Perform the computation %%%%%
            OutputNameH = ['estim_H_' SigIn_Name]; 
            varnameH = fl_find_mnames(varargin{2},OutputNameH);
            eval(['global ' varnameH]); 
            varargout{1} = [varnameH];
            chaine_in = ['=flVariaIR(',SigIn_Name,',',num2str(winsize),');'];
            chaine = [varnameH,chaine_in];
            
            eval(chaine);
            
            fl_addlist(0,varnameH);
            fl_diary(chaine);
            fl_waitoff(current_cursor);
        
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(variaIR_fig,'Tag','Button_close'),'enable','on');
            set(findobj(variaIR_fig,'Tag','Button_compute'),'enable','on');
        end
        
        
    case 'help'  
        fl_doc flvariaIR
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_variaIR'));
        
end
end
