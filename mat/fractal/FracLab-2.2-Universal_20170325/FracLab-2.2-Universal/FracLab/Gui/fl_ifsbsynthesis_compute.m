function [varargout] = fl_ifsbsynthesis_compute(varargin)
% Callback functions for ifsbsynthesis GUI Environment.

% Modified by Pierrick Legrand, January 2005
% Modified by Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,ifsbsynthesis_fig] = gcbo;

if ((isempty(ifsbsynthesis_fig)) || (~strcmp(get(ifsbsynthesis_fig,'Tag'),'Fig_gui_fl_ifsbsynthesis')))
    ifsbsynthesis_fig = findobj ('Tag','Fig_gui_fl_ifsbsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'edit_interpoint1'
        point = str2num(get(gcbo,'String'));  %#ok<ST2NM>
        if isempty(point), points(1,:) = [0,0]; else points(1,:) = point; end
        points(2,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point2'),'String'));  %#ok<ST2NM>
        points(3,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point3'),'String'));  %#ok<ST2NM>
        if isempty(point) || isequal(points(1,:),points(2,:)) || isequal(points(1,:),points(3,:))
            fl_warning('Interpolation points must be different [x,y] vectors!'); pause(.3)
            set(gcbo,'String','0,0');
        else            
            points = sortrows(points);
            set(gcbo,'String',[num2str(points(1,1)),',',num2str(points(1,2))]);
            set(findobj(ifsbsynthesis_fig,'Tag','EditText_point2'),'String',[num2str(points(2,1)),',',num2str(points(2,2))]);
            set(findobj(ifsbsynthesis_fig,'Tag','EditText_point3'),'String',[num2str(points(3,1)),',',num2str(points(3,2))]);
        end
        
    case 'edit_interpoint2'
        point = str2num(get(gcbo,'String'));  %#ok<ST2NM>
        points(1,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point1'),'String'));  %#ok<ST2NM>
        if isempty(point), points(2,:) = [0,0]; else points(2,:) = point; end
        points(3,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point3'),'String'));  %#ok<ST2NM>
        if isempty(point) || isequal(points(2,:),points(1,:)) || isequal(points(2,:),points(3,:))
            fl_warning('Interpolation point must be different [x,y] vectors!'); pause(.3)
            set(gcbo,'String',[num2str(mean([points(1,1) points(3,1)])),',',num2str(points(1,2) + 1)]);
        else
            points = sortrows(points);
            set(gcbo,'String',[num2str(points(2,1)),',',num2str(points(2,2))]);
            set(findobj(ifsbsynthesis_fig,'Tag','EditText_point1'),'String',[num2str(points(1,1)),',',num2str(points(1,2))]);
            set(findobj(ifsbsynthesis_fig,'Tag','EditText_point3'),'String',[num2str(points(3,1)),',',num2str(points(3,2))]);
        end    
    
    case 'edit_interpoint3'
        point = str2num(get(gcbo,'String'));  %#ok<ST2NM>
        points(1,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point1'),'String'));  %#ok<ST2NM>
        points(2,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point2'),'String'));  %#ok<ST2NM>
        if isempty(point), points(3,:) = [0,0]; else points(3,:) = point; end
        if isempty(point) || isequal(points(3,:),points(1,:)) || isequal(points(3,:),points(2,:))
            fl_warning('Interpolation point must be different [x,y] vectors!'); pause(.3)
            set(gcbo,'String',[num2str(points(2,1) + 0.5),',0']);
        else
            points = sortrows(points);
            set(gcbo,'String',[num2str(points(3,1)),',',num2str(points(3,2))]);
            set(findobj(ifsbsynthesis_fig,'Tag','EditText_point1'),'String',[num2str(points(1,1)),',',num2str(points(1,2))]);
            set(findobj(ifsbsynthesis_fig,'Tag','EditText_point2'),'String',[num2str(points(2,1)),',',num2str(points(2,2))]);
        end
      
    case 'edit_contraction'
        contraction = str2num(get(gcbo,'String'));  %#ok<ST2NM>
        if isempty(contraction) || length(contraction) ~= 2
            fl_warning('Contraction coefs muts be a [C1;C2] vector!'); pause(.3)
            set(gcbo,'String','0.5;0.9');
        else
            set(gcbo,'String',[num2str(contraction(1)),';',num2str(contraction(2))]);
        end
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(ifsbsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(ifsbsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
            if mod(log2(sample_value),2) ~= 0 && mod(log2(sample_value),2) ~= 1
                fl_warning('Sample size must be a power of 2');
                set(gcbo,'String',2^round(log2(sample_value)));
            end
        end
    
    case 'edit_ratio'
        ratio_value = str2double(get(gcbo,'String'));
        if isnan(ratio_value)
            set(gcbo,'String',1);
        else
            ratio_value = max(0,ratio_value);
            set(gcbo,'String',ratio_value);
        end
        
    case 'check_law'
        if get(gcbo,'Value')
            set(gcbo,'String','Uniform law');
        else
            set(gcbo,'String','Normal law');
        end
        
    case 'compute'
        current_cursor = fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(ifsbsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(ifsbsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Interoplation points, Contraction coefs, N sample and Ratio %%%%%
        Minter(1,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point1'),'String')); %#ok<ST2NM>
        Minter(2,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point2'),'String')); %#ok<ST2NM>
        Minter(3,:) = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_point3'),'String')); %#ok<ST2NM>
        Coefs = str2num(get(findobj(ifsbsynthesis_fig,'Tag','EditText_contraction'),'String')); %#ok<ST2NM> 
        Nsamp = str2double(get(findobj(ifsbsynthesis_fig,'Tag','EditText_sample'),'String'));
        Ratio = str2double(get(findobj(ifsbsynthesis_fig,'Tag','EditText_ratio'),'String'));
        
        %%%%% Look for option %%%%%
        Hldlaw = get(findobj(ifsbsynthesis_fig,'Tag','Checkbox_law'),'Value');

        %%%%% Perform the computation %%%%%
        chaine_in = ['=ifstfif(',num2str(Nsamp),',',mat2str(Minter),',',mat2str(Coefs)];
        
        if Hldlaw
            OutputNameifsb = 'fiftn';    
            chaine_in = [chaine_in,',''normal'''];
        else
            OutputNameifsb = 'fiftu';
            chaine_in = [chaine_in,',''uniform'''];
        end
        
        varname = fl_find_mnames(varargin{2},OutputNameifsb);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        chaine_in = [chaine_in,',''ratio'',',num2str(Ratio)];
        
        chaine = [varname,chaine_in,');'];
        eval(chaine);
        
        fl_diary(chaine);
        fl_addlist(0,varname);
        fl_waitoff(current_cursor);
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(ifsbsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(ifsbsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        fl_doc ifstfif
        
    case 'close'  
        close(findobj(ifsbsynthesis_fig,'Tag', 'Fig_gui_fl_ifsbsynthesis'));

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
