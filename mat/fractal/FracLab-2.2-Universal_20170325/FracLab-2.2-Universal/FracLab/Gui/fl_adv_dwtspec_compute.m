function varargout=fl_adv_dwtspec_compute(varargin)
% Callback functions for the FRACLAB Toolbox GUI ADVANCED DWTSPEC.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

Figadvdwtspec = gcf;
if ((isempty(Figadvdwtspec)) | (~strcmp(get(Figadvdwtspec,'Tag'),'Fig_gui_fl_adv_dwtspec')))
    Figadvdwtspec = findobj ('Tag','Fig_gui_fl_adv_dwtspec');
end

switch(varargin{1})

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%  Discrete WT Window %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'dwt_edit_octave'
        value=str2num(get(gcbo,'String'));
        value=floor(value);
        if(value<1.0) value=1.0; end
        set(gcbo,'String',value);

    case 'dwt_ppm_octave'
        value=get(gcbo,'Value');
        set(findobj(Figadvdwtspec,'Tag','EditText_dwt_octave'),'String',num2str(value));

    case 'radiobutton_reg'
        Reg = get(gcbo,'Value') ;
        if Reg == 1
            set(gcbo,'String','Specify Regression Range') ;
        elseif Reg == 0
            set(gcbo,'String','Full Regression Range') ;
        end

    case 'dwtspec_compute'

        current_cursor=fl_waiton;

        fl_clearerror;

        SigIn_name = get(findobj(Figadvdwtspec,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]);

        sz = eval( ['size(' SigIn_name ')'] );
        if min(min(sz))>1,
            varargout{1}=SigIn_name;
            fl_warning('input signal must be a vector!');
            fl_waitoff(current_cursor);
            return;
        end;

        %%%%% Get the octave %%%%
        edith=findobj(Figadvdwtspec,'Tag','EditText_dwt_octave');
        octave=str2num(get(edith,'String'));
        %%%%% Now get the wavelet type %%%%%
        ppmh=findobj(Figadvdwtspec,'Tag','PopupMenu_dwt_type');
        wt_order=get(ppmh,'Value');

        %%%%% Get a name for the dwt output var %%%%%

        prefix=['dwt_' SigIn_name];
        varnamedwt=fl_findname(prefix,varargin{2});
        varargout{1}=varnamedwt;
        eval(['global ' varnamedwt]);

        %%%%% Perform the computation %%%%%
        if (wt_order<=10)
            f1=MakeQMF('daubechies',wt_order*2);
        else
            switch(wt_order)
                case 11
                    f1=MakeQMF('coiflet',6);
                case 12
                    f1=MakeQMF('coiflet',12);
                case 13
                    f1=MakeQMF('coiflet',18);
                case 14
                    f1=MakeQMF('coiflet',24);
            end;
        end;

        FuncMeas = get(Figadvdwtspec,'UserData') ;
        if FuncMeas == 'SpecFunc'
            SigIn = eval(SigIn_name) ;
        elseif FuncMeas == 'SpecMeas'
            SigIn = eval(SigIn_name) ;
            SigIn = cumsum(SigIn) ;
        end


        [wt wti wtl] = FWT(SigIn,octave,f1) ;

        eval ([varnamedwt ' = struct(''type'',''dwt'',''wt'',wt,''index'',wti,''length'',wtl'');']);

        chaine1=['[',varnamedwt,'.wt,',varnamedwt,'.index,',varnamedwt,...
            '.length]=FWT(',SigIn_name,',',num2str(octave),',[',num2str(f1),']);'] ;



        %%%%% Add to ouput list %%%%%
        fl_addlist(0,varnamedwt);

        %%%%%%%% READ SPECTRUM ARGUMENTS %%%%%%%%%%

        obj=findobj(Figadvdwtspec,'Tag','EditText_adv_dwtspec_qmin');
        Qmin = str2num(get(obj,'String')) ;

        obj=findobj(Figadvdwtspec,'Tag','EditText_adv_dwtspec_qmax');
        Qmax = str2num(get(obj,'String')) ;

        obj=findobj(Figadvdwtspec,'Tag','EditText_adv_dwtspec_nbq');
        nbQ = str2num(get(obj,'String')) ;

        Q = linspace(Qmin,Qmax,nbQ) ;

        obj=findobj(Figadvdwtspec,'Tag','Radiobutton_adv_dwtspec_reg');
        Reg = get(obj,'Value') ;

        obj=findobj(Figadvdwtspec,'Tag','Radiobutton_adv_dwtspec_monolr') ;
        RegType = get(obj,'Value') ;
        switch RegType
            case 1
                RegParam{1} = 'ls' ;
            case {2,3,4,5}
                RegParam = fl_getregparam(RegType,octave) ;
            case {6,7}
                RegParam = fl_getregparam(RegType) ;
        end

        [alpha,f_alpha,logpart,tau] = dwtspec(wt,Q,Reg,RegParam{:}) ;

        Xlabel = 'Singularity \alpha' ; Ylabel = ' ' ;
        Title = 'Singularity Spectrum' ;
        varname = fl_findname([varnamedwt,'_LegSpec'],varargin{2});
        varargout{2}=varname;
        eval(['global ' varname]);
        eval ([varname '= struct (''type'',''graph'',''data1'',alpha,''data2'',f_alpha,''title'',Title,''xlabel'',Xlabel,''ylabel'',Ylabel);']);
        fl_addlist(0,varname);


        chaine2=['[',varname,'.alpha,',varname,...
            '.f_alpha]=dwtspec([',varnamedwt,'.wt','],[',num2str(Q),'],',...
            num2str(Reg),',''',RegParam{:},''');'];


        chaine=[chaine1,chaine2];
        fl_diary(chaine)

        fl_waitoff(current_cursor);

    case 'close'

        obj_reg = findobj('Tag','graph_reg') ;
        close(obj_reg) ;
        close(Figadvdwtspec) ;

    case 'help'

        helpwin gui_fl_dwtspec

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closewindow(tag)
figh=findobj(fig,'Tag',tag);
close(figh);

