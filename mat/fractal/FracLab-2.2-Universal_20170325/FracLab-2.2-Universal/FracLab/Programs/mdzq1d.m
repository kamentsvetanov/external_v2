%   Discrete partition function estimation on 1d measure
%
%   This routine computes the discrete partition function on a pre-multi-
%   fractal 1d measure.
%
%   1.  Usage
%
%   [zaq,[a,q]]=mdzq1d(mu_n,[q,[J min max],partstr])
%
%   1.1.  Input parameters
%
%   o  mu_n : strictly positive real vector
%      Contains the pre-multifractal 1d measure.
%
%   o  q : strictly positive real vector
%      Contains the exponents.
%
%   o  [J min max] : strictly positive real (integer) vector
%      Contains the number of intervals, resp. of partitions, and the
%      minimum and maximum interval sizes, resp. partition numbers.
%
%   o  partstr : string
%      Contains the string which specifies the intervals, resp. the
%      partitions progression.
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
%   The  discrete  partition    function zaq  is    computed  on  the pre-
%   multifractal 1d measure mu_n.
%
%   The vector of exponents q  and the number of intervals, resp.  of
%   partitions J set  the size of the output  real matrix zaq to
%   size(q)*J.  The  default value for  length(q) is 21  and the default
%   value for J is -log(N_n)/log(2.) where N_n is length(mu_n).
%
%   The partition string progstr specifies the type of partition.  It can
%   be  'linpart' for  linear,  'logpart' for  logarithmic,
%
%   2.2.  Algorithm details
%
%   The discrete partition   function zaq   is computed by    summing mu_n
%   on intervals, resp.  on  partitions, of increasing  diameter (fix-mass
%   box couting method).
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
%   mdzq2d,fczq1d,reynitq,linearlt,mdfl1d,mdfl2d,fcfl1d.

% Author Christophe Canus, February 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------