function [varargout] = fl_wbpsynthesis_compute(varargin)
% Callback functions for wbpsynthesis GUI Environment.

% Author Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,wbpsynthesis_fig] = gcbo;

if ((isempty(wbpsynthesis_fig)) || (~strcmp(get(wbpsynthesis_fig,'Tag'),'Fig_gui_fl_wbpsynthesis')))
    wbpsynthesis_fig = findobj ('Tag','Fig_gui_fl_wbpsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'wave1f_option'
        if ~get(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value')
            set(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value',1);
        end
        set(findobj(wbpsynthesis_fig,'Tag','RadioButton_lacunary'),'Value',0);
        set(findobj(wbpsynthesis_fig,'Tag','StaticText_octave'),'String','# octaves');
        set(findobj(wbpsynthesis_fig,'Tag','Slider_coef'),'enable','off');
        nn = str2double(get(findobj(wbpsynthesis_fig,'Tag','EditText_sample'),'String'));
        set(findobj(wbpsynthesis_fig,'Tag','EditText_octave'),'String',round(log2(nn)));
        set(findobj(wbpsynthesis_fig,'Tag','StaticText_seed'),'Enable','on');
        set(findobj(wbpsynthesis_fig,'Tag','EditText_seed'),'String','','Enable','on');
        
    case 'lacunary_option'
        if ~get(findobj(wbpsynthesis_fig,'Tag','RadioButton_lacunary'),'Value')
            set(findobj(wbpsynthesis_fig,'Tag','RadioButton_lacunary'),'Value',1);
        end
        set(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value',0);
        set(findobj(wbpsynthesis_fig,'Tag','StaticText_octave'),'String','Lacunarity coef');
        set(findobj(wbpsynthesis_fig,'Tag','Slider_coef'),'Value',0.9,'enable','on');
        set(findobj(wbpsynthesis_fig,'Tag','EditText_octave'),'String','0.9');
        set(findobj(wbpsynthesis_fig,'Tag','StaticText_seed'),'Enable','off');
        set(findobj(wbpsynthesis_fig,'Tag','EditText_seed'),'String','','Enable','off');
        
    case 'slider_exponent'
        slider_value = get(gcbo,'Value');
        set(findobj(wbpsynthesis_fig,'Tag','EditText_exponent'),'String',slider_value);

    case 'edit_exponent'
        exponent_value = str2double(get(gcbo,'String'));
        if isnan(exponent_value)
            exponent_value = 0.5;
            set(gcbo,'String',exponent_value);
            set(findobj(wbpsynthesis_fig,'Tag','Slider_exponent'),'Value',exponent_value);
        else
            exponent_value = trunc(exponent_value,0.0,1.0);
            set(gcbo,'String',exponent_value);
            set(findobj(wbpsynthesis_fig,'Tag','Slider_exponent'),'Value',exponent_value);
        end
        
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(wbpsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);
        Hldf = get(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value');
        if Hldf
            set(findobj(wbpsynthesis_fig,'Tag','EditText_octave'),'String',round(log2(sample_value)));
        end

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(wbpsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end
        Hldf = get(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value');
        if Hldf
            set(findobj(wbpsynthesis_fig,'Tag','EditText_octave'),'String',round(log2(sample_value)));
        end
        
	case 'slider_coef'
        slider_value = get(gcbo,'Value');
        set(findobj(wbpsynthesis_fig,'Tag','EditText_octave'),'String',slider_value);
        
    case 'edit_noctave'
        octave_value = str2double(get(gcbo,'String'));
        Hldf = get(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value');
        if Hldf
            nn = str2double(get(findobj(wbpsynthesis_fig,'Tag','EditText_sample'),'String'));
            if isnan(octave_value)
                set(gcbo,'String',round(log2(nn)));
            else
                octave_value = round(trunc(octave_value,1.0,log2(nn)));
                set(gcbo,'String',octave_value);
            end
        else
            lacunary_coef = octave_value;
            if isnan(lacunary_coef)
                lacunary_coef = 1;
                set(gcbo,'String',lacunary_coef);
                set(findobj(wbpsynthesis_fig,'Tag','Slider_coef'),'Value',lacunary_coef);
            else
                lacunary_coef = trunc(lacunary_coef,0.0,1.0);
                set(gcbo,'String',lacunary_coef);
                set(findobj(wbpsynthesis_fig,'Tag','Slider_coef'),'Value',lacunary_coef);
            end
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
        set(findobj(wbpsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(wbpsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Holder exponent, N sample, Noctave and Seed %%%%%
        Hexp = str2double(get(findobj(wbpsynthesis_fig,'Tag','EditText_exponent'),'String'));
        Nsamp = str2double(get(findobj(wbpsynthesis_fig,'Tag','EditText_sample'),'String'));
        Noctav = str2double(get(findobj(wbpsynthesis_fig,'Tag','EditText_octave'),'String'));
        Seed = str2double(get(findobj(wbpsynthesis_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Get wave order %%%%%
        wave_type = get(findobj(wbpsynthesis_fig,'Tag','PopupMenu_wavelet'),'Value');
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
        Hldf = get(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value');

        %%%%% Perform the computation %%%%%
        if Hldf
            OutputNamewbp = 'wgp';
            chaine_in = '=wave1f(N,H,Q';
            chaine_in = [chaine_in,',''scale'',',num2str(Noctav)];
        else
            OutputNamewbp = 'lacunary';
            chaine_in = '=lacunary(N,H,L,Q';
        end
        
        varname = fl_find_mnames(varargin{2},OutputNamewbp);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        if ~isnan(Seed), chaine_in = [chaine_in,',''seed'',',num2str(Seed)]; end
        
        chaine1 = ['N=',num2str(Nsamp),'; H=',num2str(Hexp)];
        if ~Hldf, chaine1 = [chaine1,'; L=',num2str(Noctav)]; end
        chaine1 = [chaine1,'; Q=',f1];
        eval(chaine1);
        
        chaine = [varname,chaine_in,');'];
        eval(chaine);

        fl_diary(chaine1);
        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(wbpsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(wbpsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        Hldf = get(findobj(wbpsynthesis_fig,'Tag','RadioButton_wave1f'),'Value');
        if Hldf
            fl_doc wave1f
        else
            fl_doc lacunary
        end
        
    case 'close'  
        close(findobj(wbpsynthesis_fig,'Tag', 'Fig_gui_fl_wbpsynthesis'));

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
