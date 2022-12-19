function [varargout]=fl_dwt1d_compute(varargin)
% Callback functions for contwtc GUI Environment.

% Modified by Christian Choque Cortez, May 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,dwt1d_fig] = gcbo;

if ((isempty(dwt1d_fig)) || (~strcmp(get(dwt1d_fig,'Tag'),'Fig_gui_fl_dwt1d')))
    dwt1d_fig = findobj ('Tag','Fig_gui_fl_dwt1d');
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
        SigIn = eval(SigIn_name);
        N = length(SigIn); 
        set(findobj(dwt1d_fig,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj(dwt1d_fig,'Tag','EditText_octaves'),'String',round(log2(N)));
        set(findobj(dwt1d_fig,'Tag','Check_modulus'),'Value',0);
        
    case 'edit_octaves'
        octaves_value = str2double(get(gcbo,'String'));
        SigIn_name = get(findobj(dwt1d_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        SigIn = eval(SigIn_name);
        N = length(SigIn); 
        if isnan(octaves_value)
            octaves_value = round(log2(N)); %#ok<ST2NM>
            set(gcbo,'String',octaves_value);
        else
            octaves_value = round(trunc(octaves_value,1,log2(N)));
            set(gcbo,'String',octaves_value);
        end    
                
    case 'compute'
        current_cursor = fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(dwt1d_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(dwt1d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(dwt1d_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Frequency, Voices and Wave %%%%%
            Noctav = str2double(get(findobj(dwt1d_fig,'Tag','EditText_octaves'),'String'));
            
            %%%%% Get wave order %%%%%
            wave_type = get(findobj(dwt1d_fig,'Tag','PopupMenu_wavelet'),'Value');
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
            Hldabs = get(findobj(dwt1d_fig,'Tag','Check_modulus'),'Value');
            
            %%%%% Perform the computation %%%%%
            OutputNamet = ['dwt1d_' SigIn_Name]; OutputNamemt = ['mwt1d_' SigIn_Name];
            [varnamet varnamemt] = fl_find_mnames(varargin{2},OutputNamet,OutputNamemt);
            eval(['global ' varnamet]);
            varargout{1} = varnamet;
            chaine_in = ['=FWT(',SigIn_Name,',',num2str(Noctav),',Q,0,1'];
            
            chaine1 = ['Q=',f1];
            eval(chaine1);
            
            chaine = [varnamet,chaine_in];
            chaine = [chaine,');'];
            eval(chaine);
            
            fl_diary(chaine1);
            fl_diary(chaine);
            fl_addlist(0,varnamet);
            if Hldabs 
                eval(['global ' varnamemt]);
                varargout{1} = [varnamet ' ' varnamemt];
                chaine2 = [varnamemt,'.type=',varnamet,'.type;',varnamemt,'.wt=abs(',varnamet,'.wt);'];
                eval(chaine2);
                fl_addlist(0,varnamemt);
            end
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(dwt1d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(dwt1d_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'  
        fl_doc FWT
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_dwt1d'));
        
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
