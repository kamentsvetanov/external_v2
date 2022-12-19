function [varargout] = fl_asmsynthesis_compute(varargin)
% Callback functions for asmsynthesis GUI Environment.

% Author Christian Choque Cortez, May 2008.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,asmsynthesis_fig] = gcbo;

if ((isempty(asmsynthesis_fig)) || (~strcmp(get(asmsynthesis_fig,'Tag'),'Fig_gui_fl_asmsynthesis')))
    asmsynthesis_fig = findobj ('Tag','Fig_gui_fl_asmsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'motion_option'
        if ~get(findobj(asmsynthesis_fig,'Tag','RadioButton_motion'),'Value')
            set(findobj(asmsynthesis_fig,'Tag','RadioButton_motion'),'Value',1);
        end
        set(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value',0);
        set(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value',0);
        set(findobj(asmsynthesis_fig,'Tag','StaticText_parameter'),'String','Beta (Skewness)');
        set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Enable','on','Value',0.0,'Min',-1.0,'Max',1.0);
        set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',0.0);
        set(findobj(asmsynthesis_fig,'Tag','StaticText_cutoff'),'Enable','off');
        set(findobj(asmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','off','String','');
        set(findobj(asmsynthesis_fig,'Tag','StaticText_step'),'Enable','off');
        set(findobj(asmsynthesis_fig,'Tag','EditText_step'),'Enable','off','String','');
        
    case 'linfrac_option'
        if ~get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value')
            set(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value',1);
        end
        set(findobj(asmsynthesis_fig,'Tag','RadioButton_motion'),'Value',0);
        set(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value',0);
        set(findobj(asmsynthesis_fig,'Tag','StaticText_parameter'),'String','H  (self-similarity)');
        alpha_value = get(findobj(asmsynthesis_fig,'Tag','Slider_alpha'),'Value');
        set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Enable','on','Value',0.5,'Min',0.0,'Max',1.0);
        set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',0.5);
        if get(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Value') == 1/alpha_value
            set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Enable','on','Value',0.5 - 0.02,'Min',0.0,'Max',1.0);
            set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',0.5 - 0.02);
        end
        set(findobj(asmsynthesis_fig,'Tag','StaticText_cutoff'),'Enable','on');
        nn = get(findobj(asmsynthesis_fig,'Tag','PopupMenu_sample'),'Value');
        set(findobj(asmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',3*2^(nn-1));
        set(findobj(asmsynthesis_fig,'Tag','StaticText_step'),'Enable','on');
        set(findobj(asmsynthesis_fig,'Tag','EditText_step'),'Enable','on','String',32);
        
    case 'ornhulen_option'
        if ~get(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
            set(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value',1);
        end
        set(findobj(asmsynthesis_fig,'Tag','RadioButton_motion'),'Value',0);
        set(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value',0);
        set(findobj(asmsynthesis_fig,'Tag','StaticText_parameter'),'String','Lambda');
        set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Enable','off','Min',0.0,'Max',1e10);
        set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',0.1);
        set(findobj(asmsynthesis_fig,'Tag','StaticText_cutoff'),'Enable','on');
        nn = get(findobj(asmsynthesis_fig,'Tag','PopupMenu_sample'),'Value');
        set(findobj(asmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',6*2^(nn-1));
        set(findobj(asmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on');
        set(findobj(asmsynthesis_fig,'Tag','StaticText_step'),'Enable','on');
        set(findobj(asmsynthesis_fig,'Tag','EditText_step'),'Enable','on','String',32);
        
    case 'slider_alpha'
        slider_value = get(gcbo,'Value');
        set(findobj(asmsynthesis_fig,'Tag','EditText_alpha'),'String',slider_value);
        param_value = get(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Value');
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value') && param_value == 1/slider_value
            set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Enable','on','Value',param_value - 0.02);
            set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',param_value - 0.02);
        end

    case 'edit_alpha'
        alpha_value = str2double(get(gcbo,'String'));
        param_value = get(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Value');
        if isnan(alpha_value)
            alpha_value = 1.5;
            set(gcbo,'String',alpha_value);
            set(findobj(asmsynthesis_fig,'Tag','Slider_alpha'),'Value',alpha_value);
        else
            alpha_value = trunc(alpha_value,0.0,2.0);
            set(gcbo,'String',alpha_value);
            set(findobj(asmsynthesis_fig,'Tag','Slider_alpha'),'Value',alpha_value);
        end
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value') && param_value == 1/alpha_value
            set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Enable','on','Value',param_value - 0.02);
            set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',param_value - 0.02);
        end
        
    case 'popmenu_sample'
        sample_value = 250*2^(get(gcbo,'Value')-1);
        set(findobj(asmsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value')
            set(findobj(asmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',3*2^(get(gcbo,'Value')-1));
        elseif get(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
            set(findobj(asmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',6*2^(get(gcbo,'Value')-1));
        end

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 250*2^(get(findobj(asmsynthesis_fig,'Tag','PopupMenu_sample'),'Value')-1);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end    

    case 'slider_parameter'
        slider_value = get(gcbo,'Value');
        alpha_value = get(findobj(asmsynthesis_fig,'Tag','Slider_alpha'),'Value');
        set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',slider_value);
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value') && slider_value == 1/alpha_value
            fl_warning('H must be in (0,1) different to 1/Alpha !'); pause(.3);
            set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Value',slider_value - 0.02);
            set(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String',slider_value - 0.02);
        end

    case 'edit_parameter'
        parameter_value = str2double(get(gcbo,'String'));
        Hldmotion = get(findobj(asmsynthesis_fig,'Tag','RadioButton_motion'),'Value');
        Hldornhulen = get(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value');
        alpha_value = get(findobj(asmsynthesis_fig,'Tag','Slider_alpha'),'Value');
        if isnan(parameter_value)
            if Hldornhulen, parameter_value = 1;
            elseif Hldmotion, parameter_value = 0;
            else parameter_value = 0.5;
            end
        else
            if Hldornhulen, parameter_value = max(0,parameter_value);
            elseif Hldmotion, parameter_value = trunc(parameter_value,-1.0,1.0);
            else parameter_value = trunc(parameter_value,0.0,1.0);
            end
        end
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value') && parameter_value == 1/alpha_value
            fl_warning('H must be in (0,1) different to 1/Alpha !'); pause(.3);
            parameter_value = parameter_value - 0.02;
        end
        set(gcbo,'String',parameter_value);
        set(findobj(asmsynthesis_fig,'Tag','Slider_parameter'),'Value',parameter_value);
                
    case 'edit_cutoff'
        cutoff_value = str2double(get(gcbo,'String'));
        nn = get(findobj(asmsynthesis_fig,'Tag','PopupMenu_sample'),'Value');
        if isnan(cutoff_value) && get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value')
            set(gcbo,'String',3*2^(nn-1));
        elseif isnan(cutoff_value) && get(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
            set(gcbo,'String',6*2^(nn-1));
        else
            cutoff_value = floor(max(1,cutoff_value));
            set(gcbo,'String',cutoff_value);
        end

    case 'edit_step'
        step_value = str2double(get(gcbo,'String')) ;
        if isnan(step_value)
            set(gcbo,'String',32);
        else
            step_value = floor(max(1,step_value));
            set(gcbo,'String',step_value);
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
        set(findobj(asmsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(asmsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Alpha, N sample and parameter(Beta,H or Lambda) %%%%%
        Alpha = str2double(get(findobj(asmsynthesis_fig,'Tag','EditText_alpha'),'String'));
        Nsamp = str2double(get(findobj(asmsynthesis_fig,'Tag','EditText_sample'),'String'));
        Param = str2double(get(findobj(asmsynthesis_fig,'Tag','EditText_parameter'),'String'));        
        
        %%%%% Get Cut-off parameter, Discretization step and Seed %%%%%
        Cutoff = str2double(get(findobj(asmsynthesis_fig,'Tag','EditText_cutoff'),'String'));
        Step = str2double(get(findobj(asmsynthesis_fig,'Tag','EditText_step'),'String'));
        Seed = str2double(get(findobj(asmsynthesis_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Look for option %%%%%
        Hldmotion = get(findobj(asmsynthesis_fig,'Tag','RadioButton_motion'),'Value');
        Hldlinfrac = get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value');
        Hldornhulen = get(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value');

        %%%%% Perform the computation %%%%%
        if Hldmotion
            OutputNameasm = 'asm_levy';    
            chaine_in = ['=asmlevy(',num2str(Nsamp),',',num2str(Alpha),',',num2str(Param)];
        end
        
        if Hldlinfrac
            OutputNameasm = 'asm_linfrac';    
            chaine_in = ['=asmlinfrac(',num2str(Nsamp),',',num2str(Alpha), ...
                         ',',num2str(Param),',',num2str(Cutoff),',',num2str(Step)];
        end
        
        if Hldornhulen
            OutputNameasm = 'asm_ornhulen';    
            chaine_in = ['=asmornhulen(',num2str(Nsamp),',',num2str(Alpha), ...
                         ',',num2str(Param),',',num2str(Cutoff),',',num2str(Step)];
        end
        
        varname = fl_find_mnames(varargin{2},OutputNameasm);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        if ~isnan(Seed), chaine_in = [chaine_in,',',num2str(Seed)]; end
        
        chaine = [varname, chaine_in,');'];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(asmsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(asmsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_motion'),'Value')
            fl_doc asmlevy 
        end
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_linfrac'),'Value')
            fl_doc asmlinfrac 
        end
        if get(findobj(asmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
            fl_doc asmornhulen 
        end
        
    case 'close'  
        close(findobj(asmsynthesis_fig,'Tag', 'Fig_gui_fl_asmsynthesis'));

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
