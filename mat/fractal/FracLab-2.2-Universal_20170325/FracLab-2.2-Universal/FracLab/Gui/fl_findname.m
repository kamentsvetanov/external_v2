function vname=fl_findname(prefix,env_names)
% FRACLAB Toolbox function
%
% Usage: vname=fl_findname(prefix,env_names)
%
% Finds a variable name ("vname") that have the prefix "prefix"
% not already used in the matlab env ("envname").
% Typically "envname" is given by "who" call performed in the MATLAB WorkSpace.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

k=0;
l=length(env_names);
while 1
  temp=[prefix num2str(k)];
  unique=1;
  for i=1:l
    if strcmp(env_names(i),temp)
      unique=0;
    end
  end
  if unique
    vname=temp;
    return
  end
  k=k+1;
end
