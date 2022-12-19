%   Reyni exponents estimation on a partition function
%
%   This routine estimates the Reyni exponents on a partition function.
%
%   1.  Usage
%
%   [tq,[Dq]]=reynitq(zaq,q,a)
%
%   1.1.  Input parameters
%
%   o  zaq : strictly positive real matrix
%      Contains the partition function.
%
%   o  q : strictly positive real vector
%      Contains the exponents.
%
%   o  a : strictly positive real (integer) vector
%      Contains the resolutions.
%
%   o  lrstr : string
%      Contains the  string which specifies  the type of linear regression
%      to be used.
%
%   1.2.  Output parameters
%
%   o  tq : real vector [1,size(q)]
%      Contains the Reyni exponents.
%
%   o  Dq : real vector [1,size(q)]
%      Contains the generalized dimensions.
%
%   2.  Description
%
%   2.1.  Parameters
%
%   The Reyni exponents tq and the generalized dimensions Dq (if used) are
%   computed on the partition function zaq.
%
%   The input real matrix zaq must be of height size(q) and of width
%   size(a).
%
%   The output real vectors tq and Dq (if used) are of size size(q).
%
%   The linear  regression string lrstr specifies the  type of linear
%   regression used.  It can be 'ls' for least square, 'wls' for weighted
%   least   square,  'pls'  for   penalized  least  square, procedure
%   least   square.   The  default  value   for  lrstr  is
%
%   2.2.  Algorithm details
%
%   The  mass  exponent function  tq  is  estimated using  differents
%   linear  regression methods.  For  the details  of  these methods,  see
%   monolr   (monovariate    linear   regression)   C_LAB   routine's
%   help.
%
%   3.  Examples
%
%   3.1.  Matlab
%
%   ______________________________________________________________________
%   % Pre-multifractal binomial 1d measure synthesis
%   mu_n=binom(.1,'meas',10);
%
%   % Partition function: z(a,q) on 1d measure with default input arguments and
%   % all output arguments
%   [zaq,a,q]=mdzq1d(mu_n);
%   plot(log(a),log(zaq));
%
%   % Reyni mass exponents: t(q) with custom input arguments and
%   % all ouput arguments
%   [tq,Dq]=reynitq(zaq,q,a,'wls');
%   plot(q,tq);
%
%   % Just to see that it doesn't look very good
%   [alpha,f_alpha]=linearlt(q,tq);
%   plot(alpha,f_alpha);
%   ______________________________________________________________________
%
%   3.2.  Scilab
%
%   ______________________________________________________________________
%   //
%   ______________________________________________________________________
%
%   4.  References
%
%   To be published.
%
%   5.  See also
%
%   mdzq1d,mdzq2d,fczq1d,monolr,linearlt,mdfl1d,mdfl2d,fcfl1d.

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------