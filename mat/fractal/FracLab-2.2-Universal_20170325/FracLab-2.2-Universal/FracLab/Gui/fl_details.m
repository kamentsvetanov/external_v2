% Usage : fl_details 
%
% Gets the highlighted var in the "Variables" Listbox and lists it's  
% details in the "Details" Listbox
%
% inputs: var's names
% outputs: none

% Modified by Christian Choque Cortez October 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------


%  * set src and target listbox

listbox_handle_src=findobj('Tag','Listbox_variables');
listbox_handle_target=findobj('Tag','Listbox_details');

%  * get the cell of src listbox
str_cell=get(listbox_handle_src,'String');

% * get the var of src listbox
if iscell(str_cell)
  % case non-empty src listbox
  num_val=get(listbox_handle_src,'Value');
  str_var=strtok(str_cell{num_val(1)});  
else
  % case empty src listbox
  return
end

eval (['global ' str_var]);

%            ****    modify target listbox     ****

% first, clear it 
set (listbox_handle_target,'Value',[]);
set (listbox_handle_target,'String','');

% get the type of the highlighted var in "Variables "

var_properties = whos(str_var);

% * print infos in "details" *
switch(var_properties.class)
    
    case 'double'
        % if var is a matrix, just print its name and dimentions
        str_out{1} = var_properties.name;
        str_out{2} = 'Matrix [ ';
        temp_length = length(var_properties.size);
        for temp_i = 1:(temp_length - 1)
            str_out{2} = [str_out{2},num2str(var_properties.size(temp_i)),' x '];
        end
        str_out{2} = [str_out{2},num2str(var_properties.size(temp_length)),' ]'];
        set (listbox_handle_target,'Value',1);
        set (listbox_handle_target,'String',str_out);
        
    case 'struct'
        % if var is a structure, print its name and fields
        temp_str = [str_var,'.type'];
        str_out{1} = ['Structure of type ',eval(temp_str),' containing :'];
        temp_var = fieldnames(eval(str_var));
        for temp_i = 2:(length(temp_var))
            temp_str = [str_var,'.',temp_var{temp_i}];
            temp_size = size (eval(temp_str));
            temp_length = length(temp_size);
            str_out{temp_i} = ['   ',temp_var{temp_i},'  [ '];
            for temp_j = 1 : ( temp_length - 1 )
                str_out{temp_i} = [str_out{temp_i},num2str(temp_size(temp_j)),' x '];
            end
            str_out{temp_i} = [str_out{temp_i},num2str(temp_size(temp_length)),' ]'];
        end
        set (listbox_handle_target,'Value',1);
        set (listbox_handle_target,'String',str_out);
        
    case 'cell'
        % if var is a cell, print its dimentions
        str_out{1} = 'Cell array containing matrices :';
        str_out{2} = 'Cell [ ';
        temp_length = length(var_properties.size);
        for temp_i = 1:(temp_length - 1)
            str_out{2} = [str_out{2},num2str(var_properties.size(temp_i)),' x '];
        end
        str_out{2} = [str_out{2},num2str(var_properties.size(temp_length)),' ]'];
        set (listbox_handle_target,'Value',1);
        set (listbox_handle_target,'String',str_out);
        
    otherwise
        str_out{1} = 'Variable type not supported';
        set (listbox_handle_target,'Value',1);
        set (listbox_handle_target,'String',str_out);
        
end

clear ('str_out','str_cell','str_var');
clear ('temp_j','temp_var','temp_size','temp_str','temp_i','temp_length');
clear ('num_val','var_properties');
clear listbox_handle_src;
clear listbox_handle_target;

