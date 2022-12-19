function varargout=fl_type_main(fl_variable)
% FRACALAB functions
%
% Usage: [var1 .. varn]=fl_type_main(fl_variable)
%
% If "fl_variable" is a FRACLAB cell type, fl_type_main returns the 
% "n significative fields" of "fl_variable", which is by default the second
% field (the first denoting the variable type).
% Otherwise, fl_type_main simply returns the input.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if iscell(fl_variable)
  switch(fl_variable{1})
    otherwise
      varargout{1}=fl_variable{2};
  end
else
  varargout{1}=fl_variable;
end