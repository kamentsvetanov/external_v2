function [varargout] = fl_MST_compute(varargin)

[objTmp,mstsynthesis_fig] = gcbo;

if ((isempty(mstsynthesis_fig)) || (~strcmp(get(mstsynthesis_fig,'Tag'),'Fig_gui_fl_MST')))
    mstsynthesis_fig = findobj ('Tag','Fig_gui_fl_MST');
end

fl_clearerror;
switch(varargin{1})
    case 'popmenu_alpha'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(mstsynthesis_fig,'Tag','EditText_alphat'),'String','0.9+1*t');
            case 2
                set(findobj(mstsynthesis_fig,'Tag','EditText_alphat'),'String','1.1+0.85*sin(2*pi*t)');
            case 3
                set(findobj(mstsynthesis_fig,'Tag','EditText_alphat'),'String','0.1+1.8./(1+exp(-100*(t-0.5)))');
            case 4
                set(findobj(mstsynthesis_fig,'Tag','EditText_alphat'),'String','');
        end

    case 'edit_alphat'
        N = str2double(get(findobj(mstsynthesis_fig,'Tag','EditText_sample'),'String'));
        t = linspace(0,1,N); %#ok<NASGU>
        set(findobj(mstsynthesis_fig,'Tag','popmenu_alpha'),'Value',4);
    case 'slider_C'
        slider_value = get(gcbo,'Value');
        set(findobj(mstsynthesis_fig,'Tag','EditText_C'),'String',slider_value);
    case 'slider_G'
        slider_value = get(gcbo,'Value');
        set(findobj(mstsynthesis_fig,'Tag','EditText_G'),'String',slider_value);
    case 'slider_M'
        slider_value = get(gcbo,'Value');
        set(findobj(mstsynthesis_fig,'Tag','EditText_M'),'String',slider_value);
    case 'Popupmenu_size'
        sample_value = 250*2^(get(gcbo,'Value')-1);
        set(findobj(mstsynthesis_fig,'Tag','EditText_size'),'String',sample_value);
    case 'edit_C'
        C_value = str2double(get(gcbo,'String'));
        if isnan(C_value)
            C_value = 0.001;
            set(gcbo,'String',C_value);
            set(findobj(mstsynthesis_fig,'Tag','slider_C_'),'Value',C_value);
        else
            C_value = trunc(C_value,0,0.1);
            set(gcbo,'String',C_value);
            set(findobj(mstsynthesis_fig,'Tag','slider_C_'),'Value',C_value);
        end
    case 'edit_G'
        G_value = str2double(get(gcbo,'String'));
        if isnan(G_value)
            G_value = 2;
            set(gcbo,'String',G_value);
            set(findobj(mstsynthesis_fig,'Tag','slider_G_'),'Value',G_value);
        else
            G_value = trunc(G_value,0,200);
            set(gcbo,'String',G_value);
            set(findobj(mstsynthesis_fig,'Tag','slider_G_'),'Value',G_value);
        end
    case 'edit_M'
        M_value = str2double(get(gcbo,'String'));
        if isnan(M_value)
            M_value = 2;
            set(gcbo,'String',M_value);
            set(findobj(mstsynthesis_fig,'Tag','slider_M_'),'Value',M_value);
        else
            M_value = trunc(M_value,0,200);
            set(gcbo,'String',M_value);
            set(findobj(mstsynthesis_fig,'Tag','slider_M_'),'Value',M_value);
        end
    case 'compute'

        current_cursor=fl_waiton;
        set(findobj(mstsynthesis_fig,'Tag','pushbutton_compute'),'enable','off');
        set(findobj(mstsynthesis_fig,'Tag','pushbutton_help'),'enable','off');
        set(findobj(mstsynthesis_fig,'Tag','pushbutton_close'),'enable','off');
        
        %%%%% Get Alphafunc, N sample and parameter(C, G, M) %%%%%
        Alphafunc = get(findobj(mstsynthesis_fig,'Tag','EditText_alphat'),'String');
        Nsamp = str2double(get(findobj(mstsynthesis_fig,'Tag','EditText_size'),'String'));
        C = str2double(get(findobj(mstsynthesis_fig,'Tag','EditText_C'),'String'));
        G = str2double(get(findobj(mstsynthesis_fig,'Tag','EditText_G'),'String'));
        M = str2double(get(findobj(mstsynthesis_fig,'Tag','EditText_M'),'String'));
 
        %%%%% Get Seed %%%%%
        seed = str2double(get(findobj(mstsynthesis_fig,'Tag','EditText_seed'),'String'));

        %%%%% Perform the computation %%%%%
        chaine_in = '=mst_processes(N,alphat';

        OutputName= 'tmsm';
        varname = fl_find_mnames(varargin{2},OutputName);
        eval(['global ' varname]);
        varargout{1} = varname;
        % à revoir avec alphat=t
        alphat = 0;
        chaine1 = ['N=',num2str(Nsamp),'; t=linspace(0,1,N);',' alphat = eval(''' Alphafunc ''');'];
        eval(chaine1);
        chaine = [varname, chaine_in,',',num2str(C),',',num2str(G),',',num2str(M),',',num2str(seed),');'];
        eval(chaine);

        fl_diary(chaine1);
        fl_diary(chaine);
        fl_addlist(0,varname);
        fl_waitoff(current_cursor);

        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(mstsynthesis_fig,'Tag','pushbutton_compute'),'enable','on');
        set(findobj(mstsynthesis_fig,'Tag','pushbutton_help'),'enable','on');
        set(findobj(mstsynthesis_fig,'Tag','pushbutton_close'),'enable','on');
    case 'help'
        fl_doc MST_compute 
    case 'close'
        close(findobj(mstsynthesis_fig,'Tag', 'Fig_gui_fl_MST'));

end
end

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
