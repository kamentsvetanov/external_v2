%   Continuous partition function estimation on 1d function
%
%   This routine computes a continuous partition function on a 1d func-
%   tion.
%
%   1.  Usage
%
%   [zaq,[a,q]]=fczq1d(f_x,[q,[J min max],partstr,oscstr])
%
%   1.1.  Input parameters
%
%   o  f_x : real vector
%      Contains the 1d function.
%
%   o  q : strictly positive real vector
%      Contains the exponents.
%
%   o  [J min max] : strictly positive real (integer) vector
%      Contains the number of intervals, resp. of partitions, and the
%      minimum and maximum interval sizes, resp. partition numbers.
%
%   o  progstr : string
%      Contains the string which specifies the intervals progression.
%
%   o  oscstr : string
%      Contains the string which specifies the oscillation to be used.
%
%   1.2.  Output parameters
%
%   o  zaq : real matrix [size(q),size(a)]
%      Contains the partition function.
%
%   o  a : real vector [1,J]
%      Contains the scales.
%
%   o  q : strictly positive real vector
%      Contains the exponents.
%
%   2.  Description
%
%   2.1.  Parameters
%
%   The  continuous partition  function  zaq is  computed  on the  1d
%   function f_x.
%
%   The vector of exponents q  and the number of intervals, resp.  of
%   partitions J set  the size of the output  real matrix zaq to
%   size(q)*J.  The  default value for  length(q) is 21  and the default
%   value for J  is -log(M)/log(2.) where M is length(f_x).
%
%   The  size  progression  string  progstr  sets the  type  of  size
%   discretization.  It  can be  'dec' for decimated,  'log' for
%   logarithmic  or 'lin' for  linear scale.   The default  value for
%   progstr is 'log'.
%
%   The oscillation  string oscstr sets  the type of  oscillation. It can
%   be 'osc'  for  oscillation, 'lp'  (with p  integer >1) for Lp norm and
%   'linfty' for Linf norm.
%
%   2.2.  Algorithm details
%
%   The  continuous partition  function  zaq is  computed by  summing
%   oscillations on intervals of increasing diameter.
%
%   3.  Examples
%
%   3.1.  Matlab
%
%   ______________________________________________________________________
%   % Fractional Brownian motion synthesis
%   fbm=fbmlevinson(256,.6);
%
%   % partition function: z(a,q) estimation with default input arguments and
%   % all output arguments
%   [zaq,a,q]=fczq1d(fbm);
%   % plot outputs
%   plot(log(a),log(zaq));
%
%   % partition function: z(a,q) estimation with custom input arguments and
%   % two output arguments
%   [zaq,a]=fczq1d(fbm,[-5:.1:+5],[10 1 128],'lin','l2');
%   % plot outputs
%   plot(log(a),log(zaq));
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
%   mdzq1d,mczq2d,reynitq,linearlt,mdfl1d,mdfl2d,fcfl1d.

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
