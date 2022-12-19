function [varargout] = fl_mbmsynthesis_compute(varargin)
% Callback functions for mbmsynthesis GUI Environment.

% Modified by Christian Choque Cortez, March 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mbmsynthesis_fig] = gcbo;

if ((isempty(mbmsynthesis_fig)) || (~strcmp(get(mbmsynthesis_fig,'Tag'),'Fig_gui_fl_mbmsynthesis')))
    mbmsynthesis_fig = findobj ('Tag','Fig_gui_fl_mbmsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'quantifkrigeage_option'
        if ~get(findobj(mbmsynthesis_fig,'Tag','RadioButton_quantifkrigeage'),'Value')
            set(findobj(mbmsynthesis_fig,'Tag','RadioButton_quantifkrigeage'),'Value',1);
        end
        set(findobj(mbmsynthesis_fig,'Tag','RadioButton_levinson'),'Value',0);
        set(findobj(mbmsynthesis_fig,'Tag','PopupMenu_exponent'),'String',...
            {'linear', 'periodic', 'logistic', 'user defined'});
        if get(findobj(mbmsynthesis_fig,'Tag','PopupMenu_exponent'),'Value') == 5
            set(findobj(mbmsynthesis_fig,'Tag','PopupMenu_exponent'),'Value',4);
            set(findobj(mbmsynthesis_fig,'Tag','EditText_exponent'),'String','');
        end
        set(findobj(mbmsynthesis_fig,'Tag','StaticText_kmeans'),'enable','on');
        set(findobj(mbmsynthesis_fig,'Tag','EditText_kmeans'),'enable','on');        
        
    case 'levinson_option'
        if ~get(findobj(mbmsynthesis_fig,'Tag','RadioButton_levinson'),'Value')
            set(findobj(mbmsynthesis_fig,'Tag','RadioButton_levinson'),'Value',1);
        end
        set(findobj(mbmsynthesis_fig,'Tag','RadioButton_quantifkrigeage'),'Value',0);
        set(findobj(mbmsynthesis_fig,'Tag','PopupMenu_exponent'),'String',...
            {'linear', 'periodic', 'logistic', 'user defined', 'piecewise constant'});
        set(findobj(mbmsynthesis_fig,'Tag','StaticText_kmeans'),'enable','off');
        set(findobj(mbmsynthesis_fig,'Tag','EditText_kmeans'),'enable','off','String',10);        
        
    case 'popmenu_exponent'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(mbmsynthesis_fig,'Tag','EditText_exponent'),'String','0.1+0.8*t');
                set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 2
                set(findobj(mbmsynthesis_fig,'Tag','EditText_exponent'),'String','0.5+0.3*sin(4*pi*t)');
                set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 3
                set(findobj(mbmsynthesis_fig,'Tag','EditText_exponent'),'String','0.3+0.3./(1+exp(-100*(t-0.7)))');
                set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 4
                set(findobj(mbmsynthesis_fig,'Tag','EditText_exponent'),'String','');
            case 5
                set(findobj(mbmsynthesis_fig,'Tag','EditText_exponent'),'String','[ones(1,N/2)*0.2 ones(1,N/2)*0.8]');
                set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','on');
        end
    
    case 'edit_exponent'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(mbmsynthesis_fig,'Tag','EditText_sample'),'String'));
        t = linspace(0,1,N); %#ok<NASGU>
        set(findobj(mbmsynthesis_fig,'Tag','PopupMenu_exponent'),'Value',4);
        try
            eval([function_value,';']);
            set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','on');
            set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','off');
            set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','off');
        end
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(mbmsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(mbmsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end
        	
    case 'edit_tmax'
        tmax_value = str2double(get(gcbo,'String'));
        if isnan(tmax_value)
            set(gcbo,'String',1);
        else
            tmax_value = max(0,tmax_value);
            set(gcbo,'String',tmax_value);
        end

    case 'edit_sigma'
        sigma_value = str2double(get(gcbo,'String'));
        if isnan(sigma_value)
            set(gcbo,'String',1);
        else
            sigma_value = max(0,sigma_value);
            set(gcbo,'String',sigma_value);
        end

    case 'edit_seed'
        seed_value = str2double(get(gcbo,'String'));
        if isnan(seed_value)
            set(gcbo,'String','');
        else
            seed_value = trunc(floor(seed_value),0,Inf);
            set(gcbo,'String',seed_value);
        end

    case 'edit_kmeans'
        k_value = str2double(get(gcbo,'String'));
        if isnan(k_value)
            set(gcbo,'String',10);
        else
            k_value = max(0,k_value);
            set(gcbo,'String',k_value);
        end
        
    case 'compute'
        current_cursor=fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Holder exponent and N sample %%%%%
        Hfunc = get(findobj(mbmsynthesis_fig,'Tag','EditText_exponent'),'String');
        Nsamp = str2double(get(findobj(mbmsynthesis_fig,'Tag','EditText_sample'),'String'));
        k = str2double(get(findobj(mbmsynthesis_fig,'Tag','EditText_kmeans'),'String'));
        
        %%%%% Get Tmax Sigma and Seed %%%%%
        Tmax = str2double(get(findobj(mbmsynthesis_fig,'Tag','EditText_tmax'),'String'));
        Sigma = str2double(get(findobj(mbmsynthesis_fig,'Tag','EditText_sigma'),'String'));
        Seed = str2double(get(findobj(mbmsynthesis_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Look for option %%%%%
        Hldwood = get(findobj(mbmsynthesis_fig,'Tag','RadioButton_quantifkrigeage'),'Value');

        %%%%% Computes H values %%%%%
        %Hfunc = [Hfunc ' + 0.0*t'];
        chaine1 = ['N=',num2str(Nsamp),'; t=linspace(0,',num2str(Tmax),',N); Ht = eval(''' Hfunc ''');'];
        eval(chaine1);        
        fl_diary(chaine1);
        
        %%%%% Particular case of fBm: call fbmsynthesis functions %%%%%
        if min(Ht) == max(Ht)
            
            Hexp = max(Ht);
            %%%%% Perform the computation %%%%%
            if Hldwood
                OutputNamefbm = 'mbmqk';    
                chaine_in = ['=fbmwoodchan(',num2str(Nsamp),',',num2str(Hexp)];
            else
                OutputNamefbm = 'mbmlev';
                chaine_in = ['=fbmlevinson(',num2str(Nsamp),',',num2str(Hexp)];
            end

            varname = fl_find_mnames(varargin{2},OutputNamefbm);
            eval(['global ' varname]);
            varargout{1} = varname;

            chaine_in = [chaine_in,',''support'',',num2str(Tmax),',''sigma'',',num2str(Sigma)];
            if ~isnan(Seed), chaine_in = [chaine_in,',''seed'',',num2str(Seed)]; end

            chaine = [varname,chaine_in,');'];
            eval(chaine);
            
        else   %%%%% mBm
        
            %%%%% Perform the computation %%%%%
            if Hldwood
                OutputNamefbm = 'mbmqk';    
                chaine_in = ['=mBmQuantifKrigeage(N,Ht',',',num2str(k)];
            else
                OutputNamefbm = 'mbmlev';
                chaine_in = '=mbmlevinson(N,Ht';
            end

            varname = fl_find_mnames(varargin{2},OutputNamefbm);
            eval(['global ' varname]);
            varargout{1} = varname;

            chaine_in = [chaine_in,',''support'',',num2str(Tmax),',''sigma'',',num2str(Sigma)];
            if ~isnan(Seed), chaine_in = [chaine_in,',''seed'',',num2str(Seed)]; end

            chaine = [varname,chaine_in,');'];
            eval(chaine);        
        end
        
        fl_diary(chaine);
        fl_addlist(0,varname) ;
        fl_waitoff(current_cursor);
        
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(mbmsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(mbmsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        Hldwood = get(findobj(mbmsynthesis_fig,'Tag','RadioButton_quantifkrigeage'),'Value');
        if Hldwood
            fl_doc mBmQuantifKrigeage
        else
            fl_doc mbmlevinson
        end
        
    case 'close'  
        close(findobj(mbmsynthesis_fig,'Tag', 'Fig_gui_fl_mbmsynthesis'));

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
