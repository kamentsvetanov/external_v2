function fl_estimg_compute(command)

estimg_fig = gcf;
if ((isempty(estimg_fig)) | (~strcmp(get(estimg_fig,'Tag'),'Fig_gui_estimg')))
  estimg_fig = findobj ('Tag','Fig_gui_estimg');
end
%%%% Get GUI handles %%%%%%% 
handles=guihandles(estimg_fig);

switch command
    case('Change_method')
        empiric_computation=get(handles.Empirical,'Value');
        
        if empiric_computation
            visible_empiric='on';
            visible_param='off';
        else
            visible_empiric='off';
            visible_param='on';
        end
        set([handles.Exponent,handles.text2,handles.Refresh_exp,handles.Compute_int_empiric],'Visible',visible_empiric);
        set([handles.Compute_int_param,handles.Amplitude_choice,handles.Amplitude_txt,handles.Confidence_text,handles.Pourcent],'Visible',visible_param);
    case('refresh_sig');
        fl_clearerror;
        input_sig=fl_get_input;
        set(handles.Input_Signal,'String',input_sig);
    case('refresh_exp');
        fl_clearerror;
        input_exp=fl_get_input;
        set(handles.Exponent,'String',input_exp);
    case('g_length_popup');
        i=get(handles.g_length_popup,'Value');
        vecteur_valeurs=get(handles.g_length_popup,'String');
        texte_qui_saffiche=vecteur_valeurs{i};
        set(handles.g_length_text,'String',texte_qui_saffiche);
    case('compute');
        fl_clearerror
        empiric_computation=get(handles.Empirical,'Value');
        if empiric_computation

            input_sig=get(handles.Input_Signal,'String');
            input_exp=get(handles.Exponent,'String');            
            g_length=get(handles.g_length_text,'String');
            compute_std=get(handles.Compute_int_empiric,'Value');
            draw_func=get(handles.Draw,'Value');

            ws=whos('global');
            err=0;
            if sum(strcmp(input_sig,{ws.name}))==0;
                fl_warning('Input signal must be initialized: Refresh!');err=1;
            else
                SignIn=evalin('base',input_sig);
            end
            
            if sum(strcmp(input_exp,{ws.name}))==0;
                fl_warning('Input exponent must be initialized: Refresh!');err=1;
            else
                SignExp=evalin('base',input_exp);
            end
            
            %%%%% Check size of input and exponents vectors %%%%%
            if numel(SignIn) ~= numel(SignExp)
                fl_warning('Input signal and exponent vectors must have the same size.');err=1;
            end

            if err==0
                g_length=str2num(g_length);

                pas=(max(SignIn)-min(SignIn))/g_length;
                abscisses=[min(SignIn)+pas/2:pas:max(SignIn)-pas/2];

                % Perform the computation.
                [estim,stdev]=empiric_g(SignIn,SignExp,abscisses);            

                % Assign the results to global variables.
                abscissesname=fl_findname('empiric_abscissa_',who('global'));
                eval(['global ',abscissesname]);
                evalin('base',['global ',abscissesname]);
                eval([abscissesname,'= abscisses;']);
                fl_addlist(0,abscissesname);
                numero_nom=abscissesname(18:end);

                estimname = ['empiric_g_',numero_nom];
                eval(['global ',estimname]);
                evalin('base',['global ',estimname]);
                eval([estimname,'= estim;']);
                fl_addlist(0,estimname);

                % Write formula of abscissa in the diary
                chaine1=['m=min(',input_sig,')   ;   M=max(',input_sig,')   ;   step=(M-m)/',num2str(g_length),'   ;   ',abscissesname,'=[m+step/2:step:M-step/2];'];
                fl_diary(chaine1);
                
                if compute_std
                    stdevname = ['empiric_std_',numero_nom];
                    eval(['global ',stdevname]);
                    evalin('base',['global ',stdevname]);
                    eval([stdevname,'= stdev;']);
                    fl_addlist(0,stdevname);
                    chaine2=['[',estimname,',',stdevname,']',' = empiric_g(',input_sig,',',input_exp,',',abscissesname,');'];
                else
                    chaine2=[estimname,' = empiric_g(',input_sig,',',input_exp,',abscissas);'];
                end
                % Write computation in the diary
                fl_diary(chaine2);

                if draw_func
                    figure;hold on
                    plot(abscisses,estim);
                    plot(abscisses,estim+2*stdev,'--');
                    plot(abscisses,estim-2*stdev,'--');                
                    legend('Estimated value','96% confidence interval');
                end
            end
        else
            compute_interval=get(handles.Compute_int_param,'Value');
            draw_func=get(handles.Draw,'Value');
            
            input_sig=get(handles.Input_Signal,'String');          
            g_length=get(handles.g_length_text,'String');
            pcent_str=get(handles.Pourcent,'String');
            ampli=get(handles.Amplitude_choice,'String');
            
            ws=whos('global');
            err=0;
            if sum(strcmp(input_sig,{ws.name}))==0;
                fl_warning('Input signal must be initialized: Refresh!');err=1;
            else
                SignIn=evalin('base',input_sig);
            end
            
            if err==0
                g_length=str2num(g_length);
                pcent=str2num(pcent_str)/100;
                ampli=str2num(ampli);

                pas=(max(SignIn)-min(SignIn))/g_length;
                abscisses=[min(SignIn)+pas/2:pas:max(SignIn)-pas/2];

                % Perform the computation.
                [estimateur,minerr,maxerr]=parametric_g(SignIn,abscisses,pcent,ampli);

                % Assign the results to global variables.
                abscissesname=fl_findname('param_abscissa_',who('global'));
                eval(['global ',abscissesname]);
                evalin('base',['global ',abscissesname]);
                eval([abscissesname,'= abscisses;']);
                fl_addlist(0,abscissesname);
                numero_nom=abscissesname(16:end);

                estimname = ['param_g_',numero_nom];
                eval(['global ',estimname]);
                evalin('base',['global ',estimname]);
                eval([estimname,'= estimateur;']);               
                fl_addlist(0,estimname);
               
                % Write formula of abscissa in the diary
                chaine1=['m=min(',input_sig,')   ;   M=max(',input_sig,')   ;   step=(M-m)/',num2str(g_length),'   ;   ',abscissesname,'=[m+step/2:step:M-step/2];'];
                fl_diary(chaine1);

                if compute_interval
                    min_name = ['param_min_',numero_nom];
                    max_name = ['param_max_',numero_nom];
                    eval(['global ',min_name]);
                    eval(['global ',max_name]);
                    evalin('base',['global ',min_name]);
                    evalin('base',['global ',max_name]);
                    eval([min_name,'= minerr;']);
                    eval([max_name,'= maxerr;']);
                    fl_addlist(0,min_name);
                    fl_addlist(0,max_name);                    
                    chaine2=['[',estimname,',',min_name,',',max_name,']',' = parametric_g(',input_sig,',',abscissesname,',',num2str(pcent),',',num2str(ampli),');'];
                else
                    chaine2=['[',estimname,']',' = parametric_g(',input_sig,',',abscissesname,',',num2str(pcent),',',num2str(ampli),');'];
                end
                % Write computation in the diary
                fl_diary(chaine2);
                if draw_func
                    figure;hold on
                    plot(abscisses,estimateur);
                    plot(abscisses,minerr,'--');
                    plot(abscisses,maxerr,'--');                
                    legend('Estimated value',[pcent_str,'% confidence interval']);
                end
            end
        end
    case('help');
        empiric_computation=get(handles.Empirical,'Value');
        if empiric_computation
            fl_doc empiric_g;
        else
            fl_doc parametric_g;
        end
    case('close');
        close(estimg_fig);
end