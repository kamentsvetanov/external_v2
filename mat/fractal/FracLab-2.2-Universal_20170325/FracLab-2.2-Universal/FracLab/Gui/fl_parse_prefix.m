function [varargout]=fl_parse_prefix(string)
% prefix=fl_parse_prefix(string)
% [prefix suffix]=fl_parse_prefix(string)
%
% Parse a "string" into a prefix (varargout{1}) containing non numeric
% characters, the rest is assigned to a suffix (varargout{2}, optional).

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if( (nargout==1) | (nargout==2) )
  i=1;
  L=size(string);l=L(2);
  prefix='';
  while( ((isempty(str2num(string(i)))) | (string(i)=='i'))& (i<=l) )
    prefix(i)=string(i);
    i=i+1;
  end
  if(nargout==2)
    suffix='';
    while(i<=l)
      suffix(i)=string(i);
      i=i+1;
    end
    varargout{2}=suffix;
  end
  varargout{1}=prefix;
end