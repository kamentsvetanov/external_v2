function [varargout]=fl_mfdpumping2d_compute(varargin)
% Callback functions for mfdpumping2d GUI Environment.

% Author Pierrick Legrand, September 2002
% Modified by Pierrick Legrand, January 2005
% Modified by Christian Choque Cortez, May 2010

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mfdpumping2d_fig] = gcbo;

if ((isempty(mfdpumping2d_fig)) || (~strcmp(get(mfdpumping2d_fig,'Tag'),'Fig_gui_fl_mfdpumping2d')))
    mfdpumping2d_fig = findobj ('Tag','Fig_gui_fl_mfdpumping2d');
end;

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
        [N1,N2] = size(SigIn); N = max(N1,N2); 
        set(findobj(mfdpumping2d_fig,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj(mfdpumping2d_fig,'Tag','EditText_regularity'),'String','0.5');
        set(findobj(mfdpumping2d_fig,'Tag','EditText_level'),'String',floor(log2(N)/2));
    
    case 'edit_regularity'
        reg_value = str2double(get(gcbo,'String'));
        if isnan(reg_value)
            set(gcbo,'String',0.5);
        else
            set(gcbo,'String',reg_value);
        end
        
    case 'edit_level'
        level_value = str2double(get(gcbo,'String'));
        SigIn_name = get(findobj(mfdpumping2d_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name);
        [N1,N2] = size(SigIn); N = max(N1,N2); 
        if isnan(level_value)
            level_value = floor(log2(N)/2); %#ok<ST2NM>
            set(gcbo,'String',level_value);
        else
            level_value = round(trunc(level_value,1,floor(log2(N))));
            set(gcbo,'String',level_value);
        end    
                
    case 'compute'
        current_cursor = fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(mfdpumping2d_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(mfdpumping2d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(mfdpumping2d_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Regularity and Level %%%%%
            Regularity = str2double(get(findobj(mfdpumping2d_fig,'Tag','EditText_regularity'),'String'));
            Level = str2double(get(findobj(mfdpumping2d_fig,'Tag','EditText_level'),'String'));
            
            %%%%% Get wave order %%%%%
            wave_type = get(findobj(mfdpumping2d_fig,'Tag','PopupMenu_wavelet'),'Value');
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
            
            %%%%% Perform the computation %%%%%
            OutputNamet = ['mfdpump_' SigIn_Name];
            varnamet = fl_find_mnames(varargin{2},OutputNamet);
            eval(['global ' varnamet]);
            varargout{1} = varnamet;
            chaine_in = ['=mfdpumping2d(',SigIn_Name,',Q', ...
                ',''increase'',',num2str(Regularity),',''level'',',num2str(Level)];
            
            chaine1 = ['Q=',f1];
            eval(chaine1);
            
            chaine = [varnamet,chaine_in];
            chaine = [chaine,');'];
            eval(chaine);
            
            fl_diary(chaine1);
            fl_diary(chaine);
            fl_addlist(0,varnamet);
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(mfdpumping2d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(mfdpumping2d_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'  
        fl_doc mfdpumping2d
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_mfdpumping2d'));
        
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
