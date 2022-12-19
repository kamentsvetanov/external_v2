function [varargout]=fl_estimOSC1DH_compute(varargin)
% Callback functions for estimOSC1DH GUI Environment.

% Modified by Pierrick Legrand, January 2005
% Modified by Olivier Barrière, September 2005
% Modified by Christian Choque Cortez, December 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,estimOSC1DH_fig] = gcbo;

if isempty(estimOSC1DH_fig) || ~strcmp(get(estimOSC1DH_fig,'Tag'),'Fig_gui_fl_estimOSC1DH')
    estimOSC1DH_fig = findobj ('Tag','Fig_gui_fl_estimOSC1DH');
end

fl_clearerror;
switch(varargin{1})
    case 'refresh'
        [SigIn_Name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('input signal must be a vector !');
            return;
        end
        eval(['global ' SigIn_Name]);
        set(findobj(estimOSC1DH_fig,'Tag','EditText_input'),'String',SigIn_Name);
    
    case 'edit_base'
        base_value = str2double(get(gcbo,'String'));
        if isnan(base_value)
            fl_warning('base must be real'); pause(.3);
            set(gcbo,'String',2.1);
        else
            set(gcbo,'String',base_value);
        end
        
    case 'edit_alpha'
        alpha_value = str2double(get(gcbo,'String'));
        beta_value = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_beta'),'String'));
        base_value = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_base'),'String'));
        SigIn_name = get(findobj(estimOSC1DH_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]);
        SigIn = eval(SigIn_name);
        N = length(SigIn);
        if isnan(alpha_value)
            fl_warning('alpha must be a real in (0:1) lower than beta'); pause(.3);
            set(gcbo,'String',min(beta_value,0.1));
        elseif round(base_value^(floor(N^alpha_value))) >= N/2
            fl_warning('alpha must not be too large in relation to the signal');
            set(gcbo,'String',min(beta_value,0.1));
        else
            alpha_value = trunc(alpha_value,0,beta_value);
            set(gcbo,'String',alpha_value);
        end
        
    case 'edit_beta'
        beta_value = str2double(get(gcbo,'String'));
        alpha_value = str2double(get(findobj(estimOSC1DH_fig,...
                   'Tag','EditText_alpha'),'String'));
        if isnan(beta_value)
            fl_warning('alpha must be a real in (0:1) bigger than alpha'); pause(.3);
            set(gcbo,'String',max(alpha_value,0.3));
        else
            beta_value = trunc(beta_value,alpha_value,0.9);
            set(gcbo,'String',beta_value);
        end
        
    case 'edit_zones'
        zones = str2double(get(gcbo,'String'));
        if isnan(zones)
            fl_warning('Number of Segmentation zones must be an integer !'); pause(.3);
            set(gcbo,'String','10');
        else
            SigIn_name = get(findobj(estimOSC1DH_fig,'Tag','EditText_input'),'String');
            eval(['global ',SigIn_name]);
            SigIn = eval(SigIn_name);
            N = length(SigIn);             
            zones = floor(trunc(zones,1,N));
            set(gcbo,'String',zones);
        end
        
    case 'check_average'
        if ~get(gcbo,'Value')
            set(gcbo,'String','No Averaging');
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_gamma'),'enable','off');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_gamma'),'enable','off');
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_delta'),'enable','off');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_delta'),'enable','off');            
        else
            set(gcbo,'String','Averaging') ;
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_gamma'),'enable','on');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_gamma'),'enable','on');
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_delta'),'enable','on');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_delta'),'enable','on');            
        end    
    
    case 'edit_gamma'
        gamma_value = str2double(get(gcbo,'String'));
        delta_value = str2double(get(findobj(estimOSC1DH_fig,...
                   'Tag','EditText_delta'),'String'));
        if isnan(gamma_value)
            fl_warning('gamma must be a real in (0:1) lower than delta'); pause(.3);
            set(gcbo,'String',min(delta_value,0.4));
        else
            gamma_value = trunc(gamma_value,0,delta_value);
            set(gcbo,'String',gamma_value);
        end
        
    case 'edit_delta'
        delta_value = str2double(get(gcbo,'String'));
        gamma_value = str2double(get(findobj(estimOSC1DH_fig,...
                   'Tag','EditText_gamma'),'String'));
        if isnan(delta_value)
            fl_warning('delta must be a real in (0:1) bigger than gamma'); pause(.3);
            set(gcbo,'String',max(delta_value,1));
        else
            delta_value = trunc(delta_value,gamma_value,1);
            set(gcbo,'String',delta_value);
        end
            
    case 'check_time'
        if get(gcbo,'Value')
            set(gcbo,'String','Holder Function');
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_timeinstant'),'enable','off');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_timeinstant'),'enable','off');
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_zones'),'enable','on');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_zones'),'enable','on'); 
        else
            set(gcbo,'String','Single time exponent');
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_timeinstant'),'enable','on');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_timeinstant'),'enable','on');
            set(findobj(estimOSC1DH_fig,'Tag','StaticText_zones'),'enable','off');
            set(findobj(estimOSC1DH_fig,'Tag','EditText_zones'),'enable','off','String',10);            
        end    
        
    case 'edit_time'
        SigIn_name = get(findobj(estimOSC1DH_fig,'Tag','EditText_input'),'String');
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
 
    case 'compute'
        current_cursor = fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(estimOSC1DH_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]); SigIn = eval(SigIn_Name);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(estimOSC1DH_fig,'Tag','Button_close'),'enable','off');
            set(findobj(estimOSC1DH_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Base Alpha Beta and Zones %%%%%
            base = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_base'),'String'));
            alpha = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_alpha'),'String'));
            beta = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_beta'),'String'));
            zones = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_zones'),'String'));
            
            %%%%% Look for option %%%%%
            Hldtimeinstant = get(findobj(estimOSC1DH_fig,'Tag','Check_timeinstant'),'Value');
            timeinstant = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_timeinstant'),'String'));
            Hldaverage = get(findobj(estimOSC1DH_fig,'Tag','Check_average'),'Value');
            gamma = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_gamma'),'String'));
            delta = str2double(get(findobj(estimOSC1DH_fig,'Tag','EditText_delta'),'String'));
            Hldzones = isequal(zones,10);
              
            %%%%% Regression argument %%%%%
            RegType = get(findobj(estimOSC1DH_fig,'Tag','Regtype_menu'),'Value');
            scale = floor(length(SigIn)^alpha):ceil(length(SigIn)^beta);
            RegParam = fl_getregparam(RegType,length(scale));
            Hldwlspls = strcmp(RegParam{1},'pls') || strcmp(RegParam{1},'wls') || strcmp(RegParam{1},'lapls');
            
            %%%%% Perform the computation %%%%%            
            OutputName = ['Hosc_' SigIn_Name];
            varname = fl_findname(OutputName,varargin{2});
            eval(['global ' varname]);
            varargout{1} = varname;
            chaine_in = ['=estimOSC1DH(',SigIn_Name,',',num2str(base),...
                    ',',num2str(alpha),',',num2str(beta),',''',num2str(RegParam{1}),''''];
            
            if Hldwlspls, chaine_in = [chaine_in,',[',num2str(RegParam{2}),']']; end
            
            if ~Hldtimeinstant
                chaine_in = [chaine_in,',''timeinstant'',',num2str(timeinstant)]; end
            
            if Hldaverage
                chaine_in = [chaine_in,',''average'',[',num2str(gamma),',',num2str(delta),']']; end
            
            if ~Hldzones, chaine_in = [chaine_in,',''zones'',',num2str(zones)]; end
            
            chaine = [varname,chaine_in,');'];
            eval(chaine);
            
            fl_diary(chaine);
            if Hldtimeinstant
                fl_addlist(0,varname);
            end
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(estimOSC1DH_fig,'Tag','Button_close'),'enable','on');
            set(findobj(estimOSC1DH_fig,'Tag','Button_compute'),'enable','on');
        end
            
    case 'help'
        fl_doc estimOSC1DH    
  
    case 'close'
        close(findobj('Tag', 'Fig_gui_fl_estimOSC1DH'));
        
end
end
%--------------------------------------------------------------------------
function o = trunc(i,a,b)
if i < a
    o = a;
else
    if i > b
        o = b;
    else
        o = i;
    end
end
end