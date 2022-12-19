function varargout=fl_alphagifs_adv_compute(varargin)
% Callback functions for the GIFS GUI.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%warning off;
Figadvalphagifs = gcf;
if ((isempty(Figadvalphagifs)) | (~strcmp(get(Figadvalphagifs,'Tag'),'Fig_gui_fl_alphagifs_adv')))
  Figadvalphagifs = findobj ('Tag','Fig_gui_fl_alphagifs_adv');
end

switch(varargin{1})
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%  Main ALPHAGIFS Adv Param Window %%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  case 'launch'
    [SigIn_name error_in] = fl_get_input('vector') ;
    eval(['global ' SigIn_name]) ;
    if error_in
      fl_warning('input signal must be a vector !') ;
      fl_waitoff(current_cursor);
      return ;
    end
    SigIn = eval(SigIn_name) ;
    fl_callwindow('Fig_gui_fl_alphagifs_adv','gui_fl_alphagifs_adv') ;
    Figadvalphagifs = findobj ('Tag','Fig_gui_fl_alphagifs_adv');
    set(findobj(Figadvalphagifs,'Tag','EditText_sig_nname'),'String',SigIn_name);
  case 'alphagifs_adv_ppm_limit'
    string = get(gcbo,'String');
    val = get(gcbo,'Value');
    limit = string{val} ;
  case 'alphagifs_compute' 
    %% permet d'afficher la montre et de se souvenir
    %% de la tete du pointeur souris actuel
    mon_pointeur_courant=fl_waiton;
    
    ppm_limit_h = findobj('Tag','PopupMenu_alphagifs_limit');
    string = get(ppm_limit_h,'String');
    val = get(ppm_limit_h,'Value') ;
    limit = string{val} ;
    if strcmp(limit,'regression')
      limit = 'slope' ;
    end
    
    fl_clearerror;  %%% Clear the error Zone !
    
    SigIn_name = get(findobj(Figadvalphagifs,'Tag','EditText_sig_nname'),'String') ;
    eval(['global ' SigIn_name]) ;
    SigIn = eval(SigIn_name) ;
   
    %%%%% Get a name for the output var %%%%%
    %%% Je trouve un nom pour la variable de sortie
    %%% en concatenant "alphagifs_" au nom de la variable
    %%% d'entree. De plus, avec "fl_findname",
    %%% je rajoute dans la joie un petit numero de maniere
    %%% a ne pas produire un nom deja present dans le WorkSpace
    prefix=['alphagifs_' SigIn_name];
    varname=fl_findname(prefix,varargin{2});
    %%% Je retourne le nom de la variable de sortie
    %%% pour pouvoir la "globaliser" dans le WorkSpace,
    %%% et je la globalise de suite dans cette fonction
    %%% (avant toute affectation)
    varargout{1}=varname;
    eval(['global ' varname]);
    
    %%%%% Perform the computation %%%%%
    
    eval(['N=length(' SigIn_name ');']);
    scale = floor(log2(N));
    test_size = 2^scale;
    if(N > (test_size + test_size/2))
    %  fl_message('zeros have been added to the end of the signal!');
    elseif(N > (test_size+1))
    %  fl_message('only the 2^n first samples have been processed!');
    end
    
    eval(['[H C]= alphagifs(' SigIn_name ',limit);']);
    
    
    
    %% eval([varname '={''alphagifs'';H;C};']);
    eval([varname '=H;']) ;
    
    chaine=[varname,'=alphagifs(',SigIn_name,',''',limit,''');'];
    fl_diary(chaine);
    
    
    
    varargout{1} = varname ;
    
    %%%%% Add to ouput list %%%%%
    %%% J'ajoute le nom de la variable de sortie dans la liste
    %%% des variables.
    fl_addlist(0,varname);
    %warning backtrace;
    %% retablit l'ancien pointeur	 
    fl_waitoff(mon_pointeur_courant);
end



