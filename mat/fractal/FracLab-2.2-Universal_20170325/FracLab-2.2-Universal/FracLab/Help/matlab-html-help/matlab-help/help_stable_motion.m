%  The Stable Motion pop-up menu
%  Jacques Lévy Véhel
%  22 June 1998
%
%  This text presents a brief explanation of the functionalities the Sta­
%  ble Motion pop-up menu.
%  ______________________________________________________________________
%
%  Table of Contents:
%
%  1.      Overview
%
%  2.      Synthesis
%
%  3.      Mac Culloch Method for Parameters Estimation
%
%  4.      Koutrouvelis Method for Parameters Estimation
%
%  5.      Test of Stability
%
%  6.      Spectral Measure Estimation
%
%  7.      Covariation Estimation
%
%  8.      Homework
%
%  9.      References
%  ______________________________________________________________________
%
%  1.  Overview
%
%  This menu allows to perform various operations related to stable
%  motions. A stable motion is a process with i.i.d increments which
%  follow a stable law. Stable laws are a generalization of the Gaussian,
%  in the sense that they are the only laws that are preserved under
%  convolutions. Except for the Gaussian, stable laws do not have a
%  variance, and there exists a real number alpha in (0,2) such that all
%  moments of order equal to or greater than alpha do not exist. The most
%  well known non Gaussian stable law is the Cauchy law.
%
%  Apart from the Test of Stability sub-menu, all others operations in
%  this menu are also present in other Fraclab menu: The Synthesis sub-
%  menu calls the same window as the corresponding sub-menu in the
%  Synthesis menu. The Mac Culloch Method for Parameters Estimation and
%  the Koutrouvelis Method for Parameters Estimation are the same as the
%  ones in the 1D Exponents Estimation sub-menu. The Test of Stability
%  sub-menu is described below. Finally, both the Spectral Measure
%  Estimation and the Covariation Estimation sub-menu are not implemented
%  yet. The reason why there is a special menu for Stable motions
%  although most operations are already scattered in other sections of
%  Fraclab is for visibility reasons: The operations here are strongly
%  parametric, and rather different in nature from those in the remaining
%  menus.
%
%  2.  Synthesis
%
%  In this menu, you can synthesize a stable process by specifying the
%  four parameters characterizing the stable law governing its
%  increments. The Characteristic Exponent, alpha, between 0 and 2,
%  controls the thickness of the tail of the process. alpha equal 1 gives
%  the Cauchy law, and alpha lower than or equal to one yields a process
%  without a mean. The Skewness Parameter is between -1 (distribution
%  totally skewed to the left) and 1 (distribution totally skewed to the
%  right), and controls the symmetry : the distribution is symmetric
%  (around its location parameter) if and only if the skewness parameter
%  is 0. The Location Parameter, which is simply the mean when alpha is
%  greater than 1, is any real number. Finally, the Scale Parameter,
%  often denoted gamma, is a positive number related to the "size" of the
%  distribution : multiplying the process by a positive number w results
%  in a multiplication of the scale parameter by w.  When alpha equals 2
%  (Gaussian case), the square of the scale parameter is simply the
%  variance divided by 2.
%
%  Once the computation is over, two signals are generated : the stable
%  process itself, named stable_process# and its increments, which are
%  iid realizations of a stable law, stable_increments#. Both are
%  vectors.
%
%  3.  Mac Culloch Method for Parameters Estimation
%
%  Check as usual your Input signal, and just hit Compute. The estimated
%  values of the Characteristic Exponent, the Skewness,  Location and
%  Scale parameter will appear, along with estimates of their standard
%  deviation (in the column std). Be careful that if you want to estimate
%  the parameters of the stable motion X, you should input here the
%  signal Y which contains the increments of X. In other words, this
%  procedure estimates the parameters of the process, the increments of
%  which are the input signal.
%
%  4.  Koutrouvelis Method for Parameters Estimation
%
%  This is exactly the same as above, except this time no estimates are
%  available for the standard deviations. The same remark about the
%  increments applies.
%
%  5.  Test of Stability
%
%  This menu allows you to test that a particular signal may be well
%  modeled by a stable motion. In that view, one investigates whether its
%  increments taken at different lags display some scale invariance.
%  First check your Input signal (recall that you must input here the
%  increments of the signal for which you want to test adequacy to a
%  stable motion). Then decide how many time lags you want to
%  investigate. In that view, set the Maximum Resolution parameter to the
%  desired value: A value of n will mean that that you'll estimate the
%  four parameters of the stable motion for the original signal and its
%  versions sub-sampled by factors 2,..,n. If the signal is stable, the
%  parameter alpha should be approximately the same for all sub-sampled
%  versions, while the evolution of the scale parameters gamma should
%  follow a power law with exponent related to alpha (see the references
%  cited below for precise statements). Hit Compute. On the line
%  Characteristic parameter will appear the exponent alpha estimated
%  using the power law behaviour of the scale parameter alluded to above.
%  To check stability, look at the outputs of this computation that have
%  been displayed in the Variables list. There are four of them:
%  Estim_Param_M#, Estim_Sd_Dev_M#, plot_alpha# and plot_gamma#.
%  Estim_Param_M# is an n by 4 matrix (n is the chosen Maximum
%  Resolution): Estim_Param_M#(i,j), for i=1, ...n, yields the
%  characteristic exponent alpha for j=1, the skewness parameter for j=2,
%  the location parameter (j=3) and the scale parameter gamma (j=4) all
%  estimated at resolution i using the Mac Culloch method.
%  Estim_Sd_Dev_M# is the matrix of the associated standard deviations.
%  Instead of looking at the numerical values, it is often more
%  illustrative to display the two graphs plot_alpha# and plot_gamma#.
%  plot_gamma# displays a log-log plot of the evolution of the scale
%  parameter with respect to resolution. Ideally, this should be a
%  straight line, with slope related to alpha. In practice, one computes
%  the least square regression line, the slope of which will be used to
%  estimated the alpha value displayed on the line Characteristic
%  parameter. It is always a good idea to check whether approximate
%  linearity holds. As a second test, look at plot_alpha#, which displays
%  the estimated values of alpha at the different scales: Stability
%  entails that the estimated alpha should be roughly the same at all
%  resolutions. Moreover, the estimated values should be in agreement
%  with the one obtained by regressing on the gamma values. You should
%  thus display plot_alpha# and verify that the graph is approximately
%  horizontal (remember to check the ordinates before making a
%  conclusion...), with common value close to the one displayed on the
%  line Characteristic parameter.
%
%  6.  Spectral Measure Estimation
%
%  This is not implemented in the current version of Fraclab.
%
%  7.  Covariation Estimation
%
%  This is not implemented in the current version of Fraclab.
%
%  8.  Homework
%
%  First synthesize some stable motions, and observe the effect of the
%  various parameters, of which the most important is the characteristic
%  exponent alpha. It should be particularly clear from the graphs of the
%  process and of its increments that smaller alpha-s lead to processes
%  with more discontinuities. You should also observe easily how the
%  skewness parameter affects the output. For instance, with a skewness
%  of 0.6 there will be mainly negative jumps, and positive jumps for a
%  skewness of 0.6. You may also check that, in agreement with the
%  theory, when alpha is smaller than 1 and for a skewness of 1 or -1,
%  you only get positive or negative jumps. In other terms, the
%  corresponding processes are monotonous although still very irregular.
%
%  You may then test the estimation methods. Open both the Mc Culloch and
%  Koutrouvelis estimation menus. Choose an input signal in the Variables
%  list and hit Refresh (recall that you must input the increments of the
%  stable motion and not the process itself). You'll find that, as long
%  as you have a reasonably long signal (e.g. 5000 points), both methods
%  give approximately correct results concerning the two most interesting
%  parameters, i.e. the characteristic exponent and the skewness. The
%  location and scale parameters are sometimes strongly off, especially
%  for low values of alpha and extreme skewness. You may finally try the
%  Test of Stability facilities. You'll notice that, as long as you don't
%  go to too large Maximal Resolution, the numerical result fit nicely
%  the theory. For instance, if you synthesize a stable motion with the
%  default values of 5000 points, alpha = 1.5 and gamma = 1, both the Mac
%  Culloch and Koutrouvelis methods will yield estimates of alpha and
%  gamma very close to their theoretical values. Now the Test of
%  Stability with the default Maximal Resolution 12 will yield a
%  Characteristic parameter of around 1.43 slightly below the true one.
%  plot_gamma# is reasonably linear for small and medium lags, and
%  becomes erratic for lags close to 12 (recall that the abscissa is the
%  logarithm of the scale). Finally, plot_alpha# shows that the estimated
%  values of alpha are between 1.48 and 1.63. Since the original signal
%  was indeed a stable motion, you see that, even in the ideal case,
%  there is some discrepancy between the estimated values of alpha using
%  the two methods, i.e. the direct one and the regression on the values
%  of gamma. In general, you'll find that the direct estimation yields a
%  larger value than the one obtained by regression.
%
%  To make a test on a real signal, we'll consider the financial log
%  already studied in the Homework section of the Overview of this help:
%  This is a record of the Nikkei225 index during the period 01/01/80 to
%  05/11/2000.  The log consists in 5313 daily values corresponding to
%  that period. Load first these data into Fraclab: Press the Load button
%  in the main window. A new window appears, showing the files of your
%  current directory. Change directory to the DATA directory that comes
%  with the Fraclab release. Choose the file called nikkei225.txt by
%  clicking on it. Its name is then displayed at the top of the window,
%  in the Name: box. Since this file is plain text, click on the button
%  to the right of Load as:, and select the item ASCII. Then press Load,
%  and Close the loading window.  The nikkei225 file should appear in
%  your Variables list of the main window, under the name fnikkei225.
%  View this signal: Open the View window by pressing on the View button.
%  In the View window, click on View in new. This will open a window
%  displaying the stock market log. Like most data of this type, this
%  signal is quite erratic. Other obvious features include a steady
%  increase at the beginning of the log, and strong discontinuities
%  around the points 1780, 2040, 2650, 2760 or 3200.
%
%  Financial analysts do not work directly on the prices, but on their
%  logarithms, so we'll first type lnikkei = log(fnikkei225); in the
%  matlab window, and import lnikkei into Fraclab. To do this, press the
%  Scan Workspace button in the main window. In the new windows that
%  appears, titled Import Data from MATLAB Workspace, locate the signal
%  lnikkei, select it by clicking on it, and hit Import, then Close this
%  window. lnikkei will appear in the Variables list of the main window,
%  under the same name.
%
%  Finally, because we want to check whether lnikkei can be well modeled
%  by a stable motion, and estimate the corresponding parameters, we need
%  to compute its increments.  Type incnikkei = diff(lnikkei); in the
%  matlab window, and import incnikkei into Fraclab. You may want to view
%  this new signal, and check that it indeed displays a lot of spikes of
%  wildly varying sizes, somewhat reminiscent of what happens for a
%  "true" stable process.
%
%  Open the Mac Culloch Estimation and Koutrouvelis Estimation windows,
%  verify that the Input signal is incnikkei or hit Refresh, and Compute
%  the parameters using both methods. You'll find an relatively good
%  agreement for the estimations of alpha (1.37 versus 1.49) and the
%  skewness parameter (0 versus 0.18), and an excellent agreement for the
%  location and scale parameters, which are both estimated as 0. Let us
%  now test the stability. Open the Test of Stability window, choose a
%  Maximum Resolution of 10 and hit Compute. You'll get an alpha of
%  around 1.62, somewhat larger that the estimates above. The graph of
%  plot_gamma# is nicely linear for small and medium lags, and becomes
%  erratic only for the largest lags. In fact, the linearity in this
%  graph is quite comparable to the one we had for a true stable process.
%  However, the situation is not so good for plot_alpha# : this graph
%  displays strong variations, with estimated values of alpha ranging in
%  (1.36, 1.73). This casts a doubt of the stability of lnikkei. The
%  problem most probably comes from the fact that the increments of
%  lnikkei are certainly not independent but on the contrary are likely
%  to exhibit strong dependence. Thus, although lnikkei may be a process
%  without a variance, or even a stable process (i.e. a process with
%  stable marginals), it is not a stable motion, i.e. its increments are
%  not independent. We hope to include in future releases of Fraclab some
%  tools that will allow to analyze general stable processes.
%
%  9.  References
%
%  (1) S. Rachev, S. Mittnik, Stable Paretian Models in Finance, John
%  Wiley & Sons, 2000.
%
%  (2) L. Belkacem, alpha-SDE and Option Pricing Model, Fractals in
%  Engineering (J. Lévy Véhel, E. Lutton and C. Tricot Eds.), Springer
%  Verlag, 1997.

