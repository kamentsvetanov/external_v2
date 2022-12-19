function tc_summary = MU_summarize_tresults(tc, tresults)
% MU_summarize_tresults -- Summarize a set of test results.
%
%****f* lib.report/MU_summarize_tresults
%
% NAME
%   MU_summarize_tresults -- Summarize a set of test results.
%
% SYNOPSIS
%   tc_summary = MU_summarize_tresults(tresults)
%
% INPUTS
%   * tc          -- test case struct (tcase_s).
%   * tresults    -- vector of test result structs (tresult_s).
%
% OUTPUTS
%   * tc_summary   -- test case summary struct (tc_summary_s).
%
% DESCRIPTION
%   Function summarizes the results of the test results in the
%   tresults vector and returns summary in test result summary struct.
%   
%   Test result summary struct (tc_summary_s) struct has the following fields:
%   * tcname  -- name of associated test case
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
% SEE ALSO
%
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   MUNIT Library:  Reporting Functions
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
%   $Revision: 97 $
%

%   $Id: MU_summarize_tresults.m 97 2005-07-13 23:39:25Z ccornish $

tcname = tc.name;
  
tc_summary.tcname = tcname;
tc_summary.ntests = 0;
tc_summary.npass = 0;
tc_summary.nfails = 0;
tc_summary.nerrs = 0;
tc_summary.percentPassed = 0;
tc_summary.failedTests = {};
tc_summary.failedTestNums = [];
tc_summary.erroredTests  = {};
tc_summary.erroredTestNums  = [];
tc_summary.elapsedWallTime = NaN;
tc_summary.elapsedCPUTime = NaN;


% Generate ordinal test numbers.
test_name_list = {};
for (i = 1:length(tc.tests))
    test_num_list{i} = i;
    test_name_list{i} = func2str(tc.tests{i});
end


for (i = 1:length(tresults))
  tc_summary.ntests = tc_summary.ntests + 1;
  tr = tresults(i);
  test_name = func2str(tr.testfh);
  test_num = test_num_list{strmatch(test_name, test_name_list, 'exact')};
  switch(tr.trstatus)
   case MU_lookup_tresult_status_by_name('SUCCESS');
    % pass
    tc_summary.npass = tc_summary.npass + 1;
   case MU_lookup_tresult_status_by_name('FAIL');
    % fail
    tc_summary.nfails = tc_summary.nfails + 1;
    tc_summary.failedTests{tc_summary.nfails} = func2str(tr.testfh);
    tc_summary.failedTestNums(tc_summary.nfails) = test_num;
   case MU_lookup_tresult_status_by_name('ERROR');
    % error
    tc_summary.nerrs = tc_summary.nerrs + 1;
    tc_summary.erroredTests{tc_summary.nerrs} = func2str(tr.testfh);
    tc_summary.erroredTestNums(tc_summary.nerrs) = test_num;
   otherwise
  end
  
  tc_summary.percentPassed = 100 * (tc_summary.npass / tc_summary.ntests);
  
end
  
return
