function [varargout]=fl_d2ml2frontier_compute(cmd,context);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,ml2Panel] = gcbo;

if ((isempty(ml2Panel)) | (~strcmp(get(ml2Panel,'Tag'),'gui_fl_d2ml2spectrum_control_panel')))
  ml2Panel = findobj ('Tag','gui_fl_d2ml2spectrum_control_panel');
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
      fl_warning('input signal must be a matrix !');
      return;
    end

    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval ([' global  ' varname]);
   end
    var = eval (name);

    [longueur1,longueur2]=size(var);
    long1=num2str(floor(longueur1/2)-1);
    long2=num2str(floor(longueur2/2)+1);



    set(findobj(ml2Panel,'Tag','compute'),'Enable','on');
    set(findobj(ml2Panel,'Tag','starting_point_x'),'String',long1);
    set(findobj(ml2Panel,'Tag','ending_point_x'),'String',long2);
    set(findobj(ml2Panel,'Tag','starting_point_y'),'String',long1);
    set(findobj(ml2Panel,'Tag','ending_point_y'),'String',long2);

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
    [l1,l2]=size(func);
    l=max(l1,l2);
    x=(1:l)/l;
    p1=findobj(ml2Panel,'Tag','starting_point_x');
    p2=findobj(ml2Panel,'Tag','ending_point_x');
    p3=findobj(ml2Panel,'Tag','starting_point_y');
    p4=findobj(ml2Panel,'Tag','ending_point_y');
 
    point1=str2num(get(p1,'String'));
    point2=str2num(get(p2,'String'));
    point3=str2num(get(p3,'String'));
    point4=str2num(get(p4,'String'));
    if point1>point2
    fl_warning('Reorganize the points');
    return;
    end;	    
    if point3>point4 
    fl_warning('Reorganize the points');
    return;
    end;	    
 
    if l1<point2
    fl_warning('Point to analyze too large');
    return;
    end;	    
     if l2<point4
    fl_warning('Point to analyze too large');
    return;
    end;	    
    prec=ud.Precision_frontier;
    graph_exa=ud.Choice_example;
    plotfrontiers_on=2-ud.Choice_waitbar;
    graph_pointwise=2-ud.Plot_Pointwise_exp;
    graph_local=2-ud.Plot_Local_exp;

 
clear vec_sprime;
clear pot;
    [vec_sprime,res]=d2ml2spectrum(func,x,point1,point2,point3,point4,prec,1,graph_pointwise,graph_local,15);


    front=res(:,:,1:prec);
%   ap1=res(:,:,prec+1);
    ap2=res(:,:,prec+2);
    al=res(:,:,prec+3);

pot1=length(front(:,1,1));
pot2=length(front(1,:,1));
length(vec_sprime)

if (plotfrontiers_on)
figure;
plot([-0.2 1.1], [0 0], 'k');
hold on;
axis([-0.2 1.1 -1.1 1]);
plot([0  0] , [-1.1 1], 'k');
for i=1:pot1;
for j=1:pot2;

for k=1:length(vec_sprime)
absc(k)=front(i,j,k);
end;
plot(absc,vec_sprime,'b');
end;
end;
hold off;
title('2-ml frontiers');

end;
clear absc;
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
    
    
    
    
%        [vec_sprime,res]=d2ml2spectrum...
%         (func,x,point1,point2,point3,point4,prec,1,...
%         graph_pointwise,graph_local,15);

        %%%% Modif Pierrick Legrand February 2005
       InputName=get(findobj('Tag','EditText_input'),'String');
       if isempty(InputName)
           fl_warning('Input signal must be initiated: Refresh!');
           fl_waitoff(p);
       else
           eval(['global ' InputName]);
       end;
              
       
       chaine=['[',varname1,',',varname2,']=d2ml2spectrum('...       
       InputName,',[',num2str(x),'],',...
       num2str(point1),',',num2str(point2),',',num2str(point3),',',num2str(point4),',',...   
       num2str(prec),',',num2str(graph_exa),',',num2str(graph_pointwise),',',...
       num2str(graph_local),',15);'];
       fl_diary(chaine);
 %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

 
 
    

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
