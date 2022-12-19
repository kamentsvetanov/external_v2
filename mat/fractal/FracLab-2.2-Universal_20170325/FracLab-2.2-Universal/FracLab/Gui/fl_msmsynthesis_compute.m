function [varargout] = fl_msmsynthesis_compute(varargin)
% Callback functions for msmsynthesis GUI Environment.

% Author Christian Choque Cortez, May 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,msmsynthesis_fig] = gcbo;

if ((isempty(msmsynthesis_fig)) || (~strcmp(get(msmsynthesis_fig,'Tag'),'Fig_gui_fl_msmsynthesis')))
    msmsynthesis_fig = findobj ('Tag','Fig_gui_fl_msmsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'levy_option'
        if ~get(findobj(msmsynthesis_fig,'Tag','RadioButton_levy'),'Value')
            set(findobj(msmsynthesis_fig,'Tag','RadioButton_levy'),'Value',1);
        end
        set(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value',0);
        set(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value',0);
        set(findobj(msmsynthesis_fig,'Tag','StaticText_parameter'),'Enable','off');
        set(findobj(msmsynthesis_fig,'Tag','PopupMenu_parameter'),'Enable','off','Position',[0.36 0.36 0.25 0.075]);
        set(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'Enable','off','Position',[0.79 0.36 0.17 0.075],'String','');
        set(findobj(msmsynthesis_fig,'Tag','StaticText_cutoff'),'Enable','off');
        set(findobj(msmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','off','String','');
        set(findobj(msmsynthesis_fig,'Tag','StaticText_step'),'Enable','off');
        set(findobj(msmsynthesis_fig,'Tag','EditText_step'),'Enable','off','String','');
        set(findobj(msmsynthesis_fig,'Tag','Check_normalization'),'Enable','off','Value',0);
        
    case 'linmfrac_option'
        if ~get(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value')
            set(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value',1);
        end
        set(findobj(msmsynthesis_fig,'Tag','RadioButton_levy'),'Value',0);
        set(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value',0);
        set(findobj(msmsynthesis_fig,'Tag','StaticText_parameter'),'Enable','on','String','H');
        set(findobj(msmsynthesis_fig,'Tag','PopupMenu_parameter'),'Enable','on','Position',[0.23 0.36 0.25 0.075],'Value',1);
        set(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'Enable','on','Position',[0.51 0.36 0.45 0.075],'String','0.1+0.8*t');
        set(findobj(msmsynthesis_fig,'Tag','StaticText_cutoff'),'Enable','on');
        nn = get(findobj(msmsynthesis_fig,'Tag','PopupMenu_sample'),'Value');
        set(findobj(msmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',3*2^(nn-1));
        set(findobj(msmsynthesis_fig,'Tag','StaticText_step'),'Enable','on');
        set(findobj(msmsynthesis_fig,'Tag','EditText_step'),'Enable','on','String',32);
        set(findobj(msmsynthesis_fig,'Tag','Check_normalization'),'Enable','on','Value',0);
        
    case 'ornhulen_option'
        if ~get(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
            set(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value',1);
        end
        set(findobj(msmsynthesis_fig,'Tag','RadioButton_levy'),'Value',0);
        set(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value',0);
        set(findobj(msmsynthesis_fig,'Tag','StaticText_parameter'),'Enable','on','String','Lambda');
        set(findobj(msmsynthesis_fig,'Tag','PopupMenu_parameter'),'Enable','off','Position',[0.36 0.36 0.25 0.075]);
        set(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'Enable','on','Position',[0.79 0.36 0.17 0.075],'String',1);
        set(findobj(msmsynthesis_fig,'Tag','StaticText_cutoff'),'Enable','on');
        nn = get(findobj(msmsynthesis_fig,'Tag','PopupMenu_sample'),'Value');
        set(findobj(msmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',6*2^(nn-1));
        set(findobj(msmsynthesis_fig,'Tag','StaticText_step'),'Enable','on');
        set(findobj(msmsynthesis_fig,'Tag','EditText_step'),'Enable','on','String',32);
        set(findobj(msmsynthesis_fig,'Tag','Check_normalization'),'Enable','off','Value',0);
        
    case 'popmenu_alpha'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(msmsynthesis_fig,'Tag','EditText_alpha'),'String','0.9+1*t');
                set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 2
                set(findobj(msmsynthesis_fig,'Tag','EditText_alpha'),'String','1.0+0.9*sin(2*pi*t)');
                set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 3
                set(findobj(msmsynthesis_fig,'Tag','EditText_alpha'),'String','0.1+1.8./(1+exp(-100*(t-0.5)))');
                set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 4
                set(findobj(msmsynthesis_fig,'Tag','EditText_alpha'),'String','');
        end
    
    case 'edit_alpha'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(msmsynthesis_fig,'Tag','EditText_sample'),'String'));
        t = linspace(0,1,N); %#ok<NASGU>
        set(findobj(msmsynthesis_fig,'Tag','PopupMenu_alpha'),'Value',4);
        try
            eval([function_value,';']);
            set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','on');
            set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','off');
            set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','off');
        end
        
    case 'popmenu_sample'
        sample_value = 250*2^(get(gcbo,'Value')-1);
        set(findobj(msmsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);
        if get(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value')
            set(findobj(msmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',3*2^(get(gcbo,'Value')-1));
        elseif get(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
            set(findobj(msmsynthesis_fig,'Tag','EditText_cutoff'),'Enable','on','String',6*2^(get(gcbo,'Value')-1));
        end

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 250*2^(get(findobj(msmsynthesis_fig,'Tag','PopupMenu_sample'),'Value')-1);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end    

    case 'popmenu_parameter'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'String','0.1+0.8*t');
            case 2
                set(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'String','0.5+0.3*sin(4*pi*t)');
            case 3
                set(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'String','0.3+0.3./(1+exp(-100*(t-0.5)))');
            case 4
                set(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'String','');
        end

    case 'edit_parameter'
        parameter_value = str2double(get(gcbo,'String'));
        Hldornhulen = get(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value');
        if Hldornhulen
            if isnan(parameter_value)
                parameter_value = 1;
                set(gcbo,'String',parameter_value);
            else
                parameter_value = max(0,parameter_value);
                set(gcbo,'String',parameter_value);
            end
        else
            function_value = get(gcbo,'String');
            N = str2double(get(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'String'));
            t = linspace(0,1,N); %#ok<NASGU>
            try
                eval([function_value,';']);
                set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','on');
            catch %#ok<CTCH>
                fl_warning('Bad function format');
                set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','off');
                set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','off');
            end
        end
                
    case 'edit_cutoff'
        cutoff_value = str2double(get(gcbo,'String')) ;
        nn = get(findobj(msmsynthesis_fig,'Tag','PopupMenu_sample'),'Value');
        if isnan(cutoff_value) && get(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value')
            set(gcbo,'String',3*2^(nn-1));
        elseif isnan(cutoff_value) && get(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
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
        set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Alpha, N sample and parameter(Beta,H or Lambda) %%%%%
        Alphafunc = get(findobj(msmsynthesis_fig,'Tag','EditText_alpha'),'String');
        Nsamp = str2double(get(findobj(msmsynthesis_fig,'Tag','EditText_sample'),'String'));
        Param = str2double(get(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'String'));        
        Hfunc = get(findobj(msmsynthesis_fig,'Tag','EditText_parameter'),'String');
        
        %%%%% Get Cut-off parameter, Discretization step and Seed %%%%%
        Cutoff = str2double(get(findobj(msmsynthesis_fig,'Tag','EditText_cutoff'),'String'));
        Step = str2double(get(findobj(msmsynthesis_fig,'Tag','EditText_step'),'String'));
        Seed = str2double(get(findobj(msmsynthesis_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Look for option %%%%%
        Hldlevy = get(findobj(msmsynthesis_fig,'Tag','RadioButton_levy'),'Value');
        Hldlinmfrac = get(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value');
        Hldornhulen = get(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value');
        Hldnorm = get(findobj(msmsynthesis_fig,'Tag','Check_normalization'),'Value');

        %%%%% Perform the computation %%%%%
        if Hldlevy
            OutputNamemsm = 'msm_levy';    
            chaine_in = '=msmlevy(N,alphat';
        end
        
        if Hldlinmfrac
            OutputNamemsm = 'msm_linmfrac';    
            chaine_in = ['=msmlinmfrac(N,alphat,Ht,',num2str(Cutoff),',',num2str(Step)];
        end
        
        if Hldornhulen
            OutputNamemsm = 'msm_ornhulen';    
            chaine_in = ['=msmornhulen(N,alphat,',num2str(Param),',',num2str(Cutoff),',',num2str(Step)];
        end
        
        varname = fl_find_mnames(varargin{2},OutputNamemsm);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        if Hldnorm
            varnamen = ['msmn_linmfrac' varname(end)];
            eval(['global ' varnamen]);
            varargout{1} = [varname ' ' varnamen];
        end
        
        if ~isnan(Seed), chaine_in = [chaine_in,',',num2str(Seed)]; end
        
        if ~Hldlinmfrac
            chaine1 = ['N=',num2str(Nsamp),'; t=linspace(0,1,N); alphat = eval(''' Alphafunc ''');'];
            eval(chaine1);
        else
            chaine1 = ['N=',num2str(Nsamp),'; t=linspace(0,1,N); alphat = eval(''' Alphafunc '''); Ht = eval(''' Hfunc ''');'];
            eval(chaine1);
        end

        if Hldnorm
            chaine = ['[',varname ',' varnamen,']',chaine_in,');'];
        else
            chaine = [varname, chaine_in,');'];
        end
        eval(chaine);

        fl_diary(chaine1);
        fl_diary(chaine);
        fl_addlist(0,varname);
        if Hldnorm, fl_addlist(0,varnamen); end
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(msmsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(msmsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        if get(findobj(msmsynthesis_fig,'Tag','RadioButton_levy'),'Value')
            fl_doc msmlevy 
        end
        if get(findobj(msmsynthesis_fig,'Tag','RadioButton_linmfrac'),'Value')
            fl_doc msmlinmfrac 
        end
        if get(findobj(msmsynthesis_fig,'Tag','RadioButton_ornhulen'),'Value')
            fl_doc msmornhulen 
        end
        
    case 'close'  
        close(findobj(msmsynthesis_fig,'Tag', 'Fig_gui_fl_msmsynthesis'));

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
