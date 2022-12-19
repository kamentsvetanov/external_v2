function [varargout]=fl_adv_DWTestim_compute(varargin)
% Callback functions for advanced dwtDWTestim GUI - Generation Parameter Window.

% Author Pierrick Legrand, January 2005
% Modified by Pierrick Legrand, June 2011
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

warning backtrace;
FigadvdwtDWTestim= gcf;
if ((isempty(FigadvdwtDWTestim)) | (~strcmp(get(FigadvdwtDWTestim,'Tag'),'Fig_gui_fl_adv_DWTestim')))
    FigadvdwtDWTestim = findobj ('Tag','Fig_gui_fl_adv_DWTestim');
end

fl_clearerror;
switch(varargin{1})
    case 'refresh'
        [SigIn_name error_in] = fl_get_input ('vector') ;
        if error_in
            fl_warning ('Input signal must be a vector !');
            return;
        end

        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;

        N = length(SigIn) ;
        logN=floor(log2(N(1)))-4;
        if(logN<=1.0) logN=2; end
        ppmh1=findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_fmin');
        ppmh2=findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_fmax');
        set([ppmh1 ppmh2],'Value',1);
        for i=1:logN
            varcell{i}=['2^(-',num2str(i),')'];
        end
        for i=1:logN
            varcell2{i}=['2^(-',num2str(logN-i+1),')'];
        end
        set([ppmh1],'String',varcell2);
        set([ppmh2],'String',varcell);
        set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_fmin'),'String',num2str(2^(-logN)));
        set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_fmax'),'String','0.5');
        set(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String',SigIn_name);
        set(findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_time'),'String',num2str(floor(N/2)));
        set(findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMax'),'String',num2str(floor(log2(N))));

    case 'dwt_editf'
        value=str2num(get(gcbo,'String'));
        if(value<0.0)
            SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
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

        %case 'dwt_ppm_fmin'
        %SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        %eval(['global ' SigIn_name]) ;
        %SigIn = eval(SigIn_name) ;
        %N = length(SigIn) ;
        %logN=floor(log2(N))-4;
        %if(logN<=1.0) logN=2; end
        %value=get(gcbo,'Value');
        %pow=2^(-1*(logN-value+1));
        %set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_fmin'),'String',num2str(pow));

        %case 'dwt_ppm_fmax'
        % value=get(gcbo,'Value');
        % pow=2^(-1*value);
        % set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_fmax'),'String',num2str(pow));

        %case 'dwt_edit_voices'
        %  value=str2num(get(gcbo,'String'));
        %  value=floor(value);
        %  if(value<=1.0) value=2.0; end
        %  set(gcbo,'String',value);

        %case 'dwt_ppm_voices'
        %  value=get(gcbo,'Value');
        % set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_voices'),'String',num2str(2^value));

        %case 'dwt_edit_wsize'
        % value=str2num(get(gcbo,'String'));
        % value=floor(value);
        % if(value<=1.0) value=2.0; end
        % set(gcbo,'String',value);

        %case 'dwt_ppm_wtype'
        %  ppmh=findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_wtype');
        %  eth=findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_wsize');
        % if(get(ppmh,'Value')==1)
        %   set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_wsize'),'Enable','off');
        %else
        %  set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_wsize'),'Enable','on');
        %end

        %case 'dwt_rb_mirror'
        %  if(get(gco,'Value')==0)
        %    set(gco,'String','No mirror');
        %  else
        %    set(gco,'String','Mirror');
        %  end

        % case 'dwt_compute'

        %   current_cursor=fl_waiton;

        %%%%% First get the input %%%%%%
        %   fl_clearerror;
        %   SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        %   eval(['global ' SigIn_name]);
        %   %%%%% Now get the wavelet type %%%%%
        %   ppmh=findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_wtype');
        %   eth=findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_wsize');
        %   switch(get(ppmh,'Value'))
        %     case 1
        %	wave=0;
        %     case 2
        %	wave=str2num(get(eth,'String'));
        %     case 3
        %	wave=i*str2num(get(eth,'String'));
        %   end
        %%%%% Get fmin and fmax %%%%%
        %   eth=findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_fmin');
        %   fmin=str2num(get(eth,'String'));
        %   eth=findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_fmax');
        %   fmax=str2num(get(eth,'String'));
        %%%%% Get the number of voices %%%%%
        %   eth=findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_voices');
        %  voices=str2num(get(eth,'String'));
        %%%%% L2 or L1? %%%%%
        %  mirror=get(findobj(FigadvdwtDWTestim,'Tag','Radiobutton_dwt_mirror'),'Value');
        %  if(mirror==0)
        %    command='contwt';
        %  else
        %    command='contwtmir';
        %  end

        %  %%%%% Get a name for the output var %%%%%
        %   prefix=['dwt_' SigIn_name];
        %   varname=fl_findname(prefix,varargin{2});
        %   varargout{1}=varname;
        %   eval(['global ' varname]);
        %%%%% Perform the computation %%%%%
        %   eval(['[wt scale f]=' command '(' SigIn_name ',fmin,fmax,voices,wave);']);
        %   eval ([varname ' = struct (''type'',''dwt'',''coeff'',wt,''scale'',scale,''frequency'',f);']);
        %%%%% Update the variables list %%%%%
        %   fl_addlist(0,varname);
        %  set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_nname'),'String',varname) ;
        %  fl_waitoff(current_cursor);

        %%%%%%%%% LOCAL SCALING PARAMETERS %%%%%%%%%%%%%

        % case 'refresh_dwt'
        %   [dwt_in_name error_in] = fl_get_input('dwt') ;
        %   if error_in
        %     fl_error('Input must be a dwt structure !') ;
        %     fl_waitoff(current_cursor);
        %     return ;
        %   end
        %   set(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_nname'),'String', dwt_in_name) ;

    case 'radiobutton_time'
        rb_time = get(gcbo,'Value') ;
        if rb_time == 1
            set(gcbo,'String','Single Time Exponent') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_time') ;
            set(obj,'Enable','on') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_reg') ;
            set(obj,'Enable','on') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','text_adv_DWTestim_scaleMin') ;
            set(obj,'Enable','off') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','text_adv_DWTestim_scaleMax') ;
            set(obj,'Enable','off') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMin') ;
            set(obj,'Enable','off') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMax') ;
            set(obj,'Enable','off') ;
        elseif rb_time == 0
            set(gcbo,'String','Holder Function') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_time') ;
            set(obj,'Enable','off') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_reg') ;
            set(obj,'String','Full Range Regression') ;
            set(obj,'Value',0) ;
            set(obj,'Enable','off') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','text_adv_DWTestim_scaleMin') ;
            set(obj,'Enable','on') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','text_adv_DWTestim_scaleMax') ;
            set(obj,'Enable','on') ;
             obj = findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMin') ;
            set(obj,'Enable','on') ;
            obj = findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMax') ;
            set(obj,'Enable','on') ;
        end

    case 'edit_time'
        fl_clearerror
        %dwtIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_nname'),'String') ;
        %eval(['global ' dwtIn_name]) ;
        %dwtIn = eval(dwtIn_name) ;
        %N = size(dwtIn.coeff,2) ;
        SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N=length(SigIn);
        larg=floor(N/2);
        time=str2num(get(gcbo,'String'));
        if isempty(time)| time~=floor(time)
            fl_error('Time must be an integer !');
            pause(.3);
            time=larg;
            set(gcbo,'String',num2str(time));
        else
            time = trunc(time,1,length(SigIn)) ;
            time=floor(time);
            set(gcbo,'String',num2str(time)) ;
        end;

        
   case 'scaleMin'
        fl_clearerror
        %dwtIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_nname'),'String') ;
        %eval(['global ' dwtIn_name]) ;
        %dwtIn = eval(dwtIn_name) ;
        %N = size(dwtIn.coeff,2) ;
        SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N=length(SigIn);
        larg=1;
        scmin=str2num(get(gcbo,'String'));
        scmax=get(findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMax'),'String');
        scmax=str2num(scmax);
        if isempty(scmin) | scmin~=floor(scmin)
            fl_error('Scale Min must be an integer !');
            pause(.3);
            scmin=larg;
            set(gcbo,'String',num2str(scmin));
        else
            scmin = trunc(scmin,1,scmax-1) ;
            scmin=floor(scmin);
            set(gcbo,'String',num2str(scmin)) ;
        end;
        
    case 'scaleMax'
        fl_clearerror
        %dwtIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_nname'),'String') ;
        %eval(['global ' dwtIn_name]) ;
        %dwtIn = eval(dwtIn_name) ;
        %N = size(dwtIn.coeff,2) ;
        SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N=length(SigIn);
        larg=floor(log2(N));
        scmax=str2num(get(gcbo,'String'));
        scmin=get(findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMin'),'String');
        scmin=str2num(scmin);
        if isempty(scmax) | scmax~=floor(scmax)
            fl_warning('Scale Max must be an integer !');
            pause(.3);
            scmax=larg;
            set(gcbo,'String',num2str(scmax));
        else
            scmax = trunc(scmax,scmin+1,floor(log2(N))) ;
            scmax=floor(scmax);
            set(gcbo,'String',num2str(scmax)) ;
        end;
        
        
        
    case 'edit_radius'
        fl_clearerror
        radius = str2num(get(gcbo,'String')) ;
        SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N=length(SigIn);
        larg=floor(N/2);
        radius = str2num(get(gcbo,'String')) ;
        if isempty(radius)
            fl_warning('Radius must be an integer !');
            pause(.3);
            radius=1;
            set(gcbo,'String',num2str(radius));
        else
            radius= floor(trunc(radius,0,larg)) ;
            set(gcbo,'String',num2str(radius)) ;
        end;

        %radius = max(0,radius) ;
        %set(gcbo,'String',num2str(radius)) ;

    case 'edit_deepscale'
        fl_clearerror;
        SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N=length(SigIn);
        scale=floor(log2(N));
        DeepScale = str2num(get(gcbo,'String')) ;
        if isempty(DeepScale)
            fl_warning('Scale depth must be an integer !');
            pause(.3);
            DeepScale=1;
            set(gcbo,'String',num2str(DeepScale));
        else
            DeepScale= floor(trunc(DeepScale,0,scale-2)) ;
            set(gcbo,'String',num2str(DeepScale)) ;
        end;
        %DeepScale = max(0,DeepScale);
        %DeepScale = min(scale-2,DeepScale);%trunc(DeepScale,1,(scale)) ;
        %set(gcbo,'String',num2str(DeepScale)) ;

    case 'radiobutton_findmax'
        FindMax = get(gcbo,'Value') ;
        if FindMax == 1
            obj=findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_findmax') ;
            set(obj,'String','Yes') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_deepscale') ;
            set(obj,'Enable','on') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_radius') ;
            set(obj,'Enable','on') ;
        elseif FindMax == 0
            obj=findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_findmax') ;
            set(obj,'String','No') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_deepscale') ;
            set(obj,'Enable','off') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_radius') ;
            set(obj,'Enable','off') ;
        end

    case 'radiobutton_reg'
        Reg = get(gcbo,'Value') ;
        if Reg == 1
            set(gcbo,'String','Specify Regression Range') ;
        elseif Reg == 0
            set(gcbo,'String','Full Range Regression') ;
        end


    case 'reg_type'
        type=get(gcbo,'Value');
        if type==6|type==7
            obj=findobj(FigadvdwtDWTestim,'Tag','checkbox_adv_DWTestim_tol') ;
            set(obj,'Enable','on') ;
            tol=get(obj,'Value');
            if tol==1
                set(obj,'String','With Tolerance');
                obj=findobj(FigadvdwtDWTestim,'Tag','Slider_adv_DWTestim_tol') ;
                set(obj,'Enable','on') ;
                obj=findobj(FigadvdwtDWTestim,'Tag','StaticText_tol') ;
                set(obj,'Enable','on') ;
                obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_tol') ;
                set(obj,'Enable','on') ;
            end;
        else
            obj=findobj(FigadvdwtDWTestim,'Tag','checkbox_adv_DWTestim_tol') ;
            %set(obj,'Value',0);
            set(obj,'Enable','off') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','Slider_adv_DWTestim_tol') ;
            set(obj,'Enable','off') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','StaticText_tol') ;
            set(obj,'Enable','off') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_tol') ;
            set(obj,'Enable','off') ;
        end



    case 'checkbox_tol'
        tol=get(gcbo,'value');
        if tol==1
            set(gcbo,'String','With Tolerance');
            obj=findobj(FigadvdwtDWTestim,'Tag','Slider_adv_DWTestim_tol') ;
            set(obj,'Enable','on') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','StaticText_tol') ;
            set(obj,'Enable','on') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_tol') ;
            set(obj,'Enable','on') ;
        elseif tol==0
            set(gcbo,'String','Without Tolerance');
            obj=findobj(FigadvdwtDWTestim,'Tag','Slider_adv_DWTestim_tol') ;
            set(obj,'Enable','off') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','StaticText_tol') ;
            set(obj,'Enable','off') ;
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_tol') ;
            set(obj,'Enable','off') ;
        end;

    case 'slider_tol'
        fl_clearerror;
        gamma=get(gcbo,'value');
        gamma=(floor(gamma*100))/100;
        obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_tol') ;
        set(obj,'String',gamma) ;

    case 'edit_tol'
        fl_clearerror;
        gamma=str2num(get(gcbo,'String'));
        if isempty(gamma)
            fl_warning('Gamma must be a real !');
            pause(.3);
            gamma=0.5;
            set(gcbo,'String','0.5');
        else
            gamma=gamma(1);
            gamma=trunc(gamma,0,0.9);
            set(gcbo,'String',gamma);
            obj=findobj(FigadvdwtDWTestim,'Tag','Slider_adv_DWTestim_tol') ;
            set(obj,'Value',gamma) ;
        end;

        
    case  'dwt_ppm_wtype'
        fl_clearerror;
        ondelette=(get(findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_wtype'),'String'));
        type=get(findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_wtype'),'Value');
        if type==15
            type_ond='Triangle';
            size=1;
            scmin=get(findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMin'),'String');
            scmin=str2num(scmin);
            set(findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMin'),'String',num2str(max(2,scmin)));
        else
           set(findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMin'),'String','1');
                  
        end;
        

    case 'compute_HofT'
        %fl_clearerror;
        current_cursor=fl_waiton;

        %dwt_in = get(findobj(FigadvdwtDWTestim,'Tag','EditText_dwt_nname'),'String') ;
        %eval(['global ' dwt_in]) ;
        %dwt_in = eval(dwt_in) ;
        %wt = dwt_in.coeff;
        %scale =  dwt_in.scale ;
        SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N=length(SigIn);
        scale=floor(log2(N)); % max possible scale
        obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_radius') ;
        radius = get(obj,'String') ;
        radius = str2num(radius) ;
        obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_deepscale') ;
        DeepScale = str2num(get(obj,'String')) ;
        DeepScale = trunc(DeepScale,1,(scale)) ;
      
        %set(findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_deepscale','String',num2str(scale)));
        set(obj,'String',num2str(DeepScale)) ;
        obj=findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_findmax') ;
        FindMax = get(obj,'Value') ;
        obj=findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_reg') ;
        Reg = get(obj,'Value') ;
        obj=findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_monolr') ;
        RegType = get(obj,'Value') ;
        
        obj=findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMin') ;
        scmin = get(obj,'String') ;
        scmin=str2num(scmin);
        obj=findobj(FigadvdwtDWTestim,'Tag','edit_adv_DWTestim_scaleMax') ;
        scmax = get(obj,'String') ;
        scmax=str2num(scmax);
        echelle=[scmin:scmax];
        
        switch RegType
            case {1}
                RegParam{1} = 'ls' ;
            case {2,3,4,5}
                SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
                eval(['global ' SigIn_name]) ;
                SigIn = eval(SigIn_name) ;
                N = length(SigIn) ;
                scale=ones(1,log2(N));
                RegParam = fl_getregparam(RegType,length(scale)) ;
            case {6,7}
                RegParam = fl_getregparam(RegType) ;
        end
        %%%%%
        ondelette=(get(findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_wtype'),'String'));
        type=get(findobj(FigadvdwtDWTestim,'Tag','PopupMenu_dwt_wtype'),'Value');
        if type>=11 && type<=14
            type_ond='coiflet';
            siz=ondelette(type);
            size=siz{1}(9:10);
            size=str2num(size);
        elseif type==15
            type_ond='Triangle';
            size=1;
        else
            type_ond='daubechies';
            siz=ondelette(type);
            size=siz{1}(12:13);
            size=str2num(size);
        end;
        %%%%%
        %findmax=get(findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_findmax'),'Value');
        obj=findobj(FigadvdwtDWTestim,'Tag','checkbox_adv_DWTestim_tol') ;
        Tol=get(obj,'Value');
        obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_tol') ;
        Gamma=str2num(get(obj,'String'));

        obj=findobj(FigadvdwtDWTestim,'Tag','Radiobutton_adv_DWTestim_time') ;
        rb_time = get(obj,'Value'); 
        if rb_time == 1

            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_time') ;
            whichT = str2num(get(obj,'String')) ;
            whichT = min(whichT,length(SigIn)) ;
            varname = 'HofT' ;
            varargout{1}=varname;
            eval(['global ' varname]);
            eval(['[H,', varname, 'alpha,vect_ech1,vect_log1,handlefig]=DWTestim_all(SigIn,whichT,RegParam,type_ond,size,Reg,Tol,Gamma,FindMax,radius,DeepScale,0);']);
            obj=findobj(FigadvdwtDWTestim,'Tag','EditText_adv_DWTestim_HofT') ;
            set(obj,'String',num2str(eval(varname))) ;
            h=guidata(handlefig);
            h.HandleOut=obj;
            guidata(handlefig,h);
                       

            chaine=[varname,'=DWTestim_all(',SigIn_name,',',num2str(whichT),...
                ',{''',RegParam{1},'''},''',...
                type_ond,''',',num2str(size),',',num2str(Reg),',',num2str(Tol),...
                ',',num2str(Gamma),',',num2str(FindMax),',',...
                num2str(radius),',',num2str(DeepScale),',0);'];

            fl_diary(chaine)


        elseif rb_time == 0

            Reg = 0 ; 	% As no specific regression range can be global for all
            % times :  full range regression

            SigIn_name = get(findobj(FigadvdwtDWTestim,'Tag','EditText_sig_nname'),'String') ;
            varname = fl_findname([SigIn_name,'_HDt'],varargin{2});
            varargout{1}=varname;
            eval(['global ' varname]);
            %dT = max(1 , round(size(wt,2))/64) ;

            eval([varname '=DWTestim_all(SigIn,[],RegParam,type_ond,size,Reg,Tol,Gamma,FindMax,radius,DeepScale,echelle);']);
            %[varname,ddzs,fdfd,ftr,varname2]=DWTestim(SigIn,[]);



            chaine=[varname,'=DWTestim_all(',SigIn_name,',[],{''',RegParam{1},'''},''',...
                type_ond,''',',num2str(size),',',num2str(Reg),',',num2str(Tol),...
                ',',num2str(Gamma),',',num2str(FindMax),',',...
                num2str(radius),',',num2str(DeepScale),',0,[',num2str(echelle),']);'];



            fl_diary(chaine)

            %varname2=num2str(varname);
            fl_addlist(0,varname) ;

        end

        fl_waitoff(current_cursor);

    case 'close'

        obj_reg = findobj('Tag','graph_reg') ;
        close(obj_reg) ;
        close(FigadvdwtDWTestim) ;

    case 'help'

        helpwin gui_fl_DWTestim

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











