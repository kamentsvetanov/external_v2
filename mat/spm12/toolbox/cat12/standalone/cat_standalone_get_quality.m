% batch file of volume smoothing for SPM12 standalone installation
%
%_______________________________________________________________________
% $Id: cat_standalone_get_quality.m 1837 2021-05-30 00:42:09Z gaser $

% data field, that will be dynamically replaced by cat_standalone.sh
matlabbatch{1}.spm.tools.cat.tools.quality_measures.data = '<UNDEFINED>';

% Entry for csv output filename
% Remove comments and edit entry if you would like to change the parameter.
% Otherwise the default value from cat_defaults.m is used.
% Or use 1st parameter field, that will be dynamically replaced by cat_standalone.sh
%matlabbatch{1}.spm.tools.cat.tools.quality_measures.csv_name = '<UNDEFINED>';

% Entry for enabling global scaling with TIV
% Remove comments and edit entry if you would like to change the parameter.
% Otherwise the default value from cat_defaults.m is used.
% Or use 1st parameter field, that will be dynamically replaced by cat_standalone.sh
%matlabbatch{1}.spm.tools.cat.tools.quality_measures.globals = '<UNDEFINED>';
