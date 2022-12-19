function [varargout]=fl_regdim1d_compute(varargin)
% Callback functions for regdim1d GUI Environment.

% Modified by Christian Choque Cortez, March 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,regdim1d_fig] = gcbo;

if ((isempty(regdim1d_fig)) || (~strcmp(get(regdim1d_fig,'Tag'),'Fig_gui_fl_regdim1d')))
    regdim1d_fig = findobj ('Tag','Fig_gui_fl_regdim1d');
end

fl_clearerror;

switch(varargin{1});
    case 'refresh'
        [SigIn_name error_in] = fl_get_input('vector');
        if error_in
            fl_warning('input signal must be a vector !') ;
            return
        end
        eval(['global ' SigIn_name]);
        set(findobj(regdim1d_fig,'Tag','EditText_input'),'String',SigIn_name);
        SigIn = eval(SigIn_name);
        N = length(SigIn);
        [kmin,kmax] = kranges(5,N,5);
        set(findobj(regdim1d_fig,'Tag','EditText_nmin'),'String',kmin{1});
        set(findobj(regdim1d_fig,'Tag','PopupMenu_nmin'),'String',kmin,'Value',1);
        set(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String',kmax{3});
        set(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'String',kmax,'Value',3);
        set(findobj(regdim1d_fig,'Tag','EditText_voices'),'String',32);
        set(findobj(regdim1d_fig,'Tag','PopupMenu_voices'),'Value',5);

    case 'edit_nmin'
        SigIn_name = get(findobj(regdim1d_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]);
        SigIn = eval(SigIn_name);
        N = length(SigIn); NN = floor(N/3);
        min_value = str2double(get(gcbo,'String'));
        max_value = str2double(get(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String'));
        if isnan(min_value)
            fl_warning('minimum bound must be an integer lower than Nmax'); pause(.3);
            set(findobj(regdim1d_fig,'Tag','PopupMenu_nmin'),'Value',1);
            set(gcbo,'String',5);
        else
            min_value = trunc(min_value,5,NN);
            set(gcbo,'String',min_value);
        end
        if min_value == max_value
            set(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'Value',2);
            max_value = get(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'String');
            set(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String',max_value{2});
        end
        
    case 'popmenu_nmin'
        index = get(gcbo,'Value');
        min_value = get(gcbo,'String'); min_value = str2double(min_value{index});
        set(findobj(regdim1d_fig,'Tag','EditText_nmin'),'String',min_value);
        max_value = str2double(get(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String'));
        if min_value == max_value
            set(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'Value',2);
            max_value = get(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'String');
            set(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String',max_value{2});
        end

    case 'edit_nmax'
        SigIn_name = get(findobj(regdim1d_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]);
        SigIn = eval(SigIn_name);
        N = length(SigIn); NN = floor(N/3);
        max_value = str2double(get(gcbo,'String'));
        min_value = str2double(get(findobj(regdim1d_fig,'Tag','EditText_nmin'),'String'));
        if isnan(max_value)
            fl_warning('maximum bound must be an integer bigger than Nmin'); pause(.3);
            set(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'Value',3);
            max_value = get(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'String'); 
            max_value = str2double(max_value{3}); set(gcbo,'String',max_value);
        else
            max_value = trunc(max_value,min_value,2*NN);
            set(gcbo,'String',max_value);
        end
        if min_value == max_value
            set(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'Value',2);
            max_value = get(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'String');
            set(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String',max_value{2});
        end
          
    case 'popmenu_nmax'
        index = get(gcbo,'Value');
        max_value = get(gcbo,'String'); max_value = str2double(max_value{index});
        set(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String',max_value);
        min_value = str2double(get(findobj(regdim1d_fig,'Tag','EditText_nmin'),'String'));
        if min_value == max_value
            set(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'Value',2);
            max_value = get(findobj(regdim1d_fig,'Tag','PopupMenu_nmax'),'String');
            set(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String',max_value{2});
        end
        
    case 'edit_voices'
        SigIn_name = get(findobj(regdim1d_fig,'Tag','EditText_input'),'String');
        eval(['global ',SigIn_name]);
        voices = str2double(get(gcbo,'String'));
        if isnan(voices)
            fl_warning('Number of voices must be a positive integer !'); pause(.3);
            set(gcbo,'String',32);
            set(findobj(regdim1d_fig,'Tag','PopupMenu_voices'),'Value',5);
        else
            voices = floor(trunc(voices,2,Inf));
            set(gcbo,'String',voices);
        end
    
    case 'popmenu_voices'
        voices_value = 2^get(gcbo,'Value');
        set(findobj(regdim1d_fig,'Tag','EditText_voices'),'String',voices_value);
        
    case 'edit_sigma'
        noise_value = str2double(get(gcbo,'String'));
        if isnan(noise_value)
            fl_warning('The noise value must be a real'); pause(.3);
            set(gcbo,'String',0);
        else
            noise_value = max(0,noise_value);
            set(gcbo,'String',noise_value);
        end

    case 'check_reg'
        reggraphs = get(gcbo,'Value') ;
        if ~reggraphs
            set(gcbo,'String','No regularized graphs') ;
        else
            set(gcbo,'String','Compute regularized graphs') ;
        end

    case 'compute'
        current_cursor=fl_waiton;
        
        %%%%% Get the input %%%%%%
        SigIn_Name = get(findobj(regdim1d_fig,'Tag','EditText_input'),'String');
        
        if isempty(SigIn_Name)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(current_cursor);
        else
            eval(['global ' SigIn_Name]);
            
            %%%%%% Disable close and compute %%%%%%%%
            set(findobj(regdim1d_fig,'Tag','Button_close'),'enable','off');
            set(findobj(regdim1d_fig,'Tag','Button_compute'),'enable','off');
            
            %%%%% Get Bounds and Voices %%%%%
            Nmin = str2double(get(findobj(regdim1d_fig,'Tag','EditText_nmin'),'String'));
            Nmax = str2double(get(findobj(regdim1d_fig,'Tag','EditText_nmax'),'String'));
            Voices = str2double(get(findobj(regdim1d_fig,'Tag','EditText_voices'),'String'));
                        
            %%%%% Look for option %%%%%
            Hldreggraph = get(findobj(regdim1d_fig,'Tag','Check_regularized'),'Value');
            Noise = str2double(get(findobj(regdim1d_fig,'Tag','EditText_noise'),'String'));
            Hldnoise = (Noise ~= 0);
            
            %%%%% Regression and Kernel argument %%%%%
            KerType = get(findobj(regdim1d_fig,'Tag','Kertype_menu'),'Value');
            if KerType == 1, KerParam = 'gauss'; elseif KerType ==  2, KerParam = 'rect'; end
            RegType = get(findobj(regdim1d_fig,'Tag','Regtype_menu'),'Value');
            RegParam = fl_getregparam(RegType,Voices);
            Hldwlspls = strcmp(RegParam{1},'pls') || strcmp(RegParam{1},'wls') || strcmp(RegParam{1},'lapls');
            
            %%%%% Perform the computation %%%%%
            OutputNameRgraph = ['reggraph_' SigIn_Name '_']; 
            varnameRgraph = fl_find_mnames(varargin{2},OutputNameRgraph);
            eval(['global ' varnameRgraph]); varargout{1} = 'ans';
            chaine_in = ['regdim1d(',SigIn_Name,',[',num2str(Nmin),',',num2str(Nmax),'],',...
                            num2str(Voices),',''',KerParam,'''',',''',RegParam{1},''''];
            
            if Hldwlspls, chaine_in = [chaine_in,',[',num2str(RegParam{2}),']']; end            
            if Hldnoise, chaine_in = [chaine_in,',''noise'',',num2str(Noise)]; end
            
            chaine = chaine_in;
            if Hldreggraph
                varargout{1} = varnameRgraph;
                chaine = [varnameRgraph,'=',chaine_in];
            end
            
            chaine = [chaine,');']; 
            eval(chaine); 
            fl_diary(chaine);
            if Hldreggraph, fl_addlist(0,varnameRgraph); end
            
            %%%%% Where to display the result %%%%%
            obj = findobj(regdim1d_fig,'Tag','EditText_regdim');
            h=guidata(gcf);
            h.HandleOut=obj;
            guidata(gcf,h);
            set(obj,'String',h.dim);
            
            fl_waitoff(current_cursor);
        
            %%%%%% Enable close and compute %%%%%%%%
            set(findobj(regdim1d_fig,'Tag','Button_close'),'enable','on');
            set(findobj(regdim1d_fig,'Tag','Button_compute'),'enable','on');
        end
        
    case 'help'  
        fl_doc regdim1d
        
    case 'close'  
        close(findobj('Tag', 'Fig_gui_fl_regdim1d'));
        
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
function [k1,k2] = kranges(Nmin,N,nvalues)

k1 = num2cell(floor(linspace(Nmin,max(N/3,10),nvalues)));
k2 = num2cell(floor(linspace(max(N/3,10),max(2*N/3,max(N/3,10)+5),nvalues)));

end