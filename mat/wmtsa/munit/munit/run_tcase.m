function tc_summary = run_tcase(tcase, mode, logfile, test_list)
% run_tcase -- Run a MUnit test case and print the test results.
%
%****f* Drivers/run_tcase
%
% NAME
%   run_tcase -- Run a MUnit test case and print the test results.
%
% SYNOPSIS
%   tc_summary = run_tcase(tcase, [mode], [logfile], [test_list])
%
% INPUTS
%   * tcase        -- test case (string, function handle, or tcase_s).
%   * mode         -- (optional) level of detail for output diagnostics.
%   * logfile      -- (optional) name of log file for writing output.
%   * test_list    -- (optional) name(s) or ordinal number(s) of specific tests
%                     to run.
%                     (string or integer, or cell array of strings or integer).
%
% OUTPUTS
%   * tc_summary   -- test case summary struct (tc_summary_s).
%
% SYNOPSIS
%   run_tcase(tcase)                       % default
%   run_tcase(tcase, mode)                 % specify level of detail mode.
%   run_tcase(tcase, '', logfile)          % specify log file.
%   run_tcase(tcase, '', '', test_list)    % specify tests to run.
%
% SIDE EFFECTS
%
%
% DESCRIPTION
%   run_tcase is the main driver for running a test case.
%
%   tcase is one of the following:
%    * string containing name of test case (i.e. file/function) to run.
%    * function handle of the test case to run (@tcase).
%    * a test case struct (tcase_s).
%
%   The mode argument controls level of detail of output as follows:
%    * 'silent'    -- no output.
%    * 'minimal'   -- print test case summary.
%    * 'normal'    -- print names of failed  tests and test case summary.
%    * 'verbose'   -- print all test names and their status, and test case summary.
%    * 'details'   -- print diagnostics while running tests as well all test names 
%                     and their status, and test case summary.
%
%   If logfile is specified, output is written to logfile.
%   Note that info printed by tested functions is still displayed to command window.
% 
%   The test_list argument allows the optional execution of specific test(s)
%   within test case.  By default, all tests within a test case are run.  
%   If test_list is a string or cell array of strings, then the tests with the 
%   matching names are run.  If test_list is a number or cell array of numbers, 
%   then the tests with matching order in the test list are run, i.e. 
%   if test_list = {1, 3}, then the first and third tests are run.  If items
%   in test_list that do not match by test name or test order number are ignored.
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
%   Application Drivers
%

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Apr-28
%
% COPYRIGHT
%   (c) 2004, 2005 Charles R. Cornish
%
% CREDITS
%
%
% REVISION
%   $Revision: 112 $
%
%***

%   $Id: run_tcase.m 112 2005-09-13 05:53:51Z ccornish $

usage_str = ['Usage:  [tc_summary] = ', mfilename, ...
             '(tcase, [mode], [logfile], [test_list])'];

if (nargin < 1 || nargin > 4)
  error(usage_str);
end

tcname = '';
if (isa(tcase, 'function_handle'))
  tc = MU_tcase_create(tcase);
  tcname = func2str(tcase);
%  tc.pathstr = '';
elseif (isa(tcase, 'char'))
%  [pathstr, name, ext, versn] = fileparts(tcase);
%  curpath = pwd;
%  try
%    if (~isempty(pathstr))
%      cd(pathstr);
%      tcname = name;
%    else
%      tcname = tcase;
%    end
%    tc = MU_tcase_create(tcname);
    tc = MU_tcase_create(tcase);
%    if (~isempty(pathstr))
%      cd(curpath);
%      tc.pathstr = pathstr;
%    end
%  catch
%    err = lasterror;
%    cd(curpath);
%    rethrow(err);
%  end
elseif (isa(tcase, 'struct'))
  tc = tcase;
  tcname = tc.name;
else
  error('MUNIT:unknownTestCase', ...
        ['tcase is not a valid name, function handle, or struct', ...
         ' for a test case']);
end

if (~exist('mode', 'var') || isempty(mode))
  mode = 'normal';
end

if (exist('logfile', 'var') && ~isempty(logfile))
  if (exist(logfile, 'file'))
    delete(logfile);
  end
  diary(logfile);
end

% Verify that tc is a tcase_s.
if (~isfield(tc,'name') || ~isfield(tc,'tests'))
  if (ischar(tcase))
    name = tcase;
  elseif (isa(tcase, 'function_handle'))
    name = func2str(tcase);
  else
    name = '';
  end
  error('MUNIT:InvalidTestCase', ...
        ['tcase (', name, ') is not a valid test case structure.']);
end

%% Change direction to location of tcase file.

%% Generate of list of tests to run.
run_all_tests = 1;
if (exist('test_list', 'var') && ~isempty(test_list))
  run_all_tests = 0;
  if (ischar(test_list))
    test_name_list = {test_list};
  elseif (iscellstr(test_list))
    test_name_list = test_list;
  elseif (isnumeric(test_list))
    test_name_list = {};
    ii = 0;
    for (i = 1:length(test_list))
      test_num = test_list(i);
      if (test_num <= length(tc.tests))
        ii = ii + 1;
        test_name_list{ii} = func2str(tc.tests{test_num});
      else
        warning(['Specified test number (', num2str(test_num), ...
                 ') is out of range of number of available tests', ...
                 '(', num2str(length(tc.tests)), ')']);
      end
    end
  else
    error('MUNIT:invalidArgumentType', ...
          ['Argument (test_list) must be string or cell array of strings or ', ...
           'a numeric scalar or array']);
  end
  if (isempty(test_name_list))
    warning(['No matches found for specified tests.']);
    return
  end
end


%% Run the tests

if (~strcmp(mode, 'silent'))
  disp(['Start Test Case: ', tc.name]);
  disp(['             at: ', datestr(now, 31)]);
  disp(' ');
end


%% Start timer
startWallTime = clock;
startCPUTime = cputime;

if (run_all_tests)
  tresults = MU_tcase_run(tc, mode);
else
  tresults = MU_tcase_run(tc, mode, test_name_list);
end


%% Summarize and print test results.
MU_print_tresults_report(tcname, tresults, mode);

tc_summary = MU_summarize_tresults(tc, tresults);
MU_print_tcase_summary(tc_summary, mode);

%% Stop timer
stopWallTime = clock;
stopCPUTime = cputime;

%% Change back to original direectory
%% if (~isempty(tc.pathstr))
%%    cd(curpath);
%% end


elapsedWallTime = etime(stopWallTime, startWallTime);
elapsedCPUTime = stopCPUTime - startCPUTime;
tc_summary.elapsedWallTime = elapsedWallTime;
tc_summary.elapsedCPUTime = elapsedCPUTime;

%% Print tcase results.

if (~strcmp(mode, 'silent'))
  disp(' ');
  disp(['Finished Test Case: ', tc.name]);
  disp(['                at: ', datestr(now, 31)]);
  disp(['      Elapsed Time: ', num2str(elapsedWallTime), ' sec.']);
  disp(['  Elapsed CPU Time: ', num2str(elapsedCPUTime), ' sec.']);
  disp(' ');
end

diary off;

return

  
