function MU_print_tresults_report(tcname, tresults, mode)
% MU_print_tresults_report.m  -- Print test case results.
%
%****f* lib.report/MU_print_tresults_report.m
%
% NAME
%   MU_print_tresults_report.m  -- Print test case results.
%
% SYNOPSIS
%   MU_print_tresults_report.m(tresults, [mode])
%
% INPUTS
%   * tcname      -- name of associated test case.
%   * tresults    -- vector of test result structs (tresult_s).
%   * mode        -- (optional) mode for level of detail of output.
%
% OUTPUTS
%   (none)
%
% SIDE EFFECTS
%   Test results printed to command window.
%
% DESCRIPTION
%   Function prints the test results in the tresults vector.
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
%   2004-Nov-16
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 52 $
%

%   $Id: MU_print_tresults_report.m 52 2004-11-17 04:12:02Z ccornish $

switch lower(mode)
 case {'silent'}
  % do nothing
 case {'minimal'}
  % do nothing
 case {'normal'}
  print_tfailures_report_header(tcname);
  nrec = MU_print_tresults(tresults, mode);
  if (nrec == 0)
    disp(['*** No failures or errors ***']);
  end
  print_tfailures_report_footer(tcname);
 case {'verbose', 'details'}
  print_tresults_report_header(tcname);
  nrec = MU_print_tresults(tresults, mode);
  print_tresults_report_footer(tcname);
 case 'details'
  print_tresults_report_header(tcname);
  nrec = MU_print_tresults(tresults, mode);
  print_tresults_report_footer(tcname);
 otherwise
   % Do nothing.
end
  
return

function print_tresults_report_header(tcname)
  disp(' ');
  disp(['*****    Test Results Report for Test Case:  ', tcname, '   *****']);
  disp(' ');
return

  
function print_tresults_report_footer(tcname)
  disp(' ');
  disp(['*****    End Test Results Report for Test Case:  ', tcname, '   *****']);
  disp(' ');
return

function print_tfailures_report_header(tcname)
  disp(' ');
  disp(['*****    Test Failures Report for Test Case:  ', tcname, '   *****']);
  disp(' ');
return

  
function print_tfailures_report_footer(tcname)
  disp(' ');
  disp(['*****    End Test Failures Report for Test Case:  ', tcname, '   *****']);
  disp(' ');
return
