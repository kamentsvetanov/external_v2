%  The TF-TS pop-up menu
%  Jacques Lévy Véhel
%  22 May 2000
%
%  This text presents a brief explanation of the functionalities the TF-
%  TS pop-up menu.
%  ______________________________________________________________________
%
%  Table of Contents:
%
%  1.      Overview
%
%  2.      Continuous WT
%
%  3.      Discrete WT
%
%  4.      Pseudo-affine Wigner Transform
%
%  5.      Known bugs
%  ______________________________________________________________________
%
%  1.  Overview
%
%  This menu gathers utilities related to time-frequency and time scale
%  transforms. More precisely, it allows to compute discrete and
%  continuous wavelet transforms and pseudo-affine Wigner transforms.
%  The discrete and continuous wavelet transforms windows (as well as the
%  programs) are the same as the ones present in other areas of Fraclab,
%  while the computation of the pseudo-affine Wigner transform is
%  available only in this menu.
%
%  2.  Continuous WT
%
%  This menu allows you to compute the continuous wavelet transform of 1D
%  signals. As said above, the Continuous Wavelet Transform sub-menu is
%  almost exactly the same as the one that appears in the 1D Exponents
%  Estimation and 1D Multifractal Spectra estimation menus. For
%  convenience, we recall here its main features.  Check your input
%  signal and Refresh it if needed. You need then to tune the fmin and
%  fmax values, which are the minimum and maximum frequencies of
%  analysis. The default values are the ones yielding maximal span
%  compatible with the size of the signal. You may change the extreme
%  frequencies either by typing values under fmin and fmax, or by using
%  the predefined values on the menus to the right. The Voices parameters
%  governs the number of intermediate frequencies at which the continuous
%  wavelet coefficients will be computed. Be warned that giving an
%  excessive number of voices may result in large computing times for
%  long signals. You may then decide if you want to use an L2 (the
%  default) or an L1 normalization for your wavelet. This feature is the
%  only one that is present in this menu and not in the continuous
%  wavelet computations of other parts of Fraclab. Checking the Mirror
%  item will deal the border effects by mirroring the signal at its
%  extremities. Otherwise, zero-padding is used. Finally, you may choose
%  the Size and Type of your analyzing wavelet: available wavelets are
%  the Mexican Hat, and the real and analytic Morlet wavelets. The size
%  may be any positive number (this parameter is not available for the
%  Mexican hat). Once all the parameters that define the wavelet
%  transform are chosen, hit Compute WT. The output signal is a matrix of
%  size "number of voices" x "size of the original signal".  It is called
%  cwt_signal#, if "signal" is the name of your data, and where # is as
%  usual an incremental parameter. You may visualize the continuous
%  wavelet transform using the View menu. Note that Fraclab recognizes
%  wavelet transforms, and display them differently form regular images.
%  In particular, it uses a fixed aspect ratio (this is useful for
%  instance if the number of voices is much smaller than the size of the
%  signal), and the "jet" color-map, which often allows to highlight the
%  important structures. If you want to view the transform as a normal
%  image, or make other changes in the appearance, use the
%  functionalities of the View menu described in the Overview help file.
%
%  3.  Discrete WT
%
%  Contrarily to both the continuous wavelet transform and the pseudo-
%  affine Wigner transform menus, you may here input 1D or 2D signals,
%  and get their discrete wavelet transform. As said in the overview,
%  this window is exactly the same as the one that appears in the 1D
%  Multifractal Spectra estimation menu (except in the 1D Multifractal
%  Spectra estimation menu you cannot compute transforms of images).
%  Briefly, select first your Input Signal using the Refresh button. You
%  may then choose the analyzing Wavelet from a choice of various
%  Daubechies and Coiflet wavelets. Specify next the number of Octaves,
%  i.e. on how many scale levels you wish to perform the analysis. On
%  pressing Compute, the output signal dwt_sig# will be created.
%
%  4.  Pseudo-affine Wigner Transform
%
%  The pseudo-affine Wigner transform is only implemented for 1D signals.
%  The organization is the same as for the continuous wavelet transform,
%  with some minor variations. Tune first the fmin and fmax values, which
%  are the minimum and maximum frequencies of analysis. The default
%  values are the ones yielding maximal span compatible with the size of
%  the signal. You may change the extreme frequencies either by typing
%  values under fmin and fmax, or by using the predefined values on the
%  menus to the right. Choose then the value of the parameter K from a
%  choice of -1, 0, 0.5, 2 or enter your own choice. The Voices
%  parameters governs the number of intermediate frequencies at which the
%  continuous wavelet coefficients will be computed. Be warned that
%  giving an excessive number of voices may result in large computing
%  times for long signals. You may then decide to perform some Smoothing
%  by entering a number in the corresponding box. Finally, you may choose
%  the Size and Type of your analyzing wavelet: available wavelets are
%  the Mexican Hat, and the real and analytic Morlet wavelets. The size
%  may be any positive number (this parameter is not available for the
%  Mexican hat). Once all the parameters are set, hit Compute. The output
%  signal is a matrix of size "number of voices" x "size of the original
%  signal". It is called paw_signal#. You may visualize the continuous
%  wavelet transform using the View menu. Note that Fraclab recognizes
%  pseudo-affine Wigner transforms, and display them differently form
%  regular images. In particular, it uses a fixed aspect ratio (this is
%  useful for instance if the number of voices is much smaller than the
%  size of the signal), and the "jet" color-map, which often allows to
%  highlight the important structures. If you want to view the transform
%  as a normal image, or make other changes in the appearance, use the
%  functionalities of the View menu described in the Overview help file.
%
%  5.  Known bugs
%
%  Sometimes, the windows corresponding to the computations of the three
%  transforms above will not close when pressing Close. When this
%  happens, just close them using more drastic means.

