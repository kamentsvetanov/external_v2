function [outputname]=fl_tml(fl_string,fl_whos)
% Callback functions for GUI - two microlocal frontier estimation (tml)
%
%   Two Microlocal like frontier estimation.
%
%   1.  Input Data
%
%   The input data can be any highlighted  structure of the input list
%   ListBox of the main fltool  Figure: a real vector of size [M1,M2]. 
%   
%   - In the main frame:
%   The minimum of M1 and M2 has to be equal to 1 and let their maximum
%   be M. 
%   - In the fame 'Make the frontier convex':
%   This is the output 'frd_input_data' and in this case M1 is 21 and
%   M2 is I+1 (define below).
%
%   It is selected when opening this  Figure from the corresponding
%   UiMenu of  the main  fltool  Figure, or by using the refresh PushButton.
%   When the type of the  highlighted structure does not match with the
%   authorized types, an error  message is displayed in the message 
%   StaticText of the main  fltool Figure. The name of the input
%   data and its  size are displayed in two StaticText just below.
%
%   2.  UIcontrols
%
%   2.1.  Control parameters
%
%   o  window: this is the number of points (N) to be used in the computation.  
%      The minimum allowed value is 5 and the maximum is M, the length of
%      input data. After refreshing it is initialised to M and can be
%      changed by directly editing the EditText to any value between 5 and M. 
%
%   o  step: this is the value by which the window is shifted to the right
%      for the next calculation (doing the same calculation at the next point).
%      It can take any value between 0 and M where 0 means only one
%      computation. When its value is not 0 the computation stops when a
%      part of the window goes outside the input data. Therefore, in this
%      case, the number of points at which computation is done is the
%      maximum integer I such that step*I + N is less than or equal to M. 
%      After refreshing it is initialised to M (i.e. computation at only
%      one point) and can be changed by directly editing the EditText to 
%      any value between 0 and M.
%
%   o  estimate: PopupMenu.
%      This allows to choose the computation to be performed. 
%      - frontier: string
%        This is the default choice and the frontier(s) is calculated
%        at the given points under this choice. When this choice is
%        made, the frame 'Make the frontier convex' is enabled. 
%      - local: string
%        Under this choice only the local Holder exponents are calculated
%        and the frame 'Make the frontier convex' is disabled.
%     - pointwise: string
%        Under this choice only the pointwise Holder exponents are calculated
%        and the frame 'Make the frontier convex' is disabled.
%
%   o  s' cut off: This is the value below which the frontier is
%      convexified. It can take values between -0.8 to 1.0. 
%
%   2.2.  Computation
%
%   o  Compute :  PushButton.
%      Computes the frontier(s) or local or pointwise Holder exponent(s)
%      depending on the choice in the pop-up menu.
%      Runs  coarse Hoelder exponents  estimation with parameters set as
%      It calls the  built-in C-LAB routines dtmlf if the popup menu
%      is on frontier, dtmll if the popup menu is on local or dtmlp if
%      the popup menu shows pointwise.
%
%   o  Convexify :  PushButton.
%      Convexifies the frontier(s) below the chosen cut off for s' upto
%      the last value -1. Note that only the part of the frontier below
%      the cut off is shown in the output.  
%
%   o  Help : PushButton.
%      Calls this help.
%
%   o  Close : PushButton.
%      Closes the 2-microlocal like frontier estimation Figure and returns
%      to the main fltool Figure.
%
%   3.  Outputs
%
%   o  Case frontier:
%      In this case there are three outputs: 
%      - Gfrd_input_data:
%        This is a graph structure with yields as follows:
%
%        graph.data1: real vector [21,I]
%        Contains s as a function of s'.
%
%        graph.data2 : real matrix [21,1]
%        Contains a (fixed) vector of values of s' at which computation is made.
%
%        graph.title : string
%        Contains the title.
%
%        graph.xlabel : string
%        Contains the xlabel.
%
%        graph.ylabel : string
%        Contains the ylabel.
%
%      - frd_input_data:
%        This is a matrix of size [21, I+1]. This matrix which combines
%        data1 and data2 above is used as an input for convexifying part.
%
%      - lend_input_data:
%        This output is meaningful only when the computation is performed
%        at a single point (in other cases the values are for the last point)
%        and is useful only for a more careful analysis of other results. 
%        This is a graph structure with yields as follows:
%
%        graph.data1: real vector [101,1]
%        Contains a (fixed) vector of values of s at which computation is made.
%
%        graph.data2 : real matrix [101,21]
%        Contains length of the plateau (see ref) as a function of s.
%
%        graph.title : string
%        Contains the title.
%
%        graph.xlabel : string
%        Contains the xlabel.
%
%        graph.ylabel : string
%        Contains the ylabel.
%
%   o  Case local:
%      In this case there are three outputs: 
%      - Gloc_input_data:
%        This is a graph structure with yields as follows:
%
%        graph.data1: real vector [1,I]
%        Contains a (fixed) vector of integers from 1 to I.
%
%        graph.data2 : real matrix [21,1]
%        contains estimated local Holder exponents.
%
%        graph.title : string
%        Contains the title.
%
%        graph.xlabel : string
%        Contains the xlabel.
%
%        graph.ylabel : string
%        Contains the ylabel.
%
%      - lenlocd_input_data:
%        This output is meaningful only when the computation is performed
%        at a single point (in other cases the values are for the last point)
%        and is useful only for a more careful analysis of other results. 
%        This is a graph structure with yields as follows:
%
%        graph.data1: real vector [1,101]
%        Contains a (fixed) vector of values of s at which computation is made.
%
%        graph.data2 : real matrix [1,101]
%        Contains length of the plateau (see ref) as a function of s.
%
%        graph.title : string
%        Contains the title.
%
%        graph.xlabel : string
%        Contains the xlabel.
%
%        graph.ylabel : string
%        Contains the ylabel.
%
%   o  Case pointwise:
%      In this case there are three outputs: 
%      - Gpt_input_data:
%        This is a graph structure with yields as follows:
%
%        graph.data1: real vector [1,I]
%        Contains a (fixed) vector of integers from 1 to I.
%
%        graph.data2 : real matrix [1,I]
%        contains estimated pointwise Holder exponents.
%
%        graph.title : string
%        Contains the title.
%
%        graph.xlabel : string
%        Contains the xlabel.
%
%        graph.ylabel : string
%        Contains the ylabel.
%
%      - lenptd_input_data:
%        This output is meaningful only when the computation is performed
%        at a single point (in other cases the values are for the last point)
%        and is useful only for a more careful analysis of other results. 
%        This is a graph structure with yields as follows:
%
%        graph.data1: real vector [1,101]
%        Contains a (fixed) vector of values of s at which computation is made.
%
%        graph.data2 : real matrix [1,101]
%        Contains length of the plateau (see ref) as a function of s.
%
%        graph.title : string
%        Contains the title.
%
%        graph.xlabel : string
%        Contains the xlabel.
%
%        graph.ylabel : string
%        Contains the ylabel.
%
%   o  Case convexify:
%      In this case there is one outputs: 
%      - conv_frd_input_data:
%        This is a graph structure with yields as follows:
%
%        graph.data1: real vector [J,1]
%        where J is less than 21 and depends on s' cutoff.
%        Contains s as a function of s'.
%
%        graph.data2 : real matrix [J,1]
%        where J is less than 21 and depends on s' cutoff.
%        contains a fraction of the vector containing values of s'
%        at which the computation is performed.
%
%        graph.title : string
%        Contains the title.
%
%        graph.xlabel : string
%        Contains the xlabel.
%
%        graph.ylabel : string
%        Contains the ylabel.
%
%      - lenptd_input_data:
%        This output is meaningful only when the computation is performed

% Author Kiran Kolwankar, January 2001

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

fl_clearerror;
% get minimal resolution: eta_n
eta_n=get(gcf,'UserData'); 
% set # of Hoelder exponents: N
N=200;
% set continuous string: contstr
contstr='hkern';
% set precision adaptation string: adaptstr
adapstr='maxdev';
% set normalization string: normstr
normstr='infsuppdf';

switch(fl_string)
   
      
  case 'front' 
    %[sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;  
    [SigIn_name flag_error] = fl_get_input ('vector') ;
    if flag_error
        fl_error('Use a valid vector !')
       return
    else
        [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;
    end
    advancedsettings(Nx_n,Ny_n,sig_n,sig_nname);  
  case 'refresh1'
     fl_tml('front'); 
    % no_pts_used : N_n 
  case 'edittext_no_pts_used'
     N_in=str2num(get(gcbo,'String'));
     N_in=gui_fl_fgse_fix(N_in,1);
     N_max=(get(findobj('Tag','EditText_no_pts_used'),'UserData'));
     N_in=gui_fl_fgse_trunc(N_in,5.,N_max);
     set(gcbo,'String',N_in);
    % Increment: n_incr
  case 'edittext_incr'
      n_incr=str2num(get(gcbo,'String'));
      n_incr=gui_fl_fgse_fix(n_incr,1); 
      incr_max=get(findobj('Tag','EditText_incr'),'UserData');
      n_incr=gui_fl_fgse_trunc(n_incr,1,incr_max);
      set(gcbo,'String',n_incr);
    % # of pts to be studied: n_total
  case 'edittext_no_pts_std'
    n_total=str2num(get(gcbo,'String'));
    n_total=gui_fl_fgse_fix(n_total,1);
	total_max=get(findobj('Tag','EditText_no_pts_std'),'Max');
    n_total=gui_fl_fgse_trunc(n_total,1,total_max);
    set(gcbo,'String',n_total);
    % find string: findstr
  case 'popupmenu_find'  
	if get(findobj('Tag','PopupMenu_find'),'Value')==1 
	set(findobj('Tag','StaticTextConv_frontier'),'Enable','on');
	set(findobj('Tag','StaticTextConv_input'),'Enable','on'); 
	set(findobj('Tag','PushbuttonConv_refresh'),'Enable','on');
	set(findobj('Tag','StaticTextConv_name'),'Enable','on');
	set(findobj('Tag','StaticTextConv_sig_nname'),'Enable','on');
	set(findobj('Tag','EditText_sprime'),'Enable','on');
	set(findobj('Tag','Pushbutton_do_it'),'Enable','on');
	set(findobj('Tag','StaticText_sprime'),'Enable','on');
    else
	set(findobj('Tag','StaticTextConv_frontier'),'Enable','off');
	set(findobj('Tag','StaticTextConv_input'),'Enable','off'); 
	set(findobj('Tag','PushbuttonConv_refresh'),'Enable','off');
	set(findobj('Tag','StaticTextConv_name'),'Enable','off');
	set(findobj('Tag','StaticTextConv_sig_nname'),'Enable','off');
	set(findobj('Tag','EditText_sprime'),'Enable','off');
	set(findobj('Tag','Pushbutton_do_it'),'Enable','off');
	set(findobj('Tag','StaticText_sprime'),'Enable','off');
      end
     % compute frontier
  case 'compute'
	  if get(findobj('Tag','EditText_no_pts_used'),'String')==1
		  fl_warning('set # of pts to be used');
		  return
	  end
      if strcmp(get(findobj('Tag','StaticTexttml_sig_nname'),'String'),  'Input data name')
         fl_warning('No input data: hit refresh!');
         return
      end
      mouse = fl_waiton;
      % get the input function: F_n
      [F_nname,F_n]=getinputF_n;
      % fch1d settings 
      [N_in,n_incr,findstr]=fch1dsettings; 
      jsx = 1;
      for isx = 0:0.01:1
        sx(jsx) = isx;
        jsx = jsx + 1; 
      end
      if n_incr == 0
         n_total = 1;
      else
         n_total = length(F_n);
      end
      % call of the C_LAB routine: fch1d 
      if get(findobj('Tag','PopupMenu_find'),'Value')==1
        [sprime_s,len]=dtmlf(F_n,N_in,n_incr,n_total);
        prefix=['Gfrd_' F_nname]; 
        prefix1=['frd_' F_nname]; 
        prefix2=['lend_' F_nname]; 
      output1=sprime_s;
      output2=len;
      [nspsx,nspsy] = size(sprime_s);
      spsy = sprime_s(:,1);
      for isps = 2:nspsy
        spsx(:,isps-1) = sprime_s(:,isps);
      end
    % make outputname
    outputname=fl_findname(prefix,fl_whos);
    outputname1=fl_findname(prefix1,fl_whos);
    outputname2=fl_findname(prefix2,fl_whos);
    eval(['global ' outputname]); 
    eval(['global ' outputname1]); 
    eval(['global ' outputname2]); 
    % set title, xlabel, ylabel
	title='The unconvexified frontier';
    xlabel='s';
    ylabel='s\prime';
    eval ([outputname '= struct (''type'',''graph'',''data1'',spsx,''data2'',spsy,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    eval ([outputname1 '= output1;']);
	title2='Length of the plateau vs s';
    xlabel2='s';
    ylabel2='length of the plateau';
    eval ([outputname2 '= struct (''type'',''graph'',''data1'',transpose(sx),''data2'',transpose(len),''title'',title2,''xlabel'',xlabel2,''ylabel'',ylabel2);']);
    %eval ([outputname2 '= output2;']);
    % add varname to list
    
    fl_addlist(0,outputname1)
    fl_addlist(0,outputname2)
    fl_addlist(0,outputname)
    
    set(findobj('Tag','StaticTextConv_sig_nname'),'String',outputname1);
    
	elseif get(findobj('Tag','PopupMenu_find'),'Value')==2 
           [sprime_s,len]=dtmll(F_n,N_in,n_incr,n_total);
           prefix=['Gloc_' F_nname]; 
           prefix2=['lenlocd_' F_nname]; 
           output1=sprime_s;
           output2=len;
           for isx = 1:length(sprime_s)
            sxint(isx) = isx;
           end
    outputname=fl_findname(prefix,fl_whos);
    outputname2=fl_findname(prefix2,fl_whos);
    eval(['global ' outputname]); 
    eval(['global ' outputname2]); 
    % set title, xlabel, ylabel
	title='The local Holder exponent';
    xlabel='points';
    ylabel='Local Holder exponents';
    eval ([outputname '= struct (''type'',''graph'',''data1'',sxint,''data2'',sprime_s,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    %eval ([outputname '= output1;']);
    % set title, xlabel, ylabel
	title='Length vs s';
    xlabel='s';
    ylabel='Length of the plateau';
    eval ([outputname2 '= struct (''type'',''graph'',''data1'',sx,''data2'',len,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    %eval ([outputname2 '= output2;']);
    fl_addlist(0,outputname)
    fl_addlist(0,outputname2)
        else
           [sprime_s,len]=dtmlp(F_n,N_in,n_incr,n_total);
            prefix=['Gpt_' F_nname]; 
            prefix2=['lenptd_' F_nname]; 
            output1=sprime_s;
            output2=len;
           for isx = 1:length(sprime_s)
            sxint(isx) = isx;
           end
    outputname=fl_findname(prefix,fl_whos);
    outputname2=fl_findname(prefix2,fl_whos);
    eval(['global ' outputname]); 
    eval(['global ' outputname2]); 
    % set title, xlabel, ylabel
	title='The pointwise Holder exponents';
    xlabel='points';
    ylabel='Pointwise Holder exponent';
    eval ([outputname '= struct (''type'',''graph'',''data1'',sxint,''data2'',sprime_s,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    %eval ([outputname '= output1;']);
    % set title, xlabel, ylabel
	title='Length vs s';
    xlabel='s';
    ylabel='Length of the plateau';
    eval ([outputname2 '= struct (''type'',''graph'',''data1'',sx,''data2'',len,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    %eval ([outputname2 '= output2;']);
    fl_addlist(0,outputname)
    fl_addlist(0,outputname2)
    end
    fl_waitoff(mouse);
  case 'conv' 
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input_conv;  
    if flag_error
      return
    end
    advancedsettingsconv(Nx_n,Ny_n,sig_n,sig_nname);  
  case 'refresh2'
     fl_tml('conv'); 
    % : s_prime
  case 'edittext_sprime'
      sp_start=str2num(get(gcbo,'String'));
      sp_start=gui_fl_fgse_fix(sp_start,10); 
      sprime_max=get(findobj('Tag','EditText_incr'),'Max');
      sp_start=gui_fl_fgse_trunc(sp_start,-0.8,1.0);
      set(gcbo,'String',sp_start);
 
	% do it
  case 'do_it'
    % get the input signal
      % get the input function: F_n
      if strcmp(get(findobj('Tag','StaticTextConv_sig_nname'),'String'), 'Input data name')
         fl_warning('No input data: hit refresh!');
         return
      end
      [F_nname,F_n]=getinputconvF_n;
      % fch1d settings 
      [sp_start]=fch1dsettingsconv; 
	  % call of the matlab function: twiceleg
      [lx,ly]=twiceleg(F_n,sp_start);
 
      prefix=['conv_' F_nname];
    % make outputname
    outputname=fl_findname(prefix,fl_whos);
    eval(['global ' outputname]); 
    % set title, xlabel, ylabel
	title='The convexified frontier';
    xlabel='s';
    ylabel='s\prime';
    % make global structure and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',lx,''data2'',ly,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    % add varname to list
    fl_addlist(0,outputname);
    
    
   
end

% trunc
function trunc_x=gui_fl_fgse_trunc(x,x_min,x_max)
if(x<x_min)
  trunc_x=x_min;
else
  if(x>x_max)
    trunc_x=x_max;
  else
    trunc_x=x;
  end 
end

% truncbelow
function trunc_x=gui_fl_fgse_truncbelow(x,x_min)
if(x<x_min)
  trunc_x=x_min;
else
    trunc_x=x; 
end

% fix
function fix_x=gui_fl_fgse_fix(x,ten_power)
fix_x=round(x.*ten_power)/ten_power;

	
% getinputF_n
function [F_nname,F_n]=getinputF_n
F_nname=get(findobj('Tag','StaticTexttml_sig_nname'),'String');
eval(['global ' F_nname]);
eval(['F_n=' F_nname ';']);
m=min(F_n);
M=max(F_n);
if (m~=0. & M~=1.)  
  F_n=(F_n-m)/(M-m);
end



% fch1dsettings
function [N_in,n_incr,findstr]=fch1dsettings
N_in=str2num(get(findobj('Tag','EditText_no_pts_used'),'String'));
n_incr=str2num(get(findobj('Tag','EditText_incr'),'String')); 
%n_total=str2num(get(findobj('Tag','EditText_no_pts_std'),'String')); 
  switch get(findobj('Tag','PopupMenu_find'),'Value')  
    case 1
      findstr='fro';
    case 2 
      findstr='loc';
    case 3
      findstr='pts';
  end 


function advancedsettings(Nx_n,Ny_n,sig_n,sig_nname)
J_max=floor(log(.5*Nx_n)/log(2));
J=floor(J_max/2);
Nxy =max(Nx_n,Ny_n);
a=1;
a_min=1;
A=floor(.25*Nx_n);
A_max=floor(.5*Nx_n);
eta_n=1./Nx_n;
fl_callwindow('Fig_gui_fl_tml','gui_fl_tml');
set(findobj('Tag','Fig_gui_fl_tml'),'UserData',eta_n);
set(findobj('Tag','StaticTexttml_sig_nname'),'String',sig_nname);
str=['[',num2str(Ny_n),' x ',num2str(Nx_n),']'];
set(findobj('Tag','EditTexttml_size'),'String',str); 
set(findobj('Tag','StaticText_no_pts_used'),'String','window');
set(findobj('Tag','EditText_no_pts_used'),'Style','edit');
set(findobj('Tag','EditText_no_pts_used'),'UserData',floor(Nxy/10));
set(findobj('Tag','EditText_no_pts_used'),'String',floor(Nxy/10));
set(findobj('Tag','StaticText_incr'),'String','step');
set(findobj('Tag','EditText_incr'),'Style','edit');
set(findobj('Tag','EditText_incr'),'UserData',Nxy);
set(findobj('Tag','EditText_incr'),'String',Nxy);
%set(findobj('Tag','StaticText_no_pts_std'),'String','# of pts to be studied');
%set(findobj('Tag','EditText_no_pts_std'),'Style','edit');
%set(findobj('Tag','EditText_no_pts_std'),'Max',Nxy); 
%set(findobj('Tag','EditText_no_pts_std'),'String',a); 
set(findobj('Tag','PopupMenu_ball'),'Style','popupmenu');
set(findobj('Tag','PopupMenu_ball'),'Enable','on');

function [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input
fl_clearerror;
[sig_nname flag_error]=fl_get_input('vector');
if flag_error
    fl_error('Input must be a vector !');
    return
end
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


% fch1dbasicsettings
function [S_min,S_max,J,progstr,oscstr]=fch1dbasicsettings
N_in=1;
n_incr=1;
n_total=1;
findstr='fro';

function advancedsettingsconv(Nx_n,Ny_n,sig_n,sig_nname)
J_max=floor(log(.5*Nx_n)/log(2));
J=floor(J_max/2);
a=1;
a_min=1;
A=floor(.25*Nx_n);
A_max=floor(.5*Nx_n);
eta_n=1./Nx_n;
fl_callwindow('Fig_gui_fl_tml','gui_fl_tml');
set(findobj('Tag','Fig_gui_fl_tml'),'UserData',eta_n);
set(findobj('Tag','StaticTextConv_sig_nname'),'String',sig_nname);
str=['[',num2str(Ny_n),' x ',num2str(Nx_n),']'];
%set(findobj('Tag','EditTexttml_size'),'String',str); 
set(findobj('Tag','StaticText_sprime'),'String','s` cut off');
set(findobj('Tag','EditText_sprime'),'Style','edit');
set(findobj('Tag','EditText_sprime'),'Max',1.0);
%set(findobj('Tag','EditText_sprime'),'Min',-0.8);
set(findobj('Tag','EditText_sprime'),'String',0.0);
%set(findobj('Tag','StaticText_incr'),'String','Increment');
%set(findobj('Tag','EditText_incr'),'Style','edit');
%set(findobj('Tag','EditText_incr'),'Max',Nx_n);
%set(findobj('Tag','EditText_incr'),'String',A);
%set(findobj('Tag','StaticText_no_pts_std'),'String','# of pts to be studied');
%set(findobj('Tag','EditText_no_pts_std'),'Style','edit');
%set(findobj('Tag','EditText_no_pts_std'),'Max',Nx_n); 
%set(findobj('Tag','EditText_no_pts_std'),'String',J); 
%set(findobj('Tag','PopupMenu_ball'),'Style','popupmenu');
%set(findobj('Tag','PopupMenu_ball'),'Enable','on');

function [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input_conv
fl_clearerror;
[sig_nname flag_error]=fl_get_input('matrix');
if flag_error
    fl_warning('input signal must be a matrix !');
    return
end
eval(['global ' sig_nname]);
eval(['sig_n=' sig_nname ';']);
[M N]=size(sig_n);
if M==1 | N==1
  fl_warning('Input signal must have more than 1 rows and columns');
  return
else
  Ny_n=M;
  Nx_n=N;
end

% getinputconvF_n
function [F_nname,F_n]=getinputconvF_n
F_nname=get(findobj('Tag','StaticTextConv_sig_nname'),'String');
eval(['global ' F_nname]);
eval(['F_n=' F_nname ';']);


% fch1dsettingsconv
function [sp_start]=fch1dsettingsconv
sp_start=str2num(get(findobj('Tag','EditText_sprime'),'String'));

% making frontier convex
function [lx,ly]=twiceleg(F_n,sp_start) 
si = F_n;
[nr,nc]=size(F_n);
sp_value=floor(10*sp_start)/10;
sp_start_int =-floor(10*(sp_start - 1)) + 1; 
for col=2:nc
 k1 = 1;
 for k=sp_start_int:21
  s(k1) = si(k,col);
  sp(k1) = si(k,1);
  k1 = k1+1;
 end
 i=1;
 for pp = sp_value:-0.1:-1
   l1(i,1) = pp;
   l1(i,col) = min(pp.*sp - s);
   i = i+1;
 end
 j=1;
 for p = sp_value:-0.1:-1
   ly(j,1) = p;
   lx(j,col-1) = min(p.*l1(:,1) - l1(:,col));
   j = j+1;
 end
end
