function [varargout] = fl_srmpsynthesis2d_compute(varargin)
% Callback functions for srmpsynthesis2d GUI Environment.

% Authors Christian Choque Cortez & Antoine echelard, June 2009.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,srmpsynthesis2d_fig] = gcbo;

if ((isempty(srmpsynthesis2d_fig)) || (~strcmp(get(srmpsynthesis2d_fig,'Tag'),'Fig_gui_fl_srmpsynthesis2d')))
    srmpsynthesis2d_fig = findobj ('Tag','Fig_gui_fl_srmpsynthesis2d');
end

fl_clearerror;
switch(varargin{1})
    case 'popmenu_zfunction'
        function_type = get(gcbo,'Value');
        switch function_type
            case 1
                set(findobj(srmpsynthesis2d_fig,'Tag','EditText_zfunction'),'String','1./(1+5*z.^2)');
                set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','on');
                set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','on');
            case 2
                set(findobj(srmpsynthesis2d_fig,'Tag','EditText_zfunction'),'String','(1-z).^2');
                set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','on');
                set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','on');

            case 3
                set(findobj(srmpsynthesis2d_fig,'Tag','EditText_zfunction'),'String','');        
        end
    
    case 'edit_zfunction'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(srmpsynthesis2d_fig,'Tag','EditText_sample'),'String'));
        z = linspace(0,1,N); %#ok<NASGU>
        set(findobj(srmpsynthesis2d_fig,'Tag','PopupMenu_zfunction'),'Value',3);
        try
            eval([function_value,';']);
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','off');
        end
    
    case 'popmenu_sample'
        sample_value = 2^(get(gcbo,'Value')+2);
        set(findobj(srmpsynthesis2d_fig,'Tag','EditText_sample'),'String',sample_value);

    case 'edit_sample'
        sample_value = str2num(get(gcbo,'String')); %#ok<ST2NM>
        if isempty(sample_value)
            sample_value = 2^(get(findobj(srmpsynthesis2d_fig,'Tag','PopupMenu_sample'),'Value')+2);
            set(gcbo,'String',sample_value);
        else
            sample_value = floor(trunc(sample_value,1.0,Inf));
            set(gcbo,'String',sample_value);
        end
        
    case 'check_shape'
        if get(gcbo,'Value')
            set(findobj(srmpsynthesis2d_fig,'Tag','EditText_prescription'),'enable','on');
            set(findobj(srmpsynthesis2d_fig,'Tag','StaticText_mix'),'enable','on');
            set(findobj(srmpsynthesis2d_fig,'Tag','EditText_mix'),'enable','on');
        else
            set(findobj(srmpsynthesis2d_fig,'Tag','EditText_prescription'),'enable','off');
            set(findobj(srmpsynthesis2d_fig,'Tag','StaticText_mix'),'enable','off');
            set(findobj(srmpsynthesis2d_fig,'Tag','EditText_mix'),'enable','off');
        end
        
    case 'edit_prescription'
        function_value = get(gcbo,'String');
        N = str2double(get(findobj(srmpsynthesis2d_fig,'Tag','EditText_sample'),'String'));
        x = linspace(0,1,N); y = linspace(0,1,N); %#ok<NASGU>
        try
            eval([function_value,';']);
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','on');
        catch %#ok<CTCH>
            fl_warning('Bad function format');
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','off');
        end

    case 'edit_mix'
        mix_value = str2double(get(gcbo,'String'));
        if isnan(mix_value)
            set(gcbo,'String',1);
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
        set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','off');
        set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','off');

        %%%%% Get Z function and N sample %%%%%
        Zfunc = get(findobj(srmpsynthesis2d_fig,'Tag','EditText_zfunction'),'String');
        Nsamp = str2double(get(findobj(srmpsynthesis2d_fig,'Tag','EditText_sample'),'String'));
        
        %%%%% Get Mixing/Texture and Seed %%%%%
        Mix = str2double(get(findobj(srmpsynthesis2d_fig,'Tag','EditText_mix'),'String'));
        Seed = str2double(get(findobj(srmpsynthesis2d_fig,'Tag','EditText_seed'),'String'));
        
        %%%%% Look for option %%%%%
        Hldshape = get(findobj(srmpsynthesis2d_fig,'Tag','Checkbox_prescription'),'Value');
        Shape = get(findobj(srmpsynthesis2d_fig,'Tag','EditText_prescription'),'String');
        
        %%%%% Perform the computation %%%%%
        OutputNamesrmp = 'srmpfbm2d';
        varname = fl_find_mnames(varargin{2},OutputNamesrmp);
        eval(['global ' varname]);
        varargout{1} = varname;
        
        chaine_in = '=srmpfbm2d(N,gz';
        chaine1 = ['N=',num2str(Nsamp),'; z=linspace(0.6,1,N); gz = eval(''' Zfunc ''');'];
        
        if Hldshape 
            chaine_in = [chaine_in,',''shape'',{fxy,',num2str(Mix),'}']; 
            chaine1 = [chaine1, 'x=linspace(0,1,N); y=linspace(0,1,N); ',...
            '[X,Y]=meshgrid(x,y); f = inline(''', Shape, ''',''x'',''y''); fxy = f(X,Y);'];
        end
        
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
        set(findobj(srmpsynthesis2d_fig,'Tag','Button_close'),'enable','on');
        set(findobj(srmpsynthesis2d_fig,'Tag','Button_compute'),'enable','on');

    case 'help'
        fl_doc srmpfbm2d
        
    case 'close'  
        close(findobj(srmpsynthesis2d_fig,'Tag', 'Fig_gui_fl_srmpsynthesis2d'));

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
