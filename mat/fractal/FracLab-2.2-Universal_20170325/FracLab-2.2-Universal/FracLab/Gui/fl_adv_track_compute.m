function [varargout]=fl_adv_track_compute(varargin)
% Callback functions for advanced cwttrack GUI - Generation Parameter Window.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%warning backtrace;

Figadvcwttrack = gcf;
if ((isempty(Figadvcwttrack)) | (~strcmp(get(Figadvcwttrack,'Tag'),'Fig_gui_fl_adv_track')))
    Figadvcwttrack = findobj ('Tag','Fig_gui_fl_adv_track');
end

switch(varargin{1})
    case 'refresh'
        [SigIn_name error_in] = fl_get_input ('vector') ;
        if error_in
            fl_warning ('Input must be a vector !');
            return;
        end

        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;

        N = length(SigIn) ;
        logN=floor(log2(N(1)))-4;
        if(logN<=1.0) logN=2; end
        ppmh1=findobj(Figadvcwttrack,'Tag','PopupMenu_cwt_fmin');
        ppmh2=findobj(Figadvcwttrack,'Tag','PopupMenu_cwt_fmax');
        set([ppmh1 ppmh2],'Value',1);
        for t=1:logN
            varcell{t}=['2^(-',num2str(t),')'];
        end
        for t=1:logN
            varcell2{t}=['2^(-',num2str(logN-t+1),')'];
        end
        set([ppmh1],'String',varcell2);
        set([ppmh2],'String',varcell);
        set(findobj(Figadvcwttrack,'Tag','EditText_cwt_fmin'),'String',num2str(2^(-logN)));
        set(findobj(Figadvcwttrack,'Tag','EditText_cwt_fmax'),'String','0.5');
        set(findobj(Figadvcwttrack,'Tag','EditText_sig_nname'),'String',SigIn_name);

    case 'cwt_editf'
        value=str2num(get(gcbo,'String'));
        if(value<0.0)
            SigIn_name = get(findobj(Figadvcwttrack,'Tag','EditText_sig_nname'),'String') ;
            eval(['global ' SigIn_name]) ;
            SigIn = eval(SigIn_name) ;
            N=length(SigIn);
            value=1.0/N;
        else
            if(value>0.5)
                value=0.5;
            end
        end
        set(gcbo,'String',value);

    case 'cwt_ppm_fmin'
        SigIn_name = get(findobj(Figadvcwttrack,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N = length(SigIn) ;
        logN=floor(log2(N))-4;
        if(logN<=1.0) logN=2; end
        value=get(gcbo,'Value');
        pow=2^(-1*(logN-value+1));
        set(findobj(Figadvcwttrack,'Tag','EditText_cwt_fmin'),'String',num2str(pow));

    case 'cwt_ppm_fmax'
        value=get(gcbo,'Value');
        pow=2^(-1*value);
        set(findobj(Figadvcwttrack,'Tag','EditText_cwt_fmax'),'String',num2str(pow));

    case 'cwt_edit_voices'
        value=str2num(get(gcbo,'String'));
        value=floor(value);
        if(value<=1.0) value=2.0; end
        set(gcbo,'String',value);

    case 'cwt_ppm_voices'
        value=get(gcbo,'Value');
        set(findobj(Figadvcwttrack,'Tag','EditText_cwt_voices'),'String',num2str(2^value));

    case 'cwt_edit_wsize'
        value=str2num(get(gcbo,'String'));
        value=floor(value);
        if(value<=1.0) value=2.0; end
        set(gcbo,'String',value);

    case 'cwt_ppm_wtype'
        ppmh=findobj(Figadvcwttrack,'Tag','PopupMenu_cwt_wtype');
        eth=findobj(Figadvcwttrack,'Tag','EditText_cwt_wsize');
        if(get(ppmh,'Value')==1)
            set(findobj(Figadvcwttrack,'Tag','EditText_cwt_wsize'),'Enable','off');
        else
            set(findobj(Figadvcwttrack,'Tag','EditText_cwt_wsize'),'Enable','on');
        end

    case 'cwt_rb_mirror'
        if(get(gco,'Value')==0)
            set(gco,'String','No mirror');
        else
            set(gco,'String','Mirror');
        end

    case 'cwt_compute'

        current_cursor=fl_waiton;

        %%%%% First get the input %%%%%%
        fl_clearerror;
        SigIn_name = get(findobj(Figadvcwttrack,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]);
        %%%%% Now get the wavelet type %%%%%
        ppmh=findobj(Figadvcwttrack,'Tag','PopupMenu_cwt_wtype');
        eth=findobj(Figadvcwttrack,'Tag','EditText_cwt_wsize');
        switch(get(ppmh,'Value'))
            case 1
                wave = '''mexican''';
            case 2
                wave = ['''morletr'',',get(eth,'String')];
            case 3
                wave = ['''morleta'',',get(eth,'String')];
        end
        %%%%% Get fmin and fmax %%%%%
        eth=findobj(Figadvcwttrack,'Tag','EditText_cwt_fmin');
        fmin=str2num(get(eth,'String'));
        eth=findobj(Figadvcwttrack,'Tag','EditText_cwt_fmax');
        fmax=str2num(get(eth,'String'));
        %%%%% Get the number of voices %%%%%
        eth=findobj(Figadvcwttrack,'Tag','EditText_cwt_voices');
        voices=str2num(get(eth,'String'));
        %%%%% Get a name for the output var %%%%%
        prefix=['cwt_' SigIn_name];
        varname=fl_findname(prefix,varargin{2});
        varargout{1}=varname;
        eval(['global ' varname]);
        %%%%% L2 or L1? %%%%%%
        mirror=get(findobj(Figadvcwttrack,'Tag','Radiobutton_cwt_mirror'),'Value');
        %%%%% Perform the computation %%%%%
        if ~mirror
            chaine = [varname,' = contwt(' SigIn_name ',[fmin,fmax],voices,',wave,');'];
            eval(chaine);
            chaine=[varname,'=contwt(',SigIn_name,',[',num2str(fmin),',',num2str(fmax),'],',num2str(voices),',',wave,');'];
        else
            chaine = [varname,' = contwt(' SigIn_name ',[fmin,fmax],voices,',wave,',''mirror'');'];
            eval(chaine);
            chaine=[varname,'=contwt(',SigIn_name,',[',num2str(fmin),',',num2str(fmax),'],',num2str(voices),',',wave,',''mirror'');'];
        end
        fl_diary(chaine)


        %%%%% Update the variables list %%%%%
        fl_addlist(0,varname);
        set(findobj(Figadvcwttrack,'Tag','EditText_cwt_nname'),'String',varname) ;
        fl_waitoff(current_cursor);

        %%%%%%%%% LOCAL SCALING PARAMETERS %%%%%%%%%%%%%

    case 'refresh_cwt'
        [cwt_in_name error_in] = fl_get_input('cwt') ;
        if error_in
            fl_error('Input must be a cwt structure !') ;
            %fl_waitoff(current_cursor);
            return ;
        end
        set(findobj(Figadvcwttrack,'Tag','EditText_cwt_nname'),'String', cwt_in_name) ;

    case 'radiobutton_time'
        rb_time = get(gcbo,'Value') ;
        if rb_time == 1
            set(gcbo,'String','Single Time Exponent') ;
            obj = findobj(Figadvcwttrack,'Tag','EditText_adv_track_time') ;
            set(obj,'Enable','on') ;
            obj = findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_reg') ;
            set(obj,'Enable','on') ;
        elseif rb_time == 0
            set(gcbo,'String','Holder Function') ;
            obj = findobj(Figadvcwttrack,'Tag','EditText_adv_track_time') ;
            set(obj,'Enable','off') ;
            obj = findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_reg') ;
            set(obj,'String','Full Range Regression') ;
            set(obj,'Value',0) ;
            set(obj,'Enable','off') ;
        end

    case 'edit_time'

        CwtIn_name = get(findobj(Figadvcwttrack,'Tag','EditText_cwt_nname'),'String') ;
        eval(['global ' CwtIn_name]) ;
        CwtIn = eval(CwtIn_name) ;
        N = size(CwtIn.coeff,2) ;
        time=str2num(get(gcbo,'String'));
        time = trunc(time,1,N) ;
        set(gcbo,'String',num2str(time)) ;

    case 'edit_radius'
        radius = str2num(get(gcbo,'String')) ;
        radius = max(0,radius) ;
        set(gcbo,'String',num2str(radius)) ;

    case 'edit_deepscale'
        DeepScale = str2num(get(gcbo,'String')) ;

    case 'radiobutton_findmax'
        FindMax = get(gcbo,'Value') ;
        if FindMax == 1
            obj=findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_findmax') ;
            set(obj,'String','Yes') ;
            obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_deepscale') ;
            set(obj,'Enable','on') ;
            obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_radius') ;
            set(obj,'Enable','on') ;
        elseif FindMax == 0
            obj=findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_findmax') ;
            set(obj,'String','No') ;
            obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_deepscale') ;
            set(obj,'Enable','off') ;
            obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_radius') ;
            set(obj,'Enable','off') ;
        end

    case 'radiobutton_reg'
        Reg = get(gcbo,'Value') ;
        if Reg == 1
            set(gcbo,'String','Specify Regression Range') ;
        elseif Reg == 0
            set(gcbo,'String','Full Range Regression') ;
        end

    case 'compute_HofT'

        current_cursor=fl_waiton;

        cwt_in = get(findobj(Figadvcwttrack,'Tag','EditText_cwt_nname'),'String') ;
        if isempty(cwt_in)
           fl_warning('No CWT, please compute it or refresh');
           return;
        end
        eval(['global ' cwt_in]) ;
        CWTIN=cwt_in;
        cwt_in = eval(cwt_in) ;
        wt = cwt_in.coeff;
        scale =  cwt_in.scale ;

        obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_radius') ;
        radius = get(obj,'String') ;
        radius = str2num(radius) ;
        obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_deepscale') ;
        DeepScale = str2num(get(obj,'String')) ;
        DeepScale = trunc(DeepScale,1,length(scale)) ;
        set(obj,'String',num2str(DeepScale)) ;
        obj=findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_findmax') ;
        FindMax = get(obj,'Value') ;
        obj=findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_reg') ;
        Reg = get(obj,'Value') ;
        obj=findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_monolr') ;
        RegType = get(obj,'Value') ;
        switch RegType
            case 1
                RegParam{1} = 'ls' ;
            case {2,3,4,5}
                RegParam = fl_getregparam(RegType,length(scale)) ;
            case 6
                RegParam{1} = 'linf' ;
            case 7
                RegParam{1} = 'lsup' ;
        end


        obj=findobj(Figadvcwttrack,'Tag','Radiobutton_adv_track_time') ;
        rb_time = get(obj,'Value') ;
        if rb_time == 1

            obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_time') ;
            whichT = str2num(get(obj,'String')) ;
            whichT = min(whichT,size(wt,2)) ;
            varname = 'HofT' ;
            varargout{1}=varname;
            eval(['global ' varname]);
            eval(['[' varname ' handlefig]=cwttrack(wt,scale,whichT,FindMax,Reg,radius,DeepScale,1,RegParam{:});']);
            obj=findobj(Figadvcwttrack,'Tag','EditText_adv_track_HofT') ;
            set(obj,'String',num2str(eval(varname))) ;
            if Reg
            	h=guidata(handlefig);
            	h.HandleOut=obj;
            	guidata(handlefig,h);
            end
            
            chaine=[varname,'=cwttrack(',CWTIN,...
                '.coeff,',CWTIN,'.scale,',num2str(whichT),',',num2str(FindMax),',',...
                num2str(Reg),',',num2str(radius),',',num2str(DeepScale),...
                ',1,''',num2str(RegParam{:}),''');'];
            fl_diary(chaine)
            
            

        elseif rb_time == 0

            Reg = 0 ; 	% As no specific regression range can be global for all
            % times :  full range regression

            SigIn_name = get(findobj(Figadvcwttrack,'Tag','EditText_sig_nname'),'String') ;
            varname = fl_findname([SigIn_name,'_Ht'],varargin{2});
            varargout{1}=varname;
            eval(['global ' varname]);
            dT = max(1 , round(size(wt,2))/64) ;
            eval([varname '=cwttrack_all(wt,scale,FindMax,Reg,radius,DeepScale,dT,RegParam{:});']);


            chaine=[varname,'=cwttrack_all(',CWTIN,...
                '.coeff,',CWTIN,'.scale,',num2str(FindMax),',',...
                num2str(Reg),',',num2str(radius),',',num2str(DeepScale),...
                ',',num2str(dT),',''',num2str(RegParam{:}),''');'];
            fl_diary(chaine)

            fl_addlist(0,varname) ;

        end

        fl_waitoff(current_cursor);

    case 'close'

        obj_reg = findobj('Tag','graph_reg') ;
        close(obj_reg) ;
        close(Figadvcwttrack) ;

    case 'help'

        helpwin gui_fl_track

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% trunc %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function o = trunc(i,a,b)
if(i<a)
    o=a;
else
    if(i>b)
        o=b;
    else
        o=i;
    end
end











