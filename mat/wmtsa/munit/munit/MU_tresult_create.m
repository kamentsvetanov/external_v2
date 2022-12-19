function tr = MU_tresult_create(tcname, tfh)
% MU_tresult_create -- Create a new test result struct (tresult_s).
%
%****f* lib.report/MU_tresult_create
%
% NAME
%   MU_tresult_create -- Create a new test result struct (tresult_s).
%
% SYNPOSIS
%   tr = MU_tresult_create(tcname, tfh)
%
% INPUTS
%   * tcname      -- name of test case associated with test result (string).
%   * tfh         -- function handle of test associated with test result (@tfh).
%
% OUTPUTS
%   * tr          -- test result struct (tresult_s).
%
% DESCRIPTION
%   Function creates and initializes a test result struct (tresult_s).
%
%   Test result struct has the following fields:
%     * trstatus -- result of test execution.
%     * tcname   -- name of associated test case.
%     * testfh   -- function handle of test.
%     * message  -- supplementary message associated with test execution.
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
%   $Revision: 83 $
%

%   $Id: MU_tresult_create.m 83 2005-02-15 01:02:14Z ccornish $

tr.trstatus = NaN;
tr.tcname = tcname;
tr.testfh = tfh;
tr.message = '';

return
