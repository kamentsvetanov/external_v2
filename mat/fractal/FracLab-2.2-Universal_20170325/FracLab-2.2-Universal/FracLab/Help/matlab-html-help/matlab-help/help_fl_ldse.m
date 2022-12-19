%   fl_ldse
%   Christophe Canus
%   February, 28th 1998
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
%      It is  initialized to   S_min=1 (or   to the  minimum   frequency
%      f_min of the frequency vector of the cwt structure) and can be
%      changed by selecting  any particular value within bounds 1 and
%      min(S_max,2^j_max), where  j_max=floor(log2(.5*N_n)) and N_n  is
%      the length of  the signal, using the corresponding Slider (or
%      PopupMenu when   progression PopupMenu is  on 'decimated') or
%      directly  by   editing the  EditText.    When cwt  RadioButton is
%      selected, the EditText becomes  StaticText and the Slider or
%      PopupMenu is disabled.
%
%   o  max size (or max frequency): strictly positive real scalar
%      It is  initialized  to S_max=floor(.5*j_max) (or  to  the maximum
%      frequency  f_max of the  frequency   vector of the   cwt structure)
%      and can  be  changed  by selecting  any  particular value within
%      bounds      S_min       and   2^j_max,  where
%      j_max=floor(log2(.5*N_n))  and N_n   is  the length  of  the
%      signal,  using  the   corresponding  Slider    (or   PopupMenu
%      when progression  PopupMenu is on  'decimated') or directly by
%      editing the   EditText.  When cwt  RadioButton is  selected, the
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
%   3.  Output Data
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
%   4.  See also
%
%   mcfg1d, fcfg1d, cfg1d, fch1d, mch1d, cwt, wch1d, wcfg1d.
%
%   5.  References
%
%   To be published.
%

% This Software is ( Copyright INRIA . 1998 2009  1 )
% 
% INRIA  holds all the ownership rights on the Software. 
% The scientific community is asked to use the SOFTWARE 
% in order to test and evaluate it.
% 
% INRIA freely grants the right to use modify the Software,
% integrate it in another Software. 
% Any use or reproduction of this Software to obtain profit or
% for commercial ends being subject to obtaining the prior express
% authorization of INRIA.
% 
% INRIA authorizes any reproduction of this Software.
% 
%    - in limits defined in clauses 9 and 10 of the Berne 
%    agreement for the protection of literary and artistic works 
%    respectively specify in their paragraphs 2 and 3 authorizing 
%    only the reproduction and quoting of works on the condition 
%    that :
% 
%    - "this reproduction does not adversely affect the normal 
%    exploitation of the work or cause any unjustified prejudice
%    to the legitimate interests of the author".
% 
%    - that the quotations given by way of illustration and/or 
%    tuition conform to the proper uses and that it mentions 
%    the source and name of the author if this name features 
%    in the source",
% 
%    - under the condition that this file is included with 
%    any reproduction.
%  
% Any commercial use made without obtaining the prior express 
% agreement of INRIA would therefore constitute a fraudulent
% imitation.
% 
% The Software beeing currently developed, INRIA is assuming no 
% liability, and should not be responsible, in any manner or any
% case, for any direct or indirect dammages sustained by the user.
% 
% Any user of the software shall notify at INRIA any comments 
% concerning the use of the Sofware (e-mail : support.fraclab@inria.fr)
% 
% This file is part of FracLab, a Fractal Analysis Software

