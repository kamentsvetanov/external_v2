function [varargout] = fl_mmssynthesis2d_compute(varargin)
% Callback functions for mmssynthesis2d GUI Environment.

% Author Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mmssynthesis2d_fig] = gcbo;

if ((isempty(mmssynthesis2d_fig)) || (~strcmp(get(mmssynthesis2d_fig,'Tag'),'Fig_gui_fl_mmssynthesis2d')))
    mmssynthesis2d_fig = findobj ('Tag','Fig_gui_fl_mmssynthesis2d');
end

fl_clearerror;
switch(varargin{1})
    case 'det_option'
        if ~get(findobj(mmssynthesis2d_fig,'Tag','RadioButton_deterministic'),'Value')
            set(findobj(mmssynthesis2d_fig,'Tag','RadioButton_deterministic'),'Value',1);
        end
        set(findobj(mmssynthesis2d_fig,'Tag','RadioButton_stochastic'),'Value',0);
        set(findobj(mmssynthesis2d_fig,'Tag','Popupmenu_method'),'Value',1,'Enable','off');
        set(findobj(mmssynthesis2d_fig,'Tag','StaticText_weigths'),'Enable','on');
        set(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'Enable','on');
        set(findobj(mmssynthesis2d_fig,'Tag','StaticText_parameter'),'Enable','off');
        set(findobj(mmssynthesis2d_fig,'Tag','EditText_parameter'),'Enable','off');
        
    case 'stoc_option'
        if ~get(findobj(mmssynthesis2d_fig,'Tag','RadioButton_stochastic'),'Value')
            set(findobj(mmssynthesis2d_fig,'Tag','RadioButton_stochastic'),'Value',1);
        end
        set(findobj(mmssynthesis2d_fig,'Tag','RadioButton_deterministic'),'Value',0);
        set(findobj(mmssynthesis2d_fig,'Tag','Popupmenu_method'),'Value',1,'Enable','on');
    
    case 'popmenu_method'
        method_value = get(gcbo,'Value');
        switch method_value
            case 1
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_weigths'),'Enable','on');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'Enable','on');
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_parameter'),'Enable','off');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_parameter'),'String','','Enable','off');
            case 2
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_weigths'),'Enable','on');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'Enable','on');
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_parameter'),'String','Perturbation','Enable','on');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_parameter'),'String','0.01','Enable','on');
            case 3
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_weigths'),'Enable','off');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'Enable','off');
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_parameter'),'Enable','off');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_parameter'),'String','','Enable','off');
            case 4
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_weigths'),'Enable','off');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'Enable','off');
                set(findobj(mmssynthesis2d_fig,'Tag','StaticText_parameter'),'String','Standard deviation','Enable','on');
                set(findobj(mmssynthesis2d_fig,'Tag','EditText_parameter'),'String','1','Enable','on');
        end
        
    case 'edit_base'
        base_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(base_value) || length(base_value) ~= 2
            base_value = [2,2];
            set(gcbo,'String',mat2str(base_value));
            set(findobj(mmssynthesis2d_fig,'Tag','EditText_scales'),'String',8);
            set(findobj(mmssynthesis2d_fig,'Tag','EditText_sample'),'String','256 x 256');
        else
            base_value(1) = round(trunc(base_value(1),2.0,10.0));
            base_value(2) = round(trunc(base_value(2),2.0,10.0));
            set(gcbo,'String',mat2str(base_value));
            nn = str2double(get(findobj(mmssynthesis2d_fig,'Tag','EditText_scales'),'String'));
            while round(log(prod(base_value)^nn)) > round(log(2^24)), nn = nn-1; end
            nsample = base_value.^nn;
            set(findobj(mmssynthesis2d_fig,'Tag','EditText_scales'),'String',nn);
            set(findobj(mmssynthesis2d_fig,'Tag','EditText_sample'),'String',[num2str(nsample(1)),' x ',num2str(nsample(2))]);
        end
        ww = weights(prod(base_value));
        ww = reshape(ww,base_value(1),base_value(2));
        set(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'String',mat2str(ww));
    
    case 'edit_scales'
        scales_value = str2double(get(gcbo,'String'));
        base = str2num(get(findobj(mmssynthesis2d_fig,'Tag','EditText_base'),'String')); %#ok<ST2NM>
        if isnan(scales_value)
            scales_value = 5;
            set(gcbo,'String',scales_value);
            nsample = base.^scales_value;
            set(findobj(mmssynthesis2d_fig,'Tag','EditText_sample'),'String',[num2str(nsample(1)),' x ',num2str(nsample(2))]);
        else
            scales_value = round(trunc(scales_value,2,12));
            nn = scales_value;
            while round(log(prod(base)^nn)) > round(log(2^24)), nn = nn-1; end
            scales_value = round(trunc(scales_value,2.0,nn));
            set(gcbo,'String',scales_value);
            nsample = base.^scales_value;
            set(findobj(mmssynthesis2d_fig,'Tag','EditText_sample'),'String',[num2str(nsample(1)),' x ',num2str(nsample(2))]);
        end
    
    case 'edit_weigths'
        weigths_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        base = str2num(get(findobj(mmssynthesis2d_fig,'Tag','EditText_base'),'String')); %#ok<ST2NM>
        if isempty(weigths_value)
            weigths_value = weights(prod(base));
        else
            if size(weigths_value,1) ~= base(1) || size(weigths_value,2) ~= base(2)
                fl_warning('The size of weigths must be equal to Base!'); pause(.3)
                weigths_value = weights(prod(base));
            elseif sum(sum(weigths_value)) ~= 1
                fl_warning('The sum of weigths must be equal to 1!'); pause(.3)
                weigths_value = weights(prod(base));
            end
        end
        weigths_value = reshape(weigths_value,base(1),base(2));
        set(gcbo,'String',mat2str(weigths_value));
        
    case 'edit_parameter'
        parameter_value = str2double(get(gcbo,'String'));
        method = get(findobj(mmssynthesis2d_fig,'Tag','Popupmenu_method'),'Value');
        if method == 2
            if isnan(parameter_value)
                parameter_value = 0.01;
                set(gcbo,'String',parameter_value);
            else
                ww = str2num(get(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'String')); %#ok<ST2NM>
                parameter_value = trunc(parameter_value,0.00001,min(ww(:))-0.01);
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
        set(findobj(mmssynthesis2d_fig,'Tag','Button_close'),'enable','off');
        set(findobj(mmssynthesis2d_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get global parameters %%%%%
        Base = str2num(get(findobj(mmssynthesis2d_fig,'Tag','EditText_base'),'String')); %#ok<ST2NM>
        Res = str2double(get(findobj(mmssynthesis2d_fig,'Tag','EditText_scales'),'String'));
        Weigth = str2num(get(findobj(mmssynthesis2d_fig,'Tag','EditText_weigths'),'String')); %#ok<ST2NM>
        
        %%%%% Look for option %%%%%
        Hlds = get(findobj(mmssynthesis2d_fig,'Tag','RadioButton_stochastic'),'Value');
        Method = get(findobj(mmssynthesis2d_fig,'Tag','Popupmenu_method'),'Value');
        Param = get(findobj(mmssynthesis2d_fig,'Tag','EditText_parameter'),'String');

        %%%%% Perform the computation %%%%%
        if ~Hlds
            OutputNamemms = 'mmsd2d';
            chaine_in = ['=multinom2d(',mat2str(Base),',',num2str(Res),',',mat2str(Weigth)];
        else
            chaine_in = ['=multinomstoc2d(',mat2str(Base),',',num2str(Res)];
            switch Method
                case 1
                    OutputNamemms = 'mmsshuf2d';
                    chaine_in = [chaine_in,',''shufmeas'',',mat2str(Weigth)];
                case 2
                    OutputNamemms = 'mmsper2d';
                    chaine_in = [chaine_in,',''pertmeas'',','{',mat2str(Weigth),' ',num2str(Param),'}'];
                case 3
                    OutputNamemms = 'mmsuni2d';
                case 4
                    OutputNamemms = 'mmslogn2d';
                    chaine_in = [chaine_in,',''lognmeas'',',num2str(Param)];
            end
        end
        
        varnamemms = fl_find_mnames(varargin{2},OutputNamemms);
        eval(['global ' varnamemms]); varargout{1} = varnamemms;
        chaine = [varnamemms,chaine_in];
        
        chaine = [chaine,');'];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0,varnamemms);
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(mmssynthesis2d_fig,'Tag','Button_close'),'enable','on');
        set(findobj(mmssynthesis2d_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        Hlds = get(findobj(mmssynthesis2d_fig,'Tag','RadioButton_stochastic'),'Value');
        if Hlds
            fl_doc multinomstoc2d
        else
            fl_doc multinom2d
        end
        
    case 'close'  
        close(findobj(mmssynthesis2d_fig,'Tag', 'Fig_gui_fl_mmssynthesis2d'));

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
v = round(rand(size,1)*10)/10;
while sum(v) > 1
    v = ((v/2)*10)/10;
end
if sum(v) < 1, v(size) = 1 - sum(v(1:size-1));end;
v = sort(v);
end