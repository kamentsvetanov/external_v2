function [varargout]=fl_ml2frontier_compute(cmd,context);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,ml2Panel] = gcbo;

if ((isempty(ml2Panel)) | (~strcmp(get(ml2Panel,'Tag'),'gui_fl_ml2spectrum_control_panel')))
  ml2Panel = findobj ('Tag','gui_fl_ml2spectrum_control_panel');
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
    end

    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval ([' global  ' varname]);
   end
    var = eval (name);

    longueur=length(var);
    long1=num2str(floor(longueur/2)-10);
    long2=num2str(floor(longueur/2)+10);



    set(findobj(ml2Panel,'Tag','compute'),'Enable','on');
    set(findobj(ml2Panel,'Tag','starting_point'),'String',long1);
    set(findobj(ml2Panel,'Tag','ending_point'),'String',long2);

    newUd =struct('Function',var,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_example',ud.Choice_example,'Choice_waitbar',ud.Choice_waitbar,'Plot_Pointwise_exp',ud.Plot_Pointwise_exp,'Plot_Local_exp',ud.Plot_Local_exp);
    
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
    newUd =struct('Function',ud.Function,'Precision_frontier',prec,'Frontier',ud.Frontier,'Choice_example',ud.Choice_example,'Choice_waitbar',ud.Choice_waitbar,'Plot_Pointwise_exp',ud.Plot_Pointwise_exp,'Plot_Local_exp',ud.Plot_Local_exp);
    set(ml2Panel,'UserData',newUd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%   Graph  SECTION   %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%%%%%%%%%%%%%%%%%%%%%%%
  case 'choice_example'
    %%%%%%%%%%%%%%%%%%%%%%%%

ex_est=findobj(ml2Panel,'Tag','choice_examp');
 example_est=get(ex_est,'Value')-1;
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_example',example_est,'Choice_waitbar',ud.Choice_waitbar,'Plot_Pointwise_exp',ud.Plot_Pointwise_exp,'Plot_Local_exp',ud.Plot_Local_exp);
    set(ml2Panel,'UserData',newUd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  Exponents  SECTION   %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     %%%%%%%%%%%%%%%%%%%%%%%%
  case 'plot_pointwise'
    %%%%%%%%%%%%%%%%%%%%%%%%

pointw=findobj(ml2Panel,'Tag','pointwise_p');
 pointw_p=get(pointw,'Value');
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_example',ud.Choice_example,'Choice_waitbar',ud.Choice_waitbar,'Plot_Pointwise_exp',pointw_p,'Plot_Local_exp',ud.Plot_Local_exp);
    set(ml2Panel,'UserData',newUd);
 
     %%%%%%%%%%%%%%%%%%%%%%%%
  case 'plot_local'
    %%%%%%%%%%%%%%%%%%%%%%%%

pointl=findobj(ml2Panel,'Tag','local_p');
 pointl_p=get(pointl,'Value');
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_example',ud.Choice_example,'Choice_waitbar',ud.Choice_waitbar,'Plot_Pointwise_exp',ud.Plot_Pointwise_exp,'Plot_Local_exp',pointl_p);
    set(ml2Panel,'UserData',newUd);
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  Waitbar   SECTION   %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Attention: Waitbar est devenu "plot the frontiers"
%%
%%
    %%%%%%%%%%%%%%%%%%%%%%%%
  case 'waitbar_screen'
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    ud = get(ml2Panel,'UserData');
    bar_screen=get(findobj(ml2Panel,'Tag','wait_screen'),'Value');
    
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',ud.Frontier,'Choice_example',ud.Choice_example,'Choice_waitbar',bar_screen,'Plot_Pointwise_exp',ud.Plot_Pointwise_exp,'Plot_Local_exp',ud.Plot_Local_exp);
    set(ml2Panel,'UserData',newUd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  General  SECTION   %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%
  case 'compute'
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    ud = get(ml2Panel,'UserData');
    mouse = fl_waiton;
    if (isempty(ud))
      fl_warning('Error : restart the segmentation panel');
      close (ml2Panel);
      return;
    end;

    func=ud.Function;
    x=(((1:max(size(func)))-floor(max(size(func))/2))/max(size(func)))';   
    p1=findobj(ml2Panel,'Tag','starting_point');
    p2=findobj(ml2Panel,'Tag','ending_point');

    point1=str2num(get(p1,'String'));
    point2=str2num(get(p2,'String'));
    prec=ud.Precision_frontier;
    graph_exa=ud.Choice_example;
    plotfrontiers_on=2-ud.Choice_waitbar;
    graph_pointwise=2-ud.Plot_Pointwise_exp;
    graph_local=2-ud.Plot_Local_exp;

    a=max([point1-450 1]);
    b=min([point2+450 max(size(func))]);
    newpoint1=point1-a+1;
    newpoint2=point2-a+1;

 
clear vec_sprime;
clear pot;

    [vec_sprime,res]=ml2spectrum(func(a:b),x(a:b),newpoint1,newpoint2,prec,graph_exa,1,graph_pointwise,graph_local);


    front=res(:,1:prec);
%   ap1=res(:,prec+1);
    ap2=res(:,prec+2);
    al=res(:,prec+3);
    
pot=length(front(:,1));

if (plotfrontiers_on)
figure;
hold on;
axis([-0.2 1.1 -1.1 1]);
plot([-0.2 1.1], [0 0], 'k');
plot([0  0] , [-1.1 1], 'k');
for i=1:pot;
plot(front(i,:),vec_sprime,'b');
end;
hold off;
title('2-ml frontiers');

end;

    comp=get(findobj(ml2Panel,'Tag','compute_exp'),'Value');


     % ne pas oublier de creer le userdata.
    newUd =struct('Function',ud.Function,'Precision_frontier',ud.Precision_frontier,'Frontier',res,'Choice_example',ud.Choice_example,'Choice_waitbar',ud.Choice_waitbar,'Plot_Pointwise_exp',ud.Plot_Pointwise_exp,'Plot_Local_exp',ud.Plot_Local_exp);
    set(ml2Panel,'UserData',newUd);


    outputName1=['y_Frt_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];
    outputName2=['x_Frt_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];
    outputName3=['PwExp_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];
    outputName4=['LocExp_' get(findobj(ml2Panel,'Tag','EditText_input'),'String')];

    [varname1 varname2 varname3 varname4] = fl_find_mnames(context,outputName1,outputName2,outputName3,outputName4);

    eval(['global ' varname1]);
    eval(['global ' varname2]);
    eval(['global ' varname3]);
    eval(['global ' varname4]);
    
    varargout{1} = [varname1 ' ' varname2 ' ' varname3 ' ' varname4] ;
 
    eval([varname1 '= vec_sprime;']);
    eval([varname2 '= front;']);
    eval([varname3 '= ap2;']);
    eval([varname4 '= al;']);
    
    
    
    
    
        %%%% Modif Pierrick Legrand February 2005
        InputName=get(findobj('Tag','EditText_input'),'String');
        if isempty(InputName)
            fl_warning('Input signal must be initiated: Refresh!');
            fl_waitoff(p);
        else
            eval(['global ' InputName]);
        end;
               
        
        chaine=['[',varname1,',',varname2,']=ml2spectrum('...
        InputName,',[(1:max(size(',InputName,...
        ')))-floor(max(size(',InputName,'))/2) /max(size(',InputName,'))]'',',...
        num2str(newpoint1),',',num2str(newpoint2),',',...   
        num2str(prec),',',num2str(graph_exa),',1,',num2str(graph_pointwise),',',...
        num2str(graph_local),');'];
        fl_diary(chaine);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    

    fl_addlist(0,varname1) ;
    fl_addlist(0,varname2) ;
    fl_addlist(0,varname3) ;
    fl_addlist(0,varname4) ;

    fl_waitoff(mouse);
 
    clear vec_sprime;

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
