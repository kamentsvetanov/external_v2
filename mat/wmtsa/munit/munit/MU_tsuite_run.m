function ts_results = MU_tsuite_run(ts, mode, tcases_to_run)
%  MU_tsuite_run -- Run a  test suite.
%
%****f* lib.tsuite/MU_tsuite_run
%
% NAME
%   MU_tsuite_run -- Run a test suite.
%
% SYNOPSIS
%   tr = MU_tsuite_run(ts, [mode], [tests_to_run])
%
% INPUTS
%   * ts              -- a test suite struct (tsuite_s).
%   * mode            -- (optional) mode for level of detail of output.
%   * tests_to_run    -- (optional) name(s) of specific tests to run 
%                        (string or cell array of strings).
%
% OUTPUTS
%   * ts_results -- vector of test suite result structs (ts_result_s).
%
% DESCRIPTION
%   Function runs the test cases in the test suite ts.
%  
%   See MUnit_Variables for a description of mode.
%
%   Note: For all modes, info printed by tested functions is still displayed 
%         to command window.
%
% SEE ALSO
%   mode, MU_tcase_run, MU_print_tresults_report  MU_print_tcase_summary
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
%   2004-04-28
%
% COPYRIGHT
%   (c) 2004, 2005 Charles R. Cornish
%
% CREDITS
%
%
% REVISION
%   $Revision: 103 $
%

%   $Id: MU_tsuite_run.m 103 2005-07-19 01:10:40Z ccornish $

  
if (~exist('mode', 'var') || isempty(mode))
  mode = 'normal';
end

ts_results = [];
tsr = [];  % A ts_result struct

ts_results = MU_ts_results_new;
tsr = MU_ts_results_new;

if (~exist('tcases_to_run', 'var') || isempty(tcases_to_run))
  % Run all tests case.
  for (i = 1:length(ts.tcases))
    tc = ts.tcases(i);
    
    [tresults, tc_summary] = run_and_summarize_tcase(tc, mode);
  
    tsr(1).tcase = tc;
    tsr(1).tresults = tresults;
    tsr(1).tc_summary = tc_summary;
    ts_results = [ts_results, tsr];
  end
else
  % Run specified test cases.
  if (ischar(tcases_to_run))
    tcases_to_run = {tcases_to_run};
  elseif (iscellstr(tcases_to_run))
    % OK -- do nothing
  else
    error('MUNIT:InvalidArgumentType', ...
          'Argument (tcases_to_run) must be string or cell array of strings.');
  end
  % Generate a list of test cases.
  tcase_list = {};
  for (i = 1:length(ts.tcases))
    tcase_list{i} = ts.tcases(i).name;
  end

  % Run only specified tcases from the complete test case list.
  for (i = 1:length(tcases_to_run))
    j = strmatch(tcases_to_run{i}, tcase_list, 'exact');
    if (j)
      tc = ts.tcases(j);
      [tresults, tc_summary] = run_and_summarize_tcase(tc, mode);
      tsr(1).tcase = tc;
      tsr(1).tresults = tresults;
      tsr(1).tc_summary = tc_summary;
      ts_results = [ts_results, tsr];
    else
      warning([mfilename, ...
               ':  Unknown tcase (', tcat_list{i}, ') - Cannot run test.']);
    end
  end
end

return

function tsr = MU_ts_results_new
%  MU_ts_results_new -- Create an empty tsuite results struct.
  tsr = struct('tcase', {}, ...
               'tresults', {}, ...
               'tc_summary', {});
return
  
function [tresults, tc_summary] = run_and_summarize_tcase(tc, mode)
%  run_summarize_tcase -- Run and summarize a test case.
  tresults = MU_tcase_run(tc, mode);
  MU_print_tresults_report(tc.name, tresults, mode);
  
  tc_summary = MU_summarize_tresults(tc, tresults);
  MU_print_tcase_summary(tc_summary, mode);
return
