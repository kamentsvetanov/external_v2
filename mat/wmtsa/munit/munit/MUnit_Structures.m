%****s* MUnit-API/Structures
%
% NAME
%   MUnit Structures -- structs used in MUnit.
%
% DESCRIPTION
%   MATLAB struts used in MUnit.
%
% TOOLBOX
%    munit/munit
%
% CATEGORY
%
%
%***
%****s* Structures/tcase_s
%
% NAME
%   tcase_s -- test case structure.
%
% DESCRIPTION
%   tcase_s struct has fields:
%   * name     -- name of test case (string)
%   * pathstr  -- optional path to location of tcase mfile (string).
%   * tests    -- cell array of function handles to test functions (@tfh).
%   * tresults -- test case results (vector of tresult_s).
%
%   The MU_tcase_new function creates and initializes an empty tcase_s struct.
%
% SEE ALSO
%   MU_tcase_new
%   
%***
%****s* Structures/tsuite_s
%
% NAME
%   tsuite_s -- test suite structure.
%
% DESCRIPTION
%   tsuite_s struct has fields:
%   * name         -- name of test suite (string).
%   * pathstr      -- optional path to location of tsuite mfile (string).
%   * tcases       -- vector of test case structures (tcase_s).
%   * trsummaries  -- optional path to location of tcase mfile (string).
%
%   The MU_tsuite_new function creates and initializes an empty tsuite_s struct.
%
% SEE ALSO
%   MU_tsuite_new
%
%***
%****s* Structures/tresult_s
%
% NAME
%   tresult_s -- test result structure.
%
% DESCRIPTION
%   tresult_s struct contains the results of an executed test and has
%   the following fields:
%     * trstatus -- test result status code.
%     * tcname   -- name of associated test case.
%     * testfh   -- function handle of test.
%     * message  -- supplementary message associated with test execution.
%***
%****s* Structures/tc_summary_s
%
% NAME
%   tc_summary_s -- test case summary struct.
%
% DESCRIPTION
%   The test result summary struct (tc_summary_s) summarizes the execution of
%   tests in a test case and has the following fields:
%   * ntests  -- number of tests run
%   * npass   -- number of tests passed
%   * nfails  -- number of test failed
%   * nerrs   -- number of tests returning errors
%   * percentPassed -- percent of tests passed
%   * failedTests -- list of failed tests (cell string array)
%   * failedTestNums -- ordinal number of the failed test in test case (vector).
%   * erroredTests -- list of tests that errored (cell string array)
%   * erroredTestNums -- ordinal number of the erroed test in test case (vector).
%   * elapsedWallTime -- elapsed wall time to run test case
%   * elapsedCPUTime -- elapsed cpu time to run test case.
%
%   The MU_summarize_tresults function creates a tc_summary_s struct
%   and updates all fields, except elapsedwalltime and elapsedcputime.
%
% SEE ALSO
%   MU_summarize_tresults 
%
%***
%****s* Structures/ts_result_s
%
% NAME
%   ts_result_s -- test suite result structure.
%
% DESCRIPTION
%   tresult_s struct contains the results of an executed test suite and has
%   the following fields:
%     * tcase      -- name of associated test case.
%     * tresults   -- vector of tresult_s structs for associated test case.
%     * tc_summary -- tc_summary_s struct for associated test case.
%***
%****s* Structures/ts_summary_s
%
% NAME
%   ts_summary_s -- test suite summary struct.
%
% DESCRIPTION
%   The test result summary struct (ts_summary_s) summarizes the execution of
%   tests in a suite of test cases and has the following fields:
%     * tsname  -- name of test suite.
%     * ntcases -- number of test cases run.
%     * ntests  -- number of tests run.
%     * npass   -- number of tests passed.
%     * nfails  -- number of test failed.
%     * nerrs   -- number of tests returning errors.
%     * percentPassed -- percent of tests passed.
%
%***

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%
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

%   $Id: MUnit_Structures.m 112 2005-09-13 05:53:51Z ccornish $

