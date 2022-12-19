function [varargout] = fl_ifsbdsynthesis_compute(varargin)
% Callback functions for ifsbdsynthesis GUI Environment.

% Author Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,ifsbdsynthesis_fig] = gcbo;

if ((isempty(ifsbdsynthesis_fig)) || (~strcmp(get(ifsbdsynthesis_fig,'Tag'),'Fig_gui_fl_ifsbdsynthesis')))
    ifsbdsynthesis_fig = findobj ('Tag','Fig_gui_fl_ifsbdsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'edit_interpoint'
        point = str2num(get(gcbo,'String'));  %#ok<ST2NM>
        if isempty(point) || comparevector(point)
            fl_warning('Interpolation points must be different [x,y] vectors!'); pause(.3)
            set(gcbo,'String','[0 0;0.5 1;1 0]');
            set(findobj(ifsbdsynthesis_fig,'Tag','EditText_contraction'),'String','[0.5;-0.9]');
        else
            point = sortrows(point); k =length(point);
            contraction = str2num(get(findobj(ifsbdsynthesis_fig,'Tag','EditText_contraction'),'String')); %#ok<ST2NM>
            if length(contraction) ~= length(point)
                contraction = round(10*rand(1,k-1)-5*ones(1,k-1))/5;
                set(findobj(ifsbdsynthesis_fig,'Tag','EditText_contraction'),'String',mat2str(contraction));
            end
            set(gcbo,'String',mat2str(point));
        end
        
    case 'check_law'
        if get(gcbo,'Value')
            set(gcbo,'String','Sinusoidal interpolation');
        else
            set(gcbo,'String','Affine interpolation');
        end
        
    case 'edit_contraction'
        contraction = str2num(get(gcbo,'String'));  %#ok<ST2NM>
        k = length(str2num(get(findobj(ifsbdsynthesis_fig,'Tag','EditText_point'),'String'))); %#ok<ST2NM>
        if isempty(contraction)
            fl_warning('Contraction coefs muts be a [C1;C2;...Ck-1] vector!'); pause(.3)
            contraction = round(10*rand(1,k-1)-5*ones(1,k-1))/5;
            set(gcbo,'String',mat2str(contraction));
        else
            if length(contraction) ~= k-1
                fl_warning('With k iterpolation points use k-1 coefficients!'); pause(.3)
                contraction = round(10*rand(1,k-1)-5*ones(1,k-1))/5;
                set(gcbo,'String',mat2str(contraction));
            else
                set(gcbo,'String',mat2str(contraction));
            end
        end
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(ifsbdsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(ifsbdsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end
                
    case 'compute'
        current_cursor = fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(ifsbdsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(ifsbdsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Interoplation points, Contraction coefs, N sample and Interpolation option %%%%%
        Minter = str2num(get(findobj(ifsbdsynthesis_fig,'Tag','EditText_point'),'String')); %#ok<ST2NM>
        Coefs = str2num(get(findobj(ifsbdsynthesis_fig,'Tag','EditText_contraction'),'String')); %#ok<ST2NM>
        Nsamp = str2double(get(findobj(ifsbdsynthesis_fig,'Tag','EditText_sample'),'String'));
        Hldsin = get(findobj(ifsbdsynthesis_fig,'Tag','Checkbox_law'),'Value');

        %%%%% Perform the computation %%%%%
        chaine_in = ['=ifsfif(',num2str(Nsamp),',',mat2str(Minter),',',mat2str(Coefs)];
        if Hldsin
            OutputNameifsb = 'fifds';
            chaine_in = [chaine_in,',''sinusoidal'''];
        else
            OutputNameifsb = 'fifda';
            chaine_in = [chaine_in,',''affine'''];
        end

        varname = fl_find_mnames(varargin{2},OutputNameifsb);
        eval(['global ' varname]);
        varargout{1} = varname;

        chaine = [varname,chaine_in,');'];
        eval(chaine);

        fl_diary(chaine);
        fl_addlist(0,varname);
        fl_waitoff(current_cursor);
        fl_waitoff(current_cursor);

        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(ifsbdsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(ifsbdsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        fl_doc ifsfif
        
    case 'close'  
        close(findobj(ifsbdsynthesis_fig,'Tag', 'Fig_gui_fl_ifsbdsynthesis'));

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