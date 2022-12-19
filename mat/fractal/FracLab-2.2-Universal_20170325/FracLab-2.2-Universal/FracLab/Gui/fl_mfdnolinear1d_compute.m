function [varargout]=fl_mfdnolinear1d_compute(varargin)
% Callback functions for mfdnolinear1d GUI Environment.

% Author Pierrick Legrand, July 2004
% Modified by Pierrick Legrand, January 2005
% Modified by Christian Choque Cortez, May 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mfdnolinear1d_fig] = gcbo;

if ((isempty(mfdnolinear1d_fig)) || (~strcmp(get(mfdnolinear1d_fig,'Tag'),'Fig_gui_fl_mfdnolinear1d')))
    mfdnolinear1d_fig = findobj ('Tag','Fig_gui_fl_mfdnolinear1d');
end

fl_clearerror;
switch(varargin{1});
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('input signal must be a vector !') ;
            return
        end
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name);
        N = length(SigIn); 
        set(findobj(mfdnolinear1d_fig,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj(mfdnolinear1d_fig,'Tag','EditText_regularity'),'String','0.5');
        set(findobj(mfdnolinear1d_fig,'Tag','Check_threshold'),'Value',0);
        set(findobj(mfdnolinear1d_fig,'Tag','EditText_threshold'),'String','0.5','Enable','on');
        set(findobj(mfdnolinear1d_fig,'Tag','EditText_level'),'String',floor(log2(N)/2));
    
    case 'edit_regularity'
        reg_value = str2double(get(gcbo,'String'));
        if isnan(reg_value)
            set(gcbo,'String',0.5);
        else
            set(gcbo,'String',reg_value);
        end
    
    case 'check_threshold'
        if ~get(gcbo,'Value')
            set(findobj(mfdnolinear1d_fig,'Tag','Check_threshold'),'String','Threshold');
            set(findobj(mfdnolinear1d_fig,'Tag','EditText_threshold'),'String','0.5','Enable','on');
        else
            set(findobj(mfdnolinear1d_fig,'Tag','Check_threshold'),'String','Automatic');
            set(findobj(mfdnolinear1d_fig,'Tag','EditText_threshold'),'String','','Enable','off');
        end
    
    case 'edit_threshold'
        thrs_value = str2double(get(gcbo,'String'));
        if isnan(thrs_value)
            set(gcbo,'String','0.5');
        else
            thrs_value = trunc(thrs_value,0,Inf);
            set(gcbo,'String',thrs_value);
        end
        
    case 'edit_level'
        level_value = str2double(get(gcbo,'String'));
        SigIn_name = get(findobj(mfdnolinear1d_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name);
        N = length(SigIn); 
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
        SigIn_Name = get(findobj(mfdnolinear1d_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(mfdnolinear1d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(mfdnolinear1d_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Regularity and Level %%%%%
            Regularity = str2double(get(findobj(mfdnolinear1d_fig,'Tag','EditText_regularity'),'String'));
            Level = str2double(get(findobj(mfdnolinear1d_fig,'Tag','EditText_level'),'String'));
            Threshold = str2double(get(findobj(mfdnolinear1d_fig,'Tag','EditText_threshold'),'String'));
            
            %%%%% Get wave order %%%%%
            wave_type = get(findobj(mfdnolinear1d_fig,'Tag','PopupMenu_wavelet'),'Value');
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
            Hldtrshld = get(findobj(mfdnolinear1d_fig,'Tag','Check_threshold'),'Value');
            
            %%%%% Perform the computation %%%%%
            OutputNamet = ['mfdnol_' SigIn_Name];
            varnamet = fl_find_mnames(varargin{2},OutputNamet);
            eval(['global ' varnamet]);
            varargout{1} = varnamet;
            chaine_in = ['=mfdnolinear1d(',SigIn_Name,',Q', ...
                ',''increase'',',num2str(Regularity),',''level'',',num2str(Level)];
            
            if Hldtrshld
                chaine_in = [chaine_in,',''autothreshold'''];
            else
                chaine_in = [chaine_in,',''threshold'',',num2str(Threshold)];
            end

            chaine1 = ['Q=',f1];
            eval(chaine1);
            
            if Hldtrshld
                chaine2 = ['[',varnamet,',Threshold]',chaine_in,');'];
                eval(chaine2);
                set(findobj(mfdnolinear1d_fig,'Tag','EditText_threshold'),'String',Threshold);
            end
            
            chaine = [varnamet,chaine_in];
            chaine = [chaine,');'];
            eval(chaine);
            
            fl_diary(chaine1);
            fl_diary(chaine);
            fl_addlist(0,varnamet);
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(mfdnolinear1d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(mfdnolinear1d_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'  
        fl_doc mfdnolinear1d
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_mfdnolinear1d'));
        
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
