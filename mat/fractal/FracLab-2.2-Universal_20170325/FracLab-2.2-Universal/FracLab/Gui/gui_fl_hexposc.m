function fig = gui_fl_hexposc()
% FILE:  gui_fl_hexposc.m
% DESCRIPTION: This file contains the graphical user interface for the module
% 		fl__hexposc_compute which computes the Holder exponent a variety
%		of ways using the oscillation of a the input signal.
%		Attempts have been made to make this interface consistent with the
%		gui_fl_ocsP.m interface provided by Bertrand Guiheneuf

% Author Jon C. Weil, Cambridge CB1 2NU, June 1999

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Create the gui figure, assign its Tag
a = figure( ...
	'HandleVisibility','callback', ...
	'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
	'Position',[422 314 401 400], ...
	'Tag','Fig_gui_fl_hexposc');
	
% Frame for title	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.339152435453639, ...
	'ListboxTop',0, ...
	'Position',[0.0298754 0.898052 0.947755 0.0884558], ...
	'Style','frame', ...
	'Tag','frm_Title');
	
% Create Standard buttons for Fraclab interfaces
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_hexposc_compute(''close'');', ...
	'FontSize',0.387096774193548, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.7231920199501247 0.0725 0.1770573566084788 0.0775], ...
	'String','Close', ...
	'Tag','pshbut_close');
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','eval([''global ''fl_hexposc_compute(''compute'',who);]);', ...
	'FontSize',0.387096774193548, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.102244389027431 0.07000000000000001 0.1745 0.0775], ...
	'String','Compute', ...
	'Tag','pshbut_compute');
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.6, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.142762 0.920001 0.726625 0.05], ...
	'String','Pointwise Holder exponent (oscillation method)', ...
	'Style','text', ...
	'Tag','txt_Title');
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_hexposc_compute(''help'');', ...
	'FontSize',0.387096774193548, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.406483790523691 0.07000000000000001 0.174563591022444 0.0775], ...
	'String','Help', ...
	'Tag','pshbut_help');
	
% input frame	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.272727272727273, ...
	'ListboxTop',0, ...
	'Position',[0.0298754 0.771251 0.947755 0.11], ...
	'Style','frame', ...
	'Tag','frm_input');

% input name	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.6, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[0.08 0.79425 0.25 0.05], ...
	'String','Input data name', ...
	'Style','text', ...
	'Tag','txt_inputSignalString');
% There was a bug here: tag txt_inputSignal appeared twice.

% Refresh button to get Signal if necessary
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'Callback','fl_hexposc_compute(''refresh'');', ...
	'FontSize',0.4, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.77 0.78625 0.175 0.075], ...
	'String','Refresh', ...
	'Tag','pshbut_refresh');
	
% Edit Text for Input Signal Name
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontSize',0.6, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[0.34 0.79925 0.4 0.05], ...
	'Style','edit', ...
	'Enable','inactive',...
	'Tag','txt_inputSignal');
	
% Frame	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Position',[0.03 0.54 0.45 0.2225], ...
	'Style','frame', ...
	'Tag','frm_oscest');
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Position',[0.5336658354114709 0.3475 0.438902743142145 0.4125], ...
	'Style','frame', ...
	'Tag','frm_ballseq');
	
% Popup Menu for estimation techniques	
% Change back when all options are implemented -Bertrand 
%matest{1}='Osc_cont = Osc_disc';
matest{1}='P(Osc_cont | Osc_disc)';
%matest{3}='Alpha Uniform Prior';
matest{2}='Osc. Uniform Prior';
matest{3}='Local Time Prior';
%matest{6}='Custom Prior';
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Min',1, ...
	'Max',2, ...
	'Position',[0.06 0.6 0.384039900249377 0.07000000000000001], ...
	'String',matest, ...
	'Style','popupmenu', ...
	'Tag','popmen_oscest', ...
	'Callback','fl_hexposc_compute(''ppm_oscest'');', ...
	'Value',2);
	
% Popup Menu for ball sequences	
matseq{1}='Regular';
matseq{2}='Default Subsample Seq';
matseq{3}='Custom Subsample Seq';
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Min',1, ...
	'Max',2, ...
	'Position',[0.5610972568578551 0.6 0.376558603491272 0.07000000000000001], ...
	'String',matseq, ...
	'Style','popupmenu', ...
	'Callback','fl_hexposc_compute(''ppm_ballseq'');', ...
	'Tag','popmen_ballseq', ...
	'Value',2, ...
	'Enable', 'off');

	
% Some frame titles...
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.545454545454545, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.0648379052369077 0.6850000000000001 0.374064837905237 0.055], ...
	'String','Oscillation Estimation', ...
	'Style','text', ...
	'Tag','txt_oscest');
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.545454545454545, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.56857855361596 0.6850000000000001 0.374064837905237 0.055], ...
	'String','Ball Sequence', ...
	'Style','text', ...
	'Tag','txt_ballseq');


% If the type of estimation is Osc_cont = Osc_disc, then the type of ball seq
% should be "regular" and these edits specify the max and min radii in such a 
% sequence.	
b = uicontrol('Parent',a, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[229.44 160.32 48.96 22.08], ...
	'Style','edit', ...
	'String','2', ...
	'Tag','edt_minrad', ...
	'Visible','off');
	
b = uicontrol('Parent',a, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[295.68 160.32 48.96 22.08], ...
	'Style','edit', ...
	'String','32', ...
	'Tag','edt_maxrad', ...
	'Visible','off');
	
% Radii title
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',0.631578947368421, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.6209476309226932 0.5225000000000001 0.2319201995012469 0.0475], ...
	'String','Radii', ...
	'Style','text', ...
	'Tag','txt_radii');
	
% Regression frame and title
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Position',[0.03 0.215 0.45 0.305], ...
	'Style','frame', ...
	'Tag','frm_regression');
	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'BackgroundColor',[0.701960784313725 0.701960784313725 0.701960784313725], ...
	'FontSize',0.545454545454545, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.0723192019950125 0.445 0.374064837905237 0.055], ...
	'String','Regression', ...
	'Style','text', ...
	'Tag','txt_regression');
	
% Regression Popup
matreg{1}='Least Squares';
%matreg{2}='Weighted Least Squares';
%matreg{3}='Penalized Least Squares';
matreg{5}='Lepskii Adaptive Procedure';
matreg{4}='Maximum Likelihood';
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Min',1, ...
	'Max',2, ...
	'Position',[0.06 0.38 0.384039900249377 0.07000000000000001], ...
	'String',matreg, ...
	'Style','popupmenu', ...
	'Tag','popmen_regression', ...
	'Value',1, ...
	'Enable', 'off');
	
% Title
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'FontUnits','normalized', ...
	'FontSize',0.428571428571429, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[0.06 0.29 0.384039900249377 0.07000000000000001], ...
	'String','Using', ...
	'Style','text', ...
	'Tag','txt_using', ...
	'Enable', 'off');
	
% This Popup menu specifies which balls will be used in the regression.
% Often a subsequence of balls will have the same value for oscillation
% in this case it may be desirable to select the leftmost or median of
% the plateau.
matuse{1}='All Balls';
matuse{2}='Leftmost of plateau';
matuse{3}='Median of Plateau';
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Min',1, ...
	'Max',2, ...
	'Position',[0.06 0.245 0.384039900249377 0.07000000000000001], ...
	'String',matuse, ...
	'Style','popupmenu', ...
	'Tag','popmen_using', ...
	'Value',1, ...
	'Enable', 'off');
	
% Some titles...	
b = uicontrol('Parent',a, ...
	'Units','points', ...
	'ListboxTop',0, ...
	'Position',[238.08 184.32 32.64 16.32], ...
	'String','min', ...
	'Style','text', ...
	'Tag','txt_minrad', ...
	'Visible','off');
	
b = uicontrol('Parent',a, ...
	'Units','points', ...
	'ListboxTop',0, ...
	'Position',[303.36 183.36 32.64 16.32], ...
	'String','max', ...
	'Style','text', ...
	'Tag','txt_maxrad', ...
	'Visible','off');
	
% Popup menu to specify which sequence is being used...
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[0.5760598503740648 0.4550000000000001 0.3566084788029925 0.0675], ...
	'String','Default_Sequence', ...
	'Style','edit', ...
	'Tag','edt_radii', ...
	'Enable','inactive');

% Button to load a radii sequence file	
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Position',[0.598503740648379 0.3750000000000001 0.1371571072319202 0.0625], ...
	'String','Load', ...
	'Tag','pshbut_loadradii', ...
	'Enable','off');
	
% Button to create/edit a radii sequence file
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Position',[0.7531172069825437 0.3750000000000001 0.1371571072319202 0.0625], ...
	'String','Edit', ...
	'Tag','pshbut_editradii', ...
	'Enable', 'off');
	
% Frame...
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Position',[0.538653366583541 0.2225 0.423940149625935 0.11], ...
	'Style','frame', ...
	'Tag','frm_pntwise');
	
% Button to launch a tool to show effects of regression around a particular point
b = uicontrol('Parent',a, ...
	'Units','normalized', ...
	'ListboxTop',0, ...
	'Position',[0.6458852867830424 0.2425 0.2194513715710723 0.075], ...
	'String','Advanced', ...
	'Tag','pshbut_advanced', ...
	'Enable', 'off');
	
fl_window_init(a);	
	
% Load gui	
%if nargout > 0, fig = a; end
fl_hexposc_compute('refresh');