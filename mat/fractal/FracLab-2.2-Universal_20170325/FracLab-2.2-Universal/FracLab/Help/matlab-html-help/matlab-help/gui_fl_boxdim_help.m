%   Box dimension.
%   Ina Taralova
%   January 23th 2001
%
%   Computes the box dimension of the graph of a 1d sampled function.  
%
%
%   1.  Usage of the corresponding command:
%
%
%      [dim,nb,taille,handlefig]=box_dimension(input_sig,Nmin,Nmax,reg,RegParam);
%
%
%   1.1.  Input parameters
%
%
%   o  input_sig : 1d: Real vector [1,N] 
%      Time samples of the signal to be analyzed.
%
%   o  Nmin : Integer in  [1,(floor(log2(N)))-1]
%
%      Lower size bound (lower length) of the boxes. When not
%      specified, this parameter is set to 1.
%
%   o  Nmax : Integer in  [Nmin,(floor(log2(N)))]
%
%      Upper size bound (upper length) of the boxes. When not
%      specified, this parameter is set to 5.
%
%   o  reg : Boolean, Radio button
%
%      specifies wether the regression is to be done by the user or
%      automatically (default: Specify).
%
%   o  RegParam : Integer
%
%      specifies the type of regression to be used.
%
%   o  Refresh : Push button:
%
%      Set the default values.
%
%
%   o  Compute : Push button:
%
%      Compute regularized lengths (1d) or surfaces (2d) VS scales and
%      make the regression to get the dimension.
%
%   o  Close : Push button:
%
%      Close the window and all the figures opened during the procedure.
%
%
%   1.2.  Output parameters
%
%
%   o  dim : Real
%      estimated box dimension
%
%   o  nb :  Integer vector 
%      gives the number of non-empty boxes for each size of the box
%      from Nmin to Nmax
%   
%   o  taille : Real Vector
%      contains the size 2^-n of the box "n"  
%      for each "n" belonging to (Nmin, Nmax)
%
%   o  handlefig (for Matlab only): Integer vector
%      Handles of the figures opened during the procedure.
%
%
%   2.  See also:
%
%   cwttrack, cwtspec.
%
%
%   3.  Example:
%
%
%    Signal synthesis
%
%   Synthesize a fractal 1d signal (e.g. Synthesis, Functions,
%   Deterministic, Weierstrass).
%
%   Dimension of the graph with a regression by hand
%
%   Push the Compute button, test a few regressions by pressing a mouse
%   button or any key on the keyboard except carriage return, which
%   terminates the regression and keeps the last one.
%
%
%    Close the figures
%
%   Push Close.
%
%
%  This Software is ( Copyright INRIA . 2000 2001 )
% 
% INRIA  holds all the ownership rights on the Software. 
% The scientific community is asked to use the SOFTWARE 
% in order to test and evaluate it.
% 
% INRIA freely grants the right to use modify the Software,
% integrate it in another Software. 
% Any use or reproduction of this Software to obtain profit or
% for commercial purposes being subject to obtaining the prior express
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
