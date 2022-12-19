function [varargout]=fl_pseudoaw_compute(varargin)
% Callback functions for pseudoaw GUI Environment.

% Modified by Christian Choque Cortez, December 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,pseudoaw_fig] = gcbo;

if ((isempty(pseudoaw_fig)) || (~strcmp(get(pseudoaw_fig,'Tag'),'Fig_gui_fl_pseudoaw')))
    pseudoaw_fig = findobj ('Tag','Fig_gui_fl_pseudoaw');
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
        N = length(SigIn); logN = round(log2(N)/2)+1;
        set(findobj(pseudoaw_fig,'Tag','EditText_input'),'String',SigIn_name);
        for i=1:logN-1
            varcellmin{i}=['2^(-' num2str(logN-i+1) ')'];
            varcellmax{i}=['2^(-' num2str(i) ')'];
        end
        set(findobj(pseudoaw_fig,'Tag','PopupMenu_fmin'),'String',varcellmin,'Value',1);
        set(findobj(pseudoaw_fig,'Tag','PopupMenu_fmax'),'String',varcellmax,'Value',1);
        set(findobj(pseudoaw_fig,'Tag','EditText_fmin'),'String',str2num(varcellmin{1})); %#ok<ST2NM>
        set(findobj(pseudoaw_fig,'Tag','EditText_fmax'),'String',0.5);
        set(findobj(pseudoaw_fig,'Tag','PopupMenu_voices'),'Value',7);
        set(findobj(pseudoaw_fig,'Tag','EditText_voices'),'String',128);
        set(findobj(pseudoaw_fig,'Tag','PopupMenu_distribution'),'Value',2);
        set(findobj(pseudoaw_fig,'Tag','EditText_kvalue'),'String',0);
        set(findobj(pseudoaw_fig,'Tag','PopupMenu_wavelet'),'Value',1);
        set(findobj(pseudoaw_fig,'Tag','StaticText_wave'),'Enable','off');
        set(findobj(pseudoaw_fig,'Tag','EditText_wave'),'Enable','off','String',0);
        set(findobj(pseudoaw_fig,'Tag','EditText_smooth'),'String',0);

    case 'popmenu_fmin'
        fmin_cell = get(gcbo,'String'); fmin_ind = get(gcbo,'Value');
        fmax_ind = get(findobj(pseudoaw_fig,'Tag','PopupMenu_fmax'),'Value');
        fmin_ind = trunc(fmin_ind,1,length(fmin_cell)-(fmax_ind-1));
        fmin_value = str2num(fmin_cell{fmin_ind}); %#ok<ST2NM>
        set(findobj(pseudoaw_fig,'Tag','PopupMenu_fmin'),'Value',fmin_ind);
        set(findobj(pseudoaw_fig,'Tag','EditText_fmin'),'String',fmin_value);
        
    case 'edit_fmin'
        fmin_value = str2double(get(gcbo,'String'));
        fmax_value = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_fmax'),'String')); 
        fmin_cell = get(findobj(pseudoaw_fig,'Tag','PopupMenu_fmin'),'String'); 
        fmin_ind = get(findobj(pseudoaw_fig,'Tag','PopupMenu_fmin'),'Value');
        if isnan(fmin_value)
            fmin_value = str2num(fmin_cell{fmin_ind}); %#ok<ST2NM>
            set(gcbo,'String',fmin_value);
        else
            fmin_value = trunc(fmin_value,0,fmax_value-0.01);
            set(gcbo,'String',fmin_value);
        end    
        
    case 'popmenu_fmax'
        fmax_cell = get(gcbo,'String'); fmax_ind = get(gcbo,'Value');
        fmin_ind = get(findobj(pseudoaw_fig,'Tag','PopupMenu_fmin'),'Value');
        fmax_ind = trunc(fmax_ind,1,length(fmax_cell)-(fmin_ind-1));
        fmax_value = str2num(fmax_cell{fmax_ind}); %#ok<ST2NM>
        set(findobj(pseudoaw_fig,'Tag','PopupMenu_fmax'),'Value',fmax_ind);
        set(findobj(pseudoaw_fig,'Tag','EditText_fmax'),'String',fmax_value);        
        
    case 'edit_fmax'
        fmax_value = str2double(get(gcbo,'String'));
        fmin_value = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_fmin'),'String')); 
        fmax_cell = get(findobj(pseudoaw_fig,'Tag','PopupMenu_fmax'),'String'); 
        fmax_ind = get(findobj(pseudoaw_fig,'Tag','PopupMenu_fmax'),'Value');
        if isnan(fmax_value)
            fmax_value = str2num(fmax_cell{fmax_ind}); %#ok<ST2NM>
            set(gcbo,'String',fmax_value);
        else
            fmax_value = trunc(fmax_value,fmin_value+0.01,0.5);
            set(gcbo,'String',fmax_value);
        end
        
    case 'popmenu_voices'
        voices_value = 2^get(gcbo,'Value');
        set(findobj(pseudoaw_fig,'Tag','EditText_voices'),'String',voices_value);
        
    case 'edit_voices'
        SigIn_name = get(findobj(pseudoaw_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]);
        voices = str2double(get(gcbo,'String'));
        if isnan(voices)
            voices = 2^(get(findobj(pseudoaw_fig,'Tag','PopupMenu_voices'),'Value'));
            set(gcbo,'String',voices);
        else
            voices = floor(trunc(voices,2,Inf));
            set(gcbo,'String',voices);
        end    
    
    case 'popmenu_distribution'
        distr_value = get(gcbo,'Value');
        switch distr_value
            case 1, set(findobj(pseudoaw_fig,'Tag','EditText_kvalue'),'String',-1);
            case 2, set(findobj(pseudoaw_fig,'Tag','EditText_kvalue'),'String',0);
            case 3, set(findobj(pseudoaw_fig,'Tag','EditText_kvalue'),'String',0.5);
            case 4, set(findobj(pseudoaw_fig,'Tag','EditText_kvalue'),'String',2);
        end
    
    case 'edit_kvalue'
        kvalue = str2double(get(gcbo,'String'));
        if isnan(kvalue)
            set(findobj(pseudoaw_fig,'Tag','PopupMenu_distribution'),'Value',2);
            set(gcbo,'String',0);
        else
            set(gcbo,'String',kvalue);
            if kvalue == -1, set(findobj(pseudoaw_fig,'Tag','PopupMenu_distribution'),'Value',1);
            elseif kvalue == 0, set(findobj(pseudoaw_fig,'Tag','PopupMenu_distribution'),'Value',2);
            elseif kvalue == 0.5, set(findobj(pseudoaw_fig,'Tag','PopupMenu_distribution'),'Value',3);
            elseif kvalue == 2, set(findobj(pseudoaw_fig,'Tag','PopupMenu_distribution'),'Value',4);
            end
        end
        
    case 'popmenu_wavelet'
        wavelet_value = get(gcbo,'Value');
        if wavelet_value ==  1
            set(findobj(pseudoaw_fig,'Tag','StaticText_wave'),'Enable','off');
            set(findobj(pseudoaw_fig,'Tag','EditText_wave'),'Enable','off','String',0);
        else
            set(findobj(pseudoaw_fig,'Tag','StaticText_wave'),'Enable','on');
            set(findobj(pseudoaw_fig,'Tag','EditText_wave'),'Enable','on','String',8);
        end
        
    case 'edit_wave'
        wave_value = str2double(get(gcbo,'String'));
        if isnan(wave_value)
            set(gcbo,'String',8);
        else
            wave_value = floor(trunc(wave_value,2,Inf));
            set(gcbo,'String',wave_value);
        end    
    
    case 'edit_smooth'
        smooth_value = str2double(get(gcbo,'String'));
        if isnan(smooth_value)
            set(gcbo,'String',0);
        else
            smooth_value = floor(trunc(smooth_value,0,Inf));
            set(gcbo,'String',smooth_value);
        end
        
    case 'compute'
        current_cursor = fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(pseudoaw_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(pseudoaw_fig,'Tag','Button_close'),'enable','off');
            set(findobj(pseudoaw_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Frequency, Voices, K, Wave and Smooth %%%%%
            Fmin = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_fmin'),'String'));
            Fmax = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_fmax'),'String'));
            Voices = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_voices'),'String'));
            Kvalue = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_kvalue'),'String'));
            Wave = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_wave'),'String'));
            Smooth = str2double(get(findobj(pseudoaw_fig,'Tag','EditText_smooth'),'String'));
            Waveparam = get(findobj(pseudoaw_fig,'Tag','PopupMenu_wavelet'),'Value');
                        
            %%%%% Perform the computation %%%%%
            OutputNamed = ['paw_' SigIn_Name];
            varnamed = fl_find_mnames(varargin{2},OutputNamed);
            eval(['global ' varnamed]);
            varargout{1} = varnamed;
            chaine_in = ['=pseudoaw(',SigIn_Name,',[',num2str(Fmin),',',num2str(Fmax),']',',',num2str(Voices)];
            
            if Waveparam == 1, chaine_in = [chaine_in,',''mexican'''];
            elseif Waveparam == 2, chaine_in = [chaine_in,',''morletr'',',num2str(Wave)];
            elseif Waveparam == 3, chaine_in = [chaine_in,',''morleta'',',num2str(Wave)]; 
            end
            
            chaine_in = [chaine_in,',''pseudo'',',num2str(Kvalue),',''smooth'',',num2str(Smooth)];
            
            chaine = [varnamed,chaine_in];
            chaine = [chaine,');'];
            eval(chaine);
            
            fl_diary(chaine);
            fl_addlist(0,varnamed);
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(pseudoaw_fig,'Tag','Button_close'),'enable','on');
            set(findobj(pseudoaw_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'  
        fl_doc pseudoaw
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_pseudoaw'));
        
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
