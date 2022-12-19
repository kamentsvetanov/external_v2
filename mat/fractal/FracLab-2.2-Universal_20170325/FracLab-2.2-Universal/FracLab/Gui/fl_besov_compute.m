function [varargout]=fl_besov_compute(varargin)
% Callback function for Besov GUI
%
% Besov Norms
%
%   1.  Usage of the corresponding command:
%
%       [VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]=besov_spq(Input,NbLevels,s,p,q)
%       [VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]=besov_spinf(Input,NbLevels,s,p)
%       [VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]=besov_sinfq(Input,NbLevels,s,p)
%       [VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]=besov_s(Input,NbLevels,s)
%
%       [VectEnergie,EnergieT]=besov1D_spq(Input,NbLevels,s,p,q)
%       [VectEnergie,,EnergieT]=besov1D_spinf(Input,NbLevels,s,p)
%       [VectEnergie,,EnergieT]=besov1D_sinfq(Input,NbLevels,s,p)
%       [VectEnergie,,EnergieT]=besov1D_s(Input,NbLevels,s)
%
%   1.1.  Input Data
%
%   The input signal could be any highlighted  structure of the input list
%   ListBox of the main fltool  Figure: a real matrix of size [N,M].
%
%   This matrix is selected when opening this  Figure from the corresponding
%   UiMenu of  the main  fltool  Figure, or when the refresh PushButton is used.
%   When the type of the  highlighted structure does not match with the
%   authorized types, an error  message is displayed in the message
%   StaticText of the main  fltool Figure. The name of the input
%   data is displayed in the StaticText just below.
%
%   2.  UIcontrols
%
%   2.1.  Control parameters
%
%   o  p : edit or slider or RadioButton
%
%   o  q : edit or slider or RadioButton
%
%   o  s : edit or slider or RadioButton
%
%   o  level : edit
%
%   2.2.  Computation
%
%   o  Compute :  PushButton.
%      Computes the  besov norm of the input signal
%      depending on the choice in the edit or slider menu.
%      It calls the routines besov_spq.m, besov_spinf.m, ...etc
%
%   o  Help : PushButton.
%      Calls this help.
%
%   o  Close : PushButton.
%      Returns to the main fltool Figure.
%
%   3.  Outputs
%
%   o  There is five outputs for the 2D inputs : the besov norm versus the level for vertical, horizontal and diagonal wavelet coefficients, the besov norm of the vertical wavelet coefficients,
%      the besov norm of the horizontal wavelet coefficients, the besov norm of the
%      diagonal wavelet coefficients and the besov norm of all wavelet coefficients.
%
%   o  There is two outputs for the 1D inputs : the besov norm versus the level for the wavelet coefficients,
%      and the besov norm of all wavelet coefficients.

% Author Karine Christophe, May 2003
% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

varOutstring=[];

[objTmp,besov_fig] = gcbo;
%
% besov_fig = gcf;
% if ((isempty(besov_fig)) | (~strcmp(get(besov_fig,'Tag'),'Fig_gui_fl_besov')))
%   besov_fig = findobj ('Tag','Fig_gui_fl_besov');
% end

switch(varargin{1})

    %% Multiplication param editing
    %**********************************************************************
    % case 's'
    case 'edit_param1'
        fl_clearerror;
        s=str2num(get(gcbo,'String'));
        if isempty(s)|(s<0)
            fl_warning('s must be > 0 !');
            pause(.3);
            s=1;
            set(gcbo,'String','1');
        else
            set(gcbo,'String',s);
            set(findobj('Tag','Slider_besov_param1'),'Value',s);
        end;

        % case slider s
    case 'slider_param1'
        fl_clearerror;
        s=get(gcbo,'Value');
        EditHandle1=findobj('Tag','EditText_besov_param1');
        set(EditHandle1,'String',s);



        %***********************************************************************

        % case 'p'
    case 'edit_param2'
        fl_clearerror;
        p=str2num(get(gcbo,'String'));
        if isempty(p)|(p<0)
            fl_warning('p must be > 0 !');
            pause(.2);
            p=1;
            set(gcbo,'String','1');
        else
            set(gcbo,'String',p);
            set(findobj('Tag','Slider_besov_param2'),'Value',p);
        end;

        % case slider p
    case 'slider_param2'
        fl_clearerror;
        p=get(gcbo,'Value');
        EditHandle2=findobj('Tag','EditText_besov_param2');
        set(EditHandle2,'String',p);


        %case infinity_2
    case 'mode2'
        fl_clearerror
        value_p = get(gcbo,'Value');
        if value_p == 1
            set(findobj(besov_fig,'Tag','Slider_besov_param2'),'enable','off');
            set(findobj(besov_fig,'Tag','EditText_besov_param2'),'enable','off');
            set(findobj(besov_fig,'Tag','EditText_besov_param2'),'String','Infinity');
        elseif value_p == 0
            set(findobj(besov_fig,'Tag','Slider_besov_param2'),'enable','on');
            set(findobj(besov_fig,'Tag','EditText_besov_param2'),'enable','on');
            set(findobj(besov_fig,'Tag','EditText_besov_param2'),'String','1');
        end
        %************************************************************************

        % case 'q'
    case 'edit_param3'
        fl_clearerror;
        q=str2num(get(gcbo,'String'));
        if isempty(q)|(q<0)
            fl_warning('q must be > 0 !');
            pause(.3);
            q=1;
            set(gcbo,'String','1');
        else
            set(gcbo,'String',q);
            set(findobj('Tag','Slider_besov_param3'),'Value',q);
        end;

        % case slider q
    case 'slider_param3'
        fl_clearerror;
        q=get(gcbo,'Value');
        EditHandle3=findobj('Tag','EditText_besov_param3');
        set(EditHandle3,'String',q);

        %case infinity_3
    case 'mode3'
        fl_clearerror
        value_q = get(gcbo,'Value');
        if value_q == 1
            set(findobj(besov_fig,'Tag','Slider_besov_param3'),'enable','off');
            set(findobj(besov_fig,'Tag','EditText_besov_param3'),'enable','off');
            set(findobj(besov_fig,'Tag','EditText_besov_param3'),'String','Infinity');
        elseif value_q == 0
            set(findobj(besov_fig,'Tag','Slider_besov_param3'),'enable','on');
            set(findobj(besov_fig,'Tag','EditText_besov_param3'),'enable','on');
            set(findobj(besov_fig,'Tag','EditText_besov_param3'),'String','1');
        end

        %**************************************************************************
        % case 'level'

    case 'edit_level'
        SigIn_name= get(findobj('Tag','EditText_sig_nname_besov'),'String');
        eval(['global ' SigIn_name]) ;
        SigIn = eval(SigIn_name) ;
        N = length(SigIn) ;
        fl_clearerror;
        level=str2num(get(gcbo,'String'));
        if isempty(level) | level<1 | level > log2(N)
            fl_warning('Level is an integer >1 and <log2(length(signal))!');
            pause(.3);
            level=(ceil(2*log2(N)/3));
            set(gcbo,'String',num2str(level));
        else
            level=floor(level);
            set(gcbo,'String',num2str(level));
        end


        %****************************************************************************
        %% "Compute" callbacks
    case 'compute'
        pointer=fl_waiton;

        %%%%% First get the input %%%%%%
        fl_clearerror;
        InputName=get(findobj('Tag','EditText_sig_nname_besov'),'String');
        if isempty(InputName)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(pointer);
        else
            eval(['global ' InputName]);
        end;


        %%%%%%%%%%% Perform the computation%%%%%%%%%%%%%%%%%
        value_p=get(findobj(besov_fig,'Tag','Check_besov_mode2'),'Value');
        value_q=get(findobj(besov_fig,'Tag','Check_besov_mode3'),'Value');

        obj1=findobj('Tag','EditText_besov_param1');
        s=str2num(get(obj1,'String'));
        obj2=findobj('Tag','EditText_besov_param2');
        p=str2num(get(obj2,'String'));
        obj3=findobj('Tag','EditText_besov_param3');
        q=str2num(get(obj3,'String'));
        obj4=findobj('Tag','EditText_besov_level');
        niveau=str2num(get(obj4,'String'));

        t=(1:niveau);
        %%%%%
        ondelette=(get(findobj('Tag','PopupMenu_besov_wtype'),'String'));
        type=get(findobj('Tag','PopupMenu_besov_wtype'),'Value');
        if type>=11
            type_ond='coiflet';
            siz=ondelette(type);
            siz1=siz{1}(9:10);
            siz1=str2num(siz1);
        else
            type_ond='daubechies';
            siz=ondelette(type);
            siz1=siz{1}(12:13);
            siz1=str2num(siz1);
        end;



        %%%%% Get a name for the output structure  %%%%%


        OutputName1=['besov_' InputName];
        varname1 = fl_findname(OutputName1,varargin{2});
        OutputName2=['besov_vert_' InputName];
        varname2 = fl_findname(OutputName2,varargin{2});
        OutputName3=['besov_horiz_' InputName];
        varname3 = fl_findname(OutputName3,varargin{2});
        OutputName4=['besov_diag_' InputName];
        varname4 = fl_findname(OutputName4,varargin{2});

        %     [varname1 varname2 varname3 varname4 varname5] = fl_find_mnames(varargin{2},'besov_','besov_vert_','besov_horiz_', 'besov_diag_','besov_total_');
        eval(['global ' varname1]);
        eval(['global ' varname2]);
        eval(['global ' varname3]);
        eval(['global ' varname4]);



        eval(['szmin=min(min(size(' InputName ')));']);

        if (szmin==1)
            set(findobj(besov_fig,'Tag','EditText_besov_result1'),'enable','off');
            set(findobj(besov_fig,'Tag','EditText_besov_result1'),'String','/');
            set(findobj(besov_fig,'Tag','EditText_besov_result2'),'enable','off');
            set(findobj(besov_fig,'Tag','EditText_besov_result2'),'String','/');
            set(findobj(besov_fig,'Tag','EditText_besov_result3'),'enable','off');
            set(findobj(besov_fig,'Tag','EditText_besov_result3'),'String','/');

            eval(['global ' InputName]);
            if (value_p == 1)&(value_q == 1)
                eval(['[VectEnergie,EnergieT]= besov1D_s(' InputName ',s,niveau,type_ond,siz1);']);
            
                chaine=['[VectEnergie,EnergieT]= besov1D_s(',InputName,...
                    ',',num2str(s),...
                    ',',num2str(niveau),',''',type_ond,''',',num2str(siz1),');'];
                fl_diary(chaine);
            
            elseif(value_p == 0)&(value_q == 1)
                eval(['[VectEnergie,EnergieT]= besov1D_spinf(' InputName ',s,p,niveau,type_ond,siz1);']);
           
                chaine=['[VectEnergie,EnergieT]= besov1D_spinf(',InputName,...
                    ',',num2str(s),',',num2str(p),...
                    ',',num2str(niveau),',''',type_ond,''',',num2str(siz1),');'];
                fl_diary(chaine);
            
            
            elseif(value_p == 1)&(value_q == 0)
                eval(['[VectEnergie,EnergieT]= besov1D_sinfq(' InputName ',s,q,niveau,type_ond,siz1);']);

                chaine=['[VectEnergie,EnergieT]= besov1D_sinfq(',InputName,...
                    ',',num2str(s),',',num2str(q),...
                    ',',num2str(niveau),',''',type_ond,''',',num2str(siz1),');'];
                fl_diary(chaine);
                
                
                
            else
                eval(['[VectEnergie,EnergieT]= besov1D_spq(' InputName ',s,p,q,niveau,type_ond,siz1);']);

                chaine=['[VectEnergie,EnergieT]= besov1D_spq(',InputName,...
                    ',',num2str(s),',',num2str(p),',',num2str(q),...
                    ',',num2str(niveau),',''',type_ond,''',',num2str(siz1),');'];
                fl_diary(chaine);
            end

            obj=findobj(besov_fig,'Tag','EditText_besov_result4') ;
            set(obj,'String',num2str(EnergieT)) ;

            eval([varname1 '=VectEnergie;']);
            fl_addlist(0,varname1);

            varargout{1} = [varname1];

        else
            eval(['global ' InputName]);
            if (value_p == 1)&(value_q == 1)
                eval(['[VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]= besov_s(' InputName ',s,niveau,type_ond,siz1);']);
            elseif(value_p == 0)&(value_q == 1)
                eval(['[VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]= besov_spinf(' InputName ',s,p,niveau,type_ond,siz1);']);
            elseif(value_p == 1)&(value_q == 0)
                eval(['[VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]= besov_sinfq(' InputName ',s,q,niveau,type_ond,siz1);']);
            else
                eval(['[VectEnergie,EnergieV,EnergieH,EnergieD,EnergieT]= besov_spq(' InputName ',s,p,q,niveau,type_ond,siz1);']);
            end

            obj1=findobj(besov_fig,'Tag','EditText_besov_result1') ;
            set(obj1,'String',num2str(EnergieV)) ;

            obj2=findobj(besov_fig,'Tag','EditText_besov_result2') ;
            set(obj2,'String',num2str(EnergieH)) ;

            obj3=findobj(besov_fig,'Tag','EditText_besov_result3') ;
            set(obj3,'String',num2str(EnergieD)) ;

            obj4=findobj(besov_fig,'Tag','EditText_besov_result4') ;
            set(obj4,'String',num2str(EnergieT)) ;

            eval([varname2 '=VectEnergie(1,:);']);
            fl_addlist(0,varname2);
            eval([varname3 '=VectEnergie(3,:);']);
            fl_addlist(0,varname3);
            eval([varname4 '=VectEnergie(2,:);']);
            fl_addlist(0,varname4);

            varargout{1}=[varname2 ' ' varname3 ' ' varname4 ] ;
        end



        fl_waitoff(pointer);

        %************************************************************************

    case 'refresh'
        fl_clearerror;
        [InputName flag_error]=fl_get_input('matrix');
        if flag_error
            [InputName flag_error]=fl_get_input('vector');
        end
        if flag_error
            fl_warning('input signal must be a vector or matrix !');
        else
            eval(['global ',InputName]);
            set(findobj('Tag','EditText_sig_nname_besov'),'String',InputName);
            [SigIn_name error_in] = fl_get_input ('vector') ;
            eval(['global ' SigIn_name]) ;
            SigIn=eval(SigIn_name);
            N = length(SigIn) ;
            level=num2str(floor(log2(N)));
            set(findobj('Tag','EditText_besov_level'),'String',level);
        end;


    case 'help'
        helpwin('fl_besov_compute');

    case 'close'
        fl_clearerror;
        figh = findobj('Tag','graph_segment') ;
        close(figh)
        close(gcf)

end;


