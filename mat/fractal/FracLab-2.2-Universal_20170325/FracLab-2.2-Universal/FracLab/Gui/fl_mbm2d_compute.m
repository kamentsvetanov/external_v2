function [varargout]=fl_mbm2d_compute(varargin)
% Callback functions for fbmsynthesis GUI Environment.

% Modified by Christian Choque Cortez, March 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mbmsynthesis2d_fig] = gcbo;

if ((isempty(mbmsynthesis2d_fig)) || (~strcmp(get(mbmsynthesis2d_fig,'Tag'),'Fig_gui_fl_mbmsynthesis2d')))
    mbmsynthesis2d_fig = findobj ('Tag','Fig_gui_fl_mbmsynthesis2d');
end

fl_clearerror;
switch(varargin{1})
    case 'popmenu_exponent'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(mbmsynthesis2d_fig,'Tag','EditText_exponent'),'String','0.1+0.8*x.*y');
                set(findobj(mbmsynthesis2d_fig,'Tag','Button_close'),'enable','on');
                set(findobj(mbmsynthesis2d_fig,'Tag','Button_compute'),'enable','on');
            case 2
                set(findobj(mbmsynthesis2d_fig,'Tag','EditText_exponent'),'String','0.5+0.2*sin(2*pi*x).*cos(3/2*pi*y)');
                set(findobj(mbmsynthesis2d_fig,'Tag','Button_close'),'enable','on');
                set(findobj(mbmsynthesis2d_fig,'Tag','Button_compute'),'enable','on');
            case 3
                set(findobj(mbmsynthesis2d_fig,'Tag','EditText_exponent'),'String','0.3+0.3./(1+exp(-100*(x-0.7)))');
                set(findobj(mbmsynthesis2d_fig,'Tag','Button_close'),'enable','on');
                set(findobj(mbmsynthesis2d_fig,'Tag','Button_compute'),'enable','on');
            case 4
                set(findobj(mbmsynthesis2d_fig,'Tag','EditText_exponent'),'String','');
        end

    case 'edit_exponent'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(mbmsynthesis2d_fig,'Tag','EditText_sample'),'String'));
        x = linspace(0,1,N); y = linspace(0,1,N); %#ok<NASGU>
        set(findobj(mbmsynthesis2d_fig,'Tag','PopupMenu_exponent'),'Value',4);
        try
            eval([function_value,';']);
            set(findobj(mbmsynthesis2d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(mbmsynthesis2d_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(mbmsynthesis2d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(mbmsynthesis2d_fig,'Tag','Button_compute'),'enable','off');
        end

    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(mbmsynthesis2d_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(mbmsynthesis2d_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end

    case 'edit_kmeans'
        k_value = str2double(get(gcbo,'String'));
        if isnan(k_value)
            set(gcbo,'String',25);
        else
            k_value = max(0,k_value);
            set(gcbo,'String',k_value);
        end

    case 'compute'
        current_cursor=fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(mbmsynthesis2d_fig,'Tag','Button_close'),'enable','off');
        set(findobj(mbmsynthesis2d_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Holder exponent and N sample %%%%%
        Hfunc = get(findobj(mbmsynthesis2d_fig,'Tag','EditText_exponent'),'String');
        Nsamp = str2double(get(findobj(mbmsynthesis2d_fig,'Tag','EditText_sample'),'String'));
        k = str2double(get(findobj(mbmsynthesis2d_fig,'Tag','EditText_kmeans'),'String'));

        %%%%% Perform the computation %%%%%
        OutputNamembm = 'mBm2D';
        varname = fl_find_mnames(varargin{2},OutputNamembm);
        eval(['global ' varname]);
        varargout{1} = varname;
        chaine_in = ['=mBm2DQuantifKrigeage(N,Hxy,',num2str(k)];
        
        chaine1 = ['N=', num2str(Nsamp), '; x=linspace(0,1,N); y=linspace(0,1,N); ',...
                   '[X,Y]=meshgrid(x,y); f = inline(''', Hfunc, ''',''x'',''y''); Hxy = f(X,Y);'];
        eval(chaine1);
        
        chaine = [varname,chaine_in,');'];
        eval(chaine);
        
        fl_diary(chaine1);
        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(mbmsynthesis2d_fig,'Tag','Button_close'),'enable','on');
        set(findobj(mbmsynthesis2d_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        fl_doc mBm2DQuantifKrigeage

    case 'close'
        close(findobj(mbmsynthesis2d_fig,'Tag', 'Fig_gui_fl_mbmsynthesis2d'));

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