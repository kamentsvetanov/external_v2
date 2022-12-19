function tresults = MU_tcase_run(tc, mode, tests_to_run)
% MU_tcase_run  -- Run a tcase.
%
%****f* lib.tcase/MU_tcase_run
%
% NAME
%   MU_tcase_run  -- Run a test case.
%
% SYNOPSIS
%   tresults = MU_tcase_run(tc, [mode], [tests_to_run])
%
% INPUTS
%   * tc              -- loaded test case struct (tcase_s).
%   * mode            -- (optional) mode for level of detail of output (string).
%   * tests_to_run    -- (optional) name(s) of specific tests to run 
%                        (string or cell array of strings).
%
% OUTPUTS
%   * tresults        -- vector of test result structures (tresult_s).
%
% DESCRIPTION
%   Function runs the tests in a test case and returns the
%   test results for each test.
%
%   See MUnit_Variables for a description of mode.
%
%   Note: For all modes, info printed by tested functions is still displayed 
%         to command window.
%
%   The tests_to_run argument allows the optional execution of specific test(s)
%   within test case.  By default, all tests within a test case are run.  
%   If tests_to_run is not empty, then only the tests with the 
%   matching names are run.  
%
% SEE ALSO
%   mode, MU_tcase_run_test, tcase_s, tresult_s
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
%   2004-Apr-28
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

%   $Id: MU_tcase_run.m 112 2005-09-13 05:53:51Z ccornish $

  
if (~exist('mode', 'var') || isempty(mode))
  mode = 'normal';
end

tresults = [];

if (~isempty(tc.pathstr))
  curpath = pwd;
  cd(tc.pathstr)
end

if (~exist('tests_to_run', 'var') || isempty(tests_to_run))
  % Run all tests.
  for (i = 1:length(tc.tests))
    tr = MU_tcase_run_test(tc, tc.tests{i}, mode);
    tresults = [tresults, tr];
  end
else
  % Run specified tests.
  if (ischar(tests_to_run))
    tests_to_run = {tests_to_run};
  elseif (iscellstr(tests_to_run))
    % OK -- do nothing
  else
    error('MUNIT:InvalidArgumentType', ...
          'Argument (tests_to_run) must be string or cell array of strings.');
  end

  % Generate a list of tests.
  test_list = {};
  for (i = 1:length(tc.tests))
    test_list{i} = func2str(tc.tests{i});
  end

  % Run only specified tests from the complete test list.
  for (i = 1:length(tests_to_run))
    j = strmatch(tests_to_run{i}, test_list, 'exact');
    if (j)
      tr = MU_tcase_run_test(tc, tc.tests{j}, mode);
      tresults = [tresults, tr];
    else
      warning([mfilename, ...
               ':  Unknown test (', tests_to_run{i}, ') - Cannot run test.']);
    end
  end

end
  
if (~isempty(tc.pathstr))
  cd(curpath);
end

return
 
