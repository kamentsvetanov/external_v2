function varargout=fl_stable_function(varargin)
% Callback functions for the STABLE SYNTHESIS GUI.

% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch(varargin{1})

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%  Main STABLE_SYN Window %%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'mn_stable_synthesis'
	[sig_in error_in] = fl_get_input('vector') ;
	eval(['global ' sig_in]) ;
	SigIn = eval(sig_in) ;
	if error_in
		fl_warning('Invalid Input!') ; return ;
	end
	fl_callwindow('Fig_gui_fl_stable_syn','gui_fl_stable_syn') ;
	figh = findobj('Tag','Fig_gui_fl_stable_syn') ;
	set(figh,'UserData',SigIn) ;

case 'edittext_stable_alpha'
	string = get(gcbo,'String') ;
	val = str2num(string) ;
	if(isempty(val))
		val=1.5;
	else
		if(val<0.0)
			val=0.01;
		else
			if(val>2.0)
				val=2.0;
			end
		end
	end
	string=num2str(val);
	set(gcbo,'String',string);
	set(findobj('Tag','Slider_stable_alpha'),'Value',val);

case 'slider_stable_alpha'
	val = get(gcbo,'Value');
	string = num2str(round(val*100)/100) ;
	set(findobj('Tag','EditText_stable_alpha'),'String',string);


case 'edittext_stable_beta'
	string = get(gcbo,'String') ;
	val = str2num(string) ;
	if(isempty(val))
		val=0.0;
	else
		if(val<-1.0)
			val=-1.0;
		else
			if(val>1.0)
				val=1.0;
			end
		end
	end
	string=num2str(val);
	set(gcbo,'String',string);
	set(findobj('Tag','Slider_stable_beta'),'Value',val);

case 'slider_stable_beta'
	val = get(gcbo,'Value');
	string = num2str(round(val*100)/100) ;
	set(findobj('Tag','EditText_stable_beta'),'String',string);


case 'edittext_stable_mu'
	string = get(gcbo,'String') ;
	val = str2num(string) ;
	if(isempty(val))
		val=0.0;
	end
	string=num2str(val);
	set(gcbo,'String',string);
	set(findobj('Tag','EditText_stable_mu'),'Value',val);

case 'edittext_stable_gamma'
	string = get(gcbo,'String') ;
	val = str2num(string) ;
	if(isempty(val))
		val=1.0;
	else
		if(val<0.0)
			val=0.0;
		end
	end
	string=num2str(val);
	set(gcbo,'String',string);
	set(findobj('Tag','EditText_stable_gamma'),'Value',val);


case 'edittext_stable_ssize'
	string = get(gcbo,'String') ;
	val = str2num(string) ;
	if(isempty(val))
		val=5000;
		else
		if(val<0.0)
			val=1;
		end	
	end
	string=num2str(val);
	set(gcbo,'String',string);
	set(findobj('Tag','EditText_stable_ssize'),'Value',val);

case 'pushbutton_stable_syn_compute'
	fl_clearerror;  %%% Clear the error Zone !

         %%% Je recupere quelques parametres dans ma fenetre

	editalpha=findobj('Tag','EditText_stable_alpha');
	alpha=str2num(get(editalpha,'String'));

	editbeta=findobj('Tag','EditText_stable_beta');
	beta=str2num(get(editbeta,'String'));

	editmu=findobj('Tag','EditText_stable_mu');
	mu=str2num(get(editmu,'String'));

	editgamma=findobj('Tag','EditText_stable_gamma');
	gamma=str2num(get(editgamma,'String'));

	editsize=findobj('Tag','EditText_stable_ssize');
	size=str2num(get(editsize,'String'));

	  %%%%% Get a name for the output var %%%%%
          %%% Je trouve un nom pour la variable de sortie
          %%% en concatenant "dwt_" au nom de la variable
          %%% d'entree. De plus, avec "fl_findname",
          %%% je rajoute dans la joie un petit numero de maniere
          %%% a ne pas produire un nom deja present dans le WorkSpace
	prefix='stable_process';
	varname1=fl_findname(prefix,varargin{2});
	prefix='stable_increments';
	varname2=fl_findname(prefix,varargin{2});
          %%% Je retourne le nom de la variable de sortie
          %%% pour pouvoir la "globaliser" dans le WorkSpace,
          %%% et je la globalise de suite dans cette fonction
          %%% (avant toute affectation)
	varargout{1}=[varname1 ' ' varname2];
	eval(['global ' varname1 ' ' varname2]);

	  %%%%% Perform the computation %%%%%
	mon_pointeur_courant=fl_waiton;
	eval(['[',[varname1],' ',[varname2],']=sim_stable(alpha,beta,mu,gamma,size);']);
	fl_waitoff(mon_pointeur_courant);
	  %%%%% Add to ouput list %%%%%
	%%% J'ajoute le nom de la variable de sortie dans la liste
	%%% des variables.
    
    
    fl_diary(['[',[varname1],' ',[varname2],']=sim_stable(',...
    num2str(alpha),',',num2str(beta),',',num2str(mu),',',...
    num2str(gamma),',',num2str(size),');']);
    
    
	fl_addlist(0,varname1);
	fl_addlist(0,varname2);

case 'bushbutton_stable_syn_help'
  helpwin sim_stable;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%  Main STABLE_TEST Window %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'bushbutton_stable_test_help'
  helpwin stable_test;
  
case 'refresh_test'
  test_fig = findobj ('Tag','Fig_gui_fl_stable_test');
  fl_clearerror;
  [input_sig flag_error]=fl_get_input('vector');
  if flag_error
    fl_warning('input signal must be a vector !');
  else 
  
    %%%%%%%%%%%%%%% input frame %%%%%%%%%%%
    set(findobj(test_fig,'Tag','EditText_sig_nname'), ... 
	'String',input_sig);
  end
  
case 'mn_test_stab'
	fl_callwindow('Fig_gui_fl_stable_test','gui_fl_stable_test') ;
	fl_stable_function('refresh_test');

case 'edittext_stable_maxr'
	string = get(gcbo,'String') ;
	val = str2num(string) ;
	if(isempty(val))
		val=1;
	else
		if(val<1)
			val=1;
		end
	end
	string=num2str(val);
	set(gcbo,'String',string);
	set(findobj('Tag','Slider_stable_maxr'),'Value',val);

case 'slider_stable_maxr'
	val = get(gcbo,'Value');
	string = num2str(floor(val)) ;
	set(findobj('Tag','EditText_stable_maxr'),'String',string);

case 'pushbutton_stable_test_compute'
	fl_clearerror;  %%% Clear the error Zone !

	%%% Je recupere quelques parametres dans ma fenetre

	editmaxr=findobj('Tag','EditText_stable_maxr');
	maxr=str2num(get(editmaxr,'String'));

         %%% J'ai besoin d'un vecteur en entree,
        %%% j'utilise 'EditText_sig_nname' obtenu par refresh
	
	
	test_fig = findobj ('Tag','Fig_gui_fl_stable_test');
	input_sig=get(findobj(test_fig,'Tag','EditText_sig_nname'),'String');
	if isempty(input_sig)
	  fl_warning('Input signal must be initiated: Refresh!');
	  return;
	end

          %%% Cette ligne est necessaire pour pouvoir acceder
          %%% a la variable (d'entree) dont le nom est une chaine
          %%% de caracteres contenue dans la variable "input_sig".
	eval(['global ' input_sig]);
	eval(['sig=' input_sig ';']);
	  %%%%% Get a name for the output var %%%%%
          %%% Je trouve un nom pour la variable de sortie
          %%% en concatenant "dwt_" au nom de la variable
          %%% d'entree. De plus, avec "fl_findname",
          %%% je rajoute dans la joie un petit numero de maniere
          %%% a ne pas produire un nom deja present dans le WorkSpace
	prefix='Estim_Param_M';
	varname1=fl_findname(prefix,varargin{2});
	eval(['global ',varname1]) ;
	prefix='Estim_Sd_Dev_M';
	varname2=fl_findname(prefix,varargin{2});
	eval(['global ',varname2]) ;
          %%% Je retourne le nom de la variable de sortie
          %%% pour pouvoir la "globaliser" dans le WorkSpace,
          %%% et je la globalise de suite dans cette fonction
          %%% (avant toute affectation)
	
	
	
	%%%%% Perform the computation %%%%%
	mon_pointeur_courant=fl_waiton;
	[param_M,std_dev_M]=stable_test(maxr,sig);
	fl_waitoff(mon_pointeur_courant);
	eval([varname1 '=param_M;']);
	eval([varname2 '=std_dev_M;']);
	
	%%%%% Add to ouput list %%%%%
	%%% J'ajoute le nom de la variable de sortie dans la liste
	%%% des variables.
	fl_addlist(0,varname1);
	fl_addlist(0,varname2);
	
    fl_diary(['[',[varname1],' ',[varname2],']=stable_test(',...
    num2str(maxr),',',input_sig,');']);
    

	alpha=param_M(:,1);
	gamma=param_M(:,4);
	resol=(1:maxr)';
	logresol=log(resol);
	loggamma=log(gamma);
	vslope=polyfit(logresol,loggamma,1);
	slope=vslope(1);
	alpha_estim=1/(slope+1);
	
	% plot alpha as graph
	prefix='plot_alpha';
	varname_alpha=fl_findname(prefix,varargin{2});	
	eval(['global ',varname_alpha]) ;
	alpha_title='Plot of the shape parameter';
	alpha_xlabel='resolution';
	alpha_ylabel='characteristic exponent';
	eval ([varname_alpha ' = struct(''type'',''graph'',''data1'',resol,''data2'',alpha'',''title'',alpha_title,''xlabel'',alpha_xlabel,''ylabel'',alpha_ylabel);']);

	%%%% add varname to list %%%%
	fl_addlist(0,varname_alpha);
	
	% plot gamma as graph
	prefix='plot_gamma';
	varname_gamma=fl_findname(prefix,varargin{2});	
	eval(['global ',varname_gamma]) ;
	gamma_title='log-log plot of the scale parameter';
	gamma_xlabel='resolution';
	gamma_ylabel='scale parameter';
	eval ([varname_gamma ' = struct(''type'',''graph'',''data1'',logresol,''data2'',loggamma'',''title'',gamma_title,''xlabel'',gamma_xlabel,''ylabel'',gamma_ylabel);']);
	
	%%%% add varname to list %%%%
	fl_addlist(0,varname_gamma);
	
	varargout{1}=[varname1 ' ' varname2 ' ' varname_alpha ' ' varname_gamma];
%	eval(['global ' varname1 ' ' varname2 ' ' varname_alpha ' ' varname_gamma]);
		
	objslope=findobj('Tag','StaticText_stable_test_output_alpha');
	set(objslope,'String',num2str(alpha_estim));
	
	
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  Main McCulloch Method For Parameter Estimation Window %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'bushbutton_stable_culloch_help'
  helpwin McCulloch;
  
case 'refresh_culloch'
  culloch_fig = findobj ('Tag','Fig_gui_fl_stable_culloch');
  fl_clearerror;
  [input_sig flag_error]=fl_get_input('vector');
  if flag_error
    fl_warning('input signal must be a vector !');
  else 
  
    %%%%%%%%%%%%%%% input frame %%%%%%%%%%%
    set(findobj(culloch_fig,'Tag','EditText_sig_nname'), ... 
	'String',input_sig);
  end
  
case 'mn_culloch'
	fl_callwindow('Fig_gui_fl_stable_culloch','gui_fl_stable_culloch') ;
	fl_stable_function('refresh_culloch');
	
case 'pushbutton_stable_culloch_compute'
	fl_clearerror;  %%% Clear the error Zone !

	%%% J'ai besoin d'un vecteur en entree,
        %%% j'utilise le champ 'EditText_sig_nname' obtenu par refresh
	
	
	culloch_fig = findobj ('Tag','Fig_gui_fl_stable_culloch');
	input_sig=get(findobj(culloch_fig,'Tag','EditText_sig_nname'),'String');
	if isempty(input_sig)
	  fl_warning('Input signal must be initiated: Refresh!');
	  return;
	end

          %%% Cette ligne est necessaire pour pouvoir acceder
          %%% a la variable (d'entree) dont le nom est une chaine
          %%% de caracteres contenue dans la variable "input_sig".
	eval(['global ' input_sig]);

	  %%%%% Get a name for the output var %%%%%
          %%% Je trouve un nom pour la variable de sortie
          %%% en concatenant "dwt_" au nom de la variable
          %%% d'entree. De plus, avec "fl_findname",
          %%% je rajoute dans la joie un petit numero de maniere
          %%% a ne pas produire un nom deja present dans le WorkSpace
	prefix='Estim_Param';
	varname1=fl_findname(prefix,varargin{2});
	prefix='Estim_Sd_Dev';
	varname2=fl_findname(prefix,varargin{2});
          %%% Je retourne le nom de la variable de sortie
          %%% pour pouvoir la "globaliser" dans le WorkSpace,
          %%% et je la globalise de suite dans cette fonction
          %%% (avant toute affectation)
	varargout{1}=[varname1 ' ' varname2];
	eval(['global ' varname1 ' ' varname2]);
	
	  %%%%% Perform the computation %%%%%
	mon_pointeur_courant=fl_waiton;  
	eval(['[',[varname1],' ',[varname2],']=McCulloch(',input_sig,');']);
	fl_waitoff(mon_pointeur_courant);
    
   fl_diary(['[',[varname1],' ',[varname2],']=McCulloch(',input_sig,');']);
    
	  %%%%% Add to ouput list %%%%%
	%%% J'ajoute le nom de la variable de sortie dans la liste
	%%% des variables.
	%fl_addlist(0,varname1);
	%fl_addlist(0,varname2);
	
	eval(['param=' varname1 ''';']);
	eval(['sd_param=' varname2 ''';']);
	
	alpha=findobj('Tag','StaticText_culloch_output_alpha');
	set(alpha,'String',num2str(param(1)));
	sd_alpha=findobj('Tag','StaticText_culloch_output_sd_alpha');
	set(sd_alpha,'String',num2str(sd_param(1)));
	
	beta=findobj('Tag','StaticText_culloch_output_beta');
	set(beta,'String',num2str(param(2)));
	sd_beta=findobj('Tag','StaticText_culloch_output_sd_beta');
	set(sd_beta,'String',num2str(sd_param(2)));
	
	
	mu=findobj('Tag','StaticText_culloch_output_mu');
	set(mu,'String',num2str(param(3)));
	sd_mu=findobj('Tag','StaticText_culloch_output_sd_mu');
	set(sd_mu,'String',num2str(sd_param(3)));
	
	gamma=findobj('Tag','StaticText_culloch_output_gamma');
	set(gamma,'String',num2str(param(4)));
	sd_gamma=findobj('Tag','StaticText_culloch_output_sd_gamma');
	set(sd_gamma,'String',num2str(sd_param(4)));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  Main Koutrouvelis Method For Parameter Estimation Window %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'bushbutton_stable_koutrouvelis_help'
  helpwin Koutrouvelis;
  
case 'refresh_koutrouvelis'
  koutrouvelis_fig = findobj ('Tag','Fig_gui_fl_stable_Koutrouvelis');
  fl_clearerror;
  [input_sig flag_error]=fl_get_input('vector');
  if flag_error
    fl_warning('input signal must be a vector !');
  else 
  
    %%%%%%%%%%%%%%% input frame %%%%%%%%%%%
    set(findobj(koutrouvelis_fig,'Tag','EditText_sig_nname'), ... 
	'String',input_sig);
  end
  
case 'mn_koutrouvelis'
	fl_callwindow('Fig_gui_fl_stable_Koutrouvelis','gui_fl_stable_Koutrouvelis') ;
	fl_stable_function('refresh_koutrouvelis');

case 'pushbutton_stable_koutrouvelis_compute'
	fl_clearerror;  %%% Clear the error Zone !

	%%% J'ai besoin d'un vecteur en entree,
        %%% j'utilise 'EditText_sig_nname' obtenu par refresh
	
	
	koutrouvelis_fig = findobj ('Tag','Fig_gui_fl_stable_Koutrouvelis');
	input_sig=get(findobj(koutrouvelis_fig,'Tag','EditText_sig_nname'),'String');
	if isempty(input_sig)
	  fl_warning('Input signal must be initiated: Refresh!');
	  return;
	end


          %%% Cette ligne est necessaire pour pouvoir acceder
          %%% a la variable (d'entree) dont le nom est une chaine
          %%% de caracteres contenue dans la variable "input_sig".
	eval(['global ' input_sig]);

	  %%%%% Get a name for the output var %%%%%
          %%% Je trouve un nom pour la variable de sortie
          %%% en concatenant "dwt_" au nom de la variable
          %%% d'entree. De plus, avec "fl_findname",
          %%% je rajoute dans la joie un petit numero de maniere
          %%% a ne pas produire un nom deja present dans le WorkSpace
	prefix='Estim_alpha';
	varname1=fl_findname(prefix,varargin{2});
	prefix='Estim_beta';
	varname2=fl_findname(prefix,varargin{2});
	prefix='Estim_mu';
	varname3=fl_findname(prefix,varargin{2});
	prefix='Estim_gamma';
	varname4=fl_findname(prefix,varargin{2});
          %%% Je retourne le nom de la variable de sortie
          %%% pour pouvoir la "globaliser" dans le WorkSpace,
          %%% et je la globalise de suite dans cette fonction
          %%% (avant toute affectation)
	varargout{1}=[varname1 ' ' varname2 ' ' varname3 ' ' varname4];
	eval(['global ' varname1 ' ' varname2 ' ' varname3 ' ' varname4]);
	
	  %%%%% Perform the computation %%%%%
	mon_pointeur_courant=fl_waiton;  
	eval(['[',[varname1],' ',[varname2],' ',[varname3],' ',[varname4],']=Koutrouvelis(',input_sig,');']);
	fl_waitoff(mon_pointeur_courant);
	
	eval(['param1=' varname1 ''';']);
	eval(['param2=' varname2 ''';']);
	eval(['param3=' varname3 ''';']);
	eval(['param4=' varname4 ''';']);
    
    fl_diary(['[',[varname1],' ',[varname2],' ',...
        [varname3],' ',[varname4],']=Koutrouvelis(',input_sig,');']);
	
	alpha=findobj('Tag','StaticText_koutrouvelis_output_alpha');
	set(alpha,'String',num2str(param1));
	
	beta=findobj('Tag','StaticText_koutrouvelis_output_beta');
	set(beta,'String',num2str(param2));
	
	
	mu=findobj('Tag','StaticText_koutrouvelis_output_mu');
	set(mu,'String',num2str(param3));
	
	gamma=findobj('Tag','StaticText_koutrouvelis_output_gamma');
	set(gamma,'String',num2str(param4));
	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end	

