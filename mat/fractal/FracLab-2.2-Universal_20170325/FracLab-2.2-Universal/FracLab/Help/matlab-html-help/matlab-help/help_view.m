%   The view menu
%   Jacques Levy Vehel and Frederic Raynal
%   22 June 1998
%
%   This section presents the functionalities of the view menu.
%
%   1.  The View menu
%
%   Clicking on the View button opens a new window, which serves as a
%   control center for all the displays (graphs + images) you might want
%   to have. This window is composed of four sub-windows : Figure, Image
%   mode, Tools, and finally a originally blank region which will contain
%   the list of all opened figures along with the data displayed in each
%   figure. This list allows you to select which figure or signal is
%   currently active by clicking on it. Only the active element will be
%   affected by the various commands available in the other sub-windows of
%   the View menu.
%
%   It is important to understand the difference between a View and the
%   data displayed in it. A View correponds to a Matlab figure that will
%   display one or several graphs or images. The case of several graphs
%   corresponds to the use of the subplot command in Matlab. Since, in the
%   case of multiple plots, you might want to apply a different processing
%   to each subplot, you need to tell Fraclab which subplot is the current
%   one. This is why the list at the bottom of the View window will show
%   the name of all the opened views (i.e. Matlab figures) numbered in the
%   chronological order of their appearance, and, for each of these views,
%   the name of the signals that are shown in this figure as plots or sub-
%   plots. This will allow you to select either a whole figure or one of
%   its subplot. For instance, some viewing options such as hold,  rotate
%   or  zoom are available only when a particular signal is highlighted,
%   and are greyed out when the whole view is highlighted. Note finally
%   that clicking in the list either on a view or on one of the signals
%   that it contains will bring the corresponding window to the
%   foreground, a useful feature if you have many opened windows or/and if
%   you do not remember which signal is which.
%
%   1.1.  The Figure sub-window
%
%   view in new : opens a new figure which will display the highlighted
%   data in the Variables zone of the main window.
%
%   view : displays the highlighted variable in the current figure, i.e.
%   the one which is highlighted in the figures list.  Depending on
%   whether the hold button in the Tools sub-window is selected or not,
%   pressing view will replace the current plot or will be placed on top
%   of it.
%
%   close all : Usually, you will probably find it more convenient to keep
%   the View window opened at all time. However, pressing this button will
%   close all figures, control panels and toolbar.
%
%   1.2.  The Image mode sub-window
%
%   This menu is active only when an image is selected in the list, and is
%   greyed out when either a view is selected (because Fraclab needs to
%   know which image must be processed and not merely which view is the
%   current one) or a 1D signal is  currently active (indeed, the
%   processings in this sub-window make no sense for 1D signals).
%
%   image control opens the image control panel (note that image control
%   is greyed out when the image control panel is already displayed). This
%   panel first recalls which data is being processed in the plot line.
%
%   The mode button then allows to choose how the data should be displayed
%   : as an image, a contour plot, a mesh, a surface, or as a superpostion
%   of 1D signals which might be its lines or columns. In addition, a
%   particular line/column might be selected for display.
%
%   colormap selects a colormap for the display among the Matlab
%   predefined settings.
%
%   dynamic allows to toggle between a linear and a logarithmic dynamic
%   for both the numerical and graphical display of the data.
%
%   min level, max level : these boxes allows you to enter the interval in
%   which the data must fall in order to be displayed. Pixels with grey
%   levels outside this range will be clipped.
%
%   value governs the way the data are numerically displayed, for instance
%   in the min level and max level boxes, or in the get point box :
%   normalized will forces the output to be between 0 and 1, while true
%   causes the real values to be displayed
%
%   display toggles bewteen a normalised and a true display for the  grey
%   levels in the image.
%
%   binary displays all the pixels with grey level between min level and
%   max level in white and all others in black.
%
%   reverse revert the order of the colormap. This is partcularly useful
%   in conjunction with binary to toggle between "in" and "out" pixels.
%
%   get point : pressing this button will bring the image figure to the
%   foreground and display a cross that you may center at any point.
%   Clicking will cause Fraclab to display the coordinates of the chosen
%   point along with its grey level in the box to the right. Whether the
%   displayed grey level will be the true one, a normalized one, or a
%   binary one depends on the choices described above. Note that it is
%   possible to zoom in the image before activating get point to gain more
%   precision. As said in the Message line of the main window, press Enter
%   in the image to get out of this mode, or click again on get point.
%
%   axis : toggles the aspect ratio between the true axis of the image and
%   the Matlab default.
%
%   x axis - y axis : enables to load a new array to use as axes, when the
%   data are displayed as anything but an image.
%
%   Note that the chosen modifications do not result in an immediate
%   update of the display. Rather, you need to press Apply to see the
%   effects of your choices.
%
%   The second button in Image mode is superpose. This allows to lay an
%   image on the top of another one with a control of the "transparency" :
%   when clicking on superpose, a new window appears that allows to choose
%   two parameters : the lut ratio decides how many entries in the current
%   colormap will be available for the first image, while the threshold
%   parameter ????????
%
%   1.3.  The Tools sub-window
%
%   hold causes the current plot to be held, so that subsequent graphs are
%   displayed on top of it.
%
%   rotate interactively rotates the view of a 3-D plot.
%
%   zoom allows to zoom on the current plot or image by selecting a region
%   with the mouse.
%
%   Vsplit performs a vertical split of the figure in as many subplots as
%   are specified in the box to the right.  Hsplit does the same for
%   horizontal subplots.  Thus, to have a figure with m horizontal
%   subplots and n vertical subplots, enter m in the Hsplit box, n in the
%   Vsplit box, select one by one the desired graphs in the Variables
%   window and press each time view : the data will be displayed
%   sequentially in the corresponding subplots.
%
%   Pressing axes opens the axes control panel which allows to set up
%   various parameters : the Scale type chooses between linear, semi-
%   logarithmic or bi-logarithmic plots, the X range and Y range decides
%   which parts of the data are to be displayed. For 1D signals, various
%   Aspect parameters can be specified :
%
%   mark changes the symbol used to draw the computed points, line selects
%   the symbol used to draw lines between the computed points, color
%   defines the color of the plot, width controls the width of the line.
%   Finally, the boxes red - green - blue allows to finely adjust the
%   color of the line.
%
%   print opens the print control panel that allows to save the figure or
%   print it with various options.
%
%   close figure closes the selected view and all its subplots.
%

% This Software is ( Copyright INRIA . 1998 2009  1 )
% 
% INRIA  holds all the ownership rights on the Software. 
% The scientific community is asked to use the SOFTWARE 
% in order to test and evaluate it.
% 
% INRIA freely grants the right to use modify the Software,
% integrate it in another Software. 
% Any use or reproduction of this Software to obtain profit or
% for commercial ends being subject to obtaining the prior express
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

