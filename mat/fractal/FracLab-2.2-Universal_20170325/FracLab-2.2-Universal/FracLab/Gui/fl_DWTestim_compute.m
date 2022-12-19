function [varargout]=fl_DWTestim_compute(varargin) 
% Callback functions for DWTestim GUI - Generation Parameter Window.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

warning off;
FigDWTestim=gcf;
if ((isempty(FigDWTestim)) | (~strcmp(get(FigDWTestim,'Tag'),'Fig_gui_fl_DWTestim')))
    FigDWTestim = findobj ('Tag','Fig_gui_fl_DWTestim');
end

switch(varargin{1})

    %%%%%% Time instant callbacks %%%%%%%

    case 'edit_time'

        fl_clearerror;
        [SigIn_name error_in] = fl_get_input('vector') ;
        eval(['global ',SigIn_name]) ;
        if error_in
            fl_warning('input signal must be a vector !') ;
            fl_waitoff(current_cursor);
            return ;
        end
        SigIn = eval(SigIn_name) ;
        N = length(SigIn) ;
        time=str2num(get(gcbo,'String'));
        if isempty(time)
            fl_warning('Time instant must be an integer !');
            pause(.3);
            time=floor(N/2);
            set(gcbo,'String',num2str(time));
        else
            time = floor(trunc(time,1,N)) ;
            set(gcbo,'String',num2str(time)) ;
        end;


        %%%%%%%%% "Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

    case 'compute'

        current_cursor=fl_waiton;

        obj=findobj(FigDWTestim,'Tag','EditText_DWTestim_time') ;
        whichT=str2num(get(obj,'String')) ;
        [SigIn_name error_in] = fl_get_input ('vector') ;

        if error_in
            fl_warning ('Input must be a vector !');
        else
            eval(['global ',SigIn_name]) ;
            SigIn = eval(SigIn_name) ;
            N = length(SigIn) ;
            Nscale = max(2,round(log2(N/16))) ;
            [H_,HofT,vect_ech1,vect_log1,handlefig]=DWTestim_all(SigIn,whichT,{'ls'},...
                'daubechies',10,[],0,5,0,[],[],[]);
            
            obj=findobj(FigDWTestim,'Tag','EditText_DWTestim_HofT') ;
            set(obj,'String',num2str(HofT)) ;
            h=guidata(handlefig);
            h.HandleOut=obj;
            guidata(handlefig,h);

            chaine=['[H_,HofT]=DWTestim_all(',SigIn_name,',',num2str(whichT),...
                ',{''ls''},''daubechies'',10,[],0,5,0,[],[],[]);'];
                
                
            fl_diary(chaine);

        end

        fl_waitoff(current_cursor);

        %%%%%%%%% "Advanced Compute" callbacks %%%%%%%%%%%%%%%%%%%%%%

    case 'advanced_compute'

        [SigIn_name error_in] = fl_get_input ('vector') ;

        if error_in
            fl_warning ('Input must be a vector !');
        else

            eval(['global ' SigIn_name]) ;
            SigIn = eval(SigIn_name) ;
            fl_callwindow('Fig_gui_fl_adv_DWTestim','gui_fl_adv_DWTestim') ;
            FigadvDWTestim = findobj('Tag','Fig_gui_fl_adv_DWTestim') ;

            N = length(SigIn) ;
            logN=floor(log2(N(1)))-4;
            if(logN<=1.0) logN=2; end
            ppmh1=findobj(FigadvDWTestim,'Tag','PopupMenu_dwt_fmin');
            ppmh2=findobj(FigadvDWTestim,'Tag','PopupMenu_dwt_fmax');
            set([ppmh1 ppmh2],'Value',1);
            for i=1:logN
                varcell{i}=['2^(-',num2str(i),')'];
            end
            for i=1:logN
                varcell2{i}=['2^(-',num2str(logN-i+1),')'];
            end
            set([ppmh1],'String',varcell2);
            set([ppmh2],'String',varcell);
            set(findobj(FigadvDWTestim,'Tag','EditText_dwt_fmin'),'String',num2str(2^(-logN)));
            set(findobj(FigadvDWTestim,'Tag','EditText_dwt_fmax'),'String','0.5');
            set(findobj(FigadvDWTestim,'Tag','EditText_sig_nname'),'String',SigIn_name);
            set(findobj(FigadvDWTestim,'Tag','EditText_adv_DWTestim_time'),'String',num2str(floor(N/2)));
            set(findobj(FigadvDWTestim,'Tag','edit_adv_DWTestim_scaleMax'),'String',num2str(floor(log2(N))));
            
            close(FigDWTestim) ;

        end

    case 'close'

        obj_reg = findobj(FigDWTestim,'Tag','graph_reg') ;
        close(obj_reg) ;
        obj_cwt = findobj(FigDWTestim,'Tag','graph_cwt') ;
        close(obj_cwt) ;
        close(FigDWTestim) ;

    case 'help'

        helpwin gui_fl_DWTestim

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



