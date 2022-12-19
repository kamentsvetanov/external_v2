function [varargout] = fl_ifsgbdsynthesis_compute(varargin)
% Callback functions for ifsgbdsynthesis GUI Environment.

% Author Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,ifsgbdsynthesis_fig] = gcbo;

if ((isempty(ifsgbdsynthesis_fig)) || (~strcmp(get(ifsgbdsynthesis_fig,'Tag'),'Fig_gui_fl_ifsgbdsynthesis')))
    ifsgbdsynthesis_fig = findobj ('Tag','Fig_gui_fl_ifsgbdsynthesis');
end

fl_clearerror;
switch(varargin{1})        
    case 'edit_interpoint'
        point = str2num(get(gcbo,'String'));  %#ok<ST2NM>
        if length(point) ~= 3
            fl_warning('Generalized option require 3 interpolation points!'); pause(.3)
            point = [0 0;0.5 1;1 0];
            set(gcbo,'String','[0 0;0.5 1;1 0]');
        end
        if isempty(point) || comparevector(point)
            fl_warning('Interpolation points must be different [x,y] vectors!'); pause(.3)
            set(gcbo,'String','[0 0;0.5 1;1 0]');
        end
    
    case 'popmenu_exponent'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(ifsgbdsynthesis_fig,'Tag','EditText_contraction'),'String','0.2*(1-floor(2*t))+0.8*floor(2*t)');
                set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 2
                set(findobj(ifsgbdsynthesis_fig,'Tag','EditText_contraction'),'String','0.1+0.8*t');
                set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 3
                set(findobj(ifsgbdsynthesis_fig,'Tag','EditText_contraction'),'String','abs(sin(3*pi*t))');
                set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 4
                set(findobj(ifsgbdsynthesis_fig,'Tag','EditText_contraction'),'String','');
        end
        set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','on');
        
    case 'edit_contraction'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(ifsgbdsynthesis_fig,'Tag','EditText_sample'),'String'));
        t = linspace(0,1,N); %#ok<NASGU>
        set(findobj(ifsgbdsynthesis_fig,'Tag','PopupMenu_exponent'),'Value',4);
        try
            eval([function_value,';']);
            set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','on');
            set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','off');
            set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','off');
        end
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(ifsgbdsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(ifsgbdsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
            if mod(log2(sample_value),2) ~= 0 && mod(log2(sample_value),2) ~= 1
                fl_warning('Generalized option require a power of 2 sample size');
                set(gcbo,'String',2^round(log2(sample_value)));
            end
        end
        
    case 'compute'
        current_cursor = fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Interoplation points, Holder function and N sample %%%%%
        Minter = str2num(get(findobj(ifsgbdsynthesis_fig,'Tag','EditText_point'),'String')); %#ok<ST2NM>
        Hfunc = get(findobj(ifsgbdsynthesis_fig,'Tag','EditText_contraction'),'String');
        Nsamp = str2double(get(findobj(ifsgbdsynthesis_fig,'Tag','EditText_sample'),'String'));

        %%%%% Perform the computation %%%%%
        OutputNameifsgb = 'fifdg';
        chaine_in = ['=ifsgfif(N,',mat2str(Minter),',Ht'];
        chaine1 = ['N=',num2str(Nsamp),'; Ht=''',Hfunc,''';'];
        eval(chaine1);
        fl_diary(chaine1);

        varname = fl_find_mnames(varargin{2},OutputNameifsgb);
        eval(['global ' varname]);
        varargout{1} = varname;

        chaine = [varname,chaine_in,');'];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0,varname);
        fl_waitoff(current_cursor);
        fl_waitoff(current_cursor);

        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(ifsgbdsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(ifsgbdsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
            fl_doc ifsgfif
        
    case 'close'  
        close(findobj(ifsgbdsynthesis_fig,'Tag', 'Fig_gui_fl_ifsgbdsynthesis'));

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
function o=comparevector(v)
n = length(v);
o = 0;
k = linspace(2,n,n-1);

for i = 1:n-1
    p = i;
    while p ~= n
        if isequal(v(i,:),v(k(p),:)), o = 1; return; end
        p = p+1;
    end
end
end