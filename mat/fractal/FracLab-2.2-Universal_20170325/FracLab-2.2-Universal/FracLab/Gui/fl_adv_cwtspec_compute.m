function [varargout]=fl_adv_cwtspec_compute(varargin)
% Callback functions for advanced CWTSPEC GUI - Generation Parameter Window.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

Figadvcwtspec = gcf;
if ((isempty(Figadvcwtspec)) | (~strcmp(get(Figadvcwtspec,'Tag'),'Fig_gui_fl_adv_cwtspec')))
    Figadvcwtspec = findobj ('Tag','Fig_gui_fl_adv_cwtspec');
end

switch(varargin{1})

    case 'cwt_editf'
        value=str2num(get(gcbo,'String'));
        if(value<0.0)
            SigIn_name = get(findobj(Figadvcwtspec,'Tag','EditText_sig_nname'),'String') ;
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
        SigIn_name = get(findobj(Figadvcwtspec,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N = length(SigIn) ;
        logN=floor(log2(N))-4;
        if(logN<=1.0) logN=2; end
        value=get(gcbo,'Value');
        pow=2^(-1*(logN-value+1));
        set(findobj(Figadvcwtspec,'Tag','EditText_cwt_fmin'),'String',num2str(pow));

    case 'cwt_ppm_fmax'
        value=get(gcbo,'Value');
        pow=2^(-1*value);
        set(findobj(Figadvcwtspec,'Tag','EditText_cwt_fmax'),'String',num2str(pow));

    case 'cwt_edit_voices'
        value=str2num(get(gcbo,'String'));
        value=floor(value);
        if(value<=1.0) value=2.0; end
        set(gcbo,'String',value);

    case 'cwt_ppm_voices'
        value=get(gcbo,'Value');
        set(findobj(Figadvcwtspec,'Tag','EditText_cwt_voices'),'String',num2str(2^value));

    case 'cwt_edit_wsize'
        value=str2num(get(gcbo,'String'));
        value=floor(value);
        if(value<=1.0) value=2.0; end
        set(gcbo,'String',value);

    case 'cwt_ppm_wtype'
        ppmh=findobj(Figadvcwtspec,'Tag','PopupMenu_cwt_wtype');
        eth=findobj(Figadvcwtspec,'Tag','EditText_cwt_wsize');
        if(get(ppmh,'Value')==1)
            set(findobj(Figadvcwtspec,'Tag','EditText_cwt_wsize'),'Enable','off');
        else
            set(findobj(Figadvcwtspec,'Tag','EditText_cwt_wsize'),'Enable','on');
        end

    case 'cwt_rb_mirror'
        if(get(gco,'Value')==0)
            set(gco,'String','No mirror');
        else
            set(gco,'String','Mirror');
        end

    case 'cwt_compute'

        current_cursor=fl_waiton;

        %%%%% Fisrt get the input %%%%%%
        fl_clearerror;
        SigIn_name=get(findobj(Figadvcwtspec,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]);
        sz = eval( ['size(' SigIn_name ')'] );
        if min(min(sz))>1,
            varargout{1}=SigIn_name;
            fl_warning('input signal must be a vector!');
            fl_waitoff(current_cursor);
            return;
        end;

        %%%%% Now get the wavelet tyfl_waitoff(current_cursor);pe %%%%%
        ppmh=findobj(Figadvcwtspec,'Tag','PopupMenu_cwt_wtype');
        eth=findobj(Figadvcwtspec,'Tag','EditText_cwt_wsize');
        switch(get(ppmh,'Value'))
            case 1
                wave = '''mexican''';
            case 2
                wave = ['''morletr'',',get(eth,'String')];
            case 3
                wave = ['''morleta'',',get(eth,'String')];
        end
        %%%%% Get fmin and fmax %%%%%
        eth=findobj(Figadvcwtspec,'Tag','EditText_cwt_fmin');
        fmin=str2num(get(eth,'String'));
        eth=findobj(Figadvcwtspec,'Tag','EditText_cwt_fmax');
        fmax=str2num(get(eth,'String'));
        %%%%% Get the number of voices %%%%%
        eth=findobj(Figadvcwtspec,'Tag','EditText_cwt_voices');
        voices=str2num(get(eth,'String'));
        %%%%% L2 or L1? %%%%%
        mirror=get(findobj(Figadvcwtspec,'Tag','Radiobutton_cwt_mirror'),'Value');
        %%%%% Get a name for the output var %%%%%
        prefix=['cwt_' SigIn_name];
        varnamecwt=fl_findname(prefix,varargin{2});
        varargout{1}=varnamecwt;
        eval(['global ' varnamecwt]);
        %%%%% Perform the computation %%%%%
        FuncMeas = get(Figadvcwtspec,'UserData') ;
        if FuncMeas == 'SpecFunc'
            SigIn = eval(SigIn_name) ;
        elseif FuncMeas == 'SpecMeas'
            SigIn = eval(SigIn_name) ;
            SigIn = cumsum(SigIn) ;
        end
        
        if ~mirror 
            chaine = [varnamecwt,' = contwt(' SigIn_name ',[fmin,fmax],voices,',wave,');'];
            eval(chaine);
            chaine=[varnamecwt,'=contwt(',SigIn_name,',[',num2str(fmin),',',num2str(fmax),'],',num2str(voices),',',wave,');'];
        else
            chaine = [varnamecwt,' = contwt(' SigIn_name ',[fmin,fmax],voices,',wave,',''mirror'');'];
            eval(chaine);
            chaine=[varnamecwt,'=contwt(',SigIn_name,',[',num2str(fmin),',',num2str(fmax),'],',num2str(voices),',',wave,',''mirror'');'];
        end
        fl_diary(chaine);

        %%%%% Update the cwt list %%%%%
        fl_addlist(0,varnamecwt);
        set(findobj(Figadvcwtspec,'Tag','EditText_cwt_nname'),'String',varnamecwt) ;

        fl_waitoff(current_cursor);

        %%%%%%%%% LEGENDRE SPECTRUM PARAMETERS %%%%%%%%%%%%%

    case 'refresh_cwt'
        [cwt_in_name error_in] = fl_get_input('cwt') ;
        if error_in
            fl_error('Input must be a cwt structure !') ;
            fl_waitoff(current_cursor);
            return ;
        end
        set(findobj(Figadvcwtspec,'Tag','EditText_cwt_nname'),'String', cwt_in_name) ;


    case 'radiobutton_findmax'
        FindMax = get(gcbo,'Value') ;
        if FindMax == 1
            obj=findobj(Figadvcwtspec,'Tag','Radiobutton_adv_cwtspec_findmax') ;
            set(obj,'String','Yes') ;
        elseif FindMax == 0
            obj=findobj(Figadvcwtspec,'Tag','Radiobutton_adv_cwtspec_findmax') ;
            set(obj,'String','No') ;
        end


    case 'radiobutton_reg'

        Reg = get(gcbo,'Value') ;
        if Reg == 1
            set(gcbo,'String','Specify Regression Range') ;
        elseif Reg == 0
            set(gcbo,'String','Full Range Regression') ;
        end


    case 'cwtspec_compute'

        current_cursor=fl_waiton;
        cwt_in_name = get(findobj(Figadvcwtspec,'Tag','EditText_cwt_nname'),'String');
        eval(['global ' cwt_in_name]) ;
        cwt_in = eval(cwt_in_name) ;
        wt = cwt_in.coeff ;
        scale =  cwt_in.scale ;

        whichT = 0 ;

        obj=findobj(Figadvcwtspec,'Tag','Radiobutton_adv_cwtspec_findmax') ;
        FindMax = get(obj,'Value') ;
        obj=findobj(Figadvcwtspec,'Tag','Radiobutton_adv_cwtspec_reg') ;
        ChooseReg = get(obj,'Value') ;
        obj=findobj(Figadvcwtspec,'Tag','Radiobutton_adv_cwtspec_monolr') ;
        RegType = get(obj,'Value') ;
        switch RegType
            case 1
                RegParam{1} = 'ls' ;
            case {2,3,4,5}
                RegParam = fl_getregparam(RegType,length(scale)) ;
            case {6,7}
                RegParam = fl_getregparam(RegType) ;
        end
        obj=findobj(Figadvcwtspec,'Tag','EditText_adv_cwtspec_qmin');
        Qmin = str2num(get(obj,'String')) ;
        obj=findobj(Figadvcwtspec,'Tag','EditText_adv_cwtspec_qmax');
        Qmax = str2num(get(obj,'String')) ;
        obj=findobj(Figadvcwtspec,'Tag','EditText_adv_cwtspec_nbq');
        nbQ = str2num(get(obj,'String')) ;
        Q = linspace(Qmin,Qmax,nbQ) ;

        [alpha,f_alpha] = contwtspec(wt,scale,Q,FindMax,ChooseReg,RegParam{:}) ;

        Xlabel = 'Singularity \alpha' ; Ylabel = ' ' ;
        Title = 'Singularity Spectrum' ;
        varname = fl_findname([cwt_in_name,'_LegSpec'],varargin{2});
        varargout{1}=varname;
        eval(['global ' varname]);
        eval ([varname ' = struct (''type'',''graph'',''data1'',alpha,''data2'',f_alpha,''title'',Title,''xlabel'',Xlabel,''ylabel'',Ylabel);']);


        obj=findobj(Figadvcwtspec,'Tag','EditText_cwt_nname');
        varnamecwt = (get(obj,'String')) ;
       
        chaine2=['[',varname,'.alpha,',varname,...
            '.f_alpha]=contwtspec([',varnamecwt,'.coeff','],[',...
            varnamecwt,'.scale],[',num2str(Q),'],',...
            num2str(FindMax),',',num2str(ChooseReg),',''',RegParam{:},''');'];
        fl_diary(chaine2);


        fl_addlist(0,varname);

        fl_waitoff(current_cursor);

    case 'close'

        obj_reg = findobj('Tag','graph_reg') ;
        close(obj_reg) ;
        close(Figadvcwtspec) ;

    case 'help'

        helpwin gui_fl_cwtspec


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% trunc %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
