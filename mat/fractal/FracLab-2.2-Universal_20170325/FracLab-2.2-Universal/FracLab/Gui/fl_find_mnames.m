function varargout=fl_find_mnames(varargin)
% FRACLAB Toolbox function
%
% Usage: [vname1 ... vnamen ]=fl_findname(env_names,prefix1, ... , prefixn)
%
% Finds variable names ("vname1", ... , "vnamen") that have the prefix
% "prefix1", ... , "prefix" not already used in the matlab env ("envname").
% In facts, the suffix number added to the end of each prefix is the 
% fisrt index avaible simoultaneously for each prefix.
% Typically "envname" is given by "who" call performed in the MATLAB WorkSpace.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

for j=1:nargout
  varargout{j}='';
end

if ( nargin == (nargout+1) )
  env_names=varargin{1};
  k=0;
  l=length(varargin{1});
  while 1
    unique=1;
    for j=1:nargout
      temp=[varargin{j+1} num2str(k)];
      for i=1:l
	if strcmp(env_names(i),temp)
	  unique=0;
	end
      end
    end
    if unique
      for j=1:nargout
	varargout{j}=[varargin{j+1} num2str(k)];
      end
      return
    end
    k=k+1;
  end
  
end