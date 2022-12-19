function list_tcase(tcase, logfile)
% list_tcase -- List the tests in a MUnit test case.
%
%****f* Utilities/list_tcase
%
% NAME
%   list_tcase -- List the tests in a MUnit test case.
%
% SYNOPSIS
%   list_tcase(tcase, [logfile])
%
% INPUTS
%   * tcase        -- test case (string or function handle).
%   * logfile      -- (optional) name of log file for writing output.
%
% OUTPUTS
%   (none)
%
% USAGE
%   list_tcase(tcase)                       % default
%   list_tcase(tcase, logfile)              % specify log file.
%
% SIDE EFFECTS
%   Prints the tests in the specified test case.
%
% DESCRIPTION
%   list_tcase is a utility application for listing tests in a test case.
%
%   tcase is one of the following:
%    * string containing name of test case (i.e. file/function) to run.
%    * function handle of the test case to run.
%    * a test case struct.
%
%   If logfile is specified, output is written to logfile.
%
% EXAMPLE
%
%
% WARNINGS
%
%
% ERRORS
%   MUNIT:UnknownTestCase
%
% NOTES
%
%
% BUGS
%
%
% TODO
%
%
% ALGORITHM
%
%
% REFERENCES
%
%
% SEE ALSO
%
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   Application Utilties
%

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2005-Nov-08
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 84 $
%
%***

%   $Id: list_tcase.m 84 2005-02-15 01:03:48Z ccornish $

usage_str = ['Usage:  ', mfilename, ...
             '(tcase, [logfile])'];


if (nargin < 1 || nargin > 2)
  error(usage_str);
end

if (isa(tcase, 'function_handle'))
  tc = MU_tcase_create(tcase);
elseif (isa(tcase, 'char'))
  tc = MU_tcase_create(tcase);
elseif (isa(tcase, 'struct'))
  tc = tcase;
else
  error('MUNIT:UnknownTestCase', ...
        ['tcase is not a valid name, function handle, or struct', ...
         ' for a test case']);
end

if (exist('logfile', 'var') && ~isempty(logfile))
  if (exist(logfile, 'file'))
    delete(logfile);
  end
  diary(logfile);
end

disp(['List of tests for test case:  ', tc.name]);
disp('');

MU_tcase_list_tests(tc);


diary off;

return
