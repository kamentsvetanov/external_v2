function list_tsuite(tsuite, logfile)
% list_tsuite -- List the test cases in a MUnit test suite.
%
%****f* Utilities/list_tsuite
%
% NAME
%   list_tsuite -- List the test cases in a MUnit test suite.
%
% SYNOPSIS
%   list_tsuite(tsuite, [logfile])
%
% INPUTS
%   * tsuite       -- test suite (string or function handle).
%   * logfile      -- (optional) name of log file for writing output.
%
% OUTPUTS
%   (none)
%
% USAGE
%   list_tsuite(tsuite)                       % default
%   list_tsuite(tsuite, logfile)              % specify log file.
%
% SIDE EFFECTS
%   Prints the names of the test cases in the specified test suite.
%
% DESCRIPTION
%   list_tsuite is a utility application for listing test cases in a test suite.
%
%   tsuite is one of the following:
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
%   MUNIT:UnknownTestSuite
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
%   $Revision: 82 $
%
%***

%   $Id: list_tsuite.m 82 2005-02-15 01:01:44Z ccornish $

usage_str = ['Usage:  ', mfilename, ...
             '(tsuite, [logfile])'];


if (nargin < 1 || nargin > 2)
  error(usage_str);
end

if (isa(tsuite, 'function_handle'))
  ts = MU_tsuite_create(tsuite);
elseif (isa(tsuite, 'char'))
  ts = MU_tsuite_create(tsuite);
elseif (isa(tsuite, 'struct'))
  ts = tsuite;
else
  error('MUNIT:UnknownTestSuite', ...
        ['tsuite is not a valid name, function handle, or struct', ...
         ' for a test suite']);
end

if (exist('logfile', 'var') && ~isempty(logfile))
  if (exist(logfile, 'file'))
    delete(logfile);
  end
  diary(logfile);
end

disp(['List of test cases for test suite:  ', ts.name]);
disp('');

MU_tsuite_list_tcases(ts);

diary off;

return
