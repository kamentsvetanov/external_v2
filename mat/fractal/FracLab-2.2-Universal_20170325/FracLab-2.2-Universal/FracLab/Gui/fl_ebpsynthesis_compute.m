function [varargout]=fl_ebpsynthesis_compute(varargin)
% Callback functions for ebpsynthesis GUI Environment.

% Modified By W. Arroum
% Modified by Christian Choque Cortez, June 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,ebpsynthesis_fig] = gcbo;

if ((isempty(ebpsynthesis_fig)) || (~strcmp(get(ebpsynthesis_fig,'Tag'),'Fig_gui_fl_ebpsynthesis')))
    ebpsynthesis_fig = findobj ('Tag','Fig_gui_fl_ebpsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'slider_hurst'
        slider_value = get(gcbo,'Value');
        set(findobj(ebpsynthesis_fig,'Tag','EditText_hurst'),'String',trunc(slider_value,0.01,1.0));
        
    case 'edit_hurst'
        hurst_value = str2double(get(gcbo,'String'));
        if isnan(hurst_value)
            hurst_value = 0.5;
            set(gcbo,'String',hurst_value);
            set(findobj(ebpsynthesis_fig,'Tag','Slider_hurst'),'Value',hurst_value);
        else
            hurst_value = trunc(hurst_value,0.01,1.0);
            set(gcbo,'String',hurst_value);
            set(findobj(ebpsynthesis_fig,'Tag','Slider_hurst'),'Value',hurst_value);
        end

    case 'edit_maxvar'
        max_value = str2double(get(gcbo,'String')) ;
        if isnan(max_value)
            set(gcbo,'String','');
        else
            max_value = round(trunc(max_value,1,Inf));%round(max(1,max_value));
            set(gcbo,'String',max_value);
        end

    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(ebpsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);
        
    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(ebpsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end    

    case 'edit_seed'
        seed_value = str2double(get(gcbo,'String'));
        if isnan(seed_value)
            set(gcbo,'String','');
        else
            seed_value = trunc(floor(seed_value),0,16777216);
            set(gcbo,'String',seed_value);
        end

    case 'compute'
        current_cursor=fl_waiton;
        
        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(ebpsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(ebpsynthesis_fig,'Tag','Button_compute'),'enable','off');
        
        %%%%% Get Hurst parameter, N sample, Max var and Seed %%%%%
        Hexp = str2double(get(findobj(ebpsynthesis_fig,'Tag','EditText_hurst'),'String'));
        Nsamp = str2double(get(findobj(ebpsynthesis_fig,'Tag','EditText_sample'),'String'));
        Maxvar = str2double(get(findobj(ebpsynthesis_fig,'Tag','EditText_maxvar'),'String'));
        Seed = str2double(get(findobj(ebpsynthesis_fig,'Tag','EditText_seed'),'String'));
         
        %%%%% Perform the computation %%%%%
        OutputNameebp = 'ebp';
        varname = fl_find_mnames(varargin{2},OutputNameebp);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        chaine_in = ['=ebpsimulate(',num2str(Nsamp),',',num2str(Hexp)];
        if ~isnan(Maxvar), chaine_in = [chaine_in,',''maxvar'',',num2str(Maxvar)]; end
        if ~isnan(Seed), chaine_in = [chaine_in,',''seed'',',num2str(Seed)]; end
        
        chaine = [varname,chaine_in,');'];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
         %%%%%% Enable close and compute %%%%%%%%
        set(findobj(ebpsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(ebpsynthesis_fig,'Tag','Button_compute'),'enable','on');
        
   case 'help'  
        fl_doc ebpsimulate
   
   case 'close'  
        close(findobj(ebpsynthesis_fig,'Tag', 'Fig_gui_fl_ebpsynthesis'));

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
