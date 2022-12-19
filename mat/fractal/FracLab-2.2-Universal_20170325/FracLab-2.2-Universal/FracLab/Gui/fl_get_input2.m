function [varname,flag_error]=fl_get_input(varargin);
% FRACLAB function
%
% This function had been changed, all the remarks under there will be
% changed to fit the new possibilities...
% anyway, usage stay the same.
%
% Usage: [varname,flag_error]=fl_get_input([fl_type]);
%
% Gets the name of the currently highlighted variable
% from the input listbox. Also checks that its type
% is "fl_type" (this parameter may be omitted).
%    Possiblities are:
%	- 'vector' (anything but not a cell that is [1*n] or [n*1]).
%	- 'matrix' (anything but not a cell).
%	- any other type name. The input must be a cell, which first
%         element is the type name ("cwt","dwt"). This can be used
%	  to store more than one element in an input/ouput variable.
%
% flag_error = 1 if the type is not correct, 0 otherwise.  

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

lbh=findobj('Tag','Listbox_variables');
var=get(lbh,'String');

if (~iscell(var))|(isempty (var))
  flag_error=1;
  varname='';
  return;
end

values=get(lbh,'Value');
val=values(1);

varname=strtok(var{val});

if ~exist(varname)
  eval(['global ' varname]);
end

flag_error = 1;

if isempty(varargin)
  % flag_error = 0 by default if varargin is empty
  flag_error = 0;
end  

if(nargin==1)
  switch(varargin{1})
    case 'real'
      eval (['flag_num = isnumeric (' varname ');']);flag_num
      eval (['flag_size = size (' varname ');']);	flag_size
      if ( flag_num & ((flag_size(1) == 1 ) & (flag_size(2) == 1)))
	flag_error = 0;
      end	  
    case 'vector'
      eval (['flag_num = isnumeric (' varname ');']);
      eval (['flag_size = size (' varname ');']);	
      if ( flag_num & ((flag_size(1) == 1 ) | (flag_size(2) == 1)))
	flag_error = 0;
      end	
%	eval(['flag_cell=iscell(' varname ');']);
%	if(flag_cell==1)
%	  flag_error=1;
%	else
%	  eval(['temp=size(' varname ');']);
%	  if ( (temp(1)~=1) & (temp(2)~=1) )
%	    flag_error=1;
%	  end
%	end
    case 'matrix'
	eval(['flag_matrix = isnumeric(' varname ');']);
	if flag_matrix
	  flag_error = 0;
	end
	
      case 'cwt'
	eval (['flag_struct = isstruct (' varname ');']);
	if flag_struct
	  temp = eval (varname);
	  if (temp.type == 'cwt')
	    flag_error = 0;
	  end
	end  
     case 'graph'
	eval (['flag_struct = isstruct (' varname ');']);
	if flag_struct
	  temp = eval (varname);
	  if (temp.type == 'graph')
	    flag_error = 0;
	  end
	end
     case 'dwt'
	eval (['flag_struct = isstruct (' varname ');']);
	if flag_struct
	  temp = eval (varname);
	  if (temp.type == 'dwt')
	    flag_error = 0;
	  end
	end
     case 'dwt2d'
	eval (['flag_struct = isstruct (' varname ');']);
	if flag_struct
	  temp = eval (varname);
	  if (temp.type == 'dwt2d')
	    flag_error = 0;
	  end
	end		
%    otherwise
%	eval(['flag=iscell(' varname ');']);
%	if flag
%	  flag_error=1;
%	else
%	  eval(['s_type=' varname '{1};']);
%	  if ~strcmp(s_type,fl_type)
%	    flag_error=1;
%	  end
%	end
  end
end







