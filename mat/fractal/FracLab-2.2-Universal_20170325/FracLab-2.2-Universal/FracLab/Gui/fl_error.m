function fl_error(message)
% FRACLAB ToolBox function
%
% Usage : fl_error(message) 
%
% open a Figure to display an error message
% if no message is given to input if fl_error, a default message is displayed
%
% inputs: message: string contains the message to be displayed
% outputs: none

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

beep;
if nargin==0
  % default message
  errordlg('Error. Some parameters may be inconsistent. Please re-enter values for these parameter','FracLab Error');
else
  errordlg(message,'FracLab Error');
end
