function wfu_startup
%
% wfu_startup
%       initialize WFU toolboxes, adding paths above any SPM path
%________________________________________________________________________
% specify which WFU toolboxes to reference (0 = no, 1 = yes)
%
% dependencies:
%       bpm             requires    insertion_tool
%       insertion_tool  requires    utilities
%________________________________________________________________________
add_bpm = 1;
add_insertion_tool = 1;
add_utilities = 1;
add_compatibility = 0;
add_pickatlas = 1;
%________________________________________________________________________
%
add_toolboxes = [   add_bpm ...
                    add_insertion_tool ...
                    add_utilities ...
                    add_compatibility ...
                    add_pickatlas];

add_pathname = {    'wfu_bpm'; ...
                    'wfu_insertion_tool'; ...
                    'wfu_utilities'; ...
                    'wfu_compatibility'; ...
                    'wfu_pickatlas'};
%
% check dependencies
%________________________________________________________________________
%
if add_bpm
    add_insertion_tool = 1;
end
if add_insertion_tool
    add_utilities = 1;
end
%________________________________________________________________________
%
if any(add_toolboxes)
    wfu_dir = fileparts(which('wfu_startup'));
    if isempty(wfu_dir)
        error('Add the wfu_toolboxes directory to path before calling wfu_startup.');
    end
    disp('Adding WFU toolboxes to path');
    n = length(add_pathname);
    for i = 1:n
        if add_toolboxes(i)
            wfu_path = fullfile(wfu_dir, add_pathname{i});
            disp(['... ' wfu_path]);
            addpath(wfu_path);
        end
    end
end
