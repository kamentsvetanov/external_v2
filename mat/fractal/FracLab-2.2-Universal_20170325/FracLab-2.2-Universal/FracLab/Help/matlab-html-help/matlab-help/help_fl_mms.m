%   fl_mms
%   Christophe Canus
%   March, 2nd 1998
%
%   Multifractal measures synthesis fltool Figure.
%
%   1.  UIcontrols
%
%   1.1.  Control parameters
%
%   o  resolution: strictly positive real (integer) scalar
%      It is initialized to n=7 (or to n=5 when 2d RadioButton is on) and
%      be changed by  selecting any particular value within bounds 1 and
%      n_max,  where  n_max is  such that the  resulting number of
%      intervals is not too big,  using the corresponding Slider or
%      directly by  editing the EditText.   The resulting number of
%      intervals is displayed  in  the subsequent StaticText.  When it  is
%      too big, an error message is displayed in the  message StaticText
%      of the main fltool Figure.
%
%   o  dimension: binary choice.
%      It is initialized to 1d RadioButton  on. When 2d RadioButton is on,
%      base y EditText and Slider are enabled.
%
%   o  base x: strictly positive real (integer) scalar.
%      It  is   initialized to  b_x=3  (or  to  b_x=2  when 2d RadioButton
%      is  on) and  can be  changed by  selecting  any particular value
%      within bounds  1 and 10.     The resulting number  of intervals  is
%      displayed in the preceeding  StaticText.  When it is too big, an
%      error message is  displayed in the message StaticText of the main
%      fltool Figure.
%
%   o  base y: strictly positive real (integer) scalar.
%      When 2d RadioButton  is on, it  is initialized to b_y=2  and can be
%      be changed by  selecting  any particular  value within bounds 1 and
%      10.  The resulting number of intervals is displayed in the
%      precceding StaticText.   When it is too  big, an error message  is
%      displayed in   the  message StaticText  of the   main fltool
%      Figure.
%
%   o  weights: strictly positive vector or matrix.
%      It is initialized to [.1 .3  .6] (or to  [.1 .2; .3 .4] when 2d
%      RadioButton is on) and can be changed to any particular vector of
%      length     b_x   (or    matrix   of    size  [b_xX b_y]). When the
%      vector length does not match to b_x (or when the matrix  size does
%      not match to[b_xX b_y]) , an error message is displayed  in the
%      message StaticText of the main fltool Figure.
%
%   o  deterministic - stochastic: binary choice.
%      It  is   initialized   to  deterministic  RadioButton  on.   When
%      stochastic  RadioButton   is  on,   canonical   CheckBox and
%      PopupMenu are enabled.
%
%   o  micro-canonical -  canonical: binary choice.
%
%      When  stochastic  RadioButton   is  on, it   is    initialized to
%      canonical CheckBox on.  In that case, canonical PopupMenu is
%      intialized to  'pertubated' and micro-canonical PopupMenu is
%      disabled.  It can be changed to  micro-canonical CheckBox on.  In
%      that case,   micro-canonical   PopupMenu     is  initialized to
%      'shuffled' and canonical PopupMenu is disabled.
%
%   o  micro-canonical: string.
%      When micro-canonical   CheckBox  is  on,  it    is    initialized
%      to 'shuffled' and can be  changed to 'stratified', using the
%      corresponding PopupMenu.
%
%   o  canonical: string.
%      When  canonical   CheckBox     is  on, it    is       initialized
%      to 'pertubated'   and   can  be    changed   to    'uniform' or
%      'lognormal', using the corresponding PopupMenu.
%
%   o  perturbation: stricly positive real scalar.
%      When    canonical  CheckBox   is    on    and  PopupMenu  is on
%      'pertubated', it  is initialized to 0.01  and can be changed by
%      selecting any particular value within bounds 0.0 and 1.0, using the
%      corresponding Slider or directly by editing the EditText.
%
%   o  standard deviation: stricly positive real scalar.
%      When    canonical   CheckBox   is   on    and  PopupMenu  is on
%      'lognormal',  it is initialized to 1   and can be changed by
%      selecting any particular value within  bounds 1e-05 and 5.0, using
%      the corresponding Slider or directly by editing the EditText.
%
%   o  theoretical partition function - Reyni exponents - multifractal
%      spectrum: choice.
%      In some   cases, theoretical partition   function, Reyni exponents
%      and multifractal  spectrum can be  computed, when corresponding
%      CheckBoxes are on.
%
%   1.2.  Computation
%
%   o  Compute:  PushButton.
%      Runs   multifractal measures  synthesis   with  parameters set as
%      described above.   It calls the  built-in C-LAB routines multim1d
%      if  RadioButton deterministic   (or  multim2d if RadioButton 2d is
%      on) or  smultim1d if RadioButton stochastic is on (or smultim2d if
%      RadioButton 2d is on).
%
%   o  Help: PushButton.
%      Calls this help.
%
%   o  Close: PushButton.
%      Closes the multifractal measures synthesis Figure and returns to
%      the main fltool Figure.
%
%   2.  Output Data
%
%   The output of the multifractal  measures synthesis is a vector of
%   length    b_x^n         (or       a   matrix       of        size
%   [b_x^nXb_y^n]). The output of the multifractal measures synthesis
%   theoretical  partition function, Reyni exponents or spectrum
%   computation is a graph structure.
%
%   3.  See also
%
%   binom,sbinom,multim1d,smulti1d,multim2d,smultim2d.
%
%   4.  References
%
%   "Multifractal Measures", Carl J. G. Evertsz and Benoit B. MandelBrot.
%   In Chaos and Fractals, New Frontiers of Science, Appendix B. Edited by
%   Peitgen, Juergens and Saupe, Springer Verlag, 1992 pages 921-953.
%
%   "A class of Multinomial Multifractal Measures with negative (latent)
%   values for the "Dimension" f(alpha)", Benoit B. MandelBrot. In
%   Fractals' Physical Origins and Properties, Proceeding of the Erice
%   Meeting, 1988. Edited by L. Pietronero, Plenum Press, New York, 1989
%   pages 3-29.
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

