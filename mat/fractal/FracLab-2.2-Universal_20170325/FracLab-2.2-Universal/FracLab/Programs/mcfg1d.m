%   Continuous large deviation spectrum estimation on 1d measure
%
%   This C_LAB routine estimates the continuous large deviation spectrum
%   on 1d measure.
%
%   1.  Usage
%
%   [alpha,fgc_alpha,[pc_alpha,epsilon_star,eta,alpha_eta_x]]=
%   mcfg1d(mu_n,[S_min,S_max,J],progstr,ballstr,N,epsilon,contstr,adapstr,kernstr,normstr,I_n])
%
%   1.1.  Input parameters
%
%   o  mu_n : strictly positive real vector [1,N_n] or [N_n,1]
%      Contains the 1d measure.
%
%   o  S_min : strictly positive real scalar
%      Contains the minimum size.
%
%   o  S_max : strictly positive real scalar
%      Contains the maximum size.
%
%   o  J : strictly positive real (integer) scalar
%      Contains the number of scales.
%
%   o  progstr : string
%      Contains the string which specifies the scale progression.
%
%   o  ballstr : string
%      Contains the string which specifies the type of ball.
%
%   o  N : strictly positive real (integer) scalar
%      Contains the number of Hoelder exponents.
%
%   o  epsilon : strictly positive real vector [1,N] or [N,1]
%      Contains the precisions.
%
%   o  contstr : string
%      Contains the string which specifies the definition of continuous
%      spectrum.
%
%   o  adapstr : string
%      Contains the string which specifies the precision adaptation.
%
%   o  kernstr : string
%      Contains the string which specifies the kernel form.
%
%   o  normstr : string
%      Contains the string which specifies the pdf's normalization.
%
%   o  I_n : strictly positive real vector [1,N_n] or [N_n,1]
%      Contains the intervals on which the pre-multifractal 1d measure is
%      defined.
%
%   1.2.  Output parameters
%
%   o  alpha : real vector [1,N]
%      Contains the Hoelder exponents.
%
%   o  fgc_alpha : real matrix [J,N]
%      Contains the spectrum(a).
%
%   o  pc_alpha : real matrix [J,N]
%      Contains the pdf('s).
%
%   o  epsilon_star : strictly positive real matrix [J,N]
%      Contains the optimal precisions.
%
%   o  eta : strictly positive real vector [1,J]
%      Contains the sizes.
%
%   o  alpha_eta_x : strictly positive real matrix [J,N_n]
%      exponents.
%
%   2.  Description
%
%   2.1.  Parameters
%
%   The continuous  large   deviation  spectrum (alpha,fgc_alpha)  is
%   estimated  for J sizes eta_j and  for  the precision vector epsilon
%   by taking into account  the resolution of the 1d measure mu_n.
%
%   The minimum size S_min sets the equivalent size eta_1 in the unit
%   interval at which the first spectrum is estimated.  eta_1 is equal to
%   S_min*eta_n    where  eta_n is  related    to  the resolution of the
%   1d measure (eta_n=N_n^{-1}  when all intervals are of    equal  size
%   else it is    max(|I_n|^{-1}).   It must be >=1.  The default value
%   for S_min is 1.
%
%   The maximum size S_max sets the equivalent size eta_J in the unit
%   interval at which the  last spectrum is estimated.  eta_J is equal to
%   S_max*eta_n.  It must be >=S_min.  The default value for S_max is 1.
%
%   The number  of scales J sets  the number of computed spectra. The
%   bigger  J   is,  the slower   the   computation  is.  It  must be >=1.
%   The default value for J is 1.
%
%   The scale progression string  progstr specifies the type of scale
%   discretization.  It can be   'dec' for decimated,  'log' for
%   logarithmic or 'lin'  for  linear scale.   The default value  for
%   progstr is 'dec'.
%
%   The   ball   string    ballstr  specifies  the      type  of ball
%   B_eta(x). It can be 'asym'  for asymmetric, 'cent'  for centered or
%   'star' for three  times bigger asymmetric ball.   The default value
%   for ballstr is 'asym'.
%
%   The   number N sets the discretization   of the Hoelder exponents
%   interval.   They  are linearly   spaced between alpha_eta_min and
%   alpha_eta_max  which are the   minimum and maximum  values of the
%   coarse grain Hoelder  exponents  at size eta.  The  bigger N is, the
%   slower the computation is.   It must be >=1. The default value for N
%   is 100.
%
%   The  precision vector epsilon  sets the  precisions at which  the
%   spectrum  is estimated.    It  must  be  of size   [1,N]  or [N,1].
%   When no precision vector  is given as input or when it is uniformly
%   equal to  0,  the  algorithm determines  the  optimal precisions
%   vector    epsilon_star.    The  default   value  for epsilon is
%   zeros(1,N).
%
%   The continuous    string contstr  specifies   the   definition of
%   continuous spectrum.  It can be equal to 'hnokern' for definition
%   without precision   and  kernel or  'hkern'  for  definition with
%   precision   and  kernel.  The default       value    for  contstr is
%   'hkern'.
%
%   The  precision  adaptation   string  adapstr specifies  the local
%   adaptation  of the precision  w.r.t. the Hoelder exponents alpha.  It
%   can  be  equal to   'maxdev'    for  maximum  deviation or
%   'maxadaptdev' for  maximum adaptive deviation.  The default value for
%   adapstr is 'maxdev'.
%
%   The kernel string  kernstr specifies the  kernel. It can be equal to
%   'box' for boxcar,  'tri'  for  triangle, 'mol'  for mollifier,  'epa'
%   for epanechnikhov  or  'gau' for gaussian kernel.  The default value
%   for kernstr is 'gau'.
%
%   The normalization string    normstr specifies the type   of pdf's
%   normalization  conducted  before double log-normalization.   It can be
%   equal to 'nonorm' for  no normalization  conducted, 'suppdf' for
%   normalization  w.r.t the  supremum of pdf's,  'infsuppdf' for
%   normalization  w.r.t  the  infimum and the   supremum  of pdf's.   The
%   default value for normstr is 'suppdf'.
%
%   The  intervals vector I_n can   be useful  when the intervals  on
%   which the pre-multifractal 1d measure is defined are not of equal size
%   (not implemented yet).
%
%   The  pdf  of the  coarse grain   Hoelder  exponents  matrix  or vector
%   pc_alpha,   the     optimal   precisions      matrix   or  vector
%   epsilon_star, the  sizes vector  eta and the   coarse grain Hoelder
%   exponents matrix or vector alpha_eta_x can be obtained as outputs
%   parameters.
%
%   2.2.  Algorithm details
%
%   The coarse Hoelder exponents are estimated on each point x of the unit
%   interval  discretization by   summing  interval measures  into  a
%   sliding window of  size eta containing x (which  corresponds to ball
%   B_eta(x)).
%
%   The probability density function pc_alpha is obtained by integrating
%   horizontal sections.
%
%   3.  Examples
%
%   3.1.  Matlab
%
%   ______________________________________________________________________
%   % synthesis of pre-multifractal binomial measure: mu_n
%   % resolution of the pre-multifractal measure
%   n=10;
%   % parameter of the binomial measure
%   p_0=.4;
%   % synthesis of the pre-multifractal beiscovitch 1d measure
%   mu_n=binom(p_0,'meas',n);
%   % continuous large deviation spectrum estimation: fgc_alpha
%   %  minimum size, maximum size & # of scales
%   S_min=1;S_max=8;J=4;
%   % # of hoelder exponents, precision vector
%   N=200;epsilon=zeros(1,N);
%   % estimate the continuous large deviation spectrum
%   [alpha,fgc_alpha,pc_alpha,epsilon_star]=mcfg1d(mu_n,[S_min,S_max,J],'dec','cent',N,epsilon,'hkern','maxdev','gau','suppdf');
%   % plot the continuous large deviation spectrum
%   plot(alpha,fgc_alpha);
%   title('Continuous Large Deviation spectrum');
%   xlabel('\alpha');
%   ylabel('f_{g,\eta}^{c,\epsilon}(\alpha)');
%   ______________________________________________________________________
%
%   3.2.  Scilab
%
%   ______________________________________________________________________
%   // computation of pre-multifractal besicovitch measure: mu_n
%   // resolution of the pre-multifractal measure
%   n=10;
%   // parameter of the besicovitch measure
%   p_0=.4;
%   // synthesis of the pre-multifractal besicovitch 1d measure
%   [mu_n,I_n]=binom(p_0,'meas',n);
%   // continuous large deviation spectrum estimation: fgc_alpha
%   // minimum size, maximum size & # of scales
%   S_min=1;S_max=8;J=4;
%   // # of hoelder exponents, precision vector
%   N=200;epsilon=zeros(1,N);
%   // estimate the continuous large deviation spectrum
%   [alpha,fgc_alpha,pc_alpha,epsilon_star]=mcfg1d(mu_n,[S_min,S_max,J],'dec','cent',N,epsilon,'hkern','maxdev','gau','suppdf');
%   // plot the Continuous Large Deviation spectrum
%   plot2d(a,f,[6]);
%   xtitle(["Continuous Large Deviation spectrum";" "],"alpha","fgc(alpha)");
%   ______________________________________________________________________
%
%   4.  References
%
%   To be published.
%
%   5.  See Also
%
%   mch1d, fch1d, fcfg1d, cfg1d (C_LAB routines).
%
%   MFAG_continuous, MFAG_epsilon, MFAG_eta, MFAG_epsilon_eta (Matlab
%   and/or Scilab functions).

% Author Christophe Canus, February 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------