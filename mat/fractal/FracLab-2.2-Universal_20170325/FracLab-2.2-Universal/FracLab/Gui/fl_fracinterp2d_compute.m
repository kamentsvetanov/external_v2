function [varargout]=fl_fracinterp2d_compute(varargin)
% Callback function for Hölderian Interpolation GUI

% Author Pierrick Legrand, January 2005
% Modified by Christian Choque Cortez, May 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,fracinterp2d_fig] = gcbo;

if ((isempty(fracinterp2d_fig)) || (~strcmp(get(fracinterp2d_fig,'Tag'),'Fig_gui_fl_fracinterp2d')))
    fracinterp2d_fig = findobj ('Tag','Fig_gui_fl_fracinterp2d');
end

fl_clearerror;
switch(varargin{1});
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('matrix');
        if error_in
            fl_warning('input signal must be a matrix !') ;
            return
        end
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name);
        [N1,N2] = size(SigIn);
        if (mod(log2(N1),2) ~= 0 && mod(log2(N1),2) ~= 1) || (mod(log2(N2),2) ~= 0 && mod(log2(N2),2) ~= 1)
            fl_warning('The sizes of the input signal must a power of 2!') ;
            return
        end
        set(findobj(fracinterp2d_fig,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj(fracinterp2d_fig,'Tag','EditText_ninterp'),'String',1);
        set(findobj(fracinterp2d_fig,'Tag','EditText_min'),'String',2);
        set(findobj(fracinterp2d_fig,'Tag','EditText_max'),'String',log2(min(N1,N2)));

    case 'edit_ninterp'
        ni_value = str2double(get(gcbo,'String'));
        if isnan(ni_value)
            fl_warning('Number of interpolation must be an integer!'); pause(.3);
            set(gcbo,'String',1);
        else
            ni_value = round(trunc(ni_value,1,Inf));
            set(gcbo,'String',ni_value);
        end
        
    case 'edit_min'
        min_value = str2double(get(gcbo,'String'));
        if isnan(min_value)
            fl_warning('Start level must be an integer !'); pause(.3);
            set(gcbo,'String',2);
        else
            max_value = str2double(get(findobj(fracinterp2d_fig,'Tag','EditText_max'),'String'));
            min_value = floor(trunc(min_value,2,max_value-1));
            set(gcbo,'String',min_value);
        end
        
    case 'edit_max'
        max_value = str2double(get(gcbo,'String'));
        SigIn_name = get(findobj(fracinterp2d_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]);
        SigIn = eval(SigIn_name);
        [N1,N2] = size(SigIn);
        if isnan(max_value)
            fl_warning('End level must be an integer !'); pause(.3);
            set(gcbo,'String',log2(min(N1,N2)));
        else
            min_value = str2double(get(findobj(fracinterp2d_fig,'Tag','EditText_min'),'String'));
            max_value = floor(trunc(max_value,min_value+1,log2(min(N1,N2))));
            set(gcbo,'String',max_value);
        end

    case 'compute'
        current_cursor = fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(fracinterp2d_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(fracinterp2d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(fracinterp2d_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Ni and Levels %%%%%
            Ni = str2double(get(findobj(fracinterp2d_fig,'Tag','EditText_ninterp'),'String'));
            Lmin = str2double(get(findobj(fracinterp2d_fig,'Tag','EditText_min'),'String'));
            Lmax = str2double(get(findobj(fracinterp2d_fig,'Tag','EditText_max'),'String'));        
            Waveparam = get(findobj(fracinterp2d_fig,'Tag','PopupMenu_wavelet'),'String');
            
            %%%%% Perform the computation %%%%%
            OutputNameI = ['interp_' SigIn_Name];
            varnameI = fl_find_mnames(varargin{2},OutputNameI);
            eval(['global ' varnameI]);
            varargout{1} = varnameI;
            chaine_in = ['=fracinterp2d(',SigIn_Name,',',num2str(Ni),',''', ...
                         Waveparam{1},''',''levels'',[',num2str(Lmin),',',num2str(Lmax),']'];
            
            chaine = [varnameI,chaine_in];
            chaine = [chaine,');'];
            eval(chaine);
            
            fl_diary(chaine);
            fl_addlist(0,varnameI);
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(fracinterp2d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(fracinterp2d_fig,'Tag','Button_compute'),'enable','on');
        end

    case 'help'
        fl_doc fracinterp2d

    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_fracinterp2d'));
        
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
