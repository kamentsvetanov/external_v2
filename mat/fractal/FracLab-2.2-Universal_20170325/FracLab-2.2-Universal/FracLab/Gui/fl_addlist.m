function fl_addlist(flag,string)
% FRACLAB ToolBox function
%
% Usage : fl_addlist(flag,varname) 
%
% Adds a variable wich name is "varname" to either
% the Variables list (flag=0) or Details list (flag=1).

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if flag
  lbh=findobj('Tag','Listbox_details');
else
  lbh=findobj('Tag','Listbox_variables');  
end

varcell=get(lbh,'String');
if ~iscell(varcell)  %%% varcell is an empty string
    set(lbh,'String',{string});
    set(lbh,'Value',1);
else % "varcell" is a cell!
  L=size(varcell);l=L(1);
  unique=1;
  for i=1:l
    if(strcmp(varcell{i},string))
       unique=0;
       break;
    end
  end
  if unique
    varcell{l+1}=string;
    set(lbh,'String',varcell);
    set(lbh,'Value',l+1);
  else
    set(lbh,'Value',i);
  end
end
fl_details;







