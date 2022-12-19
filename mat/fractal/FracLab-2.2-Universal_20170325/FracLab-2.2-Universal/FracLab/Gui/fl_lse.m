function [outputname]=fl_lse(fl_string,fl_whos)
% Callback functions for GUI - Legendre spectrum estimation (lse)

% Author Christophe Canus, June 1999
% Modified by Pierrick Legrand, January 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

fl_clearerror;

switch(fl_string)
  % mbasic 
  case 'mbasic'
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;
    if flag_error
      return
    end
    if ~isempty(find(sig_n<0.))
      fl_warning('Take normalized absolute values increments');
      sig_n=abs(diff(sig_n))./sum(abs(diff(sig_n)));
    end
    % mdzq1d basic settings 
    [q,J,min_size,max_size,partstr]=mdzq1dbasicsettings(Nx_n,Ny_n);
    % fl1d basic settings
    [N,lrstr,title,xlabel,ylabel]=fl1dbasicsettings;
    current_mouse_ptr=fl_waiton;
    % call of the C_LAB routine: mdfl1d
    [alpha,fl_alpha]=mdfl1d(sig_n,q,[J min_size max_size],partstr,lrstr);
    fl_waitoff(current_mouse_ptr); 
    % make outputname
    prefix=['mdfl1d_' sig_nname];
    outputname=fl_findname(prefix,fl_whos);
    % make varname global
    eval(['global ' outputname]);
    % make global cell and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fl_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    % add varname to list
    fl_addlist(0,outputname); 
    
    chaine=['[',outputname,'.data1,',outputname,'.data2]=mdfl1d(',...
        sig_nname,',[',num2str(q),'],[',num2str(J),...
        ',',num2str(min_size),',',num2str(max_size),'],''',num2str(partstr),...
        ''',''',num2str(lrstr),''');'];
    fl_diary(chaine);
    
    % fbasic
  case 'fbasic'
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;
    if flag_error
      return
    end
    m=min(sig_n);
    M=max(sig_n);
    if m~=0. & M~=1.
      sig_n=(sig_n-m)/(M-m);
    end  
    % fczq1d basic settings 
    [q,J,min_size,max_size,progstr,oscstr]=fczq1dbasicsettings(Nx_n,Ny_n); 
    % fl1d basic settings
    [N,lrstr,title,xlabel,ylabel]=fl1dbasicsettings;
    current_mouse_ptr=fl_waiton;
    % call of the C_LAB routine  
    [alpha,fl_alpha]=fcfl1d(sig_n,q,[J,min_size,max_size],progstr,oscstr,lrstr);
    
    fl_waitoff(current_mouse_ptr); 
    % make outputname
    prefix=['fcfl1d_' sig_nname]; 
    outputname=fl_findname(prefix,fl_whos);
    % make varname global
    eval(['global ' outputname]);
    % make global cell and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fl_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    % add varname to list
    fl_addlist(0,outputname);
    
    chaine=['[',outputname,'.data1,',outputname,'.data2]=fcfl1d(',sig_nname,',[',num2str(q),'],[',num2str(J),...
        ',',num2str(min_size),',',num2str(max_size),'],''',num2str(progstr),...
        ''',''',num2str(oscstr),''',''',num2str(lrstr),''');'];
    fl_diary(chaine);
    % measure advanced 
    
  case 'madvanced'
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;
    if flag_error
      return
    end
    advancedsettings(Nx_n,Ny_n,sig_n,sig_nname);
    set(findobj('Tag','fl_lse_RadioButton_measure'),'Enable','on');
    set(findobj('Tag','fl_lse_RadioButton_measure'),'Value',1); 
    set(findobj('Tag','fl_lse_RadioButton_function'),'Enable','on');
    set(findobj('Tag','fl_lse_RadioButton_function'),'Value',0); 
    set(findobj('Tag','fl_lse_RadioButton_cwt'),'Enable','off'); 
    set(findobj('Tag','fl_lse_RadioButton_cwt'),'Value',0);
  case 'fadvanced' 
    [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input;  
    if flag_error
      return
    end
    advancedsettings(Nx_n,Ny_n,sig_n,sig_nname);  
    set(findobj('Tag','fl_lse_RadioButton_measure'),'Enable','on');
    set(findobj('Tag','fl_lse_RadioButton_measure'),'Value',0); 
    set(findobj('Tag','fl_lse_RadioButton_function'),'Enable','on');  
    set(findobj('Tag','fl_lse_RadioButton_function'),'Value',1); 
    set(findobj('Tag','fl_lse_RadioButton_cwt'),'Enable','off'); 
    set(findobj('Tag','fl_lse_RadioButton_cwt'),'Value',0);  
    set(findobj('Tag','fl_lse_StaticText_ball'),'String','oscillation');
    set(findobj('Tag','fl_lse_PopupMenu_ball'),'String',{'osc','lpnorm','linfty norm'});
  case 'refresh'
    if get(findobj('Tag','fl_lse_RadioButton_measure'),'Value')==1
      fl_lse('madvanced');
    else
      fl_lse('fadvanced');
    end
    % measure
  case 'fl_lse_Radiobutton_measure'
    if get(findobj('Tag','fl_lse_RadioButton_measure'),'Value')==0
      set(findobj('Tag','fl_lse_RadioButton_measure'),'Value',1);
    end
    set(findobj('Tag','fl_lse_RadioButton_function'),'Value',0);
    set(findobj('Tag','fl_lse_StaticText_ball'),'String','ball'); 
    set(findobj('Tag','fl_lse_PopupMenu_ball'),'String',{'centered','asymmetric','star'});
    set(findobj('Tag','fl_lse_EditText_power'),'Enable','off');
    set(findobj('Tag','fl_lse_Slider_power'),'Enable','off');
    % function
  case 'fl_lse_Radiobutton_function' 
    if get(findobj('Tag','fl_lse_RadioButton_function'),'Value')==0
      set(findobj('Tag','fl_lse_RadioButton_function'),'Value',1);
    end
    set(findobj('Tag','fl_lse_RadioButton_measure'),'Value',0);
    set(findobj('Tag','fl_lse_StaticText_ball'),'String','oscillation');
    set(findobj('Tag','fl_lse_PopupMenu_ball'),'String',{'osc','lp norm','linfty norm'});
    if get(findobj('Tag','fl_lse_PopupMenu_ball'),'Value')==2 
      set(findobj('Tag','fl_lse_EditText_power'),'Enable','on');
      set(findobj('Tag','fl_lse_Slider_power'),'Enable','on');
    end 
    % cwt
  case 'cwt'  
    if get(findobj('Tag','fl_lse_RadioButton_cwt'),'Value')==0
      set(findobj('Tag','fl_lse_RadioButton_cwt'),'Value',1);
    end
    % min size: min_size 
  case 'fl_lse_EditText_min'
    if get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')~=3
      min_size=str2num(get(gcbo,'String')); 
      min_size=gui_fl_flse_fix(min_size,100);
      max_size=str2num(get(findobj('Tag','fl_lse_EditText_max'),'String'));
      min_size=gui_fl_flse_trunc(min_size,1.,max_size);  
      set(gcbo,'String',min_size);
      set(findobj('Tag','fl_lse_Slider_min'),'Value',min_size);
    end
  case 'fl_lse_Slider_min'
    if get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')~=3
      min_size=get(gcbo,'Value'); 
      min_size=gui_fl_flse_fix(min_size,100); 
      max_size=str2num(get(findobj('Tag','fl_lse_EditText_max'),'String')); 
      min_size=gui_fl_flse_trunc(min_size,1.,max_size); 
      set(gcbo,'Value',min_size);
      set(findobj('Tag','fl_lse_EditText_min'),'String',num2str(min_size)); 
    else
      j_min=get(gcbo,'Value')-1;
      j_max=get(findobj('Tag','fl_lse_Slider_max'),'Value')-1; 
      j_min=gui_fl_flse_trunc(j_min,0.,j_max); 
      set(gcbo,'Value',j_min+1);
      set(findobj('Tag','fl_lse_EditText_min'),'String',num2str(2^j_min)); 
      set(findobj('Tag','fl_lse_Slider_size_nb'),'Value',j_max-j_min+1);
      set(findobj('Tag','fl_lse_EditText_size_nb'),'String',j_max-j_min+1); 
    end
    % max size: max_size
  case 'fl_lse_EditText_max'
    if get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')~=3
      max_size=str2num(get(gcbo,'String'));
      max_size=gui_fl_flse_fix(max_size,100); 
      min_size=str2num(get(findobj('Tag','fl_lse_EditText_min'),'String'));
      max_size=gui_fl_flse_trunc(max_size,min_size,.5/eta_n);
      set(gcbo,'String',max_size);
      set(findobj('Tag','fl_lse_Slider_max'),'Value',max_size);
    end
  case 'fl_lse_Slider_max'
    if get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')~=3
      max_size=get(gcbo,'Value');
      max_size=gui_fl_flse_fix(max_size,100); 
      min_size=str2num(get(findobj('Tag','fl_lse_EditText_min'),'String'));
      max_size=gui_fl_flse_trunc(max_size,min_size,.5/eta_n); 
      set(gcbo,'Value',max_size);
      set(findobj('Tag','fl_lse_EditText_max'),'String',max_size);
    else 
      j_max=get(gcbo,'Value')-1;
      j_min=get(findobj('Tag','fl_lse_Slider_min'),'Value')-1; 
      j_max=gui_fl_flse_trunc(j_max,j_min,floor(log(.5/eta_n)/log(2))); 
      set(gcbo,'Value',j_max+1);
      set(findobj('Tag','fl_lse_EditText_max'),'String',num2str(2^j_max));
      set(findobj('Tag','fl_lse_Slider_size_nb'),'Value',j_max-j_min+1); 
      set(findobj('Tag','fl_lse_EditText_size_nb'),'String',j_max-j_min+1); 
    end
    % # of sizes: J
  case 'fl_lse_EditText_size_nb'
    J=str2num(get(gcbo,'String'));
    J=gui_fl_flse_fix(J,1);
    J=gui_fl_flse_trunc(J,1,64);
    set(gcbo,'String',J);
    set(findobj('Tag','fl_lse_Slider_size_nb'),'Value',J);
    if get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')==3
      j_min=get(findobj('Tag','fl_lse_Slider_min'),'Value')-1; 
      set(findobj('Tag','fl_lse_EditText_max'),'String',2^(j_min+J-1));
      set(findobj('Tag','fl_lse_Slider_max'),'Value',j_min+J);
    end;
  case 'fl_lse_Slider_size_nb'
    J=get(gcbo,'Value');
    J=gui_fl_flse_fix(J,1);
    set(findobj('Tag','fl_lse_EditText_size_nb'),'String',J);
    if get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')==3
      j_min=get(findobj('Tag','fl_lse_Slider_min'),'Value')-1; 
      set(findobj('Tag','fl_lse_EditText_max'),'String',2^(j_min+J-1));
      set(findobj('Tag','fl_lse_Slider_max'),'Value',j_min+J);
    end;  
    % progession string: progstr
  case 'fl_lse_Popupmenu_progression'  
    switch get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')  
      case 1
	scalestr='lin';
	setlinlog(eta_n);
      case 2
	scalestr='log';
	setlinlog(eta_n);
      case 3
	scalestr='dec';
	setdec(eta_n);
    end
    % ball string: ballstr
  case 'fl_lse_Popupmenu_ball'  
    if get(findobj('Tag','fl_lse_RadioButton_function'),'Value')==1 
      if get(findobj('Tag','fl_lse_PopupMenu_ball'),'Value')==2 
	set(findobj('Tag','fl_lse_EditText_power'),'Enable','on');
	set(findobj('Tag','fl_lse_Slider_power'),'Enable','on'); 
      else
	set(findobj('Tag','fl_lse_EditText_power'),'Enable','off');
	set(findobj('Tag','fl_lse_Slider_power'),'Enable','off');
      end
    end  
    % power: p
  case 'fl_lse_EditText_power'
    p=str2num(get(gcbo,'String')); 
    p=gui_fl_flse_fix(p,100);
    p=gui_fl_flse_trunc(p,1.,10.);  
    set(gcbo,'String',p);
    set(findobj('Tag','fl_lse_Slider_min'),'Value',p);
  case 'fl_lse_Slider_power'
    p=get(gcbo,'Value');
    p=gui_fl_flse_fix(p,100);
    p=gui_fl_flse_trunc(p,1.,10.);
    set(gcbo,'Value',p);
    set(findobj('Tag','fl_lse_EditText_power'),'String',num2str(p)); 
    % min q: q_min
  case 'fl_lse_EditText_min_q'
      min_q=str2num(get(gcbo,'String')); 
      min_q=floor(min_q);
      max_q=str2num(get(findobj('Tag','fl_lse_EditText_max_q'),'String'));
      min_q=gui_fl_flse_trunc(min_q,-50,max_q);  
      set(gcbo,'String',min_q);
    % max q : q_max
  case 'fl_lse_EditText_max_q'
      max_q=str2num(get(gcbo,'String')); 
      max_q=floor(max_q);
      min_q=str2num(get(findobj('Tag','fl_lse_EditText_min_q'),'String'));
      max_q=gui_fl_flse_trunc(max_q,min_q,50);  
      set(gcbo,'String',max_q);  
  case 'fl_lse_EditText_q_nb'
      q_nb=str2num(get(gcbo,'String')); 
      q_nb=floor(q_nb);
      q_nb=gui_fl_flse_trunc(q_nb,1,201);  
      set(gcbo,'String',q_nb); 
    % compute partition
  case 'compute_partition'
    if get(findobj('Tag','fl_lse_RadioButton_measure'),'Value')==1
      % get the input measure: mu_n
      [mu_nname,mu_n]=getinputmu_n;
      % mdzq1d settings 
      [q,J,min_size,max_size,partstr]=mdzq1dsettings;
      current_mouse_ptr=fl_waiton;
      % call of the C_LAB routine: mdzq1d 
      [zaq,a,q]=mdzq1d(mu_n,q,[J min_size max_size],partstr);
      fl_waitoff(current_mouse_ptr);
      prefix=['mdzq1d_' mu_nname];
      output=zaq;
      figure;
      plot(log(a),log(zaq));
    end
    if get(findobj('Tag','fl_lse_RadioButton_function'),'Value')==1
      % get the input function: F_n
      [F_nname,F_n]=getinputF_n;
      % fczq1d settings 
      [q,J,min_size,max_size,partstr,oscstr]=fczq1dsettings; 
      % call of the C_LAB routine: fczq1d 
      [zaq,a,q]=fczq1d(F_n,q,[J min_size max_size],progstr,oscstr);
      prefix=['fczq1d_' F_nname]; 
      output=zaq;
      figure;
      plot(log(a),log(zaq));
    end
    if get(findobj('Tag','fl_lse_RadioButton_cwt'),'Value')==1  
      % get the input cwt: cwt_struct
      [cwt_structname,cwt_struct]=getinputcwt_struct;
      % call of the matlab function: wch1d
      [alpha_a]=wch1d(cwt_struct);
      prefix=['wch1d_' cwt_structname];
      output=alpha_a;
    end 
    % make outputname
    outputname=fl_findname(prefix,fl_whos);
    eval(['global ' outputname]); 
    eval ([outputname '= output;']);
    % add varname to list
    fl_addlist(0,outputname)
    % compute
  case 'compute'
    % get the input signal
    if get(findobj('Tag','fl_lse_RadioButton_measure'),'Value')==1
      % get the input measure: mu_n
      [mu_nname,mu_n]=getinputmu_n;  
      % mdzq1d settings 
      [min_size,max_size,J,progstr,ballstr]=mdzq1dsettings;
      prefix=['mdfl1d_' mu_nname];
    elseif get(findobj('Tag','fl_lse_RadioButton_function'),'Value')==1
      % get the input function: F_n
      [F_nname,F_n]=getinputF_n;
      % fczq1d settings 
      [min_size,max_size,J,progstr,oscstr]=fczq1dsettings; 
      prefix=['fcfl1d_' F_nname];
    % elseif get(findobj('Tag','fl_lse_RadioButton_cwt'),'Value')==1
      % get the input cwt: cwt_struct
      % [cwt_structname,cwt_struct]=getinputcwt_struct;
      % prefix=['wcfl1d_' cwt_structname];
    end;
    current_mouse_ptr=fl_waiton;
    % call of the C-LAB routine or matlab function
    if get(findobj('Tag','fl_lse_RadioButton_measure'),'Value')==1
      % call of the C-LAB routine: mdfl1d
      [alpha,fl_alpha]=mdfl1d(mu_n,q,[J,min_size,max_size],partstr,lrstr);
    elseif get(findobj('Tag','fl_lse_RadioButton_function'),'Value')==1
      % call of the C-LAB routine: mdfl1d
      [alpha,fl_alpha]=fcfl1d(F_n,q,[J,min_size,max_size],progstr,oscstr,N);
    % elseif get(findobj('Tag','fl_lse_RadioButton_cwt'),'Value')==1 
      % call of the matlab function: wcfl1d
    end
    fl_waitoff(current_mouse_ptr); 
    % make outputname
    outputname=fl_findname(prefix,fl_whos);
    eval(['global ' outputname]); 
    % set xlabel, ylabel
    xlabel='Hoelder exponents: \alpha';
    ylabel='spectrum: f_l(\alpha)';
    % make global structure and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fl_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    % add varname to list
    fl_addlist(0,outputname);
end

% trunc
function trunc_x=gui_fl_flse_trunc(x,x_min,x_max)
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
function fix_x=gui_fl_flse_fix(x,ten_power)
fix_x=round(x.*ten_power)/ten_power;

% setlinlog
function setlinlog(eta_n)
J=floor(log(.5/eta_n)/log(2));
j_min=0;
j_max=floor(J/2);
set(findobj('Tag','fl_lse_EditText_min'),'Min',2^j_min);
set(findobj('Tag','fl_lse_EditText_min'),'Max',2^J);
set(findobj('Tag','fl_lse_EditText_min'),'Value',2^j_min);
set(findobj('Tag','fl_lse_Slider_min'),'Style','fl_lse_Slider');
set(findobj('Tag','fl_lse_Slider_min'),'Min',2^j_min);
set(findobj('Tag','fl_lse_Slider_min'),'Max',2^J);
set(findobj('Tag','fl_lse_Slider_min'),'Value',2^j_min);
set(findobj('Tag','fl_lse_EditText_max'),'Min',2^j_min);
set(findobj('Tag','fl_lse_EditText_max'),'Max',2^J);
set(findobj('Tag','fl_lse_EditText_max'),'Value',2^j_max);
set(findobj('Tag','fl_lse_Slider_max'),'Style','fl_lse_Slider');
set(findobj('Tag','fl_lse_Slider_max'),'Min',2^j_min);
set(findobj('Tag','fl_lse_Slider_max'),'Max',2^J);
set(findobj('Tag','fl_lse_Slider_max'),'Value',2^j_max);
set(findobj('Tag','fl_lse_EditText_size_nb'),'Min',2^j_min);
set(findobj('Tag','fl_lse_EditText_size_nb'),'Max',min(2^J,128));
set(findobj('Tag','fl_lse_EditText_size_nb'),'String',j_max);
set(findobj('Tag','fl_lse_Slider_size_nb'),'Style','fl_lse_Slider');
set(findobj('Tag','fl_lse_Slider_size_nb'),'Min',2^j_min); 
set(findobj('Tag','fl_lse_Slider_size_nb'),'Max',min(2^J,128));
set(findobj('Tag','fl_lse_Slider_size_nb'),'Value',j_max);
	
% setdec
function setdec(eta_n)
J=floor(log(.5/eta_n)/log(2)); 
j_min=0;
j_max=floor(J/2);
set(findobj('Tag','fl_lse_EditText_min'),'Min',2^j_min);
set(findobj('Tag','fl_lse_EditText_min'),'Max',2^J);
set(findobj('Tag','fl_lse_EditText_min'),'String','1');
for j=j_min:J
  varcell{j+1}=['2^(' num2str(j) ')'];
end
set(findobj('Tag','fl_lse_Slider_min'),'String',varcell);
set(findobj('Tag','fl_lse_Slider_min'),'Style','popupmenu');
set(findobj('Tag','fl_lse_Slider_min'),'Min',j_min+1);
set(findobj('Tag','fl_lse_Slider_min'),'Max',J);
set(findobj('Tag','fl_lse_Slider_min'),'Value',j_min+1);
set(findobj('Tag','fl_lse_EditText_max'),'Min',2^j_min);
set(findobj('Tag','fl_lse_EditText_max'),'Max',2^J);
set(findobj('Tag','fl_lse_EditText_max'),'String',2^j_max); 
for j=j_min:J
  varcell{j+1}=['2^(' num2str(j) ')'];
end
set(findobj('Tag','fl_lse_Slider_max'),'String',varcell);
set(findobj('Tag','fl_lse_Slider_max'),'Style','popupmenu');
set(findobj('Tag','fl_lse_Slider_max'),'Min',j_min+1);
set(findobj('Tag','fl_lse_Slider_max'),'Max',J);
set(findobj('Tag','fl_lse_Slider_max'),'Value',j_max+1);
set(findobj('Tag','fl_lse_EditText_size_nb'),'Min',j_min+1);
set(findobj('Tag','fl_lse_EditText_size_nb'),'Max',J+1);
set(findobj('Tag','fl_lse_EditText_size_nb'),'String',j_max+1);
for j=1:J
  varcellJ{j}=num2str(j);
end
set(findobj('Tag','fl_lse_Slider_size_nb'),'String',varcellJ);
set(findobj('Tag','fl_lse_Slider_size_nb'),'Style','popupmenu');
set(findobj('Tag','fl_lse_Slider_size_nb'),'Min',1);
set(findobj('Tag','fl_lse_Slider_size_nb'),'Max',J);
set(findobj('Tag','fl_lse_Slider_size_nb'),'Value',j_max+1);
	
% getinputmu_n
function [mu_nname,mu_n]=getinputmu_n
mu_nname=get(findobj('Tag','fl_lse_StaticText_sig_nname'),'String');
eval(['global ' mu_nname]);
eval(['mu_n=' mu_nname ';']); 
if ~isempty(find(mu_n<0.))
  fl_warning('Take normalized absolute values increments');
  mu_n=abs(diff(mu_n))./sum(abs(diff(mu_n)));
end 

% getinputF_n
function [F_nname,F_n]=getinputF_n
F_nname=get(findobj('Tag','fl_lse_StaticText_sig_nname'),'String');
eval(['global ' F_nname]);
eval(['F_n=' F_nname ';']);
m=min(F_n);
M=max(F_n);
if m~=0. & M~=1.
  F_n=(F_n-m)/(M-m);
end

% getinputcwt_struct
function [cwt_structname,cwt_struct]=getinputcwt_struct
cwt_structname=get(findobj('Tag','fl_lse_StaticText_sig_nname'),'String');
eval(['global ' cwt_structname]);
eval(['cwt_struct=' cwt_structname ';']);

% mdzq1dsettings
function [q,J,min_size,max_size,partstr]=mdzq1dsettings
min_q=str2num(get(findobj('Tag','fl_lse_EditText_min_q'),'String'))
max_q=str2num(get(findobj('Tag','fl_lse_EditText_max_q'),'String'))
q_nb=str2num(get(findobj('Tag','fl_lse_EditText_q_nb'),'String'))
q=[min_q:(max_q-min_q)/q_nb:max_q]
J=str2num(get(findobj('Tag','fl_lse_EditText_size_nb'),'String'))
min_size=str2num(get(findobj('Tag','fl_lse_EditText_min'),'String'))
max_size=str2num(get(findobj('Tag','fl_lse_EditText_max'),'String'))
partstr='linpart';
switch get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')
  case 1
  progstr='lin';
case 2
  progstr='log';
case 3
  progstr='dec';
  min_size=2^(floor(log(min_size)/log(2)));
  max_size=2^(floor(log(max_size)/log(2)));
  J=floor(log(max_size/min_size)/log(2))+1;
end 
if get(findobj('Tag','fl_lse_RadioButton_measure'),'Value')==1
  switch get(findobj('Tag','fl_lse_PopupMenu_ball'),'Value')  
    case 1
      ballstr='cent';
    case 2
      ballstr='asym';
    case 3
      ballstr='star';
  end 
else
   return
end

% fczq1dsettings
function [min_size,max_size,J,progstr,oscstr]=fczq1dsettings
min_size=str2num(get(findobj('Tag','fl_lse_EditText_min'),'String'));
max_size=str2num(get(findobj('Tag','fl_lse_EditText_max'),'String')); 
J=str2num(get(findobj('Tag','fl_lse_EditText_size_nb'),'String')); 
switch get(findobj('Tag','fl_lse_PopupMenu_progression'),'Value')  
case 1
  progstr='lin';
case 2
  progstr='log';
case 3
  progstr='dec';
  min_size=2^(floor(log(min_size)/log(2)));
  max_size=2^(floor(log(max_size)/log(2)));
  J=floor(log(max_size/min_size)/log(2))+1;
end 
if get(findobj('Tag','fl_lse_RadioButton_function'),'Value')==1
  switch get(findobj('Tag','fl_lse_PopupMenu_ball'),'Value')  
    case 1
      oscstr='osc';
    case 2 
      p=get(findobj('Tag','fl_lse_EditText_power'),'String');
      oscstr=strcat('l',p);
    case 3
      oscstr='linfty';
  end 
else
  return
end

function advancedsettings(Nx_n,Ny_n,sig_n,sig_nname)
J_max=floor(log(.5*Nx_n)/log(2));
J=floor(J_max/2);
a=1;
a_min=1;
A=floor(.25*Nx_n);
A_max=floor(.5*Nx_n);
eta_n=1./Nx_n;
fl_callwindow('Fig_gui_fl_lse','gui_fl_lse');
set(findobj('Tag','Fig_gui_fl_lse'),'UserData');
set(findobj('Tag','fl_lse_StaticText_sig_nname'),'String',sig_nname);
str=['[',num2str(Ny_n),' x ',num2str(Nx_n),']'];
set(findobj('Tag','fl_lse_EditText_size'),'String',str); 
set(findobj('Tag','fl_lse_StaticText_min'),'String','min size');
set(findobj('Tag','fl_lse_EditText_min'),'Style','edit');
set(findobj('Tag','fl_lse_EditText_min'),'Max',A_max);
set(findobj('Tag','fl_lse_EditText_min'),'String',a);
set(findobj('Tag','fl_lse_Slider_min'),'Max',A_max);
set(findobj('Tag','fl_lse_Slider_min'),'Value',a);
set(findobj('Tag','fl_lse_Slider_min'),'Enable','on');
set(findobj('Tag','fl_lse_StaticText_max'),'String','max size');
set(findobj('Tag','fl_lse_EditText_max'),'Style','edit');
set(findobj('Tag','fl_lse_EditText_max'),'Max',A_max);
set(findobj('Tag','fl_lse_EditText_max'),'String',A);
set(findobj('Tag','fl_lse_Slider_max'),'Max',A_max);
set(findobj('Tag','fl_lse_Slider_max'),'Value',A);
set(findobj('Tag','fl_lse_Slider_max'),'Enable','on');
set(findobj('Tag','fl_lse_StaticText_size_nb'),'String','# of scales');
set(findobj('Tag','fl_lse_EditText_size_nb'),'Style','edit');
set(findobj('Tag','fl_lse_EditText_size_nb'),'Max',J_max); 
set(findobj('Tag','fl_lse_EditText_size_nb'),'String',J); 
set(findobj('Tag','fl_lse_Slider_size_nb'),'Enable','on');
set(findobj('Tag','fl_lse_Slider_size_nb'),'Max',J_max); 
set(findobj('Tag','fl_lse_Slider_size_nb'),'Value',J);
set(findobj('Tag','fl_lse_PopupMenu_progression'),'Style','popupmenu');
set(findobj('Tag','fl_lse_PopupMenu_progression'),'String',{'linear','logarithmic','decimated'});
set(findobj('Tag','fl_lse_PopupMenu_ball'),'Style','popupmenu');
set(findobj('Tag','fl_lse_PopupMenu_ball'),'Enable','on');

function [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input
fl_clearerror;
[sig_nname flag_error]=fl_get_input('vector');
% if it is not a vector, check if it is cwt struct
if flag_error
  [cwtname flag_error]=fl_get_input('cwt');
  % if it is not a cwt struct, that's all very bad !
  if flag_error
    fl_warning('input signal must be a vector or a cwt !');
    sig_n=0;
    sig_nname='';
    Nx_n=0;
    Ny_n=0;
    return;
  end
  eval(['global ' cwtname]);
  eval(['cwt_struct=' cwtname ';']);
  cwtsettings(cwt_struct,cwtname);
  sig_n=0;
  sig_nname='';
  Nx_n=0;
  Ny_n=0;
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

% mdzq1dbasicsettings
function [q,J,min_size,max_size,partstr]=mdzq1dbasicsettings(Nx_n,Ny_n)
q=[-10.:.1:10.];
J=floor(log(Nx_n*Ny_n)/log(2.));
min_size=1.;
max_size=2.^(J-1);
partstr='logpart';

% fczq1dbasicsettings
function [q,J,min_size,max_size,progstr,oscstr]=fczq1dbasicsettings(Nx_n,Ny_n)
q=[-10.:.1:10.];
J=floor(log(Nx_n*Ny_n)/log(2.));
min_size=1.;
max_size=2.^(J-1);
progstr='lin';
oscstr='osc';

% fl1dbasicsettings
function [N,lrstr,title,xlabel,ylabel]=fl1dbasicsettings
N=200;
lrstr='ls';
title='Legendre spectrum';
xlabel='Hoelder exponents: \alpha';
ylabel='spectrum: f_l(\alpha)';
