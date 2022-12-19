function [varname,flag_error]=fl_get_input(varargin)
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
%	- 'matrix' (anything but not a cell or a vector).
%	- any other type name. The input must be a cell, which first
%         element is the type name ("cwt","dwt"). This can be used
%	  to store more than one element in an input/ouput variable.
%
% flag_error = 1 if the type is not correct, 0 otherwise.

% Modif O. Barrière
% if nothing is selected, this fonction no longer return an empty string ''
% but a variable called NoData equal to []
% ==> No more errors like
% ??? Error: Incomplete or misformed expression or statement.
% ...
%  eval(['global ' SigIn_name]) ;

% Modified by Olivier Barrière, February 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

lbh=findobj('Tag','Listbox_variables');
var=get(lbh,'String');

if ~iscell(var) || isempty(var)
    flag_error = 1;
    varname='NoData';
    NoData = []; %#ok<NASGU>
    return;
end

values = get(lbh,'Value');
val = values(1);

varname = strtok(var{val});

if ~exist(varname)
    eval(['global ' varname]);
end

flag_error = 1;

if isempty(varargin) % flag_error = 0 by default if varargin is empty
    flag_error = 0;
end

if(nargin==1)
    switch(varargin{1})
        case 'vector'
            eval (['flag_num = isnumeric (' varname ');']);
            eval (['flag_size = size (' varname ');']);
            if flag_num && (flag_size(1) == 1 || flag_size(2) == 1)
                flag_error = 0;
            end

        case 'matrix'
            eval(['flag_matrix = isnumeric(' varname ');']);
            eval (['flag_size = size (' varname ');']);
            if flag_matrix && flag_size(1) ~= 1 && flag_size(2) ~= 1
                flag_error = 0;
            end

        case 'cwt'
            eval (['flag_struct = isstruct (' varname ');']);
            if flag_struct
                temp = eval (varname);
                if strcmp(temp.type,'cwt')
                    flag_error = 0;
                end
            end
        case 'graph'
            eval (['flag_struct = isstruct (' varname ');']);
            if flag_struct
                temp = eval (varname);
                if strcmp(temp.type,'graph')
                    flag_error = 0;
                end
            end
        case 'dwt'
            eval (['flag_struct = isstruct (' varname ');']);
            if flag_struct
                temp = eval (varname);
                if strcmp(temp.type,'dwt')
                    flag_error = 0;
                end
            end
        case 'dwt2d'
            eval (['flag_struct = isstruct (' varname ');']);
            if flag_struct
                temp = eval (varname);
                if strcmp(temp.type,'dwt2d')
                    flag_error = 0;
                end
            end
    end
end

