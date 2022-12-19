function [varargout]=fl_estimirs_compute(varargin)
% Callback functions for estimOSC1DH GUI Environment.

% Author Christian Choque Cortez, April 2009.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,estimirs_fig] = gcbo;

if isempty(estimirs_fig) || ~strcmp(get(estimirs_fig,'Tag'),'Fig_gui_fl_estimirs')
    estimirs_fig = findobj ('Tag','Fig_gui_fl_estimirs');
end

fl_clearerror;
switch(varargin{1})
    case 'refresh'
        [SigIn_Name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('input signal must be a vector !');
        end
        eval(['global ' SigIn_Name]);
        set(findobj(estimirs_fig,'Tag','EditText_input'),'String',SigIn_Name);

    case 'edit_tolerence'
        tolerence_value = str2double(get(gcbo,'String'));
        if isnan(tolerence_value)
            set(gcbo,'String',1e-005);
        else
            set(gcbo,'String',tolerence_value);
        end
                
    case 'compute'
        current_cursor=fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(estimirs_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(estimirs_fig,'Tag','Button_close'),'enable','off');
            set(findobj(estimirs_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Tolerence %%%%%
            Tolerence = str2double(get(findobj(estimirs_fig,...
                        'Tag','EditText_tolerence'),'String'));
                    
            %%%%% Perform the computation %%%%%
            OutputName = ['Hirs_' SigIn_Name];
            varname = fl_findname(OutputName,varargin{2});
            eval(['global ' varname]);
            varargout{1} = varname;
            chaine_in = ['=estimirs(',SigIn_Name,',',num2str(Tolerence)];
            
            chaine = [varname,chaine_in,');'];
            eval(chaine);
            set(findobj(estimirs_fig,'Tag','EditText_output'),'String',eval(varname));
            
            fl_diary(chaine);
            % fl_addlist(0,varname);
            fl_waitoff(current_cursor);
            
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(estimirs_fig,'Tag','Button_close'),'enable','on');
            set(findobj(estimirs_fig,'Tag','Button_compute'),'enable','on');
        end
                
    case 'help'
        fl_doc estimirs
        
    case 'close'
        close(findobj('Tag', 'Fig_gui_fl_estimirs'));
end
end