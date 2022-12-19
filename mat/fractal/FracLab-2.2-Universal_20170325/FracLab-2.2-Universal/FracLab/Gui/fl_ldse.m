function [outputname]=fl_ldse(fl_string,fl_whos)
% Callback functions for GUI - large deviation spectrum estimation (ldse)
%
%   Large deviation spectrum estimation fltool Figure.
%
%   1.  Input Data
%
%   The input data can be any highlighted  structure of the input list
%   ListBox of the main fltool  Figure: either a real vector or a matrix
%   of size  [J,N_n] or [N_n,J] or a  cwt structure (see fl_cwt  help for
%   details of this structure).  It is selected when opening this  Figure
%   from the corresponding UiMenu of  the main  fltool    Figure, or   by
%   using the   refresh PushButton.  When the type of the  highlighted
%   structure does not match with the authorized types, an error  message
%   is displayed in the message StaticText  of the main  fltool Figure.
%   If a vector or a matrix is highlighted, it can be  considered as a
%   measure or as a function by selecting the  measure or the function
%   RadioButton.  If a cwt structure  is highlighted, it can only  be
%   considered as  the  result of  continuous  wavelet  transformation, on
%   which the coarse  grain Hoelder exponents  are estimated  and the
%   RadioButtons measure or  function are disabled.  The name of the input
%   data and its  size (or the  size of the coeff matrix of the cwt
%   structure) are displayed in two StaticText just below.
%
%   2.  UIcontrols
%
%   2.1.  Control parameters
%
%   o  min size (or min frequency): strictly positive real scalar
%      It  is  initialized to  S_min=1   (or  to the  minimum  frequency
%      f_min of the frequency vector of the cwt structure) and be changed
%      by selecting any particular  value within bounds 1 and
%      min(S_max,2^j_max),    where j_max=floor(log2(.5*N_n))   and N_n is
%      the  length of the  signal, using the corresponding Slider (or
%      PopupMenu  when  progression PopupMenu is on  'decimated') or
%      directly   by editing the  EditText.     When cwt RadioButton  is
%      selected, the EditText becomes  StaticText and the Slider or
%      PopupMenu is disabled.
%
%   o  max size (or max frequency): strictly positive real scalar
%      It is initialized   to S_max=floor(.5*j_max) (or to  the  maximum
%      frequency f_max  of the   frequency  vector of  the  cwt structure)
%      and be changed by  selecting any  particular value within bounds
%      S_min       and     2^j_max,           where
%      j_max=floor(log2(.5*N_n))  and  N_n is   the  length of  the
%      signal,   using the      corresponding Slider   (or   PopupMenu
%      when progression  PopupMenu is on  'decimated') or directly by
%      editing the  EditText.  When cwt  RadioButton  is selected, the
%      EditText becomes StaticText and the Slider or PopupMenu is
%      disabled.
%
%   o  number of scales (or number of voices): strictly positive real
%      (integer) scalar.
%      It is initialized to  J=floor(.5*j_max) (or to  the length of the
%      frequency     vector    of the    cwt     structure),  where
%      j_max=floor(log2(.5*N_n))  and  N_n  is   the length of  the
%      signal, and  can be changed  by selecting any particular  value
%      within bounds   1 and j_max   using  the  corresponding Slider  (or
%      PopupMenu when  progression PopupMenu    is on  'decimated')   or
%      directly by   editing   the EditText. When    cwt  RadioButton is
%      selected, the EditText becomes StaticText  and the Slider or
%      PopupMenu is disabled.
%
%   o  progression: string.
%      It initialized   to 'linear'  and  can  be changed  by  selecting
%      strings 'logarithmic'  or  'decimated'  in the corresponding
%      PopupMenu.  When   cwt RadioButton  is   selected,  the PopupMenu
%      becomes StaticText and set to 'logarithmic'.
%
%   o  ball (or oscillation): string.
%      When   measure   RadioButton  is  selected,   it  initialized to
%      'centered'  and    can   be   changed  by  selecting strings
%      'asymmetric' or 'star'  in the corresponding PopupMenu. When
%      function RadioButton  is  selected, it  initialized to 'osc' and
%      can be changed by selecting  strings 'lp' or 'linfty' in the
%      corresponding  PopupMenu.  When cwt RadioButton  is selected, the
%      PopupMenu is disabled.
%
%   o  power: strictly positive real scalar.
%      When function  RadioButton is selected and  when oscillation
%      PopupMenu is on 'lp', both EditText and Slider are enabled. It is
%      initialized to 2  and can be changed  by selecting any particular
%      value within bounds 1 and 10  using the corresponding Slider or
%      directly by editing the EditText.
%
%   o  density: string.
%      It is initialized to 'continuous' and can be changed by selecting
%      strings 'discrete'  (not  implemented yet), 'wavelets'  (not
%      implemented yet) or 'parametric'  (not  implemented yet) in   the
%      corresponding PopupMenu.
%
%   o  kernel: string.
%      It is initialized  to 'gaussian' and can  be changed by selecting
%      strings    'box',      'triangle',     'mollifier' or
%      'epanechnikov' in the corresponding PopupMenu.
%
%   o  adaptation:  string    and stricly positive    real scalar.
%      It is initialized to  'maxdev'  and can  be changed by  selecting
%      strings 'manual',  'double kernel'  (not implemented yet) or
%      'diagonal' in the  corresponding PopupMenu.  When PopupMenu is on
%      'manual', both EditText and Slider are enabled. It is initialized
%      to 0.1  and can be   changed by  selecting any  particular  value
%      within bounds 0.0 and 1.0  using the corresponding Slider or
%      directly by editing the EditText.
%
%   2.2.  Computation
%
%   o  Compute exponents :  PushButton.
%      Runs  coarse Hoelder exponents  estimation with parameters set as
%      described above.  It calls the  built-in C-LAB routines mch1d  if
%      RadioButton     measure   is  on,   fch1d     if RadioButton
%      function is on   or  matlab  routine wch1d  if   RadioButton cwt is
%      on.
%
%   o  Compute :  PushButton.
%      Runs  large deviation spectrum  estimation with parameters set as
%      described above.  It calls  the built-in C-LAB routines mcfg1d if
%      RadioButton    measure    is   on,  fcfg1d   if  RadioButton
%      function is on or  matlab routine wcfg1d  if RadioButton cwt is on.
%
%   o  Help : PushButton.
%      Calls this help.
%
%   o  Close : PushButton.
%      Closes the large deviation spectrum estimation Figure and returns
%      to the main fltool Figure.
%   3.  Outputs
%
%   The output of the coarse grain Hoelder estimation  is a matrix of
%   size[J,N_n].The output  of the large  deviation spectrum estimation is
%   a graph structure with yields as follows:
%
%   o  graph.data1: real vector [1,N]
%      Contains the estimated Hoelder exponents.
%
%   o  graph.data2 : real matrix [J,N]
%      Contains the estimated spectra.
%
%   o  graph.title : string
%      Contains the title.
%
%   o  graph.xlabel : string
%      Contains the xlabel.
%
%   o  graph.ylabel : string
%      Contains the ylabel.
%
%   4.  See also:
%
%   mcfg1d, fcfg1d, cfg1d, fch1d, mch1d, cwt1D, wch1d, wcfg1d.

% Author Christope Canus, February 1998
% Modified by Pierrick Legrand, January 2005

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
    % mch1d basicsetting 
    [S_min,S_max,J,progstr,ballstr]=mch1dbasicsettings; 
    % cfg1d basicsetting 
    [N,epsilon,contstr,precstr,kernstr,normstr,xlabel,ylabel]=cfg1dbasicsettings;
    current_mouse_ptr=fl_waiton;
    % call of the C_LAB routine: mcfg1d 
    [alpha,fg_alpha,pc_alpha,epsilon_star]=...
        mcfg1d(sig_n,[S_min,S_max,J],progstr,ballstr,...
        N,zeros(1,N),contstr,precstr,kernstr,normstr); 
    fl_waitoff(current_mouse_ptr); 
    % set title
    title=['Large deviation spectrum with (cst) precision: \epsilon_\eta=',num2str(epsilon_star(1)),' and (min) scale: \eta=\eta_n=',num2str(1./(Nx_n*Ny_n))];
    % make outputname
    prefix=['mcfg1d_' sig_nname];
    outputname=fl_findname(prefix,fl_whos);
    % make varname global
    eval(['global ' outputname]);
    % make global cell and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fg_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    
    chaine=['[',outputname,'.data1,',outputname,'.data2]=mcfg1d(',...
        sig_nname,',[',num2str(S_min),',',num2str(S_max),',',num2str(J),...
        '],''',num2str(progstr),...
        ''',''',num2str(ballstr),''',',num2str(N),...
        ',[',num2str(zeros(1,N)),'],''',num2str(contstr),''',''',...
        num2str(precstr),...
        ''',''',num2str(kernstr),''',''',num2str(normstr),''');'];
    fl_diary(chaine);
    
    % add varname to list
    fl_addlist(0,outputname); 
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
    % fch1d basicsetting 
    [S_min,S_max,J,progstr,oscstr]=fch1dbasicsettings; 
    % cfg1d basicsetting 
    [N,epsilon,contstr,precstr,kernstr,normstr,xlabel,ylabel]=cfg1dbasicsettings;
    current_mouse_ptr=fl_waiton;
    % call of the C_LAB routine  
    [alpha,fg_alpha,pc_alpha,epsilon_star]=...
        fcfg1d(sig_n,[S_min,S_max,J],progstr,oscstr,...
        N,zeros(1,200),contstr,precstr,kernstr,normstr);
    fl_waitoff(current_mouse_ptr); 
    % set title
    title=['Large deviation spectrum with (cst) precision: \epsilon_\eta=',num2str(epsilon_star(1)),' and (min) scale: \eta=\eta_n=',num2str(1./(Nx_n*Ny_n))];
    % make outputname
    prefix=['fcfg1d_' sig_nname]; 
    outputname=fl_findname(prefix,fl_whos);
    % make varname global
    eval(['global ' outputname]);
    % make global cell and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fg_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
    
    chaine=['[',outputname,'.data1,',outputname,'.data2]=fcfg1d(',...
        sig_nname,',[',num2str(S_min),',',num2str(S_max),',',num2str(J),...
        '],''',num2str(progstr),...
        ''',''',num2str(oscstr),''',',num2str(N),...
        ',[',num2str(zeros(1,200)),'],''',num2str(contstr),''',''',...
        num2str(precstr),...
        ''',''',num2str(kernstr),''',''',num2str(normstr),''');'];
    fl_diary(chaine);
    
    % add varname to list
    fl_addlist(0,outputname);  
    % measure advanced 
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
    set(findobj('Tag','RadioButton_cwt'),'Enable','off'); 
    set(findobj('Tag','RadioButton_cwt'),'Value',0);
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
    set(findobj('Tag','RadioButton_cwt'),'Enable','off'); 
    set(findobj('Tag','RadioButton_cwt'),'Value',0);  
    set(findobj('Tag','StaticText_ball'),'String','oscillation');
    set(findobj('Tag','PopupMenu_ball'),'String',{'osc','lpnorm','linfty norm'});
  case 'refresh'
    if get(findobj('Tag','RadioButton_measure'),'Value')==1
      fl_ldse('madvanced');
    else
      fl_ldse('fadvanced');
    end
    % measure
  case 'radiobutton_measure'
    if get(findobj('Tag','RadioButton_measure'),'Value')==0
      set(findobj('Tag','RadioButton_measure'),'Value',1);
    end
    set(findobj('Tag','RadioButton_function'),'Value',0);
    set(findobj('Tag','StaticText_ball'),'String','ball'); 
    set(findobj('Tag','PopupMenu_ball'),'String',{'centered','asymmetric','star'});
    set(findobj('Tag','EditText_power'),'Enable','off');
    set(findobj('Tag','Slider_power'),'Enable','off');
    % function
  case 'radiobutton_function' 
    if get(findobj('Tag','RadioButton_function'),'Value')==0
      set(findobj('Tag','RadioButton_function'),'Value',1);
    end
    set(findobj('Tag','RadioButton_measure'),'Value',0);
    set(findobj('Tag','StaticText_ball'),'String','oscillation');
    set(findobj('Tag','PopupMenu_ball'),'String',{'osc','lp norm','linfty norm'});
    if get(findobj('Tag','PopupMenu_ball'),'Value')==2 
      set(findobj('Tag','EditText_power'),'Enable','on');
      set(findobj('Tag','Slider_power'),'Enable','on');
    end 
    % cwt
  case 'cwt'  
    if get(findobj('Tag','RadioButton_cwt'),'Value')==0
      set(findobj('Tag','RadioButton_cwt'),'Value',1);
    end
    % minimum size: S_min 
  case 'edittext_min'
    if get(findobj('Tag','PopupMenu_progression'),'Value')~=3
      S_min=str2num(get(gcbo,'String')); 
      S_min=gui_fl_fgse_fix(S_min,100);
      S_max=str2num(get(findobj('Tag','EditText_max'),'String'));
      S_min=gui_fl_fgse_trunc(S_min,1.,S_max);  
      set(gcbo,'String',S_min);
      set(findobj('Tag','Slider_min'),'Value',S_min);
    end
  case 'slider_min'
    if get(findobj('Tag','PopupMenu_progression'),'Value')~=3
      S_min=get(gcbo,'Value'); 
      S_min=gui_fl_fgse_fix(S_min,100); 
      S_max=str2num(get(findobj('Tag','EditText_max'),'String')); 
      S_min=gui_fl_fgse_trunc(S_min,1.,S_max); 
      set(gcbo,'Value',S_min);
      set(findobj('Tag','EditText_min'),'String',num2str(S_min)); 
    else
      j_min=get(gcbo,'Value')-1;
      j_max=get(findobj('Tag','Slider_max'),'Value')-1; 
      j_min=gui_fl_fgse_trunc(j_min,0.,j_max); 
      set(gcbo,'Value',j_min+1);
      set(findobj('Tag','EditText_min'),'String',num2str(2^j_min)); 
      set(findobj('Tag','Slider_scale_nb'),'Value',j_max-j_min+1);
      set(findobj('Tag','EditText_scale_nb'),'String',j_max-j_min+1); 
    end
    % maximum size: S_max
  case 'edittext_max'
    if get(findobj('Tag','PopupMenu_progression'),'Value')~=3
      S_max=str2num(get(gcbo,'String'));
      S_max=gui_fl_fgse_fix(S_max,100); 
      S_min=str2num(get(findobj('Tag','EditText_min'),'String'));
      S_max=gui_fl_fgse_trunc(S_max,S_min,.5/eta_n);
      set(gcbo,'String',S_max);
      set(findobj('Tag','Slider_max'),'Value',S_max);
    end
  case 'slider_max'
    if get(findobj('Tag','PopupMenu_progression'),'Value')~=3
      S_max=get(gcbo,'Value');
      S_max=gui_fl_fgse_fix(S_max,100); 
      S_min=str2num(get(findobj('Tag','EditText_min'),'String'));
      S_max=gui_fl_fgse_trunc(S_max,S_min,.5/eta_n); 
      set(gcbo,'Value',S_max);
      set(findobj('Tag','EditText_max'),'String',S_max);
    else 
      j_max=get(gcbo,'Value')-1;
      j_min=get(findobj('Tag','Slider_min'),'Value')-1; 
      j_max=gui_fl_fgse_trunc(j_max,j_min,floor(log(.5/eta_n)/log(2))); 
      set(gcbo,'Value',j_max+1);
      set(findobj('Tag','EditText_max'),'String',num2str(2^j_max));
      set(findobj('Tag','Slider_scale_nb'),'Value',j_max-j_min+1); 
      set(findobj('Tag','EditText_scale_nb'),'String',j_max-j_min+1); 
    end
    % # of scales: J
  case 'edittext_scale_nb'
    J=str2num(get(gcbo,'String'));
    J=gui_fl_fgse_fix(J,1);
    J=gui_fl_fgse_trunc(J,1,64);
    set(gcbo,'String',J);
    set(findobj('Tag','Slider_scale_nb'),'Value',J);
    if get(findobj('Tag','PopupMenu_progression'),'Value')==3
      j_min=get(findobj('Tag','Slider_min'),'Value')-1; 
      set(findobj('Tag','EditText_max'),'String',2^(j_min+J-1));
      set(findobj('Tag','Slider_max'),'Value',j_min+J);
    end;
  case 'slider_scale_nb'
    J=get(gcbo,'Value');
    J=gui_fl_fgse_fix(J,1);
    set(findobj('Tag','EditText_scale_nb'),'String',J);
    if get(findobj('Tag','PopupMenu_progression'),'Value')==3
      j_min=get(findobj('Tag','Slider_min'),'Value')-1; 
      set(findobj('Tag','EditText_max'),'String',2^(j_min+J-1));
      set(findobj('Tag','Slider_max'),'Value',j_min+J);
    end;  
    % progession: progstr
  case 'popupmenu_progression'  
    switch get(findobj('Tag','PopupMenu_progression'),'Value')  
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
  case 'popupmenu_ball'  
    if get(findobj('Tag','RadioButton_function'),'Value')==1 
      if get(findobj('Tag','PopupMenu_ball'),'Value')==2 
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
    p=gui_fl_fgse_fix(p,100);
    p=gui_fl_fgse_trunc(p,1.,10.);  
    set(gcbo,'String',p);
    set(findobj('Tag','Slider_min'),'Value',p);
  case 'slider_power'
    p=get(gcbo,'Value');
    p=gui_fl_fgse_fix(p,100);
    p=gui_fl_fgse_trunc(p,1.,10.);
    set(gcbo,'Value',p);
    set(findobj('Tag','EditText_power'),'String',num2str(p));
    % compute exponents
  case 'compute_exponents'
    if get(findobj('Tag','RadioButton_measure'),'Value')==1
      % get the input measure: mu_n
      [mu_nname,mu_n]=getinputmu_n;
      % mch1d settings 
      [S_min,S_max,J,progstr,ballstr]=mch1dsettings;
      current_mouse_ptr=fl_waiton;
      % call of the C_LAB routine: mch1d 
      [alpha_eta_x,eta,x]=mch1d(mu_n,[S_min,S_max,J],progstr,ballstr);
      fl_waitoff(current_mouse_ptr);
      prefix=['mch1d_' mu_nname];
      output=alpha_eta_x;
    end
    if get(findobj('Tag','RadioButton_function'),'Value')==1
      % get the input function: F_n
      [F_nname,F_n]=getinputF_n;
      % fch1d settings 
      [S_min,S_max,J,progstr,oscstr]=fch1dsettings; 
      % call of the C_LAB routine: fch1d 
      [alpha_eta_x,eta]=fch1d(F_n,[S_min,S_max,J],progstr,oscstr);
      prefix=['fch1d_' F_nname]; 
      output=alpha_eta_x;
    end
    if get(findobj('Tag','RadioButton_cwt'),'Value')==1  
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
    % density estimation
  case 'popupmenu_density'
    if ~(get(findobj('Tag','PopupMenu_density'),'Value')==1)
      fl_warning('Not Implemented Yet: Choose another');
      set(findobj('Tag','PopupMenu_density'),'Value',1);
    end
    % precision adaptation
  case 'popupmenu_precision'
    if get(findobj('Tag','PopupMenu_precision'),'Value')~=1
      set(findobj('Tag','EditText_precision'),'Enable','off');
      set(findobj('Tag','Slider_precision'),'Enable','off');
    else
      set(findobj('Tag','EditText_precision'),'Enable','on');
      set(findobj('Tag','Slider_precision'),'Enable','on');
    end
    if get(findobj('Tag','PopupMenu_precision'),'Value')==3
      fl_warning('Not implemented yet: Choose another');
    end
    if get(findobj('Tag','PopupMenu_precision'),'Value')==4
      fl_warning('Not implemented yet: Choose another');
    end 
    % precision adaptation: precision
  case 'edit_precision'
    e=str2num(get(gcbo,'String'));
    e=gui_fl_fgse_trunc(e,.0,1.);
    epsilon=e*ones(1,N);
    set(gcbo,'String',e);
    set(findobj('Tag','Slider_precision'),'Value',e);
  case 'slider_precision'
    e=get(gcbo,'Value');
    set(gcbo,'String',e);
    e=gui_fl_fgse_fix(e,10000);
    epsilon=e*ones(1,N);
    set(findobj('Tag','EditText_precision'),'String',e);
    % compute
  case 'compute'
    % get the input signal
    if get(findobj('Tag','RadioButton_measure'),'Value')==1
      % get the input measure: mu_n
      [mu_nname,mu_n]=getinputmu_n;  
      % mch1d settings 
      [S_min,S_max,J,progstr,ballstr]=mch1dsettings;
      prefix=['mcfg1d_' mu_nname];
    elseif get(findobj('Tag','RadioButton_function'),'Value')==1
      % get the input function: F_n
      [F_nname,F_n]=getinputF_n;
      % fch1d settings 
      [S_min,S_max,J,progstr,oscstr]=fch1dsettings; 
      prefix=['fcfg1d_' F_nname];
    elseif get(findobj('Tag','RadioButton_cwt'),'Value')==1
      % get the input cwt: cwt_struct
      [cwt_structname,cwt_struct]=getinputcwt_struct;
      prefix=['wcfg1d_' cwt_structname];
    end;
    % get the kern string
    switch get(findobj('Tag','PopupMenu_kern'),'Value')  
      case 1
	kernstr='box';
      case 2
	kernstr='tri';
      case 3
	kernstr='mol';
      case 4
	kernstr='epa';
      case 5
	kernstr='gau';
    end
    % get the precision adaptation string: adapstr
    if get(findobj('Tag','PopupMenu_precision'),'Value')==1
      % set precision scalar: e
      e=str2num(get(findobj('Tag','EditText_precision'),'String'));  
      % set precision vector: epsilon
      epsilon=e*ones(1,N); 
      % set title
      title=['large deviation spectrum with (cst) precision: \epsilon=',num2str(e)];
    elseif get(findobj('Tag','PopupMenu_precision'),'Value')==2
      % set precision vector: epsilon
      epsilon=zeros(1,N); 
      % set title
      title='Large Deviation spectrum with adapted (maxdev) precision';
    elseif get(findobj('Tag','PopupMenu_precision'),'Value')==3
      fl_warning('Not implemented yet: Choose another');
      return
      % set precision vector:e
      % e=[.05:.01:.15];
      % pause(0);
      % current_mouse_ptr=fl_waiton;
      % call of the MATLAB routine
      % [alpha,fg_alpha]=MFAG_epsilon_eta(mu_n,N,a,e,1);
      % fl_waitoff(current_mouse_ptr);
      % set title
      % title='Large Deviation spectrum (diagonal method)';
    elseif get(findobj('Tag','PopupMenu_precision'),'Value')==4
      fl_warning('Not implemented yet: Choose another');
      return
    end
    current_mouse_ptr=fl_waiton;
    % call of the C-LAB routine or matlab function
    if get(findobj('Tag','RadioButton_measure'),'Value')==1
      % call of the C-LAB routine: mcfg1d
      [alpha,fg_alpha]=mcfg1d(mu_n,[S_min,S_max,J],progstr,ballstr,N,epsilon,contstr,adapstr,kernstr,normstr);
    elseif get(findobj('Tag','RadioButton_function'),'Value')==1
      % call of the C-LAB routine: mcfg1d
      [alpha,fg_alpha]=fcfg1d(F_n,[S_min,S_max,J],progstr,oscstr,N,epsilon,contstr,adapstr,kernstr,normstr);
    elseif get(findobj('Tag','RadioButton_cwt'),'Value')==1 
      % call of the matlab function: wcfg1d
      [alpha,fg_alpha]=wcfg1d(cwt_struct,N,epsilon,contstr,adapstr,kernstr,normstr);
    end
    fl_waitoff(current_mouse_ptr); 
    % make outputname
    outputname=fl_findname(prefix,fl_whos);
    eval(['global ' outputname]); 
    % set xlabel, ylabel
    xlabel='Hoelder exponents: \alpha';
    ylabel='spectrum: f_{g,\eta}^{c,\epsilon}(\alpha)';
    % make global structure and put it in varname
    eval ([outputname '= struct (''type'',''graph'',''data1'',alpha,''data2'',fg_alpha,''title'',title,''xlabel'',xlabel,''ylabel'',ylabel);']);
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

% fix
function fix_x=gui_fl_fgse_fix(x,ten_power)
fix_x=round(x.*ten_power)/ten_power;

% setlinlog
function setlinlog(eta_n)
J=floor(log(.5/eta_n)/log(2));
j_min=0;
j_max=floor(J/2);
set(findobj('Tag','EditText_min'),'Min',2^j_min);
set(findobj('Tag','EditText_min'),'Max',2^J);
set(findobj('Tag','EditText_min'),'Value',2^j_min);
set(findobj('Tag','Slider_min'),'Style','Slider');
set(findobj('Tag','Slider_min'),'Min',2^j_min);
set(findobj('Tag','Slider_min'),'Max',2^J);
set(findobj('Tag','Slider_min'),'Value',2^j_min);
set(findobj('Tag','EditText_max'),'Min',2^j_min);
set(findobj('Tag','EditText_max'),'Max',2^J);
set(findobj('Tag','EditText_max'),'Value',2^j_max);
set(findobj('Tag','Slider_max'),'Style','Slider');
set(findobj('Tag','Slider_max'),'Min',2^j_min);
set(findobj('Tag','Slider_max'),'Max',2^J);
set(findobj('Tag','Slider_max'),'Value',2^j_max);
set(findobj('Tag','EditText_scale_nb'),'Min',2^j_min);
set(findobj('Tag','EditText_scale_nb'),'Max',min(2^J,128));
set(findobj('Tag','EditText_scale_nb'),'String',j_max);
set(findobj('Tag','Slider_scale_nb'),'Style','Slider');
set(findobj('Tag','Slider_scale_nb'),'Min',2^j_min); 
set(findobj('Tag','Slider_scale_nb'),'Max',min(2^J,128));
set(findobj('Tag','Slider_scale_nb'),'Value',j_max);
	
% setdec
function setdec(eta_n)
J=floor(log(.5/eta_n)/log(2)); 
j_min=0;
j_max=floor(J/2);
set(findobj('Tag','EditText_min'),'Min',2^j_min);
set(findobj('Tag','EditText_min'),'Max',2^J);
set(findobj('Tag','EditText_min'),'String','1');
for j=j_min:J
  varcell{j+1}=['2^(' num2str(j) ')'];
end
set(findobj('Tag','Slider_min'),'String',varcell);
set(findobj('Tag','Slider_min'),'Style','popupmenu');
set(findobj('Tag','Slider_min'),'Min',j_min+1);
set(findobj('Tag','Slider_min'),'Max',J);
set(findobj('Tag','Slider_min'),'Value',j_min+1);
set(findobj('Tag','EditText_max'),'Min',2^j_min);
set(findobj('Tag','EditText_max'),'Max',2^J);
set(findobj('Tag','EditText_max'),'String',2^j_max); 
for j=j_min:J
  varcell{j+1}=['2^(' num2str(j) ')'];
end
set(findobj('Tag','Slider_max'),'String',varcell);
set(findobj('Tag','Slider_max'),'Style','popupmenu');
set(findobj('Tag','Slider_max'),'Min',j_min+1);
set(findobj('Tag','Slider_max'),'Max',J);
set(findobj('Tag','Slider_max'),'Value',j_max+1);
set(findobj('Tag','EditText_scale_nb'),'Min',j_min+1);
set(findobj('Tag','EditText_scale_nb'),'Max',J+1);
set(findobj('Tag','EditText_scale_nb'),'String',j_max+1);
for j=1:J
  varcellJ{j}=num2str(j);
end
set(findobj('Tag','Slider_scale_nb'),'String',varcellJ);
set(findobj('Tag','Slider_scale_nb'),'Style','popupmenu');
set(findobj('Tag','Slider_scale_nb'),'Min',1);
set(findobj('Tag','Slider_scale_nb'),'Max',J);
set(findobj('Tag','Slider_scale_nb'),'Value',j_max+1);
	
% getinputmu_n
function [mu_nname,mu_n]=getinputmu_n
mu_nname=get(findobj('Tag','StaticText_sig_nname'),'String');
eval(['global ' mu_nname]);
eval(['mu_n=' mu_nname ';']); 
if ~isempty(find(mu_n<0.))
  fl_warning('Take normalized absolute values increments');
  mu_n=abs(diff(mu_n))./sum(abs(diff(mu_n)));
end 

% getinputF_n
function [F_nname,F_n]=getinputF_n
F_nname=get(findobj('Tag','StaticText_sig_nname'),'String');
eval(['global ' F_nname]);
eval(['F_n=' F_nname ';']);
m=min(F_n);
M=max(F_n);
if m~=0. & M~=1.
  F_n=(F_n-m)/(M-m);
end

% getinputcwt_struct
function [cwt_structname,cwt_struct]=getinputcwt_struct
cwt_structname=get(findobj('Tag','StaticText_sig_nname'),'String');
eval(['global ' cwt_structname]);
eval(['cwt_struct=' cwt_structname ';']);

% mch1dsettings
function [S_min,S_max,J,progstr,ballstr]=mch1dsettings
S_min=str2num(get(findobj('Tag','EditText_min'),'String'));
S_max=str2num(get(findobj('Tag','EditText_max'),'String')); 
J=str2num(get(findobj('Tag','EditText_scale_nb'),'String')); 
switch get(findobj('Tag','PopupMenu_progression'),'Value')
  case 1
  progstr='lin';
case 2
  progstr='log';
case 3
  progstr='dec';
  S_min=2^(floor(log(S_min)/log(2)));
  S_max=2^(floor(log(S_max)/log(2)));
  J=floor(log(S_max/S_min)/log(2))+1;
end 
if get(findobj('Tag','RadioButton_measure'),'Value')==1
  switch get(findobj('Tag','PopupMenu_ball'),'Value')  
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

% fch1dsettings
function [S_min,S_max,J,progstr,oscstr]=fch1dsettings
S_min=str2num(get(findobj('Tag','EditText_min'),'String'));
S_max=str2num(get(findobj('Tag','EditText_max'),'String')); 
J=str2num(get(findobj('Tag','EditText_scale_nb'),'String')); 
switch get(findobj('Tag','PopupMenu_progression'),'Value')  
case 1
  progstr='lin';
case 2
  progstr='log';
case 3
  progstr='dec';
  S_min=2^(floor(log(S_min)/log(2)));
  S_max=2^(floor(log(S_max)/log(2)));
  J=floor(log(S_max/S_min)/log(2))+1;
end 
if get(findobj('Tag','RadioButton_function'),'Value')==1
  switch get(findobj('Tag','PopupMenu_ball'),'Value')  
    case 1
      oscstr='osc';
    case 2 
      p=get(findobj('Tag','EditText_power'),'String');
      oscstr=strcat('l',p);
    case 3
      oscstr='linfty';
  end 
else
  return
end

% wch1d
function [alpha_a]=wch1d(cwt_struct)
C_a_x=cwt_struct.coeff;
a=cwt_struct.scale; 
mod_C_a_x_2=real(C_a_x.*conj(C_a_x));
[J N]=size(C_a_x);
for j=2:J  
  m=min(mod_C_a_x_2(j,:)); 
  M=max(mod_C_a_x_2(j,:));
  mod_C_a_x_2(j,:)=(mod_C_a_x_2(j,:)-m/2)/(M-m);
  alpha_a(j,:)=log(mod_C_a_x_2(j,:))./log(a(j)/N);
  for k=1:N
    if alpha_a(j,k)>2;
      alpha_a(j,k)=2;
    end
  end
end

% wcfg1d
function [alpha,fgc_alpha]=wcfg1d(cwt_struct,N,epsilon,contstr,adapstr,kernstr,normstr)
C_a_x=abs(cwt_struct.coeff);
a=cwt_struct.scale;
mod_C_a_x_2=real(C_a_x.*conj(C_a_x));
[J N_n]=size(C_a_x);
for j=2:J  
  m=min(mod_C_a_x_2(j,:)); 
  M=max(mod_C_a_x_2(j,:));
  mod_C_a_x_2(j,:)=(mod_C_a_x_2(j,:)-m/2)/(M-m);
  alpha_a(j,:)=log(mod_C_a_x_2(j,:))./log(a(j)/N_n);
  for k=1:N_n
    if alpha_a(j,k)>2;
      alpha_a(j,k)=2;
    end
  end
end
[alpha,fgc_alpha]=cfg1d(alpha_a,a'/N_n,(linspace(0,1-1/N_n,N_n)),N,epsilon,contstr,adapstr,kernstr,'suppdf');
function cwtsettings(cwt_struct,cwtname)
fl_callwindow('Fig_gui_fl_ldse','gui_fl_ldse');
set(findobj('Tag','StaticText_sig_nname'),'String',cwtname);
set(findobj('Tag','RadioButton_measure'),'Value',0); 
set(findobj('Tag','RadioButton_measure'),'Enable','off');
set(findobj('Tag','RadioButton_function'),'Value',0);  
set(findobj('Tag','RadioButton_function'),'Enable','off');
set(findobj('Tag','RadioButton_cwt'),'Enable','on'); 
set(findobj('Tag','RadioButton_cwt'),'Value',1);
[J N]=size(cwt_struct.coeff);
str=['[',num2str(J),' x ',num2str(N),']'];
set(findobj('Tag','EditText_size'),'String',str); 
set(findobj('Tag','StaticText_min'),'String','min frequency');
set(findobj('Tag','EditText_min'),'Style','text');
set(findobj('Tag','EditText_min'),'String',cwt_struct.frequency(J));
set(findobj('Tag','Slider_min'),'Enable','off');
set(findobj('Tag','StaticText_max'),'String','max frequency');
set(findobj('Tag','EditText_max'),'Style','text');
set(findobj('Tag','EditText_max'),'String',cwt_struct.frequency(1));
set(findobj('Tag','Slider_max'),'Enable','off');
set(findobj('Tag','StaticText_scale_nb'),'String','# of voices');
set(findobj('Tag','EditText_scale_nb'),'Style','text');
set(findobj('Tag','EditText_scale_nb'),'String',J);
set(findobj('Tag','Slider_scale_nb'),'Enable','off');
set(findobj('Tag','PopupMenu_progression'),'Style','text');
set(findobj('Tag','PopupMenu_progression'),'String','logarithmic');
set(findobj('Tag','PopupMenu_ball'),'Style','pushbutton');
set(findobj('Tag','PopupMenu_ball'),'Enable','off');

function advancedsettings(Nx_n,Ny_n,sig_n,sig_nname)
J_max=floor(log(.5*Nx_n)/log(2));
J=floor(J_max/2);
a=1;
a_min=1;
A=floor(.25*Nx_n);
A_max=floor(.5*Nx_n);
eta_n=1./Nx_n;
fl_callwindow('Fig_gui_fl_ldse','gui_fl_ldse');
set(findobj('Tag','Fig_gui_fl_ldse'),'UserData',eta_n);
set(findobj('Tag','StaticText_sig_nname'),'String',sig_nname);
str=['[',num2str(Ny_n),' x ',num2str(Nx_n),']'];
set(findobj('Tag','EditText_size'),'String',str); 
set(findobj('Tag','StaticText_min'),'String','min size');
set(findobj('Tag','EditText_min'),'Style','edit');
set(findobj('Tag','EditText_min'),'Max',A_max);
set(findobj('Tag','EditText_min'),'String',a);
set(findobj('Tag','Slider_min'),'Max',A_max);
set(findobj('Tag','Slider_min'),'Value',a);
set(findobj('Tag','Slider_min'),'Enable','on');
set(findobj('Tag','StaticText_max'),'String','max size');
set(findobj('Tag','EditText_max'),'Style','edit');
set(findobj('Tag','EditText_max'),'Max',A_max);
set(findobj('Tag','EditText_max'),'String',A);
set(findobj('Tag','Slider_max'),'Max',A_max);
set(findobj('Tag','Slider_max'),'Value',A);
set(findobj('Tag','Slider_max'),'Enable','on');
set(findobj('Tag','StaticText_scale_nb'),'String','# of scales');
set(findobj('Tag','EditText_scale_nb'),'Style','edit');
set(findobj('Tag','EditText_scale_nb'),'Max',J_max); 
set(findobj('Tag','EditText_scale_nb'),'String',J); 
set(findobj('Tag','Slider_scale_nb'),'Enable','on');
set(findobj('Tag','Slider_scale_nb'),'Max',J_max); 
set(findobj('Tag','Slider_scale_nb'),'Value',J);
set(findobj('Tag','PopupMenu_progression'),'Style','popupmenu');
set(findobj('Tag','PopupMenu_progression'),'String',{'linear','logarithmic','decimated'});
set(findobj('Tag','PopupMenu_ball'),'Style','popupmenu');
set(findobj('Tag','PopupMenu_ball'),'Enable','on');

function [sig_n,sig_nname,Nx_n,Ny_n,flag_error]=get_input
fl_clearerror;
[sig_nname flag_error]=fl_get_input('vector');
if flag_error
  [cwtname flag_error]=fl_get_input('cwt'); 
  if flag_error
    fl_warning('input signal must be a vector or a cwt !');
    return
  end
  eval(['global ' cwtname]);
  eval(['cwt_struct=' cwtname ';']);
  cwtsettings(cwt_struct,cwtname);
  sig_n=0;
  sig_nname'';
  Nx_n=0;
  Ny_n=0;
  flag_error=1;
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

% mch1dbasicsettings
function [S_min,S_max,J,progstr,ballstr]=mch1dbasicsettings
S_min=1;
S_max=1;
J=1;
progstr='lin';
ballstr='asym';

% fch1dbasicsettings
function [S_min,S_max,J,progstr,oscstr]=fch1dbasicsettings
S_min=1;
S_max=1;
J=1;
progstr='lin';
oscstr='osc';

% cfg1dbasicsettings
function [N,epsilon,contstr,precstr,kernstr,normstr,xlabel,ylabel]=cfg1dbasicsettings
N=200;
epsilon=zeros(1,N);   
contstr='hkern'; 
precstr='maxdev';
kernstr='gau';
normstr='infsuppdf';  
xlabel='Hoelder exponents: \alpha';
ylabel='spectrum: f_{g,\eta}^{c,\epsilon_\eta}(\alpha)';
