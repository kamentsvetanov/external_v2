function tr = MU_tcase_run_test(tc, tfh, mode)
% MU_tcase_run_test -- Run specified test within a test case.
%
%****f* lib.tcase/MU_tcase_run_test
%
% NAME
%   MU_tcase_run_test -- Run specified test within a test case.
%
% SYNOPSIS
%   tr = MU_tcase_run_test(tc, tfh, [mode])
%
% INPUTS
%   * tc         -- a loaded test case struct (tcase_s).
%   * tfh        -- function handle to test function.
%   * mode       -- (optional) mode for level of detail of output.
%
% OUTPUTS
%   * tr         -- a test result struct (tresult_s).
%
% DESCRIPTION
%   Function runs a specified test for test case.
%  
%   See MUnit_Variables for a description of mode.
%
% SEE ALSO
%   mode, MU_tresult_create, MU_lookup_tresult_status_by_name
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
%   $Revision: 111 $
%

%   $Id: MU_tcase_run_test.m 111 2005-08-03 00:51:53Z ccornish $

if (~exist('mode', 'var') || isempty(mode))
  mode = 'normal';
end

tr = MU_tresult_create(tc.name, tfh);

if (strcmpi(mode, 'details'))
  disp(['Running test: ', func2str(tfh), '...']);
end

try

  feval(tfh, mode);
  tr.trstatus = MU_lookup_tresult_status_by_name('SUCCESS');

catch

  [errmsg, msg_id] = lasterr;

  % If stoponerror mode, re-run the test to display the stack leadding up
  % to the error.
  if (strcmp(mode, 'stoponerror'))
    feval(tfh,mode);
    % Should not reach here after re-running error, but just in case
    % throw an error.
    error('MUnit:MU_tcase_run_test:RunTestError', ...
          ['Error encountered while re-running test case ', ...
           '(', func2str, ').']);
  end
  
  switch(msg_id)
   case 'MUNIT:AssertionFailedError'
    tr.trstatus = MU_lookup_tresult_status_by_name('FAIL');
    tr.message = errmsg;
   otherwise
    tr.trstatus = MU_lookup_tresult_status_by_name('ERROR');
    tr.message = errmsg;
    disp([' *** Error occurred while running test: ', ...
          func2str(tfh), ...
          ',  errmsg:  ', ...
          errmsg]);
  end

end

switch lower(mode)
 case 'details'
  status_name = lookup_tresult_name_by_trstatus(tr.trstatus);
  disp(['Test Result: ', func2str(tfh), ':  ', status_name]);
 otherwise
end


return


function name = lookup_tresult_name_by_trstatus(trstatus)

  switch trstatus
   case 1
    name = 'SUCCESS';
   case 0
    name = 'FAIL';
   case -1
    name = 'ERROR';
   otherwise
    name = '';
  end

return
  
