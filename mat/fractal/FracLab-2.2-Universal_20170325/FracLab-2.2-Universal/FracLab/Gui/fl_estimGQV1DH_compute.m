function [varargout]=fl_estimGQV1DH_compute(varargin)
% Callback functions for estimGQV1DH GUI Environment.

% Modified by Christian Choque Cortez, December 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,estimGQV1DH_fig] = gcbo;

if ((isempty(estimGQV1DH_fig)) || (~strcmp(get(estimGQV1DH_fig,'Tag'),'Fig_gui_fl_estimGQV1DH')))
    estimGQV1DH_fig = findobj ('Tag','Fig_gui_fl_estimGQV1DH');
end;

fl_clearerror;
switch(varargin{1});
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('input signal must be a vector !') ;
            return
        end
        eval(['global ' SigIn_name]);
        set(findobj(estimGQV1DH_fig,'Tag','EditText_input'),'String',SigIn_name);

    case 'edit_gamma'
        gamma_value = str2double(get(gcbo,'String'));
        if isnan(gamma_value)
            fl_warning('Gamma must be real !'); pause(.3);
            set(gcbo,'String',0.8);
        else
            gamma_value = max(0,gamma_value);
            set(gcbo,'String',gamma_value);
        end    
        
    case 'edit_delta'
        delta_value = str2double(get(gcbo,'String'));
        if isnan(delta_value)
            fl_warning('Delta must be real !'); pause(.3);
            set(gcbo,'String',1);
        else
            delta_value = max(0,delta_value);
            set(gcbo,'String',delta_value);
        end

    case 'linear_option'
        if ~get(findobj('Tag','RadioButton_linear'),'Value')
            set(findobj('Tag','RadioButton_linear'),'Value',1);
        end
        set(findobj('Tag','RadioButton_geometric'),'Value',0);
        set(findobj('Tag','StaticText_step'),'String','Step');
        set(findobj('Tag','EditText_step'),'String','1');
        set(findobj('Tag','EditText_k1'),'String','1');        
        set(findobj('Tag','EditText_k2'),'String','5');

    case 'geometric_option'
        if ~get(findobj('Tag','RadioButton_geometric'),'Value')
            set(findobj('Tag','RadioButton_geometric'),'Value',1);
        end
        set(findobj('Tag','RadioButton_linear'),'Value',0);
        set(findobj('Tag','StaticText_step'),'String','Ratio');
        set(findobj('Tag','EditText_step'),'String','2');
        set(findobj('Tag','EditText_k1'),'String','1');        
        set(findobj('Tag','EditText_k2'),'String','32');

    case 'edit_zones'
        zones = str2double(get(gcbo,'String'));
        if isnan(zones)
            fl_warning('Number of segmentation zones must be an integer !'); pause(.3);
            set(gcbo,'String',10);
        else
            SigIn_name = get(findobj(estimGQV1DH_fig,'Tag','EditText_input'),'String');
            eval(['global ',SigIn_name]);
            SigIn = eval(SigIn_name);
            N = length(SigIn);
            zones = floor(trunc(zones,1,N));
            set(gcbo,'String',zones);
        end
        
    case 'edit_k1'
        k_value = str2double(get(gcbo,'String'));
        if isnan(k_value)
            fl_warning('Initial sub-sampling must be an integer !'); pause(.3);
            set(gcbo,'String',1);
        else
            k2 = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_k2'),'String'));
            k_value = floor(min(k_value,k2-1));
            set(gcbo,'String',k_value);
        end
        
    case 'edit_k2'
        k_value = str2double(get(gcbo,'String'));
        if isnan(k_value)
            fl_warning('Final sub-sampling must be an integer !'); pause(.3);
            if get(findobj('Tag','RadioButton_geometric'),'Value')
                set(gcbo,'String',32);
            else
                set(gcbo,'String',5);
            end
        else
            k1 = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_k1'),'String'));
            k_value = floor(max(k1+1,k_value));
            set(gcbo,'String',k_value);
        end
    
    case 'edit_step'
        step_value = str2double(get(gcbo,'String'));
        if isnan(step_value)
            fl_warning('The step must be an integer !'); pause(.3);
            if get(findobj('Tag','RadioButton_geometric'),'Value')
                set(gcbo,'String',2);
            else
                set(gcbo,'String',1);
            end
        else
            step_value = floor(max(1,step_value));
            set(gcbo,'String',step_value);
        end    
                
    case 'check_time'
        if get(gcbo,'Value')
            set(gcbo,'String','Holder Function');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_timeinstant'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_timeinstant'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_zones'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_zones'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','Check_regression'),'enable','on');
        else
            set(gcbo,'String','Single time exponent');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_timeinstant'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','Regtype_menu'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_timeinstant'),'enable','on');            
            set(findobj(estimGQV1DH_fig,'Tag','Check_regression'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_zones'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_zones'),'enable','off','String',10);            
        end

    case 'edit_time'
        SigIn_name = get(findobj(estimGQV1DH_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]);
        SigIn = eval(SigIn_name);
        N = length(SigIn);
        time = str2double(get(gcbo,'String'));
        if isnan(time)
            fl_warning('Time instant must be an integer !'); pause(.3);
            set(gcbo,'String',floor(N/2));
        else
            time = floor(trunc(time,1,N)); 
            set(gcbo,'String',time);
        end
  
    case 'check_regression'
        if get(gcbo,'Value')
            set(gcbo,'String','Regression');
            set(findobj(estimGQV1DH_fig,'Tag','RadioButton_linear'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','RadioButton_geometric'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_zones'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_zones'),'enable','on'); 
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_k1'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_k1'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_k2'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_k2'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_step'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_step'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','Check_timeinstant'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','Regtype_menu'),'enable','on');
        else
            set(gcbo,'String','No Regression');
            set(findobj(estimGQV1DH_fig,'Tag','RadioButton_linear'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','RadioButton_geometric'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_zones'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_zones'),'enable','off','String',10);
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_k1'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_k1'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_k2'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_k2'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','StaticText_step'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','EditText_step'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','Check_timeinstant'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','Regtype_menu'),'enable','off');
        end
                
    case 'compute'
        current_cursor=fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(estimGQV1DH_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(estimGQV1DH_fig,'Tag','Button_close'),'enable','off');
            set(findobj(estimGQV1DH_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Gamma and Delta %%%%%
            Gamma = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_gamma'),'String'));
            Delta = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_delta'),'String'));
            
            %%%%% Get Initial, Final and Step of Sampling %%%%%
            zones = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_zones'),'String'));
            k1 = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_k1'),'String'));
            k2 = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_k2'),'String'));
            Step = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_step'),'String'));
                        
            %%%%% Look for option %%%%%
            Hldgeo = get(findobj(estimGQV1DH_fig,'Tag','RadioButton_geometric'),'Value');
            Hldreg = get(findobj(estimGQV1DH_fig,'Tag','Check_regression'),'Value');
            Hldtimeinstant = get(findobj(estimGQV1DH_fig,'Tag','Check_timeinstant'),'Value');
            timeinstant = str2double(get(findobj(estimGQV1DH_fig,'Tag','EditText_timeinstant'),'String'));
            Hldzones = isequal(zones,10);
            
            %%%%% Regression argument %%%%%
            RegType = get(findobj(estimGQV1DH_fig,'Tag','Regtype_menu'),'Value');
            scale = k1:Step:k2;
            if Hldgeo, scale = Step.^(log(k1)/log(Step):log(k2)/log(Step)); end
            RegParam = fl_getregparam(RegType,length(scale));
            Hldwlspls = strcmp(RegParam{1},'pls') || strcmp(RegParam{1},'wls') || strcmp(RegParam{1},'lapls');
            
            %%%%% Perform the computation %%%%%
            OutputNameH = ['estim_H_' SigIn_Name]; OutputNameG = ['estim_G_' SigIn_Name];
            [varnameH varnameG] = fl_find_mnames(varargin{2},OutputNameH,OutputNameG);
            eval(['global ' varnameH]); eval(['global ' varnameG]);
            varargout{1} = [varnameH ' ' varnameG];
            chaine_in = ['=estimGQV1DH(',SigIn_Name,',',num2str(Gamma),',',num2str(Delta),...
                            ',[',num2str(k1),':',num2str(Step),':',num2str(k2),'],',...
                            '''',RegParam{1},''''];
            if Hldgeo
                chaine_in = ['=estimGQV1DH(',SigIn_Name,',',num2str(Gamma),',',num2str(Delta),',',...
                            num2str(Step),'.^[',num2str(log(k1)/log(Step)),':',num2str(log(k2)/log(Step)),'],',...
                            '''',RegParam{1},''''];
            end
            
            if ~Hldreg
                chaine_in = ['=estimGQV1DH(',SigIn_Name,',',num2str(Gamma),',',num2str(Delta),',1,','''noreg'''];
            end
            
            if Hldwlspls, chaine_in = [chaine_in,',[',num2str(RegParam{2}),']']; end
            
            chaine = ['[',varnameH ' ' varnameG,']',chaine_in];
            
            if ~Hldtimeinstant
                varargout{1} = varnameH;
                chaine = [varnameH,chaine_in,',''timeinstant'',',num2str(timeinstant)];
            end

            if ~Hldzones, chaine = [chaine,',''zones'',',num2str(zones)]; end
            
            chaine = [chaine,');']; 
            eval(chaine);
            
            if Hldtimeinstant
                fl_addlist(0,varnameH);
                fl_addlist(0,varnameG);
                
                lbh=findobj('Tag','Listbox_variables');  
                varcell = get(lbh,'String');
                set(lbh,'Value',numel(varcell)-1);

            end
            fl_diary(chaine);
            fl_waitoff(current_cursor);
        
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(estimGQV1DH_fig,'Tag','Button_close'),'enable','on');
            set(findobj(estimGQV1DH_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'  
        fl_doc estimGQV1DH
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_estimGQV1DH'));
        
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
