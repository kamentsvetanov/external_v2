function [varargout]=fl_dlasynthesis_compute(varargin)
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

[objTmp,dlasynthesis_fig] = gcbo;

if ((isempty(dlasynthesis_fig)) || (~strcmp(get(dlasynthesis_fig,'Tag'),'Fig_gui_fl_dlasynthesis')))
  dlasynthesis_fig = findobj ('Tag','Fig_gui_fl_dlasynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'popmenu_predefined'
        value = get(gcbo,'Value');
        switch (value)
            case 1
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_sample'),'Value',3);
                set(findobj(dlasynthesis_fig,'Tag','EditText_sample'),'String',32);
                set(findobj(dlasynthesis_fig,'Tag','EditText_particles'),'String',250);
                set(findobj(dlasynthesis_fig,'Tag','EditText_moves'),'String',200);
                set(findobj(dlasynthesis_fig,'Tag','EditText_launch'),'String',1);
                set(findobj(dlasynthesis_fig,'Tag','EditText_kill'),'String',5);
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_visu'),'Value',2);
            case 2
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_sample'),'Value',5);
                set(findobj(dlasynthesis_fig,'Tag','EditText_sample'),'String',128);
                set(findobj(dlasynthesis_fig,'Tag','EditText_particles'),'String',2500);
                set(findobj(dlasynthesis_fig,'Tag','EditText_moves'),'String',2000);
                set(findobj(dlasynthesis_fig,'Tag','EditText_launch'),'String',1);
                set(findobj(dlasynthesis_fig,'Tag','EditText_kill'),'String',20);
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_visu'),'Value',1);
            case 3
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_sample'),'Value',6);
                set(findobj(dlasynthesis_fig,'Tag','EditText_sample'),'String',256);
                set(findobj(dlasynthesis_fig,'Tag','EditText_particles'),'String',10000);
                set(findobj(dlasynthesis_fig,'Tag','EditText_moves'),'String',2000);
                set(findobj(dlasynthesis_fig,'Tag','EditText_launch'),'String',1);
                set(findobj(dlasynthesis_fig,'Tag','EditText_kill'),'String',20);
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_visu'),'Value',1);
            case 4
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_sample'),'Value',7);
                set(findobj(dlasynthesis_fig,'Tag','EditText_sample'),'String',512);
                set(findobj(dlasynthesis_fig,'Tag','EditText_particles'),'String',30000);
                set(findobj(dlasynthesis_fig,'Tag','EditText_moves'),'String',10000);
                set(findobj(dlasynthesis_fig,'Tag','EditText_launch'),'String',1);
                set(findobj(dlasynthesis_fig,'Tag','EditText_kill'),'String',20);
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_visu'),'Value',3);
            case 5
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_sample'),'Value',8);
                set(findobj(dlasynthesis_fig,'Tag','EditText_sample'),'String',1024);
                set(findobj(dlasynthesis_fig,'Tag','EditText_particles'),'String',100000);
                set(findobj(dlasynthesis_fig,'Tag','EditText_moves'),'String',20000);
                set(findobj(dlasynthesis_fig,'Tag','EditText_launch'),'String',1);
                set(findobj(dlasynthesis_fig,'Tag','EditText_kill'),'String',20);
                set(findobj(dlasynthesis_fig,'Tag','PopupMenu_visu'),'Value',3);
        end
        
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(dlasynthesis_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2double(get(gcbo,'String'));
        if isnan(sample_value)
            sample_value = 2^(get(findobj(dlasynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end    

    case 'edit_particles'
        p_value = str2double(get(gcbo,'String')) ;
        if isnan(p_value)
            set(gcbo,'String','10000');
        else
            p_value = floor(trunc(p_value,1.0,Inf));
            set(gcbo,'String',num2str(p_value)) ;
        end

    case 'edit_moves'
        m_value = str2double(get(gcbo,'String')) ;
        if isnan(m_value)
            set(gcbo,'String','2000');
        else
            m_value = floor(trunc(m_value,1.0,Inf));
            set(gcbo,'String',num2str(m_value)) ;
        end

    case 'edit_launch'
        rl_value = str2double(get(gcbo,'String')) ;
        if isnan(rl_value)
            set(gcbo,'String','1');
        else
            rl_value = floor(trunc(rl_value,1.0,Inf));
            set(gcbo,'String',num2str(rl_value)) ;
        end

    case 'edit_kill'
        rk_value = str2double(get(gcbo,'String')) ;
        if isnan(rk_value)
            set(gcbo,'String','20');
        else
            rk_value = floor(trunc(rk_value,1.0,Inf));
            set(gcbo,'String',num2str(rk_value)) ;
        end

    case 'edit_stick'
        sp_value = str2double(get(gcbo,'String')) ;
        if isnan(sp_value)
            set(gcbo,'String','1');
        else
            sp_value = trunc(sp_value,0.0,Inf);
            set(gcbo,'String',num2str(sp_value)) ;
        end

    case 'compute'
        current_cursor=fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(dlasynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(dlasynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Parameters %%%%%
        Nsamp = str2double(get(findobj(dlasynthesis_fig,'Tag','EditText_sample'),'String'));
        rl = str2double(get(findobj(dlasynthesis_fig,'Tag','EditText_launch'),'String'));
        rk = str2double(get(findobj(dlasynthesis_fig,'Tag','EditText_kill'),'String'));
        np = str2double(get(findobj(dlasynthesis_fig,'Tag','EditText_particles'),'String'));        
        nm = str2double(get(findobj(dlasynthesis_fig,'Tag','EditText_moves'),'String'));
        sp = str2double(get(findobj(dlasynthesis_fig,'Tag','EditText_stick'),'String'));
        visu = get(findobj(dlasynthesis_fig,'Tag','PopupMenu_visu'),'Value');
        if visu == 1, visu = 'visup';
        elseif visu == 2, visu = 'visud';
        else visu = 'novisu';
        end

        %%%%% Perform the computation %%%%%
        OutputNamedla = 'dla'; OutputNamer = 'rnp'; OutputNamep = 'pnp';
        [varnamedla varnamer varnamep] = fl_find_mnames(varargin{2},OutputNamedla,OutputNamer,OutputNamep);
        eval(['global ' varnamedla]); eval(['global ' varnamer]); eval(['global ' varnamep]);
        varargout{1} = [varnamedla ' ' varnamer ' ' varnamep];
        
        chaine_in = ['=dla(',num2str(Nsamp),',''radius'',',mat2str([rl,rk]),',''parts'',',num2str(np)];
        chaine_in = [chaine_in,',''moves'',',num2str(nm),',''stick'',',num2str(sp),',''',visu,''''];
        
        chaine = ['[',varnamedla ' ' varnamer ' ' varnamep,']',chaine_in,');'];
        eval(chaine);
        fl_diary(chaine);

        fl_addlist(0,varnamedla); fl_addlist(0,varnamer); fl_addlist(0,varnamep);
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(dlasynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(dlasynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        fl_doc dla

    case 'close'
        close(findobj(dlasynthesis_fig,'Tag', 'Fig_gui_fl_dlasynthesis'));

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
