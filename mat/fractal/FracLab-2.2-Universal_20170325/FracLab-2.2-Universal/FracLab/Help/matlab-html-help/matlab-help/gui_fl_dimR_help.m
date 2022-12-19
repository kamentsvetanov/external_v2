%   Regularization dimension.
%   Francois Roueff
%   February 13th 1998
%
%   Computes the regularization dimension of the graph of a 1d or 2d func-
%   tion.  Two kernels are available: the Gaussian or the Rectangle.
%
%
%
%   1.  Usage of the corresponding command:
%
%   [dim,
%   handlefig]=regdim(x,sigma,voices,Nmin,Nmax,kernel,mirror,reg,graphs)
%
%
%   1.1.  Input parameters
%
%
%   o  Input Signal (x) : Real vector [1,nt] or [nt,1] or matrix [pt,nt]
%      Signal or surface to be analyzed.
%
%   o  StD (sigma) : Edit text (Real positive number)
%      Standard Deviation of the noise. Its default value is null
%      (noisefree)
%
%   o  Voices (voices) : Edit text or popup menu (Positive integer)
%      number of analyzing voices.  When not specified, this parameter is
%      set to 64 for 1d or 16 for 2d.
%
%   o  Nmin (Nmin) : Edit text or popup menu (Integer in  [2,nt/3])
%      Lower scale bound (lower length) of the analysing kernel. When not
%      specified, this parameter is set to 2 for 1d or around nt/12 for
%      2d.
%
%   o  Nmax (Nmax) : Edit text or popup menu (Integer in  [Nmin,2nt/3])
%      Upper scale bound (upper length) of the analysing kernel. When not
%      specified, this parameter is set to nt/2 for 1d or nt/3 for 2d. To
%      avoid too long computing times be carreful not to set this
%      parameter to high.
%
%   o  kernel (kernel) : Popup menu (String)
%      specifies the analyzing kernel:
%      Gaussian ("gauss"): Gaussian kernel (default)
%      Rectangle ("rect"): Rectangle kernel
%
%   o  Mirror (mirror) : Radio button (Boolean)
%
%      specifies wether the signal is to be mirrorized for the analyse
%      (default: No).
%
%   o  Plot regularized graphs (graphs) : Radio button (Boolean):
%
%      specifies wether the regularized graphs have to be displayed
%      (default: Do Not).
%
%   o  Specify or automatic regression range (reg) :  Radio button
%      (Boolean)
%
%      specifies wether the regression is to be done by the user or
%      automatically (default: Specify).
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
%   o  Regularization Dimension (dim) : Real
%      Estimated regularization dimension.
%
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
%   Deterministic, Weierstrass) or get a 2d signal.
%
%    Dimension of the graph with a regression by hand
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
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
