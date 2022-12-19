function [varargout] = fl_srmpsynthesis_compute(varargin)
% Callback functions for srmpsynthesis GUI Environment.

% Authors Christian Choque Cortez & Antoine echelard, June 2009.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,srmpsynthesis_fig] = gcbo;

if ((isempty(srmpsynthesis_fig)) || (~strcmp(get(srmpsynthesis_fig,'Tag'),'Fig_gui_fl_srmpsynthesis')))
    srmpsynthesis_fig = findobj ('Tag','Fig_gui_fl_srmpsynthesis');
end

fl_clearerror;
switch(varargin{1})
    case 'fbmbased_option'
        if ~get(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value')
            set(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value',1);
        end
        set(findobj(srmpsynthesis_fig,'Tag','RadioButton_midpoint'),'Value',0);
        set(findobj(srmpsynthesis_fig,'Tag','Checkbox_prescription'),'Style','checkbox', ...
            'Position',[0.05 0.29 0.36 0.075],'String','Prescribed shape','Value',0);
        set(findobj(srmpsynthesis_fig,'Tag','EditText_prescription'),'enable','off', ...
            'String','cos(2*pi*t)','Position',[0.5 0.295 0.46 0.075]);
        set(findobj(srmpsynthesis_fig,'Tag','StaticText_mix'),'enable','off','String','Mixing parameter');
        set(findobj(srmpsynthesis_fig,'Tag','EditText_mix'),'enable','off','String','2');
        
    case 'midpoint_option'
        if ~get(findobj(srmpsynthesis_fig,'Tag','RadioButton_midpoint'),'Value')
            set(findobj(srmpsynthesis_fig,'Tag','RadioButton_midpoint'),'Value',1);
        end
        set(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value',0);
        set(findobj(srmpsynthesis_fig,'Tag','Checkbox_prescription'),'Style','text', ...
            'Position',[0.05 0.28 0.36 0.075],'Horizontalalignment','left','String','Z(0), Z(1)','Value',0);
        set(findobj(srmpsynthesis_fig,'Tag','EditText_prescription'),'enable','on', ...
            'String','0,0','Position',[0.36 0.295 0.15 0.075]);
        set(findobj(srmpsynthesis_fig,'Tag','StaticText_mix'),'enable','on','String','Texture amplitude');
        set(findobj(srmpsynthesis_fig,'Tag','EditText_mix'),'enable','on','String','0.8');
        
    case 'popmenu_zfunction'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(srmpsynthesis_fig,'Tag','EditText_zfunction'),'String','1./(1+5*z.^2)');
                set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 2
                set(findobj(srmpsynthesis_fig,'Tag','EditText_zfunction'),'String','(1-z).^2');
                set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','on');
            case 3
                set(findobj(srmpsynthesis_fig,'Tag','EditText_zfunction'),'String','');        
        end
    
    case 'edit_zfunction'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(srmpsynthesis_fig,'Tag','EditText_sample'),'String'));
        z = linspace(0,1,N); %#ok<NASGU>
        set(findobj(srmpsynthesis_fig,'Tag','PopupMenu_zfunction'),'Value',3);
        try
            eval([function_value,';']);
            set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','on');
            set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','off');
            set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','off');
        end
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+3);
        set(findobj(srmpsynthesis_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        Hldfbmbased = get(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value');
        if isempty(sample_value)
            sample_value = 2^(get(findobj(srmpsynthesis_fig,'Tag','PopupMenu_sample'),'Value')+3);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
            if ~Hldfbmbased && mod(log2(sample_value),2) ~= 0 && mod(log2(sample_value),2) ~= 1
                fl_warning('With midpoint method size must be a power of 2');
                set(gcbo,'String',2^round(log2(sample_value)));
            end            
        end
        
    case 'check_shape'
        if get(gcbo,'Value')
            set(findobj(srmpsynthesis_fig,'Tag','EditText_prescription'),'enable','on');
            set(findobj(srmpsynthesis_fig,'Tag','StaticText_mix'),'enable','on');
            set(findobj(srmpsynthesis_fig,'Tag','EditText_mix'),'enable','on');
        else
            set(findobj(srmpsynthesis_fig,'Tag','EditText_prescription'),'enable','off');
            set(findobj(srmpsynthesis_fig,'Tag','StaticText_mix'),'enable','off');
            set(findobj(srmpsynthesis_fig,'Tag','EditText_mix'),'enable','off');
        end
        
    case 'edit_prescription'
        Hldfbmbased = get(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value');
        N = str2double(get(findobj(srmpsynthesis_fig,'Tag','EditText_sample'),'String'));
        if Hldfbmbased
            function_value = get(gcbo,'String');
            t = linspace(0,1,N); %#ok<NASGU>
            try
                eval([function_value,';']);
                set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','on');
                set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','on');
            catch %#ok<CTCH>
                fl_warning('Bad function format');
                set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','off');
                set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','off');
            end
        else
            param_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
            if isempty(param_value) || size(param_value,1) > 1 || size(param_value,2) ~= 2
                fl_warning('Z(0),Z(1) must be a [x,y] vector !'); pause(.3);
                set(gcbo,'String','0,0');
            else
                set(gcbo,'String',[num2str(param_value(1)),',',num2str(param_value(2))]);
            end
        end

    case 'edit_mix'
        mix_value = str2double(get(gcbo,'String'));
        if isnan(mix_value)
            if get(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value')
                set(gcbo,'String',2);
            else
                set(gcbo,'String',0.8);
            end
        else
            mix_value = max(0,mix_value);
            set(gcbo,'String',mix_value);
        end

    case 'edit_seed'
        seed_value = str2double(get(gcbo,'String'));
        if isnan(seed_value)
            set(gcbo,'String','');
        else
            seed_value = trunc(floor(seed_value),0,Inf);
            set(gcbo,'String',seed_value);
        end
        
    case 'compute'
        current_cursor = fl_waiton;

        %%%%%% Disable close and compute %%%%%%%%
        set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','off');
        set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Z function and N sample %%%%%
        Zfunc = get(findobj(srmpsynthesis_fig,'Tag','EditText_zfunction'),'String');
        Nsamp = str2double(get(findobj(srmpsynthesis_fig,'Tag','EditText_sample'),'String'));
        
        %%%%% Get Mixing/Texture and Seed %%%%%
        Mix = str2double(get(findobj(srmpsynthesis_fig,'Tag','EditText_mix'),'String'));
        Seed = str2double(get(findobj(srmpsynthesis_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Look for option %%%%%
        Hldfbmbased = get(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value');
        Hldshape = get(findobj(srmpsynthesis_fig,'Tag','Checkbox_prescription'),'Value');
        Shape = get(findobj(srmpsynthesis_fig,'Tag','EditText_prescription'),'String');

        %%%%% Perform the computation %%%%%
        if Hldfbmbased
            OutputNamesrmp = 'srmpfbm';    
            chaine_in = '=srmpfbm(N,gz';
            chaine1 = ['N=',num2str(Nsamp),'; z=linspace(0,1,N); gz = eval(''' Zfunc ''');'];
        else
            OutputNamesrmp = 'srmpmidpoint';
            chaine_in = '=srmpmidpoint(N,gz';
            chaine1 = ['N=',num2str(Nsamp),'; gz=''',Zfunc,''';'];
        end
        
        varname = fl_find_mnames(varargin{2},OutputNamesrmp);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        if Hldshape
            chaine_in = [chaine_in,',''shape'',{ft,',num2str(Mix),'}'];
            chaine1 = [chaine1, 't=linspace(0,1,N); ft = eval(''' Shape ''');'];
        end
        
        if ~Hldfbmbased && ~strcmp(Shape,'0,0'), chaine_in = [chaine_in,',''limits'',[',Shape,']']; end
        if ~Hldfbmbased && Mix ~= 1, chaine_in = [chaine_in,',''ampli'',',num2str(Mix)]; end       
        if ~isnan(Seed), chaine_in = [chaine_in,',',num2str(Seed)]; end
         
        eval(chaine1);
        try
            chaine = [varname,chaine_in,');'];
            eval(chaine);
            fl_diary(chaine1);
            fl_diary(chaine);
            fl_addlist(0,varname) ;
        catch %#ok<CTCH>
            fl_warning('The algorithm didn''t converge');
            varargout{1} = 'ans';
        end
        fl_waitoff(current_cursor);
        
        %%%%%% Enable close and compute %%%%%%%%
        set(findobj(srmpsynthesis_fig,'Tag','Button_close'),'enable','on');
        set(findobj(srmpsynthesis_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        Hldfbmbased = get(findobj(srmpsynthesis_fig,'Tag','RadioButton_fbmbased'),'Value');
        if Hldfbmbased
            fl_doc srmpfbm
        else
            fl_doc srmpmidpoint
        end
        
    case 'close'  
        close(findobj(srmpsynthesis_fig,'Tag', 'Fig_gui_fl_srmpsynthesis'));

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
