function [varargout] = fl_wsamod_compute(varargin)
% Callback functions for wsamod GUI Environment.

% Modified by Pierrick Legrand, December 2001
% Modified by Christian Choque Cortez, April 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,wsamod_fig] = gcbo;

if ((isempty(wsamod_fig)) || (~strcmp(get(wsamod_fig,'Tag'),'Fig_gui_fl_wsamod')))
    wsamod_fig = findobj ('Tag','Fig_gui_fl_wsamod');
end;

fl_clearerror;
switch(varargin{1})
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('input signal must be a vector !');
            return
        end
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name); N = length(SigIn);
        if log2(N) ~= floor(log2(N))
            fl_warning('Input vector length must be a power of 2!');
            return
        end
        set(findobj(wsamod_fig,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj(wsamod_fig,'Tag','EditText_scale'),'String',round(log2(N))-1);

    case 'edit_scale'
        scale_value = str2double(get(gcbo,'String'));
        SigIn_name = get(findobj(wsamod_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]); SigIn = eval(SigIn_name); nn = length(SigIn);
        if isnan(scale_value)
            set(gcbo,'String',round(log2(nn))-1);
        else
            scale_value = round(trunc(scale_value,3,round(log2(nn))-1));
            set(gcbo,'String',scale_value);
        end
    
    case 'edit_threshold'
        maxerr = str2double(get(gcbo,'String'));
        if isnan(maxerr)
            fl_warning('The threshold value must be a positive real'); pause(.3);
            set(gcbo,'String',10);
        else
            maxerr = trunc(maxerr,0.0,Inf);
            set(gcbo,'String',maxerr);
        end
        
    case 'edit_cmin'
        c_min = str2double(get(gcbo,'String'));
        c_max = str2double(get(findobj(wsamod_fig,'Tag','EditText_cmax'),'String'));
        if isnan(c_min)
            fl_warning('The minimum value must be a positive real'); pause(.3);
            set(gcbo,'String',0.1);
            set(findobj(wsamod_fig,'Tag','EditText_cmax'),'String',1);
        else            
            c_min = trunc(c_min,0.0,c_max-0.1);
            set(gcbo,'String',c_min);
        end

    case 'edit_cmax'
        c_max = str2double(get(gcbo,'String'));
        c_min = str2double(get(findobj(wsamod_fig,'Tag','EditText_cmin'),'String'));
        if isnan(c_max)
            fl_warning('The maximum value must be a positive real'); pause(.3);
            set(gcbo,'String',1);
            set(findobj(wsamod_fig,'Tag','EditText_cmin'),'String',0.1);
        else
            c_max = trunc(c_max,c_min+0.1,Inf);
            set(gcbo,'String',num2str(c_max));
        end

    case 'compute'
        current_cursor = fl_waiton;
        SigIn_name = get(findobj(wsamod_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_name)
            fl_warning('Input image must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(wsamod_fig,'Tag','Button_close'),'enable','off');
            set(findobj(wsamod_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get wave order %%%%%
            wave_type = get(findobj(wsamod_fig,'Tag','PopupMenu_wavelet'),'Value');
            f1 = ['MakeQMF(''daubechies'',',num2str(wave_type*2),');'];
            
            %%%%%% Get Scale Threshold Cmin and Cmax %%%%%%%%
            Scale = str2double(get(findobj(wsamod_fig,'Tag','EditText_scale'),'String'));
            Maxerr = str2double(get(findobj(wsamod_fig,'Tag','EditText_threshold'),'String'));
            Cmin = str2double(get(findobj(wsamod_fig,'Tag','EditText_cmin'),'String'));
            Cmax = str2double(get(findobj(wsamod_fig,'Tag','EditText_cmax'),'String'));
            
            %%%%% Perform the computation %%%%%
            OutputName = ['wsa_' SigIn_name];
            varname = fl_findname(OutputName,varargin{2});
            eval(['global ' varname]);
            varargout{1} = varname;
            chaine_in = ['=wsamod(',SigIn_name,',Q,''scale'',',num2str(Scale),',''threshold'',',num2str(Maxerr),...
                        ',''limits'',[',num2str(Cmin),',',num2str(Cmax),']'];
            
            chaine1 = ['Q=',f1];        
            eval(chaine1);
            chaine2 = ['[',varname,',count]',chaine_in,');'];
            eval(chaine2);
            chaine = [varname,chaine_in,');'];
            
            %%%%% Display the result of count %%%%%
            set(findobj(wsamod_fig,'Tag','EditText_count'),'String',num2str(count));
            
            fl_diary(chaine1);
            fl_diary(chaine);
            fl_addlist(0,varname) ;
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(wsamod_fig,'Tag','Button_close'),'enable','on');
            set(findobj(wsamod_fig,'Tag','Button_compute'),'enable','on');
        end

    case 'help'
        fl_doc wsamod
        
    case 'close'
        close(findobj('Tag','Fig_gui_fl_wsamod'));
        
end
end
%--------------------------------------------------------------------------
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
end