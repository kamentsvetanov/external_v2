function [outputname]=fl_dse(fl_string,fl_whos)
% Callback functions for GUI - 1D dimension spectrum estimation (dse)
%
%   1D Lim sup dimension spectrum estimation fltool Figure.
%
%   1.  Input Data
%
%   The input data can be any highlighted  structure of the input list
%   ListBox of the main fltool  Figure: either a real vector or a matrix.  
%   It is selected when opening this  Figure from the corresponding UiMenu 
%   of  the main  fltool    Figure, or   by using the   refresh PushButton.  
%   When the type of the  highlighted structure does not match with the 
%   authorized types, an error  message is displayed in the message StaticText  
%   of the main  fltool Figure.
%   If a vector or a matrix is highlighted, it can be  considered as a
%   measure or as a function by selecting the  measure or the function
%   RadioButton.
%   The name of the input data and its  size are displayed in two
%   StaticText just below.

% Author Desire Sidibe, July 2004
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

fl_clearerror;

switch(fl_string)
    %mbasic
    case 'mbasic'
     %get input signal
      [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;
      if flag_error
         return
      end
      if ~isempty(find(sig_n<0.))
          fl_warning('Take normalized absolute values increments');
          sig_n=abs(diff(sig_n))./sum(abs(diff(sig_n)));
      end

      %setting parameters
      [n,capa,epsilon,B,dim,xlabel,ylabel]=fdlssettings;
      current_mouse_ptr=fl_waiton;
      % call of the C_LAB routine: mfdls1d 
      [alpha,fdls1d_alpha]=mfdls1d(sig_n,n,capa,epsilon,B,dim); 
      fl_waitoff(current_mouse_ptr); 
      % set title
      title=['Lim sup dimension spectrum'];
      % make outputname
      prefix=['mfdls1d_' sig_nname];
      outputname=fl_findname(prefix,fl_whos);
      % make varname global
      eval(['global ' outputname]);
      % make global cell and put it in varname
      eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fdls1d_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
      % add varname to list
      fl_addlist(0,outputname); 
      
      %fbasic
  case 'fbasic'
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;
    if flag_error
      return
    end
    %setting parameters
    [n,capa,epsilon,B,dim,xlabel,ylabel]=fdlssettings;
    current_mouse_ptr=fl_waiton;
    % call of the C_LAB routine: mfdls1d 
    %calcul des accroissements
    sig_n=accroiss(sig_n);
    %sig_n=accroiss2(sig_n);
    [alpha,fdls1d_alpha]=mfdls1d(sig_n,n,capa,epsilon,B,dim); 
    fl_waitoff(current_mouse_ptr); 
    % set title
    title=['Lim sup dimension spectrum'];
    % make outputname
    prefix=['fdls1d_' sig_nname];
    outputname=fl_findname(prefix,fl_whos);
    % make varname global
    eval(['global ' outputname]);
    % make global cell and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fdls1d_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    % add varname to list
    fl_addlist(0,outputname); 
    
  %advanced    
  case 'madvanced'
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;
    if flag_error
      return
    end
    advancedsettings(Nx_n,Ny_n,sig_n,sig_nname);
    set(findobj('Tag','RadioButton_measure'),'Enable','on');
    set(findobj('Tag','RadioButton_measure'),'Value',1); 
    set(findobj('Tag','RadioButton_function'),'Enable','on');
    set(findobj('Tag','RadioButton_function'),'Value',0); 
case 'fadvanced'
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;  
    if flag_error
      return
    end
    advancedsettings(Nx_n,Ny_n,sig_n,sig_nname);  
    set(findobj('Tag','RadioButton_measure'),'Enable','on');
    set(findobj('Tag','RadioButton_measure'),'Value',0); 
    set(findobj('Tag','RadioButton_function'),'Enable','on');  
    set(findobj('Tag','RadioButton_function'),'Value',1); 
case 'refresh'
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;  
    if flag_error
      return
    end
    if get(findobj('Tag','RadioButton_measure'),'Value')==1
      fl_dse('madvanced');
    else
      fl_dse('fadvanced');
    end
    %measure
case 'radiobutton_measure'
    if get(findobj('Tag','RadioButton_measure'),'Value')==0
      set(findobj('Tag','RadioButton_measure'),'Value',1);
    end
    set(findobj('Tag','RadioButton_function'),'Value',0);
    %function
case 'radiobutton_function'
    if get(findobj('Tag','RadioButton_function'),'Value')==0
      set(findobj('Tag','RadioButton_function'),'Value',1);
    end
    set(findobj('Tag','RadioButton_measure'),'Value',0);
    %precision
case 'edittext_precision'
    fl_clearerror;
      e=str2num(get(gcbo,'String'));
      if isempty(e)
         fl_warning('precision epsilon must be a real !');
         pause(.3);
         e=0.5; 
         set(findobj('Tag','EditText_precision'),'String','0.5');
         set(findobj('Tag','Slider_precision'),'Value',e);
     else
        e=gui_fl_dse_trunc(e,.0,1.);
        epsilon=e;
        set(gcbo,'String',num2str(e));
        set(findobj('Tag','Slider_precision'),'Value',e);
    end
case 'slider_precision'
    e=get(gcbo,'Value');
    set(gcbo,'String',e);
    e=gui_fl_dse_fix(e,10000);
    epsilon=e;
    set(findobj('Tag','EditText_precision'),'String',e);
    % lpsum capacity
case 'popupmenu_capacity'  
    if get(findobj('Tag','RadioButton_function'),'Value')==1 
      if get(findobj('Tag','PopupMenu_capacity'),'Value')==2 
	set(findobj('Tag','EditText_power'),'Enable','on');
	set(findobj('Tag','Slider_power'),'Enable','on'); 
      else
	set(findobj('Tag','EditText_power'),'Enable','off');
	set(findobj('Tag','Slider_power'),'Enable','off');
      end
end
    % power: p
case 'edittext_power'
    p=str2num(get(gcbo,'String')); 
    p=gui_fl_dse_fix(p,100);
    p=gui_fl_dse_trunc(p,1.,10.);  
    set(gcbo,'String',p);
    set(findobj('Tag','Slider_min'),'Value',p);
case 'slider_power'
    p=get(gcbo,'Value');
    p=gui_fl_dse_fix(p,100);
    p=gui_fl_dse_trunc(p,1.,10.);
    set(gcbo,'Value',p);
    set(findobj('Tag','EditText_power'),'String',num2str(p));
    %B et n
case 'edittext_B'
    error=0;
    eval(['B=' get(gcbo,'String') ';'],'error=1;');
    if error==1
      fl_warning('B vector or matrix invalid: Modify B');
      set(gcbo,'String','[ ]');
      return;
    end
case 'edittext_n'
    error=0;
    eval(['n=' get(gcbo,'String') ';'],'error=1;');
    if error==1
      fl_warning('n vector or matrix invalid: Modify n');
      set(gcbo,'String','[ ]');
      return;
    end
case 'popupmenu_resolutionmin'
    switch get(findobj('Tag','PopupMenu_resolutionmin'),'Value')
        case 1
            n_min = 4;
        case 2
            n_min = 5;
        case 3
            n_min = 6;
        case 4
            n_min = 7;
        case 5
            n_min = 8;
        case 6
            n_min = 9;
        case 7
            n_min = 10;
        case 8
            n_min = 11;
        case 9
            n_min = 12;
        case 10
            n_min = 13;
        case 11
            n_min = 14;
        case 12
            n_min = 15;
        case 13
            n_min = 16;
        case 14
            n_min = 17;
        case 15
            n_min = 18;
        case 16
            n_min = 19;
    end
  
case 'popupmenu_resolutionmax'
    switch get(findobj('Tag','PopupMenu_resolutionmax'),'Value')
        case 1
            n_max = 5;
        case 2
            n_max = 6;
        case 3
            n_max = 7;
        case 4
            n_max = 8;
        case 5
            n_max = 9;
        case 6
            n_max = 10;
        case 7
            n_max = 11;
        case 8
            n_max = 12;
        case 9
            n_max = 13;
        case 10
            n_max = 14;
        case 11
            n_max = 15;
        case 12
            n_max = 16;
        case 13
            n_max = 17;
        case 14
            n_max = 18;
        case 15
            n_max = 19;
        case 16
            n_max = 20;
    end

    %compute
case 'compute'
    % get the input signal
    if get(findobj('Tag','RadioButton_measure'),'Value')==1
      % get the input measure: mu_n
      [mu_nname,mu_n]=getinputmu_n; %ok 
      % advanced settings 
      [n,B,dim]=advsettings;
      prefix=['mfdls1d_' mu_nname];
    elseif get(findobj('Tag','RadioButton_function'),'Value')==1
      % get the input function: F_n
      [F_nname,F_n]=getinputF_n; %ok
      % advanced settings 
      [n,B,dim]=advsettings; 
      prefix=['fdls1d_' F_nname];
    end;
    %precision
        e=str2num(get(findobj('Tag','EditText_precision'),'String'));
        epsilon=e;
    %capacity
    switch get(findobj('Tag','PopupMenu_capacity'),'Value')  
      case 1
	capa='sum';
      case 2
	p=get(findobj('Tag','EditText_power'),'String');
    capa=strcat('l','p','sum');
      case 3
	capa='iso';
      case 4
	capa='adapiso';
    end
    current_mouse_ptr=fl_waiton;
    % call of the C-LAB routine or matlab function
    if get(findobj('Tag','RadioButton_measure'),'Value')==1
      % call of the C-LAB routine: mfdls1d
      [alpha,fdls1d_alpha]=mfdls1d(mu_n,n,capa,epsilon,B,dim);
    elseif get(findobj('Tag','RadioButton_function'),'Value')==1
      % call of the C-LAB routine: mfdls1d
      F_n=accroiss(F_n);
      %F_n=accroiss2(F_n);
      [alpha,fdls1d_alpha]=mfdls1d(F_n,n,capa,epsilon,B,dim);
    end
    fl_waitoff(current_mouse_ptr); 
    %set title
    title=['lim sup dimension spectrum'];
    % make outputname
    outputname=fl_findname(prefix,fl_whos);
    eval(['global ' outputname]); 
    %set xlabel and ylabel
    xlabel='Hoelder exponents: \alpha';
    ylabel='spectrum: f_{d}^{limsup}(\alpha)';
    % make global structure and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fdls1d_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    % add varname to list
    fl_addlist(0,outputname);    
end

%%%%%%%%%%%%%%%%%%%%%%
% trunc
function trunc_x=gui_fl_dse_trunc(x,x_min,x_max)
if(x<x_min)
  trunc_x=x_min;
else
  if(x>x_max)
    trunc_x=x_max;
  else
    trunc_x=x;
  end 
end

% fix
function fix_x=gui_fl_dse_fix(x,ten_power)
fix_x=round(x.*ten_power)/ten_power;

% getinputmu_n
function [mu_nname,mu_n]=getinputmu_n
mu_nname=get(findobj('Tag','StaticText_sig_nname'),'String'); %ok
eval(['global ' mu_nname]);
eval(['mu_n=' mu_nname ';']); 
if ~isempty(find(mu_n<0.))
  fl_warning('Take normalized absolute values increments');
  mu_n=abs(diff(mu_n))./sum(abs(diff(mu_n)));
end 

% getinputF_n
function [F_nname,F_n]=getinputF_n
F_nname=get(findobj('Tag','StaticText_sig_nname'),'String'); %ok
eval(['global ' F_nname]);
eval(['F_n=' F_nname ';']);
m=min(F_n);
M=max(F_n);
if m~=0. & M~=1.
  F_n=(F_n-m)/(M-m);
end

function [n,B,dim]=advsettings
eval(['B=' get(findobj('Tag','EditText_B'),'String') ';']);
%eval(['n=' get(findobj('Tag','EditText_n'),'String') ';']);
%n=[0 0];
switch get(findobj('Tag','PopupMenu_dimension'),'Value')
    case 1
        dim= 'box';
    case 2
        dim= 'voss';
    case 3
        dim= 'brnb';
    case 4
        dim = 'haus';
end
%[SigIn_name error_in] = fl_get_input ('vector'); 
SigIn_name=get(findobj('Tag','StaticText_sig_nname'),'String');
eval(['global ' SigIn_name]) ;
SigIn = eval(SigIn_name) ;
N = length(SigIn) ;
n_maxm=ceil(log2(N));
n_minm=ceil(log2(N))-1;
n_min=get(findobj('Tag','PopupMenu_resolutionmin'),'Value')+3;
n_max=get(findobj('Tag','PopupMenu_resolutionmax'),'Value')+4;

if (n_min > (n_max-1))
    n_min=n_max - 1;
end
if (n_max > n_maxm)
    n_max=n_maxm;
end

n = [n_min n_max];

      
function advancedsettings(Nx_n,Ny_n,sig_n,sig_nname)
eta_n=1./Nx_n;
fl_callwindow('Fig_gui_fl_dse','gui_fl_dse');
set(findobj('Tag','Fig_gui_fl_dse'),'UserData',eta_n);
set(findobj('Tag','StaticText_sig_nname'),'String',sig_nname);
str=['[',num2str(Ny_n),' x ',num2str(Nx_n),']'];
set(findobj('Tag','EditText_size'),'String',str); 
set(findobj('Tag','PopupMenu_ball'),'Style','popupmenu');
set(findobj('Tag','PopupMenu_capacity'),'Enable','on');


function [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input
fl_clearerror;
[sig_nname flag_error]=fl_get_input('vector');
% flag_error=0;
% sig_nname=get(findobj('Tag','StaticText_sig_nname'),'String')
% if flag_error
%   [cwtname flag_error]=fl_get_input('cwt'); 
%   if flag_error
%     fl_warning('Input must be a vector or a cwt !');
%     return
%   end
%   eval(['global ' cwtname]);
%   eval(['cwt_struct=' cwtname ';']);
%   cwtsettings(cwt_struct,cwtname);
%   sig_n=0;
%   sig_nname'';
%   Nx_n=0;
%   Ny_n=0;
%   flag_error=1;
%   return
% end
eval(['global ' sig_nname]);
eval(['sig_n=' sig_nname ';']);
[M N]=size(sig_n);
if M==1 | N==1
  Nx_n=max([M N]);
  Ny_n=min([M N]);
else
  Ny_n=M;
  Nx_n=N;
end

% fdlssettings
function [n,capa,epsilon,B,dim,xlabel,ylabel]=fdlssettings
n=[0 0];
capa='sum';
epsilon=0.5;
B=[1:2:21];
dim='box';
xlabel='Hoelder exponents: \alpha';
ylabel='spectrum: f_{d}^{limsup}(\alpha)';

% calcul des accroissements
function y=accroiss(x)
n=length(x);
for i=2:n,
    y(i)=x(i)-x(i-1);
end
y(1)=x(1);
%y=abs(y)/sum(abs(y));

%fonction accroiss2 prenant en compte les données manquantes
function y=accroiss2(x)
n=length(x);
for i=1:n-1,
    if (x(i)~=0 & x(i+1)~=0)
        y(i)=x(i+1)-x(i);
    else
        if (x(i)==0 |x(i+1)==0)
            y(i)=9999;
        end
    end
end
if (x(n)~=0 & x(n-1)~=0)
    y(n)=x(n)-x(n-1);
else
    y(n)=9999;
end
%y=y/sum(y);        