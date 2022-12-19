% No help found

% Modified by Pierrick Legrand, January 2005
% Modified by Olivier Barrière, April 2007

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

lbh3=findobj('Tag','Listbox_imp_type');
if (strcmp(lbh3, 'uint8') == 1)
    fl_warning('Cant work with uint8 variables. Convert it in double.');
    return;
end

fl_import_obj=findobj('Tag','Listbox_imp_name');
fl_import_values=get(fl_import_obj,'Value');
fl_import_list=get(fl_import_obj,'String');
fl_import_temp=size(fl_import_values);
fl_import_l=fl_import_temp(2);
for fl_import_i=1:fl_import_l
    fl_import_val=fl_import_values(fl_import_i);
    fl_import_string=fl_import_list{fl_import_val};
    %   if isempty(whos('global',fl_import_string))    %(~isglobal(fl_import_string))
    %       eval(['global ' fl_import_string]);
    %   end

    % %The variable is local only, and not global => clear the
    % %local copy, make it global with the same value
    %
    %   if ~isempty(who(fl_import_string)) && isempty(who('global',fl_import_string))
    %       eval(['clear ' fl_import_string]);
    %       eval(['global ' fl_import_string]);
    %       eval([fl_import_string '=fl_import_val;']);
    %   end
    %
    % %The variable is both global (hidden) and local to Matlab workspace => the
    % %local value (visible) is kept, local and global variables are cleared, and the
    % %global variable is recreated with the local value.
    %
    %   if ~isempty(who(fl_import_string)) && ~isempty(who('global',fl_import_string))
    %       eval(['clear ' fl_import_string]);
    %       eval(['clear global' fl_import_string]);
    %       eval(['global ' fl_import_string]);
    %       eval([fl_import_string '=fl_import_val;']);
    %   end
    %
    % %The variable is already global with no local => nothing is done :)

    eval(['fl_import_temp_val=' fl_import_string ';']);
    eval(['clear ' fl_import_string]);    
    eval(['clear global ' fl_import_string]);
    eval(['global ' fl_import_string]);
    eval([fl_import_string '=fl_import_temp_val;']);

    fl_addlist(0,fl_import_string);
end
clear fl_import_values fl_import_val fl_import_obj fl_import_string;
clear fl_import_list fl_import_temp fl_import_temp_val fl_import_l fl_import_i;
clear lbh3;