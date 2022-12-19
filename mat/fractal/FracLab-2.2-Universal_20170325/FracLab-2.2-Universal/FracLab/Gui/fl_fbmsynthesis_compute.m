function [varargout] = fl_fbmsynthesis_compute(varargin)
% Callback functions for fbmsynthesis GUI Environment.

% Modified by Christian Choque Cortez, March 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,fbmsynthesis_fig] = gcbo;

if ((isempty(fbmsynthesis_fig)) || (~strcmp(get(fbmsynthesis_fig,'Tag'),'Fig_gui_fl_fbmsynthesis')))
    fbmsynthesis_fig = findobj ('Tag','Fig_gui_fl_fbmsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'woodchan_option'
        if ~get(findobj(fbmsynthesis_fig,'Tag','RadioButton_woodchan'),'Value')
            set(findobj(fbmsynthesis_fig,'Tag','RadioButton_woodchan'),'Value',1);
        end
        set(findobj(fbmsynthesis_fig,'Tag','RadioButton_levinson'),'Value',0);
        
    case 'levinson_option'
        if ~get(findobj(fbmsynthesis_fig,'Tag','RadioButton_levinson'),'Value')
            set(findobj(fbmsynthesis_fig,'Tag','RadioButton_levinson'),'Value',1);
        end
        set(findobj(fbmsynthesis_fig,'Tag','RadioButton_woodchan'),'Value',0);
        
    case 'slider_exponent'
        slider_value = get(gcbo,'Value');
        set(findobj(fbmsynthesis_fig,'Tag','EditText_exponent'),'String',slider_value);

    case 'edit_exponent'
        exponent_value = str2double(get(gcbo,'String'));
        if isnan(exponent_value)
            exponent_value = 0.5;
            set(gcbo,'String',exponent_value);
            set(findobj(fbmsynthesis_fig,'Tag','Slider_exponent'),'Value',exponent_value);
        else
            exponent_value = trunc(exponent_value,0.0,1.0);
            set(gcbo,'String',exponent_value);
            set(findobj(fbmsynthesis_fig,'Tag','Slider_exponent'),'Value',exponent_value);
        end
        
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(fbmsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(fbmsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end    
	
    case 'edit_tmax'
        tmax_value = str2double(get(gcbo,'String')) ;
        if isnan(tmax_value)
            set(gcbo,'String',1);
        else
            tmax_value = max(0,tmax_value);
            set(gcbo,'String',tmax_value);
        end

    case 'edit_sigma'
        sigma_value = str2double(get(gcbo,'String')) ;
        if isnan(sigma_value)
            set(gcbo,'String',1);
        else
            sigma_value = max(0,sigma_value);
            set(gcbo,'String',sigma_value);
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
        %%%%% Get Holder exponent and N sample %%%%%
        Hexp = str2double(get(findobj(fbmsynthesis_fig,'Tag','EditText_exponent'),'String'));
        Nsamp = str2double(get(findobj(fbmsynthesis_fig,'Tag','EditText_sample'),'String'));
                
        %%%%% Get Tmax Sigma and Seed %%%%%
        Tmax = str2double(get(findobj(fbmsynthesis_fig,'Tag','EditText_tmax'),'String'));
        Sigma = str2double(get(findobj(fbmsynthesis_fig,'Tag','EditText_sigma'),'String'));
        Seed = str2double(get(findobj(fbmsynthesis_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Look for option %%%%%
        Hldwood = get(findobj(fbmsynthesis_fig,'Tag','RadioButton_woodchan'),'Value');

        %%%%% H in the interval (0,1) %%%%%
        if Hexp <= 0 || Hexp > 1
           fl_warning('H must be in the interval (0,1).');
           varargout{1} = 'ans';
           return;
        end
     
        %%%%%% Disable close and compute %%%%%%%%
        current_cursor=fl_waiton;
        set(findobj(fbmsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(fbmsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Perform the computation %%%%%
        if Hldwood
            OutputNamefbm = 'fbmwch';    
            chaine_in = ['=fbmwoodchan(',num2str(Nsamp),',',num2str(Hexp)];
        else
            OutputNamefbm = 'fbmlev';
            chaine_in = ['=fbmlevinson(',num2str(Nsamp),',',num2str(Hexp)];
        end
        
        varname = fl_find_mnames(varargin{2},OutputNamefbm);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        chaine_in = [chaine_in,',''support'',',num2str(Tmax),',''sigma'',',num2str(Sigma)];
        if ~isnan(Seed), chaine_in = [chaine_in,',''seed'',',num2str(Seed)]; end
        
        chaine = [varname,chaine_in,');'];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(fbmsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(fbmsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        Hldwood = get(findobj(fbmsynthesis_fig,'Tag','RadioButton_woodchan'),'Value');
        if Hldwood
            fl_doc fbmwoodchan
        else
            fl_doc fbmlevinson
        end
        
    case 'close'  
        close(findobj(fbmsynthesis_fig,'Tag', 'Fig_gui_fl_fbmsynthesis'));

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
