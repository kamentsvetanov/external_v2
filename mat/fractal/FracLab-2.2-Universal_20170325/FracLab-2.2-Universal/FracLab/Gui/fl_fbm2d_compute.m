function [varargout]=fl_fbm2d_compute(varargin)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

% Modification Pierrick Legrand, January 2005.
% Modified by Christian Choque Cortez, March 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,fbmsynthesis2d_fig] = gcbo;

if ((isempty(fbmsynthesis2d_fig)) || (~strcmp(get(fbmsynthesis2d_fig,'Tag'),'Fig_gui_fl_fbmsynthesis2d')))
    fbmsynthesis2d_fig = findobj ('Tag','Fig_gui_fl_fbmsynthesis2d');
end

fl_clearerror;
switch(varargin{1})
    case 'slider_exponent'        
        slider_value = get(gcbo,'Value');
        set(findobj(fbmsynthesis2d_fig,'Tag','EditText_exponent'),'String',slider_value);

    case 'edit_exponent'
        exponent_value = str2double(get(gcbo,'String'));
        exponent_value = trunc(exponent_value,0.0,1.0);
        set(gcbo,'String',exponent_value);
        set(findobj(fbmsynthesis2d_fig,'Tag','Slider_exponent'),'Value',exponent_value);

    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(fbmsynthesis2d_fig,'Tag','EditText_sample'),'String',sample_value);
        
    case 'edit_sample'
        sample_value = str2double(get(gcbo,'String'));
        if isnan(sample_value)
            sample_value = 2^(get(findobj(fbmsynthesis2d_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end

    case 'compute'
        current_cursor=fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(fbmsynthesis2d_fig,'Tag','Button_close'),'enable','off');
        set(findobj(fbmsynthesis2d_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Holder exponent and N sample %%%%%
        Hexp = str2double(get(findobj(fbmsynthesis2d_fig,'Tag','EditText_exponent'),'String'));
        Nsamp = str2double(get(findobj(fbmsynthesis2d_fig,'Tag','EditText_sample'),'String'));

        %%%%% Perform the computation %%%%%
        OutputNamefbm = 'fBm2D';
        varname = fl_find_mnames(varargin{2},OutputNamefbm);
        eval(['global ' varname]);
        varargout{1} = varname;
        chaine_in = '=synth2(N,H';
        chaine = [varname chaine_in];

        chaine = [chaine ');'];
        chaine1 = ['N=', num2str(Nsamp),'; H=', num2str(Hexp),';'];

        eval(chaine1);
        eval(chaine);

        fl_diary(chaine1);
        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);

        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(fbmsynthesis2d_fig,'Tag','Button_close'),'enable','on');
        set(findobj(fbmsynthesis2d_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        fl_doc synth2

    case 'close'
        close(findobj(fbmsynthesis2d_fig,'Tag', 'Fig_gui_fl_fbmsynthesis2d'));

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