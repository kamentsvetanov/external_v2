function gui_figure()
% This is the machine-generated representation of a MATLAB object
% and its children.  Note that handle values may change when these
% objects are re-created. This may cause problems with some callbacks.
% The command syntax may be supported in the future, but is currently 
% incomplete and subject to change.
%
% To re-open this system, just type the name of the m-file at the MATLAB
% prompt. The M-file and its associtated MAT-file must be on your path.

% Modified by Christian Choque Cortez, October 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                              ATTENTION
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% the number of items present in this gui is used by some functions
% (in fl_view_toolbar). There is four childrens, this number
% must not be changed without the proper changes in the afected
% functions ...

% UserData(1) = Vsplit
% UserData(2) = Hsplit
% UserData(3) = rotate flag
% UserData(4) = zoom flag
% UserData(5) = hold flag
% UserData(6) = superpose flag

a = figure('MenuBar','none', ...
   'Units','Normalized', ...
   'CloseRequestFcn','fl_figure (''close'');', ...
   'Position',[0.125 0.17 0.44 0.43], ...
   'Tag','Temp', ...
   'UserData', [1,1,0,0,0,0]);


fl_window_init(a,'Figure');