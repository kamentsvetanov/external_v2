function [varargout] = fl_mmssynthesis_compute(varargin)
% Callback functions for mmssynthesis GUI Environment.

% Author Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mmssynthesis_fig] = gcbo;

if ((isempty(mmssynthesis_fig)) || (~strcmp(get(mmssynthesis_fig,'Tag'),'Fig_gui_fl_mmssynthesis')))
    mmssynthesis_fig = findobj ('Tag','Fig_gui_fl_mmssynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'det_option'
        if ~get(findobj(mmssynthesis_fig,'Tag','RadioButton_deterministic'),'Value')
            set(findobj(mmssynthesis_fig,'Tag','RadioButton_deterministic'),'Value',1);
        end
        set(findobj(mmssynthesis_fig,'Tag','RadioButton_stochastic'),'Value',0);
        set(findobj(mmssynthesis_fig,'Tag','Popupmenu_method'),'Value',1,'Enable','off');
        set(findobj(mmssynthesis_fig,'Tag','StaticText_weigths'),'Enable','on');
        set(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'Enable','on');
        set(findobj(mmssynthesis_fig,'Tag','StaticText_parameter'),'Enable','off');
        set(findobj(mmssynthesis_fig,'Tag','EditText_parameter'),'Enable','off');
        
    case 'stoc_option'
        if ~get(findobj(mmssynthesis_fig,'Tag','RadioButton_stochastic'),'Value')
            set(findobj(mmssynthesis_fig,'Tag','RadioButton_stochastic'),'Value',1);
        end
        set(findobj(mmssynthesis_fig,'Tag','RadioButton_deterministic'),'Value',0);
        set(findobj(mmssynthesis_fig,'Tag','Popupmenu_method'),'Value',1,'Enable','on');
        
    case 'popmenu_method'
        method_value = get(gcbo,'Value');
        switch method_value
            case 1
                set(findobj(mmssynthesis_fig,'Tag','StaticText_weigths'),'Enable','on');
                set(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'Enable','on');
                set(findobj(mmssynthesis_fig,'Tag','StaticText_parameter'),'Enable','off');
                set(findobj(mmssynthesis_fig,'Tag','EditText_parameter'),'String','','Enable','off');
            case 2
                set(findobj(mmssynthesis_fig,'Tag','StaticText_weigths'),'Enable','on');
                set(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'Enable','on');
                set(findobj(mmssynthesis_fig,'Tag','StaticText_parameter'),'String','Perturbation','Enable','on');
                set(findobj(mmssynthesis_fig,'Tag','EditText_parameter'),'String','0.01','Enable','on');
            case 3
                set(findobj(mmssynthesis_fig,'Tag','StaticText_weigths'),'Enable','off');
                set(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'Enable','off');
                set(findobj(mmssynthesis_fig,'Tag','StaticText_parameter'),'Enable','off');
                set(findobj(mmssynthesis_fig,'Tag','EditText_parameter'),'String','','Enable','off');
            case 4
                set(findobj(mmssynthesis_fig,'Tag','StaticText_weigths'),'Enable','off');
                set(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'Enable','off');
                set(findobj(mmssynthesis_fig,'Tag','StaticText_parameter'),'String','Standard deviation','Enable','on');
                set(findobj(mmssynthesis_fig,'Tag','EditText_parameter'),'String','1','Enable','on');
        end    

    case 'edit_base'
        base_value = str2double(get(gcbo,'String'));
        if isnan(base_value)
            base_value = 2;
            set(gcbo,'String',base_value);
            set(findobj(mmssynthesis_fig,'Tag','EditText_scales'),'String',10);
            set(findobj(mmssynthesis_fig,'Tag','EditText_sample'),'String',1024);
        else
            base_value = round(trunc(base_value,2.0,10.0));
            set(gcbo,'String',base_value);
            nn = str2double(get(findobj(mmssynthesis_fig,'Tag','EditText_scales'),'String'));
            while round(log(base_value^nn)) > round(log(2^24)), nn = nn-1; end
            nsample = base_value^nn;
            set(findobj(mmssynthesis_fig,'Tag','EditText_scales'),'String',nn);
            set(findobj(mmssynthesis_fig,'Tag','EditText_sample'),'String',nsample);
        end
        ww = weights(base_value);
        set(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'String',mat2str(ww));
    
    case 'edit_scales'
        scales_value = str2double(get(gcbo,'String'));
        base = str2double(get(findobj(mmssynthesis_fig,'Tag','EditText_base'),'String'));
        if isnan(scales_value)
            scales_value = 7;
            set(gcbo,'String',scales_value);
            set(findobj(mmssynthesis_fig,'Tag','EditText_sample'),'String',base^scales_value);
        else
            scales_value = round(trunc(scales_value,2.0,24));
            nn = scales_value;
            while round(log(base^nn)) > round(log(2^24)), nn = nn-1; end
            scales_value = round(trunc(scales_value,2.0,nn));
            set(gcbo,'String',scales_value);
            nsample = base^scales_value;
            set(findobj(mmssynthesis_fig,'Tag','EditText_sample'),'String',nsample);
        end
    
    case 'edit_weigths'
        weigths_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        base = str2double(get(findobj(mmssynthesis_fig,'Tag','EditText_base'),'String'));
        if isempty(weigths_value)
            weigths_value = weights(base);
            set(gcbo,'String',mat2str(weigths_value));
        else
            if length(weigths_value) ~= base
                fl_warning('The number of weigths must be equal to Base!'); pause(.3)
                weigths_value = weights(base);
            elseif sum(weigths_value) ~= 1
                fl_warning('The sum of weigths must be equal to 1!'); pause(.3)
                weigths_value = weights(base);
            end
            set(gcbo,'String',mat2str(weigths_value));
        end
        
    case 'edit_parameter'
        parameter_value = str2double(get(gcbo,'String'));
        method = get(findobj(mmssynthesis_fig,'Tag','Popupmenu_method'),'Value');
        if method == 2
            if isnan(parameter_value)
                parameter_value = 0.01;
                set(gcbo,'String',parameter_value);
            else
                ww = str2num(get(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'String')); %#ok<ST2NM>
                parameter_value = trunc(parameter_value,0.00001,min(ww)-0.01);
                set(gcbo,'String',parameter_value);
            end
        else
            if isnan(parameter_value)
                parameter_value = 1;
                set(gcbo,'String',parameter_value);
            else
                parameter_value = trunc(parameter_value,0.00001,Inf);
                set(gcbo,'String',parameter_value);
            end
        end
                
    case 'compute'
        current_cursor=fl_waiton;
     
        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(mmssynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(mmssynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get global parameters %%%%%
        Base = str2double(get(findobj(mmssynthesis_fig,'Tag','EditText_base'),'String'));
        Res = str2double(get(findobj(mmssynthesis_fig,'Tag','EditText_scales'),'String'));
        Weigth = str2num(get(findobj(mmssynthesis_fig,'Tag','EditText_weigths'),'String')); %#ok<ST2NM>
        
        %%%%% Look for option %%%%%
        Hlds = get(findobj(mmssynthesis_fig,'Tag','RadioButton_stochastic'),'Value');
        Method = get(findobj(mmssynthesis_fig,'Tag','Popupmenu_method'),'Value');
        Param = get(findobj(mmssynthesis_fig,'Tag','EditText_parameter'),'String');
        Hldspec = get(findobj(mmssynthesis_fig,'Tag','Check_spectrum'),'Value');

        %%%%% Perform the computation %%%%%
        stitle = 'Multinomial measure Multifractal spectrum';
        if ~Hlds
            OutputNamemms = 'mmsd'; OutputNamespec = 'mmsfsd';
            chaine_in = ['=multinom(',num2str(Base),',',num2str(Res),',',mat2str(Weigth)];
        else
            chaine_in = ['=multinomstoc(',num2str(Base),',',num2str(Res)];
            switch Method
                case 1
                    OutputNamemms = 'mmsshuf'; OutputNamespec = 'mmsfss';
                    chaine_in = [chaine_in,',''shufmeas'',',mat2str(Weigth)];
                case 2
                    OutputNamemms = 'mmsper'; OutputNamespec = 'mmsfsp';
                    chaine_in = [chaine_in,',''pertmeas'',','{',mat2str(Weigth),' ',num2str(Param),'}'];
                case 3
                    OutputNamemms = 'mmsuni'; OutputNamespec = 'mmsfsu';
                    stitle = 'Uniform law measure Multifractal spectrum';
                case 4
                    OutputNamemms = 'mmslogn'; OutputNamespec = 'mmsfsl';
                    chaine_in = [chaine_in,',''lognmeas'',',num2str(Param)];
                    stitle = 'Lognormal law measure Multifractal spectrum';
            end
        end
        
        [varnamemms varnamespec] = fl_find_mnames(varargin{2},OutputNamemms,OutputNamespec);
        eval(['global ' varnamemms]); eval(['global ' varnamespec]);
        
        if Hldspec
            varargout{1} = [varnamemms ' ' varnamespec];
            chaine = ['[',varnamemms,',',varnamespec,']',chaine_in];
        else
            varargout{1} = varnamemms;
            chaine = [varnamemms,chaine_in];
        end
        
        chaine = [chaine,');'];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0,varnamemms);
        if Hldspec
            xxlabel='Holder exponents: \alpha';
            yylabel='spectrum: f(\alpha)';
            eval ([varnamespec '=struct(''type'',''graph'',''exp'',',varnamespec,'.exp,''spec'',',varnamespec,'.spec,', ...
                   '''title'',''',stitle,''',''xlabel'',''',xxlabel,''',''ylabel'',''',yylabel,''');']);
            fl_addlist(0,varnamespec); 
        end
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(mmssynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(mmssynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        Hlds = get(findobj(mmssynthesis_fig,'Tag','RadioButton_stochastic'),'Value');
        if Hlds
            fl_doc multinomstoc
        else
            fl_doc multinom
        end
        
    case 'close'  
        close(findobj(mmssynthesis_fig,'Tag', 'Fig_gui_fl_mmssynthesis'));

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
%--------------------------------------------------------------------------
function v = weights(size)
v = round(rand(size,1)*100)/100;
while sum(v) > 1
    v = round((v/2)*100)/100;
end
if sum(v) < 1, v(size) = 1 - sum(v(1:size-1));end;
v = sort(v);
end