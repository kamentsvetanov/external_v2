%   stochastic multinomial 2d measure synthesis
%
%   This  C_LAB   routine   synthesizes two   types    of pre-multifractal
%   stochastic measures related to the multinomial 2d measure (uniform law
%   and lognormal law).
%
%   1.  Usage
%
%   [varargout,[optvarargout]]=sbinom(bx,by,str,varargin,[optvarargin])
%
%   1.1.  Input parameters
%
%   o  bx : strictly positive real (integer) scalar
%      Contains the abscissa base of the multinomial.
%
%   o  by : strictly positive real (integer) scalar
%      Contains the ordonate base of the multinomial.
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
%   n=5;
%   bx=2;
%   by=3;
%   % synthesizes a pre-multifractal uniform Law multinomial 2d measure
%   [mu_n,I_nx,I_ny]=smultim2d(bx,by,'unifmeas',n);
%   mesh(I_nx,I_ny,mu_n);
%
%   s=1.;
%   % synthesizes the cdf of a pre-multifractal lognormal law multinomial 2d measure
%   F_n=smultim2d(bx,by,'logncdf',n,s);
%   mesh(I_nx,I_ny,F_n);
%
%   e=.19;
%   % synthesizes the pdf of a pre-multifractal uniform law multinomial 2d measure
%   p_n=smultim2d(bx,by,'unifpdf',n,e);
%   mesh(I_nx,I_ny,p_n);
%   ______________________________________________________________________
%
%   2.2.  Scilab
%
%   ______________________________________________________________________
%
%   n=5;
%   bx=2;
%   by=3;
%   // synthesizes a pre-multifractal uniform Law multinomial 2d measure
%   [mu_n,I_nx,I_ny]=smultim2d(bx,by,'unifmeas',n);
%   mesh(I_nx,I_ny,mu_n);
%
%   s=1.;
%   // synthesizes the cdf of a pre-multifractal lognormal law multinomial 2d measure
%   F_n=smultim2d(bx,by,'logncdf',n,s);
%   mesh(I_nx,I_ny,F_n);
%
%   e=.19;
%   // synthesizes the pdf of a pre-multifractal uniform law multinomial 2d measure
%   p_n=smultim2d(bx,by,'unifpdf',n,e);
%   mesh(I_nx,I_ny,p_n);
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
%   binom, sbinom, multim1d, multim2d, smultim1d (C_LAB routines).
%
%   MFAS_measures, MFAS_dimensions, MFAS_spectra (Matlab and/or Scilab
%   demo scripts).

% Author Christophe Canus, July 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------