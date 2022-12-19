function tc = MU_tcase_create(tcase)
% MU_tcase_create -- Create and load a tcase.
%
%****f* lib.tcase/MU_tcase_create
%
% NAME
%   MU_tcase_create -- Create and load a tcase.
%
% SYNOPSIS
%   tc = MU_tcase_create(tcase)
%
% INPUTS
%   * tcase -- name of test case (string or function handle).
%
% OUTPUTS
%   * tc     -- loaded tcase_s struct (tcase_s).
%
% DESCRIPTION
%   Function creates via MU_tcase_new and loads the tcase found 
%   in tcase file (tcase) or function handle (@tcase).
%
% EXAMPLE
%   tcase = 'mytestcase';
%   tc = MU_tcase_create(tcase);         % use a filename.
%   tc = MU_tcase_create(@tcase);        % use a function handle
%
% ERRORS
%   MUNIT:MissingRequiredArgument
%   MUNIT:UnknownTestCase
%
% SEE ALSO
%   MU_tcase_new
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   MUNIT Library:  Test Case Functions
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
%   $Revision: 118 $
%

%   $Id: MU_tcase_create.m 118 2005-10-28 21:57:19Z ccornish $

if(~exist('tcase', 'var') || isempty(tcase))
  error('MUNIT:MissingRequiredArgument', ...
        [mfilename, ' requires a tcase argument.']);
end

pathstr = '';


if (isa(tcase, 'function_handle'))
  tc_file = func2str(tcase);
  pathstr = '';
% else
elseif (isa(tcase, 'char'))
  [pathstr, name, ext, versn] = fileparts(tcase);
  if (~isempty(pathstr))
    tc_file = name;
  else
    tc_file = tcase;
  end
end

%% Verify that tcase function file exists current path
if (isempty(pathstr))
  if (isempty(which(tc_file)))
    error('MUNIT:UnknownTestCase', ...
          ['TestCase (', tc_file, ') not found']);
  end
%% else, verify tcase function file exists in alternate path
else
  if (~exist(fullfile(pathstr, [name '.m'])))
    error('MUNIT:UnknownTestCase', ...
          ['TestCase (', tc_file, ') not found']);
  end
end    

curpath = pwd;
try
  if (~isempty(pathstr))
    cd(pathstr);
  end
  tc = feval(tc_file);
  if (~isempty(pathstr))
    cd(curpath);
  end
catch
  err = lasterror;
  cd(curpath);
  rethrow(err);
%  error('MUNIT:MU_tcase_case:creationError', ...
%        ['Error creating test case (', tcase, ').']);
end

tc.pathstr = pathstr;

return
