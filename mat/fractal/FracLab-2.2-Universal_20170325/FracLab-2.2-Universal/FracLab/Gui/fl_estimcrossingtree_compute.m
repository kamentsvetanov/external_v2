function [varargout]=fl_estimcrossingtree_compute(varargin)
% No help found

% Modified by W. Arroum

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

Figestimcrossingtree = gcf;
if ((isempty(Figestimcrossingtree)) | (~strcmp(get(Figestimcrossingtree,'Tag'),'Fig_gui_fl_estimcrossingtree')))
    Figestimcrossingtree = findobj ('Tag','Fig_gui_fl_estimcrossingtree');
end
ebp = guihandles(Figestimcrossingtree);
ebp = guidata(Figestimcrossingtree);
%==========================================================================
switch(varargin{1})
    case 'launch'
        [SigIn_name error_in] = fl_get_input('vector') ;
        eval(['global ' SigIn_name]) ;
        if error_in
            fl_error('Input must be a vector !') ;
            return ;
        end
        SigIn = eval(SigIn_name);
        fl_callwindow('Fig_gui_fl_estimcrossingtree','gui_fl_estimcrossingtree') ;
        %set(findobj('tag','Pushbutton_refreshInput'),'enable','off');
        set(findobj(Figestimcrossingtree,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj('tag','Pushbutton_get_hits'),'enable','on');
        set(findobj('tag','Pushbutton_clear'),'enable','on');
        set(findobj('tag','Pushbutton_option'),'enable','off');
        set(findobj('tag','Pushbutton_estimcrossingtree_compute'),'enable','on');

    case 'launch_op'
        [SigIn_name error_in] = fl_get_input('vector') ;
        eval(['global ' SigIn_name]) ;
        if error_in
            fl_warning('input signal must be a vector !') ;
            return ;
        end
        SigIn = eval(SigIn_name);
        fl_callwindow('Fig_gui_fl_estimcrossingtree','gui_fl_estimcrossingtree') ;
        set(findobj(Figestimcrossingtree,'Tag','EditText_input'),'String',SigIn_name);
        set(findobj('tag','Pushbutton_estimcrossingtree_compute'),'enable','on');
        set(findobj('tag','PushbuttonV'),'enable','on');
        set(findobj('tag','Pushbutton_clear2'),'enable','on');
        set(findobj('tag','FrameParam'),'enable','on');
        set(findobj('tag','checkbox_inputtime'),'enable','on','Value',0);
        set(findobj('tag','EditText_inputtime'),'String','time indexed');
        set(findobj('tag','EditText_method'),'Value',1);
        set(findobj('tag','checkbox_delta'),'enable','on','Value',0);
        set(findobj('tag','EditText_delta'),'String','delta');
        set(findobj('tag','checkbox_mmlevel'),'enable','on','Value',0);
        set(findobj('tag','EditText_minl'),'String','min level');
        set(findobj('tag','EditText_maxl'),'String','max level');
        set(findobj('tag','checkbox_deletefirst'),'enable','on','Value',1);
        set(findobj('tag','checkbox_plot_Xing'),'enable','on','Value',0);
        set(findobj('Tag','Frame2Title'),'enable','off');
        set(findobj('Tag','Frame3Title'),'enable','on');
        set(findobj('tag','StaticText_maxl'),'enable','on');
        set(findobj('tag','StaticText_minl'),'enable','on');
        set(findobj('tag','Pushbutton_clear2'),'enable','on');
        set(findobj('tag','PushbuttonV'),'enable','on');
        
%==========================================================================
%=                           Option Window                                =
%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Option %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'option'
        fl_callwindow('Fig_gui_fl_estimcrossingtree_op','gui_fl_estimcrossingtree_op') ;
        Figestimcrossingtree_op = findobj('Tag','Fig_gui_fl_estimcrossingtree_op') ;
        close(Figestimcrossingtree)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Validate Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'validate'
        SigIn_name = get(findobj('tag','EditText_input'),'String');
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name);
        if (max(size(SigIn))<2 || ischar(SigIn) || isempty(SigIn)|| min(size(SigIn))>1)
            fl_error('input signal must be a vector !') ;
            return ;
        end
        isTimeSeries = get(findobj('tag','checkbox_inputtime'),'Value');
        isDelta = get(findobj('tag','checkbox_delta'),'Value');
        ismmlevel = get(findobj('tag','checkbox_mmlevel'),'Value');
        mnlevel=[];
        delta=[];
        if isTimeSeries
            SigIn_name = get(findobj('tag','EditText_inputtime'),'String');
            if (isempty(SigIn_name))
                fl_error('Input ''time index'' empty!') ;
                return ;
            end
            eval(['global ' SigIn_name]) ;
            SigIntime = eval(SigIn_name);
            if (ischar(SigIntime))
                fl_error('Input ''time index'' must be a numerical vector!') ;
                return ;
            end
            if ~isempty(find(diff(SigIntime)<=0))
                fl_error('Input ''time index'' must be strictly increasing!') ;
                return ;
            end
            if  (max(size(SigIntime))<2 || min(size(SigIntime))>1)
                fl_error('Input must be a vector !') ;
                return ;
            end
            if  length(SigIntime)~=length(SigIn)
                fl_error('Time and Series have to have the same length !') ;
                return ;
            end
        end
        
        if isDelta
            delta = str2num(get(findobj('tag','EditText_delta'),'String'));
            if (ischar(delta))  || (isempty(delta) )
                fl_error('Input ''Delta'' must be a real strictly positive !') ;
                return ;
            elseif delta<=0
                fl_error('Input ''Delta'' must be a real strictly positive !') ;
                return ;
            end
        end
        
        if ismmlevel
            minl = str2num(get(findobj('tag','EditText_minl'),'String'));
            maxl = str2num(get(findobj('tag','EditText_maxl'),'String'));
            if (isempty(minl) )
                fl_error('Input ''Minimum level'' must be an integer positive or null!') ;
                return ;
            end
            if (isempty(maxl)  )
                fl_error('Input ''Maximum level'' must be an integer positive!') ;
                return ;
            end
            if (minl<0  ||  minl-floor(minl)~=0 )
                fl_error('Input ''Minimum level'' must be an integer positive or null !') ;
                return ;
            end
            if (maxl<=0 || maxl-floor(maxl)~=0 )
                fl_error('Input ''Maximum level'' must be an integer strictly positive !') ;
                return ;
            end
            if ( maxl<=minl )
                fl_error('Input ''Maximum level'' must be strictly biger than ''Minimum level'' input!') ;
                return ;
            end
            mnlevel=[minl;maxl];
        end

        [Lt,levels]=fl_estimebp_test(SigIn,delta,mnlevel);
        if Lt==0
            return
        end
        ebp.levels=levels;
        guidata(Figestimcrossingtree, ebp);

        set(findobj('tag','FrameParam'),'enable','off');
        set(findobj('tag','PushbuttonV'),'enable','off');
        set(findobj('tag','checkbox_inputtime'),'enable','off');
        set(findobj('tag','EditText_inputtime'),'enable','off');
        set(findobj('tag','Pushbutton_refreshInputtime'),'enable','off');
        set(findobj('tag','checkbox_delta'),'enable','off');
        set(findobj('tag','EditText_delta'),'enable','off');
        set(findobj('tag','checkbox_mmlevel'),'enable','off');
        set(findobj('tag','EditText_minl'),'enable','off');
        set(findobj('tag','EditText_maxl'),'enable','off');
        set(findobj('tag','checkbox_deletefirst'),'enable','off');
        set(findobj('tag','checkbox_plot_Xing'),'enable','off');
        set(findobj('tag','EditText_method'),'enable','off');
        set(findobj('tag','checkbox_biasCorrected'),'enable','off');
        set(findobj('tag','checkbox_diagnosticPlot'),'enable','off');
        set(findobj('tag','StaticText_maxl'),'enable','off');
        set(findobj('tag','StaticText_minl'),'enable','off');
        set(findobj('tag','Pushbutton_get_hits'),'enable','on');
        set(findobj('tag','Pushbutton_refreshInput'),'enable','off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% The options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'launch_time'
        [SigInTime_name error_in] = fl_get_input('vector') ;
        eval(['global ' SigInTime_name]) ;
        if error_in
            fl_warning('input signal must be a vector !') ;
            return ;
        end
        SigInTime = eval(SigInTime_name);
        fl_callwindow('Fig_gui_fl_estimcrossingtree','gui_fl_estimcrossingtree') ;
        set(findobj(Figestimcrossingtree,'Tag','EditText_inputtime'),'String',SigInTime_name);

    case 'isTimeSeries'
        isTimeSeries = get(gcbo,'Value') ;
        if isTimeSeries == 1
            set(findobj('tag','Pushbutton_refreshInputtime'),'enable','on');
            set(findobj('tag','EditText_inputtime'),'String','');
            set(findobj('tag','EditText_inputtime'),'enable','inactive');
        else
            set(findobj('tag','EditText_inputtime'),'String','time indexed');
            set(findobj('tag','EditText_inputtime'),'enable','off');
            set(findobj('tag','Pushbutton_refreshInputtime'),'enable','off');
        end

    case 'delta'
        if get(gcbo,'Value') == 1
            set(findobj('tag','EditText_delta'),'String','');
            set(findobj('tag','EditText_delta'),'enable','on');
        else
            set(findobj('tag','EditText_delta'),'String','delta');
            set(findobj('tag','EditText_delta'),'enable','off');
        end
   
    case 'mmlevel'
        if get(gcbo,'Value') == 1
            set(findobj('tag','EditText_minl'),'String','');
            set(findobj('tag','EditText_minl'),'enable','on');
            set(findobj('tag','EditText_maxl'),'String','');
            set(findobj('tag','EditText_maxl'),'enable','on');
        else
            set(findobj('tag','EditText_minl'),'String','min level');
            set(findobj('tag','EditText_minl'),'enable','off');
            set(findobj('tag','EditText_maxl'),'String','max level');
            set(findobj('tag','EditText_maxl'),'enable','off');
        end
        
    case 'edittext_method'
    	if get(gcbo,'Value') == 1
    		set(findobj('tag','checkbox_diagnosticPlot'),'enable','off','Value',0);
    	else
    		set(findobj('tag','checkbox_diagnosticPlot'),'enable','on');
        end

%==========================================================================
%=                    Clear/Clear option/Help                             =
%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Clear %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Clear'
        set(findobj('tag','EditText_level'),'enable','off','Value',1,'String',{' '});
        set(findobj('Tag','StaticText_level'),'enable','off');
        set(findobj('tag','Pushbutton_estimcrossingtree_compute'),'enable','off');
        set(findobj('tag','Pushbutton_clear'),'enable','off');
        set(findobj('tag','EditText_HurstIndex_lb'),'String','');
        set(findobj('tag','EditText_HurstIndex'),'String','');
        set(findobj('tag','EditText_HurstIndex_ub'),'String','');
        set(findobj('tag','EditText_input'),'String','');
        cla(findobj('Tag','Axes_plotH'));
        
        h0=findobj('Tag','Fig_gui_fl_estimcrossingtree');
        tbl=findobj('Tag','table');
        Cdata = {'','','',''};
        cla(tbl);
        delete(findobj('tag','sctab'));
        ebp_table(h0, tbl, 'Table',Cdata);

        if exist('fil.mat') delete fil.mat; end;
        set(findobj('tag','Pushbutton_refreshInput'),'enable','on');
        set(findobj('tag','Pushbutton_option'),'enable','on');
        set(findobj('tag','Frame2Title'),'enable','on');
        set(findobj('tag','Frame3Title'),'enable','off');
%%%%%%%%%%%%%%%%%%%%%%%% Clear (option window) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Clearop'
        set(findobj('tag','Pushbutton_estimcrossingtree_compute_op'),'enable','off');
        set(findobj('tag','Pushbutton_clear2'),'enable','off');
        set(findobj('tag','Pushbutton_get_hits'),'enable','off');
        set(findobj('tag','EditText_HurstIndex_lb'),'String','');
        set(findobj('tag','EditText_HurstIndex'),'String','');
        set(findobj('tag','EditText_HurstIndex_ub'),'String','');
        set(findobj('tag','EditText_input'),'String','');
        set(findobj('Tag','StaticText_level'),'enable','off');
        
        cla(findobj('Tag','Axes_plotH'));
        
        h0=findobj('Tag','Fig_gui_fl_estimcrossingtree');
        tbl=findobj('Tag','table');
        Cdata = {'','','',''};
        cla(tbl);
        delete(findobj('tag','sctab'));
        ebp_table(h0, tbl,'Table',Cdata);
        
        set(findobj('tag','EditText_level'),'enable','off','Value',1,'String',{''});
        if exist('fil.mat') delete fil.mat; end;
        set(findobj('tag','Pushbutton_refreshInput'),'enable','on');
        set(findobj('tag','Pushbutton_refreshInputtime'),'enable','off');
        set(findobj('tag','FrameParam'),'enable','off');
        set(findobj('tag','PushbuttonV'),'enable','off');
        set(findobj('tag','checkbox_inputtime'),'enable','off','Value',0);
        set(findobj('tag','EditText_inputtime'),'enable','off','String','time indexed');
        set(findobj('tag','EditText_method'),'Value',1);
        set(findobj('tag','checkbox_delta'),'enable','off','Value',0);
        set(findobj('tag','EditText_delta'),'enable','off','String','delta');
        set(findobj('tag','checkbox_mmlevel'),'enable','off','Value',0);
        set(findobj('tag','EditText_minl'),'enable','off','String','min level');
        set(findobj('tag','EditText_maxl'),'enable','off','String','max level');
        set(findobj('tag','checkbox_deletefirst'),'enable','off','Value',1);
        set(findobj('tag','checkbox_plot_Xing'),'enable','off','Value',0);
        set(findobj('tag','EditText_method'),'enable','off');
        set(findobj('tag','StaticText_method'),'enable','off');
        set(findobj('tag','checkbox_biasCorrected'),'enable','off','Value',1);
        set(findobj('tag','checkbox_diagnosticPlot'),'enable','off','Value',0);
        set(findobj('tag','Pushbutton_clear2'),'enable','off');
        set(findobj('Tag','Frame2Title'),'enable','on');
        set(findobj('Tag','Frame3Title'),'enable','off');
        set(findobj('Tag','Frame4Title'),'enable','off');
        set(findobj('Tag','Frame5Title'),'enable','off');
        set(findobj('tag','StaticText_maxl'),'enable','off');
        set(findobj('tag','StaticText_minl'),'enable','off');
        set(findobj('tag','EditText_HurstIndex_lb'),'String','');
        set(findobj('tag','EditText_HurstIndex'),'String','');
        set(findobj('tag','EditText_HurstIndex_ub'),'String','');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Help %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'help'
        helpwin 
    
%==========================================================================
%=                              Computation                               =
%==========================================================================      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Hits %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Get Hits with options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'get_hits_op'
        current_cursor=fl_waiton;
        SigIn_name = get(findobj('tag','EditText_input'),'String');
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name);
        if (max(size(SigIn))<2 || ischar(SigIn) || isempty(SigIn)|| min(size(SigIn))>1)
            fl_warning('input signal must be a vector !') ;
            fl_waitoff(current_cursor);
            return ;
        end
        
        if get(findobj('tag','checkbox_inputtime'),'Value');
            SigIntime_name = get(findobj('tag','EditText_inputtime'),'String');
            eval(['global ' SigIntime_name]) ;
            SigIntime = eval(SigIntime_name);
            if  length(SigIntime)~=length(SigIn)
                fl_warning('Time and Series have to have the same length !') ;
                fl_waitoff(current_cursor);
                return ;
            end
            data=[SigIntime(:) SigIn(:)];
        else
            data=[SigIn(:)];
        end
        input=[];
        if ~get(findobj('tag','checkbox_deletefirst'),'Value');
            input=[input ',''deleteFirst'',''no'''];
        end
        if get(findobj('tag','checkbox_delta'),'Value');
            delta = str2num(get(findobj('tag','EditText_delta'),'String'));
            input=[input ',''delta'',' num2str(delta) ];
        end
        if get(findobj('tag','checkbox_mmlevel'),'Value');
            minl = str2num(get(findobj('tag','EditText_minl'),'String'));
            maxl = str2num(get(findobj('tag','EditText_maxl'),'String'));
            input=[input ',''min_max_levels'',[' num2str(ebp.levels(1)) ';' num2str(ebp.levels(2)) ']'];
        end
        if get(findobj('tag','checkbox_plot_Xing'),'Value');
            input=[input ',''Plot'',''yes'''];
            PltXing_fig = figure;
            fl_window_init(PltXing_fig,'Figure');
            clf
        end
         
        eval(['[Sub,levels2]=get_hits_W(data' input ');']);
        ebp.levels2=levels2;
        ebp.Sub=Sub;
        guidata(Figestimcrossingtree, ebp);
        
        set(findobj('tag','Pushbutton_get_hits'),'enable','off');
        set(findobj('tag','Pushbutton_estimcrossingtree_compute_op'),'enable','on');
        set(findobj('tag','EditText_method'),'enable','on');
        set(findobj('tag','StaticText_method'),'enable','on');
        set(findobj('tag','checkbox_biasCorrected'),'enable','on','Value',1);
        set(findobj('tag','Frame3Title'),'enable','off');
        set(findobj('tag','Frame4Title'),'enable','on');
        fl_waitoff(current_cursor);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Compute H %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'compute'
        current_cursor=fl_waiton;
        SigIn_name = get(findobj('tag','EditText_input'),'String');
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name);
        if (max(size(SigIn))<2 || ischar(SigIn) || isempty(SigIn))
            fl_error('Input must be a vector !') ;
            fl_waitoff(current_cursor);
            return ;
        end
        [Lt,levels]=fl_estimebp_test(SigIn,[],[]);
        if Lt==0
            fl_waitoff(current_cursor);
            return
        end
        [Sub,levels2]=get_hits_W(SigIn,'min_max_levels',levels);
        for k=1:length(levels2(:,2))      
            [H(k), H_lb(k), H_ub(k)] = calc_H_W(Sub,levels2,levels2(k,2));
            Cdata{k,2}=H(k);
            Cdata{k,3}=H_lb(k);
            Cdata{k,4}=H_ub(k);
            Cdata{k,1}=levels2(k,2);
            L(k)={num2str(levels2(k,2))};
            L2(k)=levels2(k,2);
        end
        tab=findobj('Tag','table');
        h=findobj('Tag','Fig_gui_fl_estimcrossingtree');
        cla(tab);
        delete(findobj('tag','sctab'));
        ebp_table(h, tab, 'Table', Cdata);
        
        set(h, 'CurrentAxes', findobj('Tag','Axes_plotH'));
        cla(findobj('Tag','Axes_plotH'))
        hold on
        plot(L2,H,'.-')
        plot(L2,H_lb,'.-.')
        plot(L2,H_ub,'.-.')
        hold off
        
        set(findobj('tag','EditText_level'),'enable','on','String',L);
        set(findobj('Tag','StaticText_level'),'enable','on');
        set(findobj('tag','Frame2Title'),'enable','off');
        set(findobj('tag','Frame3Title'),'enable','on');
        set(findobj('tag','Pushbutton_estimcrossingtree_compute'),'enable','off');
        fl_waitoff(current_cursor);
        return
%%%%%%%%%%%%%%%%%%%%%%%%%%% Compute H at level %%%%%%%%%%%%%%%%%%%%%%%%%%%%
             

        %%%%%%%%%%%%%%%%%%%%%%%%%%% Compute H at level %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'compute_op'
        current_cursor=fl_waiton;
        
        methods = get(findobj('tag','EditText_method'),'String');
        method = methods{get(findobj('tag','EditText_method'),'Value')};
        biasCorrected = get(findobj('tag','checkbox_biasCorrected'),'Value');
        
        for k=1:length(ebp.levels2(:,2))      
            [H(k), H_lb(k), H_ub(k)] = calc_H_W(ebp.Sub,ebp.levels2,ebp.levels2(k,2),biasCorrected,method);
            if (~isnan(H(k)) & ~isnan(H_lb(k))& ~isnan(H_ub(k)))
                Cdata{k,2}= real(H(k));
                Cdata{k,3}= real(H_lb(k));
                Cdata{k,4}= real(H_ub(k));
                Cdata{k,1}= ebp.levels2(k,2);
            end
            L(k)={num2str(ebp.levels2(k,2))};
            L2(k)=ebp.levels2(k,2);
        end
        ebp.Cdata=Cdata;

        tab=findobj('Tag','table');
        h=findobj('Tag','Fig_gui_fl_estimcrossingtree');
        cla(tab);
        delete(findobj('tag','sctab'));
        ebp_table(h, tab, 'Table', Cdata);
        
        set(h, 'CurrentAxes', findobj('Tag','Axes_plotH'));

        cla(findobj('Tag','Axes_plotH'))
        hold on
        plot(L2,real(H),'.-')
        plot(L2,real(H_lb),'.-.')
        plot(L2,real(H_ub),'.-.')
        hold off
        guidata(Figestimcrossingtree,ebp);
        set(findobj('tag','EditText_level'),'enable','on','String',L);
        set(findobj('Tag','StaticText_level'),'enable','on');
        set(findobj('tag','Frame5Title'),'enable','on');

    	if method == 'iid'
    		set(findobj('tag','checkbox_diagnosticPlot'),'enable','off');
    	else
    		set(findobj('tag','checkbox_diagnosticPlot'),'enable','on');
        end
        fl_waitoff(current_cursor);
        return
                %%%%%%%%%%%%%%%%%%%%%%%%%%% 'checkbox_diagnosticPlot' %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'checkbox_diagnosticPlot'
        current_cursor=fl_waiton;
        levels = get(findobj('tag','EditText_level'),'String');
        level = str2num(levels{get(findobj('tag','EditText_level'),'Value')});
        methods = get(findobj('tag','EditText_method'),'String');
        method = methods{get(findobj('tag','EditText_method'),'Value')};
        biasCorrected = get(findobj('tag','checkbox_biasCorrected'),'Value');

        diag_fig = figure;
        fl_window_init(diag_fig,'Figure');
        clf
        A=calc_H_W( ebp.Sub  ,ebp.levels2,level,biasCorrected,method,1);
        if isnan(A)
            close(diag_fig)
            fl_error('No diagnostic plot for this level!') ;
        end
        fl_waitoff(current_cursor);
        
        return
end

