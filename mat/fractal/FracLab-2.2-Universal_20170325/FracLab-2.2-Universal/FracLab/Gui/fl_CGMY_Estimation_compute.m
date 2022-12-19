function [varargout] = fl_CGMY_Estimation_compute(varargin)

fl_clearerror;  %%% Clear the error Zone !

switch(varargin{1})
    case 'Refrech_Btn'
        culloch_fig = findobj ('Tag','Fig_gui_fl_CGMY_Estimation');
        fl_clearerror;
        [input_sig flag_error]=fl_get_input('vector');
        if flag_error
        fl_warning('input signal must be a vector !');
        else 
        %%%%%%%%%%%%%%% input frame %%%%%%%%%%%
        set(findobj(culloch_fig,'Tag','EditText_sig_nname'), ... 
        'String',input_sig);
        end
  
    case 'compute'
      
        CGMY_fig = findobj ('Tag','Fig_gui_fl_CGMY_Estimation');
        input_sig=get(findobj(CGMY_fig,'Tag','EditText_sig_nname'),'String');
        if isempty(input_sig)
          fl_warning('Input signal must be initiated: Refresh!');
          return;
        end

        eval(['global ' input_sig]);
        prefix='Estim_Param';
        varname1 = fl_find_mnames(varargin{2},prefix);
        varargout{1}=varname1;
        eval(['global ' varname1]);

          %%%%% Perform the computation %%%%%
        mon_pointeur_courant=fl_waiton;
        chaine = ['[' varname1 ']=CGMY_Calcul_Param(',input_sig,');'];
        eval(chaine);
        
        fl_waitoff(mon_pointeur_courant);
        fl_diary(chaine);
        fl_addlist(0,varname1) ;

        eval(['param=' varname1 ''';']);

        C=findobj('Tag','EditText_C_');
        set(C,'String',num2str(param(1)));

        G=findobj('Tag','EditText_G_');
        set(G,'String',num2str(param(2)));

        M=findobj('Tag','EditText_M_');
        set(M,'String',num2str(param(3)));

        Y=findobj('Tag','EditText_Y_');
        set(Y,'String',num2str(param(4)));
     
    case 'close'
        close(findobj('Tag', 'Fig_gui_fl_CGMY_Estimation'));
    case 'help'
        fl_doc CGMY_Calcul_Param 
        
end