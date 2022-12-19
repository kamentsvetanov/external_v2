function ts = MU_tsuite_create(tsuite)
% MU_tsuite_create -- Create and load a test tsuite.
%
%****f* lib.tsuite/MU_tsuite_create
%
% NAME
%   MU_tsuite_create -- Create and load a test tsuite.
%
% SYNOPSIS
%   ts = MU_tsuite_create(tsuite)
%
% INPUTS
%   * tsuite -- name of test suite (string or function handle).
%
% OUTPUTS
%   * ts     -- loaded tsuite struc (tsuite_s).
%
% DESCRIPTION
%   Function creates via MU_tcase_new and loads the tsuite found 
%   in tsuite file (tsuite) or function handle (@tsuite).
%
% EXAMPLE
%   tsuite = 'mytestsuite';
%   ts = MU_tsuite_create(tsuite);         % use a filename.
%   ts = MU_tsuite_create(@tsuite);        % use a function handle
%
% ERRORS
%   MUNIT:MissingRequiredArgument
%   MUNIT:UnknownTestSuite
%
% SEE ALSO
%   MU_tcase_new
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   MUNIT Library:  Test Suite Functions
%
%***

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Apr-27
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 112 $
%

%   $Id: MU_tsuite_create.m 112 2005-09-13 05:53:51Z ccornish $

if(~exist('tsuite', 'var') || isempty(tsuite))
  error('MUNIT:MissingRequiredArgument', ...
        [mfilename, ' requires a tsuite argument.']);
end

if (isa(tsuite, 'function_handle'))
  ts_file = func2str(tsuite);
  pathstr = '';
else
  [pathstr, name, ext, versn] = fileparts(tsuite);
  if (~isempty(pathstr))
    ts_file = name;
  else
    ts_file = tsuite;
  end
end

%% Verify that tsuite function file exists current path
if (isempty(pathstr))
  if (isempty(which(ts_file)))
    error('MUNIT:UnknownTestSuite', ...
          ['TestSuite (', ts_file, ') not found']);
  end
%% else, verify tsuite function file exists in alternate path
else
  if (~exist(fullfile(pathstr, [name '.m'])))
    error('MUNIT:UnknownTestSuite', ...
          ['TestSuite (', ts_file, ') not found']);
  end
end    


curpath = pwd;
try
  if (~isempty(pathstr))
    cd(pathstr);
  end
  ts = feval(ts_file);
  if (~isempty(pathstr))
    cd(curpath);
  end
catch
  err = lasterror;
  cd(curpath);
%    rethrow(err);
  error('MUNIT:MU_tsuite_case:creationError', ...
        ['Error creating test suite (', ts_file, ').']);
end

ts.pathstr = pathstr;

return

