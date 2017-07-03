function [file_names,no_groups] = wfu_bpm_get_file_names( mod_file_name )
%________________________________________________________________________
%  This function reads the content of the modality and flist files giving
%  back the file names of the subjects classified by groups.
%________________________________________________________________________
% Input Parameters
% mod_file_name - the path and name of the modality file.
%________________________________________________________________________
% Output parameters
% file_names - is a cell containing as many elements as groups in the
%              current modality. Each element will be a cell with as many
%              elements as subjects in the corresponding group.
% no_groups  - Number of groups in the current modality.
%________________________________________________________________________

%no_groups = 1;
%% file_names = cell(no_groups);
%fp_grp_list = fopen(mod_file_name);
%
%while (feof(fp_grp_list) == 0 )
%    grp_name = fgetl(fp_grp_list);   
%    % Reading the flist
%    file_names{no_groups} = wfu_bpm_read_flist(grp_name);
%    no_groups = no_groups + 1;
%end
%
%no_groups = no_groups-1;

%grpname = textread(mod_file_name, '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', 0);
grpname = textread(deblank(mod_file_name), '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', 0);
no_groups = size(grpname, 1);
for i = 1:no_groups
    file_names{i} = wfu_bpm_read_flist(grpname{i});
end
