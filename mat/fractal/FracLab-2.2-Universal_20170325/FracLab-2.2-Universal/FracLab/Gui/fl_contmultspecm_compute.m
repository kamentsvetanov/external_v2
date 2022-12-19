function [varargout]=fl_contmultspecm_compute(varargin)
% Callback functions for contmultspecm GUI Environment.

% Modified by Paul Balança, December 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,contmultspecm_fig] = gcbo;

if ((isempty(contmultspecm_fig)) || (~strcmp(get(contmultspecm_fig,'Tag'),'Fig_gui_fl_contmultspecm')))
    contmultspecm_fig = findobj ('Tag','Fig_gui_fl_contmultspecm');
end;

fl_clearerror;
switch(varargin{1});
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('Input signal must be a vector !') ;
            return
        end
        eval(['global ' SigIn_name]);
        set(findobj(contmultspecm_fig,'Tag','EditText_input'),'String',SigIn_name);
    
    case 'base_option'
        base = str2double(get(findobj(contmultspecm_fig,'Tag','EditText_base'),'String'));
        if get(findobj('Tag','RadioButton_linear'),'Value') && base < 1
            set(findobj(contmultspecm_fig,'Tag','EditText_base'),'String','2');
        elseif ~get(findobj('Tag','RadioButton_linear'),'Value') && base < 1.1
            set(findobj(contmultspecm_fig,'Tag','EditText_base'),'String','2');
        end
        
    case 'linear_option'
        if ~get(findobj('Tag','RadioButton_linear'),'Value')
            set(findobj('Tag','RadioButton_linear'),'Value',1);
        end
        set(findobj('Tag','RadioButton_geometric'),'Value',0);

    case 'geometric_option'
        if ~get(findobj('Tag','RadioButton_geometric'),'Value')
            set(findobj('Tag','RadioButton_geometric'),'Value',1);
        end
        set(findobj('Tag','RadioButton_linear'),'Value',0);
        fl_contmultspecm_compute('base_option');
        
    case 'compute'
        current_cursor=fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(contmultspecm_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
            return;
        end
        eval(['global ' SigIn_Name]);
        
        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(contmultspecm_fig,'Tag','Button_close'),'enable','off');
        set(findobj(contmultspecm_fig,'Tag','Button_compute'),'enable','off');
        
        %%%%% Get parameters %%%%%
        disc(1) = str2double(get(findobj(contmultspecm_fig,'Tag','EditText_alphadisc'),'String'));
        disc(2) = str2double(get(findobj(contmultspecm_fig,'Tag','EditText_epsdisc'),'String'));
        scale(1) = str2double(get(findobj(contmultspecm_fig,'Tag','EditText_minscale'),'String'));
        scale(2) = str2double(get(findobj(contmultspecm_fig,'Tag','EditText_maxscale'),'String'));
        base = str2double(get(findobj(contmultspecm_fig,'Tag','EditText_base'),'String'));

        smooth = 'nosmooth';
        if get(findobj(contmultspecm_fig,'Tag','Check_smooth'),'Value')
            smooth = 'smooth';
        end
        
        progression='power';
        if get(findobj(contmultspecm_fig,'Tag','RadioButton_linear'),'Value')
            progression='linear';
        end
        
        kernel_str{1} = 'rectangular';
        kernel_str{2} = 'epanechnikov';
        kernel = kernel_str{get(findobj(contmultspecm_fig,'Tag','Menu_kernel'),'Value')};
        
        %%%%% Perform the computation %%%%%
        OutputName = [SigIn_Name '_multspecf'];
        varname = fl_find_mnames(varargin{2},OutputName);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        chaine_in = ['=contmultspecm(',SigIn_Name,',''',kernel,...
                            ''',''',smooth,''',''',progression,...
                            ''',''sampling'',',mat2str(disc),',''limits'',',mat2str(scale),',''base'',',num2str(base),');'];
        chaine = [varname,chaine_in];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0, varname) ;
        fl_waitoff(current_cursor);

        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(contmultspecm_fig,'Tag','Button_close'),'enable','on');
        set(findobj(contmultspecm_fig,'Tag','Button_compute'),'enable','on');

    case 'help'  
        fl_doc contmultspecm
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_contmultspecm'));
end

end