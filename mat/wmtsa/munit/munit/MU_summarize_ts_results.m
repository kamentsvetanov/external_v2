function ts_summary = MU_summarize_ts_results(tsname, ts_results)
% MU_summarize_ts_results -- Summarize the test suite results.
%
%****f* lib.report/MU_summarize_ts_results
%
% NAME
%    MU_summarize_ts_results -- Summarize the test suite results.
%
% SYNOPSIS
%   ts_summary = MU_summarize_ts_results(ts_results)
%
% INPUTS
%   * tcname     -- name of associated test suite.
%   * ts_results -- vector of test suite result structs (ts_result_s).
%
% OUTPUTS
%   * ts_summary -- a test suite summary struct (ts_summary_s).
%
% DESCRIPTION
%   Function summarizes the test case summaries contained in the ts_results 
%   vector and returns the test suite summary in ts_summary struct.
%   
%   Test suite summary struct (ts_summary_s) has the following fields:
%     * tsname  -- name of associated test suite.
%     * ntcases -- number of test cases.
%     * ntests  -- number of tests run.
%     * npass   -- number of tests passed.
%     * nfails  -- number of test failed.
%     * nerrs   -- number of tests returning errors.
%     * percentPassed -- percent of tests passed.
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
%   $Revision: 89 $
%

%   $Id: MU_summarize_ts_results.m 89 2005-02-28 23:47:28Z ccornish $

ts_summary.tsname = tsname;

ntcases = 0;
ntests = 0;
npass = 0;
nfails = 0;
nerrs = 0;
percentPassed = 0;


for (i = 1:length(ts_results))
  tsr = ts_results(i);    % A ts_result struct
  ntcases = ntcases + 1;
  ntests = ntests + tsr.tc_summary.ntests;
  npass = npass + tsr.tc_summary.npass;
  nfails = nfails + tsr.tc_summary.nfails;
  nerrs = nerrs + tsr.tc_summary.nerrs;
end
  
percentPassed = 100 * (npass / ntests);
  
ts_summary.ntcases = ntcases;
ts_summary.ntests = ntests;
ts_summary.npass = npass;
ts_summary.nfails = nfails;
ts_summary.nerrs = nerrs;
ts_summary.percentPassed = percentPassed;
  
return
