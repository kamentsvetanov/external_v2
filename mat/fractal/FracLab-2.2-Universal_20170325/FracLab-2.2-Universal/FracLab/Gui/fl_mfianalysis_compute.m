function [varargout] = fl_mfianalysis_compute(varargin)
% Callback functions for mfianalysis GUI Environment.

% Author Christian Choque Cortez, September 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,mfianalysis_fig] = gcbo;

if ((isempty(mfianalysis_fig)) || (~strcmp(get(mfianalysis_fig,'Tag'),'Fig_gui_fl_mfianalysis')))
    mfianalysis_fig = findobj ('Tag','Fig_gui_fl_mfianalysis');
end

fl_clearerror;
switch(varargin{1});
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('matrix');
        if error_in
            fl_warning('input signal must be a matrix !') ;
            return
        end
        eval(['global ' SigIn_name]);
        set(findobj(mfianalysis_fig,'Tag','EditText_input'),'String',SigIn_name);
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes3'));
        set(findobj(mfianalysis_fig,'Tag','StaticText_fig3'),'String',SigIn_name);
        imagesc(eval(SigIn_name));set(gca,'Tag','axes3');
    
    case 'method'
        if get(gcbo,'Value') == 6
            set(findobj(mfianalysis_fig,'Tag','StaticText_sensibility'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','Slider_sensibility'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','EditText_sensibility'),'enable','on');
        else
            set(findobj(mfianalysis_fig,'Tag','StaticText_sensibility'),'enable','off');
            set(findobj(mfianalysis_fig,'Tag','Slider_sensibility'),'enable','off');
            set(findobj(mfianalysis_fig,'Tag','EditText_sensibility'),'enable','off');
        end
    
    case 'slider_sensibility'
        nmax = 250; nfigmax = 255;
        slider_value = trunc(get(gcbo,'Value'),0.1,1)*nmax;
        if slider_value == nmax
            set(findobj(mfianalysis_fig,'Tag','EditText_sensibility'),'String',nfigmax);
        else
            set(findobj(mfianalysis_fig,'Tag','EditText_sensibility'),'String',slider_value);
        end
    
    case 'edit_sensibility'
        sensibility_value = str2double(get(gcbo,'String'));
        nmax = 250; nfigmax = 255; nfigmin = 25; 
        if isnan(sensibility_value)
            sensibility_value = 200;
            set(gcbo,'String',sensibility_value);
            set(findobj(mfianalysis_fig,'Tag','Slider_sensibility'),'Value',sensibility_value/nmax);
        else
            sensibility_value = trunc(sensibility_value,nfigmin,nfigmax);
            set(gcbo,'String',sensibility_value);
            sensibility_slider = trunc(sensibility_value/nfigmax,0.1,1);
            set(findobj(mfianalysis_fig,'Tag','Slider_sensibility'),'Value',sensibility_slider);
        end
            
    case 'check_negative'
        if get(gcbo,'Value')
            set(gcbo,'String','Negative image');
        else
            set(gcbo,'String','Original image');
        end
    
    case 'edit_radius'
        radius_value = str2double(get(gcbo,'String'));
        if isnan(radius_value)
            fl_warning('The radius must be an integer !'); pause(.3);
            set(gcbo,'String',2);
        else
            radius_value = round(trunc(radius_value,1,5));
            set(gcbo,'String',radius_value);
        end
    
    case 'edit_step'
        na_value = str2double(get(gcbo,'String'));
        if isnan(na_value)
            fl_warning('The number of alpha bins must be an integer !'); pause(.3);
            set(gcbo,'String',100);
        else
            na_value = round(trunc(na_value,1,inf));
            set(gcbo,'String',na_value);
        end
    
    case 'edit_min'
        min_value = str2double(get(gcbo,'String'));
        max_value = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_max'),'String'));
        if isnan(min_value)
            set(gcbo,'String',max_value - 0.25)
        else
            min_value = trunc(min_value,0,max_value);
            set(gcbo,'String',min_value);
        end
        
    case 'edit_max'
        max_value = str2double(get(gcbo,'String'));
        min_value = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_min'),'String'));
        if isnan(max_value)
            set(gcbo,'String',min_value + 0.25)
        else
            max_value = trunc(max_value,min_value,2);
            set(gcbo,'String',max_value);
        end

    case 'compute'
        current_cursor = fl_waiton;
        method = get(findobj(mfianalysis_fig,'Tag','Method_menu'),'String');
        %%%%% Get the input %%%%%%
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        if isempty(SigIn_name)
            fl_warning('Input image must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_name]);
            SigIn = eval(SigIn_name);
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(mfianalysis_fig,'Tag','Button_close'),'enable','off');
            set(findobj(mfianalysis_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Method Radius and Alpha bins %%%%%
            Method = method{get(findobj(mfianalysis_fig,'Tag','Method_menu'),'Value')};
            Radius = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_radius'),'String'));
            NA_value = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_alphabins'),'String'));
            Sensibility = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_sensibility'),'String'));
            
            %%%%% Look for option %%%%%
            Hldnegative = get(findobj(mfianalysis_fig,'Tag','Check_negative'),'Value');
            Hldiso = strcmp(Method,'iso');
            
            %%%%% Perform the computation %%%%%
            OutputNameA = ['A_image_' SigIn_name]; OutputNameF = ['F_image_' SigIn_name];
            [varnameA varnameF] = fl_find_mnames(varargin{2},OutputNameA,OutputNameF);                                    
            eval(['global ' varnameA]); eval(['global ' varnameF]); 
            varargout{1} = varnameA; varargout{2} = varnameF; 
            
            chaine1 = ['=alphaimage(',SigIn_name,',',num2str(Radius),',','''',Method,''''];
            
            if Hldiso, chaine1 = [chaine1,',',num2str(Sensibility)]; end
            if Hldnegative, chaine1 = [chaine1,',''neg''']; end
            
            chaine2 = ['=falphaimage(',varnameA,',',num2str(NA_value)];  
            chaine1 = [varnameA chaine1,');']; 
            eval(chaine1);
            chaine2 = [varnameF chaine2,');'];
            eval(chaine2);
            
            fl_diary(chaine1);
            fl_addlist(0,varnameA);
            fl_diary(chaine2);
            fl_addlist(0,varnameF);

            %%%%% Displaying figures %%%%%%%%%%%%%%%%%%%%
            A = eval(varnameA);
            [F,fs] = falphaimage(A,NA_value);
            [Yh,catSe] = spotted(SigIn,F);
            
            set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes1')); 
            imagesc(Yh); set(gca,'Tag','axes1'); % 0 < F(alpha) bw < 0.25
            set(findobj(mfianalysis_fig,'Tag','StaticText_fig1'),'String','0 < F(alpha) bw < 0.25');
            set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes2')); 
            imagesc(catSe); set(gca,'Tag','axes2'); % Haussdorf segmentation
            set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes4'));
            set(findobj(mfianalysis_fig,'Tag','StaticText_fig4'),'String',varnameA);
            imagesc(A); set(gca,'Tag','axes4'); % Alpha Image
            set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes5'));
            plot(fs.bins,fs.spec); set(gca,'Tag','axes5'); % Spectrum MF
            set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes6'));
            set(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String',varnameF);
            imagesc(F); set(gca,'Tag','axes6'); % F(alpha) Image
            set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes7'));
            imagesc(spotted(SigIn,F,[0.8,1.2])); set(gca,'Tag','axes7'); % 0.8 < F(alpha) bw < 1.2
            set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes8'));
            imagesc(spotted(SigIn,F,[1.3,1.7])); set(gca,'Tag','axes8'); % 1.3 < F(alpha) bw < 1.7
            
            fl_waitoff(current_cursor);
        
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(mfianalysis_fig,'Tag','Button_close'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','Button_compute'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','StaticText_min'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','EditText_min'),'String',0,'enable','on');
            set(findobj(mfianalysis_fig,'Tag','StaticText_max'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','EditText_max'),'String',0.25,'enable','on');
            set(findobj(mfianalysis_fig,'Tag','Check_normalized'),'Value',0);
            set(findobj(mfianalysis_fig,'Tag','Button_apply'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','Button_default'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','Button_increase'),'enable','on');
            set(findobj(mfianalysis_fig,'Tag','Button_decrease'),'enable','on');
        end
    
    case 'apply'
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        OutputNameF = get(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String');
        eval(['global ' OutputNameF]);
        OutputNameYh = ['Fbw_' SigIn_name]; OutputNameC = ['Seg_' SigIn_name];

        donjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_min'),'String'));
        gornjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_max'),'String'));
        
        chaine = ['=spotted(',SigIn_name,',',OutputNameF,',[',num2str(donjif),',',num2str(gornjif),']'];
        chaine = ['[',OutputNameYh ' ' OutputNameC ']',chaine,');']; 
        eval(chaine);
        
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes1')); 
        imagesc(eval(OutputNameYh)); set(gca,'Tag','axes1');
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes2')); 
        imagesc(eval(OutputNameC)); set(gca,'Tag','axes2');
        set(findobj(mfianalysis_fig,'Tag','StaticText_fig1'),'String',[num2str(donjif),' < F(alpha) bw < ',num2str(gornjif)]);
        
    case 'default'
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        OutputNameF = get(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String');
        eval(['global ' OutputNameF]);
        OutputNameYh = ['Fbw_' SigIn_name]; OutputNameC = ['Seg_' SigIn_name];

        donjif = 0; gornjif = 0.25;
        set(findobj(mfianalysis_fig,'Tag','EditText_min'),'String',donjif);
        set(findobj(mfianalysis_fig,'Tag','EditText_max'),'String',gornjif);
        
        chaine = ['=spotted(',SigIn_name,',',OutputNameF,',[',num2str(donjif),',',num2str(gornjif),']'];
        chaine = ['[',OutputNameYh ' ' OutputNameC ']',chaine,');']; 
        eval(chaine);
        
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes1')); 
        imagesc(eval(OutputNameYh)); set(gca,'Tag','axes1');
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes2')); 
        imagesc(eval(OutputNameC)); set(gca,'Tag','axes2');
        set(findobj(mfianalysis_fig,'Tag','StaticText_fig1'),'String','0 < F(alpha) bw < 0.25 ');
        
    case 'increase'
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        OutputNameF = get(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String');
        eval(['global ' OutputNameF]);
        OutputNameYh = ['Fbw_' SigIn_name]; OutputNameC = ['Seg_' SigIn_name];

        donjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_min'),'String'));
        gornjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_max'),'String'));
        set(findobj(mfianalysis_fig,'Tag','EditText_max'),'String',min(2,gornjif + 0.05));
        gornjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_max'),'String'));
        
        chaine = ['=spotted(',SigIn_name,',',OutputNameF,',[',num2str(donjif),',',num2str(gornjif),']'];
        chaine = ['[',OutputNameYh ' ' OutputNameC ']',chaine,');']; 
        eval(chaine);
        
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes1')); 
        imagesc(eval(OutputNameYh)); set(gca,'Tag','axes1');
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes2')); 
        imagesc(eval(OutputNameC)); set(gca,'Tag','axes2');
        set(findobj(mfianalysis_fig,'Tag','StaticText_fig1'),'String',[num2str(donjif),' < F(alpha) bw < ',num2str(gornjif)]);
        
    case 'decrease'
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        OutputNameF = get(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String');
        eval(['global ' OutputNameF]);
        OutputNameYh = ['Fbw_' SigIn_name]; OutputNameC = ['Seg_' SigIn_name];

        donjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_min'),'String'));
        gornjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_max'),'String'));
        set(findobj(mfianalysis_fig,'Tag','EditText_max'),'String',max(donjif,gornjif - 0.05));
        gornjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_max'),'String'));
        
        chaine = ['=spotted(',SigIn_name,',',OutputNameF,',[',num2str(donjif),',',num2str(gornjif),']'];
        chaine = ['[',OutputNameYh ' ' OutputNameC ']',chaine,');']; 
        eval(chaine);
                
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes1')); 
        imagesc(eval(OutputNameYh)); set(gca,'Tag','axes1');
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes2')); 
        imagesc(eval(OutputNameC)); set(gca,'Tag','axes2');
        set(findobj(mfianalysis_fig,'Tag','StaticText_fig1'),'String',[num2str(donjif),' < F(alpha) bw < ',num2str(gornjif)]);
        
    case 'save2'
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        OutputNameF = get(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String');
        eval(['global ' OutputNameF]);
        
        OutputNameYh = ['Fbw_' SigIn_name]; OutputNameC = ['Seg_' SigIn_name];
        [varnameYh varnameC] = fl_find_mnames(varargin{2},OutputNameYh,OutputNameC);        
        
        eval(['global ' varnameYh]); eval(['global ' varnameC]);
        varargout{1} = varnameYh; varargout{2} = varnameC; 

        donjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_min'),'String'));
        gornjif = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_max'),'String'));
        
        chaine = ['=spotted(',SigIn_name,',',OutputNameF,',[',num2str(donjif),',',num2str(gornjif),']'];
        chaine = ['[',varnameYh ' ' varnameC ']',chaine,');']; 
        eval(chaine);       
        fl_diary(chaine);
        fl_addlist(0,varnameYh); fl_addlist(0,varnameC);
    
    case 'check_normalized'
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        OutputNameA = get(findobj(mfianalysis_fig,'Tag','StaticText_fig4'),'String');
        eval(['global ' OutputNameA]);
        OutputNameF = get(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String');
        OutputNamef = ['fs_spectrum_' SigIn_name];
        
        NA_value = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_alphabins'),'String'));
        Hldnorm = get(findobj(mfianalysis_fig,'Tag','Check_normalized'),'Value');
        
        chaine = ['=falphaimage(',OutputNameA,',',num2str(NA_value)];
        if Hldnorm, chaine = [chaine,',''norm''']; end
        chaine = ['[',OutputNameF ' ' OutputNamef,']',chaine,');'];    
        eval(chaine);
        
        set(mfianalysis_fig,'CurrentAxes',findobj(mfianalysis_fig,'Tag','axes5'));
        plot(eval([OutputNamef,'.bins']),eval([OutputNamef,'.spec'])); set(gca,'Tag','axes5');
        
    case 'save5'
        SigIn_name = get(findobj(mfianalysis_fig,'Tag','EditText_input'),'String');
        eval(['global ' SigIn_name]);
        OutputNameA = get(findobj(mfianalysis_fig,'Tag','StaticText_fig4'),'String');
        OutputNameF = get(findobj(mfianalysis_fig,'Tag','StaticText_fig6'),'String');
        eval(['global ' OutputNameA]); eval(['global ' OutputNameF]);
        
        NA_value = str2double(get(findobj(mfianalysis_fig,'Tag','EditText_alphabins'),'String'));
        Hldnorm = get(findobj(mfianalysis_fig,'Tag','Check_normalized'),'Value');
        
        OutputNamef = ['fs_spectrum_' SigIn_name];      
        varnamef = fl_find_mnames(varargin{2},OutputNamef);
        
        eval(['global ' varnamef]);
        varargout{1} = varnamef;
        
        chaine = ['=falphaimage(',OutputNameA,',',num2str(NA_value)];
        if Hldnorm, chaine = [chaine,',''norm''']; end
        chaine = ['[',OutputNameF ' ' varnamef,']',chaine,');'];
        eval(chaine);       
        fl_diary(chaine);
        eval ([varnamef '=struct(''type'',''graph'',''bins'',',varnamef,'.bins,''spectrum'',',varnamef,'.spec);']);
        fl_addlist(0,varnamef);
        
    case 'help'  
        fl_doc alphaimage
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_mfianalysis'));
        
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
