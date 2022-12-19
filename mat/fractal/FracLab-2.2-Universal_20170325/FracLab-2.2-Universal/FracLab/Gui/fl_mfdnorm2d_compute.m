function [varargout]=fl_mfdnorm2d_compute(varargin)
% Callback functions for mfdnorm2d GUI Environment.

% Author Pierrick Legrand, January 2005
% Modified by Christian Choque Cortez, May 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mfdnorm2d_fig] = gcbo;

if ((isempty(mfdnorm2d_fig)) || (~strcmp(get(mfdnorm2d_fig,'Tag'),'Fig_gui_fl_mfdnorm2d')))
    mfdnorm2d_fig = findobj ('Tag','Fig_gui_fl_mfdnorm2d');
end

fl_clearerror;
switch(varargin{1})
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('matrix');
        if error_in
            fl_warning('input signal must be a matrix !') ;
            return
        end
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name);
        [N1,N2] = size(SigIn); N = max(N1,N2); 
        set(findobj(mfdnorm2d_fig,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj(mfdnorm2d_fig,'Tag','EditText_regularity'),'String','0.5');
        set(findobj(mfdnorm2d_fig,'Tag','Check_noise'),'Value',0);
        set(findobj(mfdnorm2d_fig,'Tag','EditText_noise'),'String','0.5','Enable','on');
        set(findobj(mfdnorm2d_fig,'Tag','EditText_level'),'String',1+round(log2(N)/2));
    
    case 'edit_regularity'
        reg_value = str2double(get(gcbo,'String'));
        if isnan(reg_value)
            set(gcbo,'String',0.5);
        else
            reg_value = trunc(reg_value,0,Inf);
            set(gcbo,'String',reg_value);
        end
    
    case 'check_noise'
        if ~get(gcbo,'Value')
            set(findobj(mfdnorm2d_fig,'Tag','Check_noise'),'String','Noise std');
            set(findobj(mfdnorm2d_fig,'Tag','EditText_noise'),'String','0.5','Enable','on');
        else
            set(findobj(mfdnorm2d_fig,'Tag','Check_noise'),'String','Automatic');
            set(findobj(mfdnorm2d_fig,'Tag','EditText_noise'),'String','','Enable','off');
        end
    
    case 'edit_noise'
        std_value = str2double(get(gcbo,'String'));
        if isnan(std_value)
            set(gcbo,'String',0.5);
        else
            std_value = trunc(std_value,0,Inf);
            set(gcbo,'String',std_value);
        end
        
    case 'edit_level'
        level_value = str2double(get(gcbo,'String'));
        SigIn_name = get(findobj(mfdnorm2d_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name);
        [N1,N2] = size(SigIn); N = max(N1,N2);
        if isnan(level_value)
            level_value = 1+round(log2(N)/2);
            set(gcbo,'String',level_value);
        else
            level_value = round(trunc(level_value,1+round(log2(N)/2),floor(log2(N))));
            set(gcbo,'String',level_value);
        end    
            
    case 'compute'
        current_cursor = fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(mfdnorm2d_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(mfdnorm2d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(mfdnorm2d_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Regularity and Level %%%%%
            Regularity = str2double(get(findobj(mfdnorm2d_fig,'Tag','EditText_regularity'),'String'));
            Level = str2double(get(findobj(mfdnorm2d_fig,'Tag','EditText_level'),'String'));
            Noise = str2double(get(findobj(mfdnorm2d_fig,'Tag','EditText_noise'),'String'));
            
            %%%%% Get wave order %%%%%
            wave_type = get(findobj(mfdnorm2d_fig,'Tag','PopupMenu_wavelet'),'Value');
            switch wave_type
                case 11
                    f1 = 'MakeQMF(''coiflet'',6);';
                case 12
                    f1 = 'MakeQMF(''coiflet'',12);';
                case 13
                    f1 = 'MakeQMF(''coiflet'',18);';
                case 14
                    f1 = 'MakeQMF(''coiflet'',24);';
                otherwise
                    f1 = ['MakeQMF(''daubechies'',',num2str(wave_type*2),');'];
            end
            
            %%%%% Look for option %%%%%
            Hldnoise = get(findobj(mfdnorm2d_fig,'Tag','Check_noise'),'Value');
            
            %%%%% Perform the computation %%%%%
            OutputNamet = ['mfdnol_' SigIn_Name];
            varnamet = fl_find_mnames(varargin{2},OutputNamet);
            eval(['global ' varnamet]);
            varargout{1} = varnamet;
            chaine_in = ['=mfdnorm2d(',SigIn_Name,',Q', ...
                ',''increase'',',num2str(Regularity),',''level'',',num2str(Level)];
            
            if Hldnoise
                chaine_in = [chaine_in,',''autonoise'''];
            else
                chaine_in = [chaine_in,',''noise'',',num2str(Noise)];
            end

            chaine1 = ['Q=',f1];
            eval(chaine1);
            
            if Hldnoise
                chaine2 = ['[',varnamet,',Noise]',chaine_in,');'];
                eval(chaine2);
                set(findobj(mfdnorm2d_fig,'Tag','EditText_noise'),'String',Noise);
            end
            
            chaine = [varnamet,chaine_in];
            chaine = [chaine,');'];
            eval(chaine);
            
            fl_diary(chaine1);
            fl_diary(chaine);
            fl_addlist(0,varnamet);
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(mfdnorm2d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(mfdnorm2d_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'  
        fl_doc mfdnorm2d
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_mfdnorm2d'));
        
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
