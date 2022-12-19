function [varargout] = fl_weisynthesis_compute(varargin)
% Callback functions for weisynthesis GUI Environment.

% Author Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,weisynthesis_fig] = gcbo;

if ((isempty(weisynthesis_fig)) || (~strcmp(get(weisynthesis_fig,'Tag'),'Fig_gui_fl_weisynthesis')))
    weisynthesis_fig = findobj ('Tag','Fig_gui_fl_weisynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'standard_option'
        if ~get(findobj(weisynthesis_fig,'Tag','RadioButton_standard'),'Value')
            set(findobj(weisynthesis_fig,'Tag','RadioButton_standard'),'Value',1);
        end
        set(findobj(weisynthesis_fig,'Tag','RadioButton_generalized'),'Value',0);
        set(findobj(weisynthesis_fig,'Tag','StaticText_holder'),'String','Holder exponent');
        set(findobj(weisynthesis_fig,'Tag','Slider_exponent'),'Value',0.5,'Visible','on','Enable','on');
        set(findobj(weisynthesis_fig,'Tag','PopupMenu_exponent'),'Style','edit','Position',[0.81 0.61 0.15 0.075],'String','0.5');
        set(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String','','Enable','off');
        
    case 'generalized_option'
        if ~get(findobj(weisynthesis_fig,'Tag','RadioButton_generalized'),'Value')
            set(findobj(weisynthesis_fig,'Tag','RadioButton_generalized'),'Value',1);
        end
        set(findobj(weisynthesis_fig,'Tag','RadioButton_standard'),'Value',0);
        set(findobj(weisynthesis_fig,'Tag','StaticText_holder'),'String','Holder function');
        set(findobj(weisynthesis_fig,'Tag','Slider_exponent'),'Visible','off','Enable','off');
        set(findobj(weisynthesis_fig,'Tag','PopupMenu_exponent'),'Style','popupmenu','Position',[0.59 0.61 0.37 0.075], ...
            'String',{'linear','periodic','logistic','piecewise constant','user defined'},'Value',1);
        set(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String','0.1+0.8*t','Enable','on');
    
    case 'slider_exponent'
        slider_value = get(gcbo,'Value');
        set(findobj(weisynthesis_fig,'Tag','PopupMenu_exponent'),'String',slider_value);
        
    case 'popmenu_exponent'
        Hldl = get(findobj(weisynthesis_fig,'Tag','RadioButton_standard'),'Value');
        if Hldl
            exponent_value = str2double(get(gcbo,'String'));
            if isnan(exponent_value)
                exponent_value = 0.5;
                set(gcbo,'String',exponent_value);
                set(findobj(weisynthesis_fig,'Tag','Slider_exponent'),'Value',exponent_value);
            else
                exponent_value = trunc(exponent_value,0.0,1.0);
                set(gcbo,'String',exponent_value);
                set(findobj(weisynthesis_fig,'Tag','Slider_exponent'),'Value',exponent_value);
            end
        else
            function_type = get(gcbo,'Value');
            switch function_type
                case 1
                    set(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String','0.1+0.8*t');
                    set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','on');
                    set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','on');
                case 2
                    set(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String','0.5+0.3*sin(4*pi*t)');
                    set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','on');
                    set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','on');
                case 3
                    set(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String','0.3+0.3./(1+exp(-100*(t-0.7)))');
                    set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','on');
                    set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','on');
                case 4
                    set(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String','[ones(1,N/2)*0.2 ones(1,N/2)*0.8]');
                    set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','on');
                    set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','on');
                case 5
                    set(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String','');
            end
        end
    
    case 'edit_fexponent'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_sample'),'String'));
        t = linspace(0,1,N); %#ok<NASGU>
        set(findobj(weisynthesis_fig,'Tag','PopupMenu_exponent'),'Value',3);
        try
            eval([function_value,';']);
            set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','on');
            set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','off');
            set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','off');
        end
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(weisynthesis_fig,'Tag','EditText_sample'),'String',sample_value);
        
    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(weisynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end
        	
    case 'edit_tmax'
        tmax_value = str2double(get(gcbo,'String'));
        if isnan(tmax_value)
            set(gcbo,'String',1);
        else
            tmax_value = round(trunc(tmax_value,1,Inf));
            set(gcbo,'String',tmax_value);
        end
        
    case 'edit_frequency'
        lambda_value = str2double(get(gcbo,'String'));
        if isnan(lambda_value)
            set(gcbo,'String',2);
        else
            lambda_value = trunc(lambda_value,1.01,Inf);
            set(gcbo,'String',lambda_value);
        end
        
    case 'edit_seed'
        seed_value = str2double(get(gcbo,'String'));
        if isnan(seed_value)
            set(gcbo,'String','');
        else
            seed_value = trunc(floor(seed_value),0,Inf);
            set(gcbo,'String',seed_value);
        end

    case 'edit_nterms'
        k_value = str2double(get(gcbo,'String'));
        if isnan(k_value)
            set(gcbo,'String',50);
        else
            k_value = round(max(1,k_value));
            set(gcbo,'String',k_value);
            N = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_sample'),'String'));
            tmax = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_tmax'),'String'));
            lambda = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_frequency'),'String'));
            nyquist = floor(log(N/2*tmax)/log(lambda));
            if k_value <= nyquist
                fl_warning(['N terms should be greater than the Nyquist value :',num2str(nyquist)],'black','');
            end
        end
        
    case 'compute'
        current_cursor=fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Holder exponent and N sample %%%%%
        Hexp = get(findobj(weisynthesis_fig,'Tag','PopupMenu_exponent'),'String');
        Hfunc = get(findobj(weisynthesis_fig,'Tag','EditText_fexponent'),'String');
        Nsamp = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_sample'),'String'));
        
        %%%%% Get Tmax Sigma and Seed %%%%%
        Tmax = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_tmax'),'String'));
        Lambda = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_frequency'),'String'));
        Kmax = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_nterms'),'String'));
        Seed = str2double(get(findobj(weisynthesis_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Look for option %%%%%
        Hldlocal = get(findobj(weisynthesis_fig,'Tag','RadioButton_standard'),'Value');

        %%%%% Perform the computation %%%%%
        if Hldlocal
            OutputNamewei = 'weis';
            chaine_in = ['=genewei(',num2str(Nsamp),',',num2str(Hexp)];
        else
            OutputNamewei = 'gweis';
            chaine_in = '=genegwei(N,Ht';
            chaine1 = ['N=',num2str(Nsamp),'; t=linspace(0,',num2str(Tmax),',N); Ht = eval(''' Hfunc ''');'];
            eval(chaine1);
            fl_diary(chaine1);
        end
        
        varname = fl_find_mnames(varargin{2},OutputNamewei);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        chaine_in = [chaine_in,',''support'',',num2str(Tmax),',''frequency'',',num2str(Lambda),',''nterms'',',num2str(Kmax)];
        if ~isnan(Seed), chaine_in = [chaine_in,',''seed'',',num2str(Seed)]; end
    
        chaine = [varname,chaine_in,');'];
        eval(chaine);        

        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(weisynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(weisynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        Hldlocal = get(findobj(weisynthesis_fig,'Tag','RadioButton_standard'),'Value');
        if Hldlocal
            fl_doc genewei
        else
            fl_doc genegwei
        end
        
    case 'close'  
        close(findobj(weisynthesis_fig,'Tag', 'Fig_gui_fl_weisynthesis'));

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
