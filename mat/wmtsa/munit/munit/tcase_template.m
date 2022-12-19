function tc = XXX_tcase
% XXX_tcase -- munit test case to test XXX.
%
%****f*  toolbox.subdirectory/XXX
%
% NAME
%   XXX_tcase -- munit test case to test XXX.
%
% USAGE
%   run_tcase('XXX_tcase')
%
% INPUTS
%
%
% OUTPUTS
%   tc            = tcase structure for XXX testcase.
%
% SIDE EFFECTS
%
%
% DESCRIPTION
%
%
% SEE ALSO
%   XXX
%
  
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
%   $Revision$
%
%***

%   $Id$

  
tc = MU_tcase_new(mfilename);

tc = MU_tcase_add_test(tc, @test_normal_default);
tc = MU_tcase_add_test(tc, @test_insufficient_num_arguments);
tc = MU_tcase_add_test(tc, @test_YYY);

return

function test_normal_default(mode)
  % Test Description:  
  %    Smoke test:  Normal execution, default parameters
    
  % Insert default function call
return

function test_insufficient_num_arguments(mode)
  % Test Description:  
  %    Expected error: WMTSA:InvalidNumArguments
  try
    % Insert function call
  catch
    [errmsg, msg_id] = lasterr;
    MU_assert_error('MATLAB:nargchk:notEnoughInputs', msg_id);
  end
return

function test_YYY(mode)
  % Test Description:  
  %    
return

function test_YYY_assert_error(mode)
  % Test Description:  
  %    Expected error:  YYYY
  try
    % function to try
  catch
    [errmsg, msg_id] = lasterr;
    MU_assert_error(Expected_msg_id, msg_id);
  end
return
