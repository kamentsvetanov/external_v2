function [varargout]=fl_ml2frontier_compute(cmd,context);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,ml2Panel] = gcbo;

if ((isempty(ml2Panel)) | (~strcmp(get(ml2Panel,'Tag'),'gui_fl_ml2frontier_control_panel')))
  ml2Panel = findobj ('Tag','gui_fl_ml2frontier_control_panel');
end;

ud = get(ml2Panel,'UserData');
%returnString = '';


switch(cmd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  INPUT SECTION  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%
  case 'refresh_input'
    %%%%%%%%%%%%%%%%%%%%
  

    [name flag_error] = fl_get_details;

    if flag_error
      fl_warning('input signal must be a vector or matrix !');
      return;
    end;

    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval ([' global  ' varname]);
   end;

    var = eval (name);
    longueur=length(var);
    long=num2str(floor(longueur/2));

    set(findobj(ml2Panel,'Tag','compute'),'Enable','on');
    set(findobj(ml2Panel,'Tag','analysed_point'),'String',long);
    newUd =struct('Function',var,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_estim',ud.Choice_estim,'Choice_example',ud.Choice_example);
%,'Choice_waitbar',ud.Choice_waitbar);
    
    set(ml2Panel,'UserData',newUd);
    edit_input = findobj(ml2Panel,'Tag','EditText_input');
    set(edit_input,'String',name);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   2ml-parameters  SECTION   %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %%%%%%%%%%%%%%%%%%%%%%
  case 'precision_exp'
    %%%%%%%%%%%%%%%%%%%%%%
    p=findobj(ml2Panel,'Tag','precision_exp');
    prec=get(p,'Value')*5+5;
    newUd  =struct('Function',ud.Function,'Precision_frontier',prec,'Frontier',ud.Frontier,'Choice_estim',ud.Choice_estim,'Choice_example',ud.Choice_example);
%,'Choice_waitbar',ud.Choice_waitbar););
    set(ml2Panel,'UserData',newUd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%   Graph  SECTION   %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%%%%%%%%%%%%%%%%%%%%%%%
  case 'choice_example'
    %%%%%%%%%%%%%%%%%%%%%%%%

ex_est=findobj(ml2Panel,'Tag','choice_examp');
 example_est=get(ex_est,'Value')-1;
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_estim',ud.Choice_estim,'Choice_example',example_est);

%,'Choice_waitbar',ud.Choice_waitbar);
    set(ml2Panel,'UserData',newUd);

    %%%%%%%%%%%%%%%%%%%%%%%%
  case 'choice_estimation'
    %%%%%%%%%%%%%%%%%%%%%%%%

sev_est=findobj(ml2Panel,'Tag','choice_est');
 several_est=get(sev_est,'Value')-1;
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_estim',several_est,'Choice_example',ud.Choice_example);

%,'Choice_waitbar',ud.Choice_waitbar);
    set(ml2Panel,'UserData',newUd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  Exponents  SECTION   %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%
  case 'compute_exponents'
    %%%%%%%%%%%%%%%%%%%%%%%%


    comp=2;

    if(comp==1)
	set(findobj(ml2Panel,'Tag','StaticText_pointwise1'),'Enable','off');
	set(findobj(ml2Panel,'Tag','EditText_pointwise1'),'Enable','off');
	set(findobj(ml2Panel,'Tag','StaticText_pointwise2'),'Enable','off');
	set(findobj(ml2Panel,'Tag','EditText_pointwise2'),'Enable','off');
	set(findobj(ml2Panel,'Tag','StaticText_local'),'Enable','off');
	set(findobj(ml2Panel,'Tag','EditText_local'),'Enable','off');
	end;

    if (comp==2)
	set(findobj(ml2Panel,'Tag','StaticText_pointwise1'),'Enable','on');
	set(findobj(ml2Panel,'Tag','EditText_pointwise1'),'Enable','on');
	set(findobj(ml2Panel,'Tag','StaticText_pointwise2'),'Enable','on');
	set(findobj(ml2Panel,'Tag','EditText_pointwise2'),'Enable','on');
	set(findobj(ml2Panel,'Tag','StaticText_local'),'Enable','on');
	set(findobj(ml2Panel,'Tag','EditText_local'),'Enable','on');
	end;

  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  Waitbar   SECTION   %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    %%%%%%%%%%%%%%%%%%%%%%%%
%  case 'waitbar_screen'
%    %%%%%%%%%%%%%%%%%%%%%%%%
%    
%    ud = get(ml2Panel,'UserData');
%    bar_screen=get(findobj(ml2Panel,'Tag','wait_screen'),'Value');
%    
%    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_estim',ud.Choice_estim,'Choice_example',ud.Choice_example);

%,'Choice_waitbar',bar_screen);
%    set(ml2Panel,'UserData',newUd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  General  SECTION   %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%
  case 'compute'
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    ud = get(ml2Panel,'UserData');
    if (isempty(ud))
      fl_warning('Error : restart the segmentation panel');
      close (ml2Panel);
      return;
    end;

    alpha_p1=0;
    alpha_p2=0;
    alpha_l=0;
    func=ud.Function;
    x=(( (1:max(size(func)))-floor(max(size(func))/2)) /max(size(func)))';   
    point=findobj(ml2Panel,'Tag','analysed_point');
    p=str2num(get(point,'String'));
    if max(size(func))<p
    fl_warning('Point to analyze too large');
    return;
    end;	    
    prec=ud.Precision_frontier;
    vec=-1.25+2./prec;

    graph_exa=0;
    trace_frontiere=ud.Choice_example;
    graph_est=ud.Choice_estim;
    %waitbar_on=2-ud.Choice_waitbar;
    a=max([p-500 1]);
    b=min([p+500 max(size(func))]);
    mouse = fl_waiton;
    [vec_sprime,front,alpha_p1,alpha_p2,alpha_l]=ml2frontier(func(a:b),p-a+1,x(a:b),prec,20,graph_exa,1,0,trace_frontiere,1,1);
    
     

%    comp=get(findobj(ml2Panel,'Tag','compute_exp'),'Value');

     comp=2;

    if (comp==2)
%	pointwise1=findobj(ml2Panel,'Tag','EditText_pointwise1');
	pointwise2=findobj(ml2Panel,'Tag','EditText_pointwise2');
	local=findobj(ml2Panel,'Tag','EditText_local');
%	set(pointwise1,'String',num2str(alpha_p1));
	set(pointwise2,'String',num2str(alpha_p2));
	set(local,'String',num2str(alpha_l));
	end;

     % ne pas oublier de creer le userdata.

    sev_est=findobj(ml2Panel,'Tag','choice_est');
    several_est=get(sev_est,'Value')-1;
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',front,'Choice_estim',several_est,'Choice_example',ud.Choice_example);

%,'Choice_waitbar',ud.Choice_waitbar);

    set(ml2Panel,'UserData',newUd);


    outputName1=['x_frt_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];
    outputName2=['y_frt_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];
    outputName3=['pwExp_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];
    outputName4=['locExp_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];
    
    [varname1 varname2 varname3 varname4] = fl_find_mnames(context,outputName1,outputName2,outputName3,outputName4);

    eval(['global ' varname1]);
    eval(['global ' varname2]);
    eval(['global ' varname3]);
    eval(['global ' varname4]);
    
    varargout{1} = [varname1 ' ' varname2 ' ' varname3 ' ' varname4] ;

%   eval([varname1 '= struct(''type'',''graph'', ''data1'',front, ''data2'',vec_sprime,''title'',[type ''Frontier''],''xlabel'',''vec_sprime'',''ylabel'',''vec_sprime''); ']);

    eval([varname1 '= front; ']);
    eval([varname2 '= vec_sprime;']);
    eval([varname3 '= alpha_p2;']);
    eval([varname4 '= alpha_l;']);
 
    
 
        %%%% Modif Pierrick Legrand February 2005
        InputName=get(findobj('Tag','EditText_input'),'String');
        if isempty(InputName)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(p);
        else
            eval(['global ' InputName]);
        end;
               
        chaine=['[',varname1,',',varname2,',',varname3,',',varname4,']=ml2frontier(['...
        InputName,'],',num2str(p-a+1),',[(1:max(size(',InputName,...
        ')))-floor(max(size(',InputName,'))/2) /max(size(',InputName,'))]'',',...
        num2str(prec),',20,',num2str(graph_exa),',1,0,',num2str(trace_frontiere),',1,1);'];
        fl_diary(chaine);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              
    fl_addlist(0,varname1) ;
    fl_addlist(0,varname2) ;
    fl_addlist(0,varname3) ;
    fl_addlist(0,varname4) ;

    fl_waitoff(mouse);
 %   Frt=[varname ' ' Frt];
  


    %%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'help'
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
if (isempty(ud))
      fl_warning('Error : restart the segmentation panel');
      close (ml2Panel);
      return;
    end;


    %%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'close'
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    fl_clearerror;
    close (ml2Panel);
  
  
end % 
