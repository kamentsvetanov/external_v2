function MU_print_tcase_summary(tc_summary, mode)
% MU_print_tcase_summary -- Print a test case summary.
%
%****f* lib.report/MU_print_tcase_summary
%
% NAME
%   MU_print_tcase_summary -- Print a test case summary.
%
% SYNOPSIS
%   MU_print_tcase_summary(tc_summary)
%
% INPUTS
%   tc_summary     = test case summary struct.
%
% OUTPUTS
%   (none)
%
% SIDE EFFECTS
%   Test case summary printed to display or log file.
%
%
% DESCRIPTION
%   Function prints a summary of a test case run.
%
%   See MUnit_Variables for a description of mode.
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
%   2004-Apr-27
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

%   $Id: MU_print_tcase_summary.m 89 2005-02-28 23:47:28Z ccornish $

  
switch(lower(mode))
 case {'minimal', 'normal', 'verbose', 'details'}
  str = ['Summary for Test Case:  ', tc_summary.tcname];
  disp(str);
  str = '';
  str = ['Pass Rate: ', int2str(tc_summary.percentPassed), '%'];
  str = [str, ': ', 'Tests: ', int2str(tc_summary.ntests)];
  str = [str, ', ', 'Failures: ', int2str(tc_summary.nfails)];
  str = [str, ', ', 'Errors: ', int2str(tc_summary.nerrs)];
   disp(str);

 otherwise
   % Do nothing.
end

return
