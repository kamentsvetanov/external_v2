function MU_print_tsuite_summary(ts_summary, mode)
% MU_print_tsuite_summary  -- Print summary for a test suite.
%
%****f* lib.report/MU_print_tsuite_summary
%
% NAME
%    MU_print_tsuite_summary  -- Print summary for a test suite.
%
% SYNOPSIS
%   MU_tcase_print_summary(ts, [mode])
%
% INPUTS
%   * ts          -- a test suite struct (tsuite_s).
%   * mode        -- (optional) mode for level of detail of output.
%
% OUTPUTS
%   * ts_summary -- a test suite summary struct (ts_summary_s).
%
% SIDE EFFECTS
%   Test suite summary displayed or printed to log file.
%
% DESCRIPTION
%   Function prints the summary for test suite.
%
%   See MUnit_Variables for a description of mode.
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

%   $Id: MU_print_tsuite_summary.m 89 2005-02-28 23:47:28Z ccornish $

if (strcmpi(mode, 'silent'))
  return
end

tsname = ts_summary.tsname;

ntcases = ts_summary.ntcases;
ntests  = ts_summary.ntests;
npass   = ts_summary.npass;
nfails  = ts_summary.nfails;
nerrs   = ts_summary.nerrs;
percentPassed = ts_summary.percentPassed;

disp(['***** Summary Report for Test Suite:  ', tsname, ' *****']);

  str = '';
  str = [str, int2str(percentPassed), '%'];
  str = [str, ', ', 'TCases: ', int2str(ntcases)];
  str = [str, ', ', 'Tests: ', int2str(ntests)];
  str = [str, ', ', 'Pass: ', int2str(npass)];
  str = [str, ', ', 'Failures: ', int2str(nfails)];
  str = [str, ', ', 'Errors: ', int2str(nerrs)];
  
  disp(str);
  
return
  
  
