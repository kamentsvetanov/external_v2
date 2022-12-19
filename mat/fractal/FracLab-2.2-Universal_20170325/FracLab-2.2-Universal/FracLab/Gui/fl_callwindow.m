function fl_callwindow(tag,gui_name)
% Usage: fl_callwindow(tag,gui_name)
%
% Call the GUI window "gui_name" which tag is "tag".
% If the window is already present, just puts it in foreground.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

figh=findobj('Tag',tag);
if isempty(figh)
  eval(gui_name);
else
  figure(figh);
end