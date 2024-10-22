function cat_batch_long(namefile,output_surface,large_changes,cat_defaults)
% wrapper for using batch mode (see cat_batch_long.sh)
%
% namefile       - array of file names
% output_surface - enable surface estimation
% cat_defaults   - use this default file instead of cat_defaults.m
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
% $Id: cat_batch_long.m 1791 2021-04-06 09:15:54Z gaser $

if nargin < 1
  fprintf('Syntax: cat_batch_long(namefile)\n');
  exit
end

if nargin < 2
  output_surface = 1;
else
  % string argument has to be converted 
  if isstr(output_surface)
    output_surface = str2num(output_surface);
  end
  if isstr(large_changes)
    large_changes = str2num(large_changes);
  end
end

fid = fopen(namefile,'r');
names = textscan(fid,'%s');
names = names{:};
fclose(fid);

n = length(names);

if n == 0, error('No file found in %s.\n',namefile); end

global defaults cat matlabbatch

spm_get_defaults;

if nargin < 3
    cat_get_defaults;
else
  if isempty(cat_defaults)
    cat_get_defaults;
  else
    fprintf('Use defaults in %s.\n',cat_defaults);
    [pp, name] = spm_fileparts(cat_defaults);
    clear cat_defaults
    oldpath = pwd;
    cd(pp)
    eval(name);
    cd(oldpath)
  end
end

matlabbatch{1}.spm.tools.cat.long.datalong.subjects{1} = names;
matlabbatch{1}.spm.tools.cat.long.nproc = 0;
matlabbatch{1}.spm.tools.cat.long.modulate = 1;

if output_surface == 1
  matlabbatch{1}.spm.tools.cat.long.output.surface = 1;
else
  matlabbatch{1}.spm.tools.cat.long.output.surface = 0;
end

if large_changes == 1
  matlabbatch{1}.spm.tools.cat.long.longmodel = 2;
else
  matlabbatch{1}.spm.tools.cat.long.longmodel = 1;
end

warning off
try
  % use expert mode for long. batch
  cat12('expert')
  spm_jobman('initcfg');
  spm_jobman('run',matlabbatch);
catch %#ok<CTCH> % catch with lasterror is necessary for old matlab versions
  caterr = lasterror;  %#ok<LERR>
  fprintf('\n%s\nCAT Preprocessing error: %s:\n%s\n', repmat('-',1,72),caterr.identifier,caterr.message,repmat('-',1,72));
  for si=1:numel(caterr.stack), cat_io_cprintf('err',sprintf('%5d - %s\n',caterr.stack(si).line,caterr.stack(si).name)); end;
  cat_io_cprintf('err',sprintf('%s\\n',repmat('-',1,72)));  
  error('Batch failed.');
end

spm_unlink(char(namefile))

warning off
exit
