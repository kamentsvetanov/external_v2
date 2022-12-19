%   stochastic multinomial 1d measure synthesis
%
%   This C_LAB routine synthesizes two types of pre-multifractal stochas-
%   tic measures related to the multinomial 1d measure (uniform law and
%   lognormal law) and computes linked multifractal spectrum.
%
%   1.  Usage
%
%   [varargout,[optvarargout]]=sbinom(b,str,varargin,[optvarargin])
%
%   1.1.  Input parameters
%
%   o  b : strictly positive real (integer) scalar
%      Contains the base of the multinomial.
%
%   o  str : string
%      Contains the type of ouput.
%
%   o  varargin : variable input argument
%      Contains the variable input argument.
%
%   o  optvarargin : optional variable input arguments
%      Contains optional variable input arguments.
%
%   1.2.  Output parameters
%
%   o  varargout : variable output argument
%      Contains the variable output argument.
%
%   o  optvarargout : optional variable output argument
%      Contains an optional variable output argument.
%
%   2.  Examples
%
%   2.1.  Matlab
%
%   ______________________________________________________________________
%
%   n=10;
%   % synthesizes a pre-multifractal uniform Law multinomial 1d measure
%   [mu_n,I_n]=smultim1d(b,'unifmeas',n);
%   plot(I_n,mu_n);
%
%   s=1.;
%   % synthesizes the cdf of a pre-multifractal lognormal law multinomial 1d measure
%   F_n=smultim1d(b,'logncdf',n,s);
%   plot(I_n,F_n);
%
%   e=.19;
%   % synthesizes the pdf of a pre-multifractal uniform law multinomial 1d measure
%   p_n=smultim1d(b,'unifpdf',n,e);
%   plot(I_n,p_n);
%
%   N=200;
%   s=1.;
%   % computes the multifractal spectrum of the lognormal law multinomial 1d measure
%   [alpha,f_alpha]=smultim1d(b,'lognspec',N,s);
%   plot(alpha,f_alpha);
%   ______________________________________________________________________
%
%   2.2.  Scilab
%
%   ______________________________________________________________________
%
%   n=10;
%   // synthesizes a pre-multifractal uniform Law multinomial 1d measure
%   [mu_n,I_n]=smultim1d(b,'unifmeas',n);
%   plot(I_n,mu_n);
%
%   s=1.;
%   // synthesizes the cdf of a pre-multifractal lognormal law multinomial 1d measure
%   F_n=smultim1d(b,'logncdf',n,s);
%   plot(I_n,F_n);
%
%   e=.19;
%   // synthesizes the pdf of a pre-multifractal uniform law multinomial 1d measure
%   p_n=smultim1d(b,'unifpdf',n,e);
%   plot(I_n,p_n);
%
%   N=200;
%   // computes the multifractal spectrum of the lognormal law multinomial 1d measure
%   [alpha,f_alpha]=smultim1d(b,'lognspec',N,s);
%   plot(alpha,f_alpha);
%   ______________________________________________________________________
%
%   3.  References
%
%   "A class of Multinomial Multifractal Measures with negative (latent)
%   values for the "Dimension" f(alpha)", Benoit B. MandelBrot. In
%   Fractals' Physical Origins and Properties, Proceeding of the Erice
%   Meeting, 1988. Edited by L. Pietronero, Plenum Press, New York, 1989
%   pages 3-29.
%
%   "Limit Lognormal Multifractal Measures", Benoit B. MandelBrot. In
%   Frontiers of Physics, Landau Memorial Conference, Proceeding of the
%   Tel-Aviv Meeting, 1988. Edited by Errol Asher Gotsman, Yuval Ne'eman
%   and Alexander Voronoi, New York Pergamon, 1990 pages 309-340.
%
%   4.  See also
%
%   binom, sbinom, multim1d, multim2d, smultim2d (C_LAB routines).
%
%   MFAS_measures, MFAS_dimensions, MFAS_spectra (Matlab and/or Scilab
%   demo scripts).

% Author Christophe Canus, July 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------