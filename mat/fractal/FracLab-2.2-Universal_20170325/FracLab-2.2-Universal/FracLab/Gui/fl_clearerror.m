function fl_clearerror()
% FRACLAB function
% Clear the text of the StaticText dedicated to error messages.
% No input/output.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

  sth=findobj('Tag','StaticText_error');
  set(sth,'String','');

