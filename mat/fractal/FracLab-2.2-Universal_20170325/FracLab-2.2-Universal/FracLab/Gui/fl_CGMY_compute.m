function [varargout] = fl_CGMY_compute(varargin)


[objTmp,tasmsynthesis_fig] = gcbo;

if ((isempty(tasmsynthesis_fig)) || (~strcmp(get(tasmsynthesis_fig,'Tag'),'Fig_gui_fl_CGMY')))
    tasmsynthesis_fig = findobj ('Tag','Fig_gui_fl_CGMY');
end

fl_clearerror;
switch(varargin{1})
    case 'slider_Alpha'
        slider_value = get(gcbo,'Value');
        set(findobj(tasmsynthesis_fig,'Tag','EditText_alpha'),'String',slider_value);
    case 'slider_C'
        slider_value = get(gcbo,'Value');
        set(findobj(tasmsynthesis_fig,'Tag','EditText_C'),'String',slider_value);
    case 'slider_G'
        slider_value = get(gcbo,'Value');
        set(findobj(tasmsynthesis_fig,'Tag','EditText_G'),'String',slider_value);
    case 'slider_M'
        slider_value = get(gcbo,'Value');
        set(findobj(tasmsynthesis_fig,'Tag','EditText_M'),'String',slider_value);
    case 'PopupMenu_Size'
        sample_value = 250*2^(get(gcbo,'Value')-1);
        set(findobj(tasmsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);
    case 'edit_Alpha'
        alpha_value = str2double(get(gcbo,'String'));
        if isnan(alpha_value)
            alpha_value = 1.5;
            set(gcbo,'String',alpha_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider1'),'Value',alpha_value);
        else
            alpha_value = trunc(alpha_value,0.01,1.99);
            set(gcbo,'String',alpha_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider1'),'Value',alpha_value);
        end          
    case 'edit_C'
        C_value = str2double(get(gcbo,'String'));
        if isnan(C_value)
            C_value = 0.001;
            set(gcbo,'String',C_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider2'),'Value',C_value);
        else
            C_value = trunc(C_value,0,0.1);
            set(gcbo,'String',C_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider2'),'Value',C_value);
        end
    case 'edit_G'
        G_value = str2double(get(gcbo,'String'));
        if isnan(G_value)
            G_value = 2;
            set(gcbo,'String',G_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider3'),'Value',G_value);
        else
            G_value = trunc(G_value,0,200);
            set(gcbo,'String',G_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider3'),'Value',G_value);
        end
    case 'edit_M'
        M_value = str2double(get(gcbo,'String'));
        if isnan(M_value)
            M_value = 2;
            set(gcbo,'String',M_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider4'),'Value',M_value);
        else
            M_value = trunc(M_value,0,200);
            set(gcbo,'String',M_value);
            set(findobj(tasmsynthesis_fig,'Tag','slider4'),'Value',M_value);
        end
    case 'edit_Size'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 250*2^(get(findobj(tasmsynthesis_fig,'Tag','PopupMenu_sample'),'Value')-1);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end
        
    case 'compute'
       current_cursor=fl_waiton;
     
        set(findobj(tasmsynthesis_fig,'Tag','pushbutton_compute'),'enable','off');
        set(findobj(tasmsynthesis_fig,'Tag','pushbutton_help'),'enable','off');
        set(findobj(tasmsynthesis_fig,'Tag','pushbutton_close'),'enable','off');

        %%%%% Get Alpha, C, G, M,  %%%%%
        alpha = str2double(get(findobj(tasmsynthesis_fig,'Tag','EditText_alpha'),'String'));
        C = str2double(get(findobj(tasmsynthesis_fig,'Tag','EditText_C'),'String'));
        G = str2double(get(findobj(tasmsynthesis_fig,'Tag','EditText_G'),'String'));
        M = str2double(get(findobj(tasmsynthesis_fig,'Tag','EditText_M'),'String'));


        
%         %%%%% Get Discretization step and Seed %%%%%
        size = str2double(get(findobj(tasmsynthesis_fig,'Tag','EditText_sample'),'String'));
        seed = str2double(get(findobj(tasmsynthesis_fig,'Tag','EditText_seed'),'String'));

        %%%%% Perform the computation %%%%%

        chaine_in = ['=CGMY_Principal(',num2str(alpha),',',num2str(C),',',num2str(G),',',num2str(M),',',num2str(size),',',num2str(seed)];
        OutputName= 'tasm';
        varname = fl_find_mnames(varargin{2},OutputName);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        %if ~isnan(seed), chaine_in = [chaine_in,',',num2str(seed)]; end
        
        chaine = [varname, chaine_in,');'];
        eval(chaine); %-----------------

        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(tasmsynthesis_fig,'Tag','pushbutton_compute'),'enable','on');
        set(findobj(tasmsynthesis_fig,'Tag','pushbutton_help'),'enable','on');
        set(findobj(tasmsynthesis_fig,'Tag','pushbutton_close'),'enable','on');
    case 'help'
        fl_doc CGMY_compute 
    case 'close'
        close(findobj(tasmsynthesis_fig,'Tag', 'Fig_gui_fl_CGMY'));
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