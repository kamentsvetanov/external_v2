function tse = MU_tsensemble_create(tsensemble)

if(~exist('tsensemble', 'var') || isempty(tsensemble))
  error('MUNIT:MissingRequiredArgument', ...
        [mfilename, ' requires a tsensemble argument.']);
end

if (isa(tsensemble, 'function_handle'))
  tse_file = func2str(tsensemble);
  pathstr = '';
else
  [pathstr, name, ext, versn] = fileparts(tsensemble);
  if (~isempty(pathstr))
    tse_file = name;
  else
    tse_file = tsensemble;
  end
end

%% Verify that tsensemble function file exists current path
if (isempty(pathstr))
  if (isempty(which(tse_file)))
    error('MUNIT:UnknownTestsensemble', ...
          ['Testsensemble (', tse_file, ') not found']);
  end
%% else, verify tsensemble function file exists in alternate path
else
  if (~exist(fullfile(pathstr, [name '.m'])))
    error('MUNIT:UnknownTestsensemble', ...
          ['Testsensemble (', tse_file, ') not found']);
  end
end    


curpath = pwd;
try
  if (~isempty(pathstr))
    cd(pathstr);
  end
  tse = feval(tse_file);
  if (~isempty(pathstr))
    cd(curpath);
  end
catch
  err = lasterror;
  cd(curpath);
%    rethrow(err);
  error('MUNIT:MU_tsensemble_case:creationError', ...
        ['Error creating test suite ensemble (', tse_file, ').']);
end

return


