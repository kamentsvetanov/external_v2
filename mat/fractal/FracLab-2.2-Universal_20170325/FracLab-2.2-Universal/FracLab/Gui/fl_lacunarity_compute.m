function [varargout] = fl_lacunarity_compute(varargin)
% Callback functions for lacunarity GUI Environment.

% Author Karine CHRISTOPHE, April 2003
% Modified by Pierrick LEGRAND, January 2005
% Modified by Christian Choque Cortez, November 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,lacunarity_fig] = gcbo;

if ((isempty(lacunarity_fig)) || (~strcmp(get(lacunarity_fig,'Tag'),'Fig_gui_fl_lacunarity')))
    lacunarity_fig = findobj ('Tag','Fig_gui_fl_lacunarity');
end;

fl_clearerror;
switch(varargin{1})
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('matrix');
        if error_in
            fl_warning('input signal must be a matrix !');
            return
        end
        eval(['global ' SigIn_name]);
        set(findobj(lacunarity_fig,'Tag','EditText_input'),'String',SigIn_name);

    case 'edit_min'
        k_min = str2double(get(gcbo,'String'));
        if isnan(k_min)
            fl_warning('The minimum value must be a positive integer'); pause(.3);
            set(gcbo,'String',1);
        else
            k_max = str2double(get(findobj(lacunarity_fig,'Tag','EditText_max'),'String'));
            k_min = floor(trunc(k_min,1,k_max-1));
            set(gcbo,'String',k_min);
        end

    case 'edit_max'
        SigIn_name = get(findobj(lacunarity_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]); SigIn = eval(SigIn_name); N = min(size(SigIn));
        k_max = str2double(get(gcbo,'String'));
        if isnan(k_max)
            fl_warning('The maximum value must be a positive integer'); pause(.3);
            set(gcbo,'String',N);
        else
            k_min = str2double(get(findobj(lacunarity_fig,'Tag','EditText_min'),'String'));
            k_max = floor(trunc(k_max,k_min+1,N));
            set(gcbo,'String',num2str(k_max));
        end

    case 'edit_step'
        step = str2double(get(gcbo,'String'));
        if isnan(step)
            fl_warning('The step must be an integer'); pause(.3);
            set(gcbo,'String',1);
        else
            step = floor(max(1,step));
            set(gcbo,'String',step);
        end

    case 'check_mask'
        if ~get(gcbo,'Value')
            set(findobj(lacunarity_fig,'Tag','EditText_mask'),'string',[]);
            set(findobj(lacunarity_fig,'Tag','EditText_mask'),'enable','off');
            set(findobj(lacunarity_fig,'Tag','Button_refresh_mask'),'enable','off');
            set(findobj(lacunarity_fig,'Tag','Button_new_mask'),'enable','off');
        else
            set(findobj(lacunarity_fig,'Tag','EditText_mask'),'enable','on');
            set(findobj(lacunarity_fig,'Tag','Button_refresh_mask'),'enable','on');
            set(findobj(lacunarity_fig,'Tag','Button_new_mask'),'enable','on');
        end

    case 'refresh_mask'
        [Mask_name error_in] = fl_get_input('matrix');
        if error_in
            fl_warning('input signal must be a matrix !');
            return
        end
        eval(['global ' Mask_name]);
        set(findobj(lacunarity_fig,'Tag','EditText_mask'),'String',Mask_name);

        SigIn_name = get(findobj(lacunarity_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]); SigIn = eval(SigIn_name); [N1,N2] = size(SigIn);

        Mask_name = get(findobj(lacunarity_fig,'Tag','EditText_mask'),'String');
        eval(['global ',Mask_name]); SigIn_mask = eval(Mask_name); [M1,M2] = size(SigIn_mask);

        if (M1 ~= N1) || (M2 ~= N2)
            fl_warning('Input mask must be the same size than input signal');
            return
        end

    case 'new_mask'
        current_cursor = fl_waiton;
        SigIn_name = get(findobj(lacunarity_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_name)
            fl_warning('Input image must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(lacunarity_fig,'Tag','Button_close'),'enable','off');
            set(findobj(lacunarity_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%%% Create a mask %%%%%%%%%
            Out_name = ['mask_' SigIn_name];
            Mask_name = fl_findname(Out_name,varargin{2});
            eval(['global ' Mask_name]); eval(['global ' SigIn_name]);
            chaine = ['cropormask(' SigIn_name ',''' Mask_name ''',''mask'');'];
            eval(chaine);
            varargout{1} = Mask_name;
            set(findobj(lacunarity_fig,'Tag','EditText_mask'),'String',Mask_name);
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(lacunarity_fig,'Tag','Button_close'),'enable','on');
            set(findobj(lacunarity_fig,'Tag','Button_compute'),'enable','on');
        end

    case 'compute'
        current_cursor = fl_waiton;
        SigIn_name = get(findobj(lacunarity_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_name)
            fl_warning('Input image must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_name]);
            if sum(sum(SigIn_name)) == 0
                fl_warning('Input signal must not be a uniformly black image')
            end
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(lacunarity_fig,'Tag','Button_close'),'enable','off');
            set(findobj(lacunarity_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%%% Get Min Max and Step %%%%%%%%
            k_min = str2double(get(findobj(lacunarity_fig,...
                    'Tag','EditText_min'),'String'));
            k_max = str2double(get(findobj(lacunarity_fig,...
                    'Tag','EditText_max'),'String'));
            step = str2double(get(findobj(lacunarity_fig,...
                    'Tag','EditText_step'),'String'));
            
            %%%%% Look for option %%%%%
            Hldmask = get(findobj(lacunarity_fig,...
                         'Tag','Check_mask'),'Value');
            
            Mask_name = get(findobj(lacunarity_fig,'Tag','EditText_mask'),'String');
            if ~isempty(Mask_name), eval(['global ',Mask_name]); end
            
            %%%%% Perform the computation %%%%%
            OutputName = ['lac_' SigIn_name];
            varnameL = fl_findname(OutputName,varargin{2});
            eval(['global ' varnameL]);
            varargout{1} = varnameL;
            chaine_in = ['=lacunarity(',SigIn_name,...
                        ',[',num2str(k_min),':',num2str(step),':',num2str(k_max),']'];
            
            if Hldmask, chaine_in = [chaine_in,',''mask'',',Mask_name]; end
            
            chaine = [varnameL,chaine_in,');'];
            eval(chaine);
            
            fl_diary(chaine);
            eval ([varnameL '= struct (''type'',''graph'','...
                '''data1'',','[',num2str(k_min),':',num2str(step),':',num2str(k_max),']''',...
                ',''data2'',',varnameL,',''title'',[''Lacunarity''],'...
                '''xlabel'',''window size'',''ylabel'',''Lacunarity'');']);
            fl_addlist(0,varnameL) ;
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(lacunarity_fig,'Tag','Button_close'),'enable','on');
            set(findobj(lacunarity_fig,'Tag','Button_compute'),'enable','on');
        end

    case 'help'
        fl_doc lacunarity
        
    case 'close'
        close(findobj('Tag','Fig_gui_fl_lacunarity'));
        
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