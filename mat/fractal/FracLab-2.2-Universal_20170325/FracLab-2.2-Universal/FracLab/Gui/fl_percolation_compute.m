function [varargout]=fl_percolation_compute(varargin)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

% Modified by Christian Choque Cortez, November 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,percolation_fig] = gcbo;

if ((isempty(percolation_fig)) || (~strcmp(get(percolation_fig,'Tag'),'Fig_gui_fl_percolation')))
    percolation_fig = findobj ('Tag','Fig_gui_fl_percolation');
end;

fl_clearerror;
switch(varargin{1});
    case 'popmenu_material'
        material_value = get(gcbo,'Value');
        if material_value ~= 3
            set(findobj(percolation_fig,'Tag','EditText_material'),'String','','Enable','inactive');
            set(findobj(percolation_fig,'Tag','Button_refresh'),'Enable','off');
            set(findobj(percolation_fig,'Tag','Button_build'),'Enable','on');
            set(findobj(percolation_fig,'Tag','StaticText_sample'),'Enable','on');
            set(findobj(percolation_fig,'Tag','PopupMenu_sample'),'Value',5,'Enable','on');
            set(findobj(percolation_fig,'Tag','EditText_sample'),'String','128','Enable','on');
        else
            set(findobj(percolation_fig,'Tag','EditText_material'),'String','','Enable','inactive');
            set(findobj(percolation_fig,'Tag','Button_refresh'),'Enable','on');
            set(findobj(percolation_fig,'Tag','Button_build'),'Enable','off');
            set(findobj(percolation_fig,'Tag','StaticText_sample'),'Enable','off');
            set(findobj(percolation_fig,'Tag','PopupMenu_sample'),'Enable','off');
            set(findobj(percolation_fig,'Tag','EditText_sample'),'Enable','off');
            fl_warning('choose a signal and click Refresh',[],'Warning : ') ;
        end
    
    case 'build'
        current_cursor = fl_waiton;
        Mat_value = get(findobj(percolation_fig,'Tag','PopupMenu_material'),'Value');
        Nsamp = str2double(get(findobj(percolation_fig,'Tag','EditText_sample'),'String'));
        switch(Mat_value)
            case 1
                Out_name = 'Signalunif';
                SigIn_name = fl_findname(Out_name,varargin{2});
                eval(['global ' SigIn_name]);
                chaine = [SigIn_name,'=rand(',num2str(Nsamp),',',num2str(Nsamp),');'];
                eval(chaine);
                varargout{1} = SigIn_name;
            case 2
                Out_name = 'Signalfbm';
                SigIn_name = fl_findname(Out_name,varargin{2});
                eval(['global ' SigIn_name]);
                chaine = [SigIn_name,'=synth2(',num2str(Nsamp),',0.5);'];
                eval(chaine);
                varargout{1} = SigIn_name;
        end
        set(findobj(percolation_fig,'Tag','EditText_material'),'String',SigIn_name,'Enable','inactive');
        fl_diary(chaine);
        fl_addlist(0,SigIn_name);
        fl_waitoff(current_cursor);
        
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('matrix');
        if error_in
            fl_warning('input signal must be a matrix !') ;
            return
        end
        eval(['global ' SigIn_name]);
        set(findobj(percolation_fig,'Tag','EditText_material'),'String',SigIn_name);
        set(findobj(percolation_fig,'Tag','PopupMenu_material'),'Value',3);
        set(findobj(percolation_fig,'Tag','StaticText_sample'),'Enable','off');
        set(findobj(percolation_fig,'Tag','PopupMenu_sample'),'Enable','off');
        set(findobj(percolation_fig,'Tag','EditText_sample'),'Enable','off');
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(percolation_fig,'Tag','EditText_sample'),'String',sample_value);
        set(findobj(percolation_fig,'Tag','EditText_material'),'String','','Enable','inactive');
        
    case 'edit_sample'
        sample_value = str2double(get(gcbo,'String'));
        if isnan(sample_value)
            sample_value = 2^(get(findobj(percolation_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end
        set(findobj(percolation_fig,'Tag','EditText_material'),'String','','Enable','inactive');
    
    case 'edit_iterations'
        ni_value = str2double(get(gcbo,'String')) ;
        if isnan(ni_value)
            set(gcbo,'String','1000');
        else
            ni_value = floor(trunc(ni_value,1.0,Inf));
            set(gcbo,'String',num2str(ni_value)) ;
        end
        
    case 'check_visu'
        if get(gcbo,'Value')
            set(findobj(percolation_fig,'Tag','Check_visu'),'String','Show visu')
        else
            set(findobj(percolation_fig,'Tag','Check_visu'),'String','No visu')
        end

    case 'compute'
        current_cursor = fl_waiton;
        SigIn_name = get(findobj(percolation_fig,'Tag','EditText_material'),'String');
        if isempty(SigIn_name)
            fl_warning('Material must be initiated, click on Build or Refresh!');
            fl_waitoff(current_cursor);
            varargout{1} = 'flerror';
        else
            eval(['global ' SigIn_name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(percolation_fig,'Tag','Button_close'),'enable','off');
            set(findobj(percolation_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Parameters %%%%%
            Niter = str2double(get(findobj(percolation_fig,'Tag','EditText_iterations'),'String'));
            Hldvisu = get(findobj(percolation_fig,'Tag','Check_visu'),'Value');
            
            %%%%% Perform the computation %%%%%
            OutputNamea = 'perc'; OutputNamepc = 'cluster'; OutputNamepcb = 'clusterbin';
            OutputNamed = 'depth'; OutputNamef = 'front';
            [varnamea varnamepc varnamepcb varnamed varnamef] = fl_find_mnames(varargin{2}, ...
                OutputNamea,OutputNamepc,OutputNamepcb,OutputNamed,OutputNamef);
            eval(['global ' varnamea]); eval(['global ' varnamepc]); eval(['global ' varnamepcb]);
            eval(['global ' varnamed]); eval(['global ' varnamef]);
            varargout{1} = [varnamea ' ' varnamepc ' ' varnamepcb ' ' varnamed ' ' varnamef];

            chaine_in = ['=percolation(',SigIn_name,',''iter'',',num2str(Niter)];
            
            if ~Hldvisu, chaine_in = [chaine_in,',''novisu''']; end

            chaine = ['[',varnamea ' ' varnamepc ' ' varnamepcb ' ' varnamed ' ' varnamef,']',chaine_in,');'];
            eval(chaine);

            fl_diary(chaine);
            fl_addlist(0,varnamea); fl_addlist(0,varnamepc); fl_addlist(0,varnamepcb);
            fl_addlist(0,varnamed); fl_addlist(0,varnamef);
            fl_waitoff(current_cursor);

            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(percolation_fig,'Tag','Button_close'),'enable','on');
            set(findobj(percolation_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'
        fl_doc percolation

    case 'close'
        close(findobj(percolation_fig,'Tag', 'Fig_gui_fl_percolation'));

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
