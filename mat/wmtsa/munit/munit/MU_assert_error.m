function MU_assert_error(expected_msg_id, actual_msg_id, message, mode)
% MU_assert_error -- Assert that expected and actual error message ids are equal.
%
%****f* lib.assert/MU_assert_error
%
% NAME
%   MU_assert_error -- Assert that expected and actual error message ids are equal.
%
% SYNOPSIS
%   MU_assert_error(expected_msg_id, actual_msg_id, [message])
%
% INPUTS
%   * expected_msg_id -- expected message id.
%   * actual_msg_id   -- actual message id.
%   * message         -- (optional) supplemental message (string)
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function checks that expected and actual error message ids are equal.  If not,
%   it calls MU_fail to throw MUNIT:AssertionFailedError.
%
% ERRORS
%   MUNIT:AssertionFailedError  (via MU_fail).
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%    MUNIT Library:  Assert Functions
%

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Apr-27
%
% COPYRIGHT
%   (c) Charles R. Cornish 2004, 2005
%
% CREDITS
%
%
% REVISION
%   $Revision: 111 $
%
%***

%   $Id: MU_assert_error.m 111 2005-08-03 00:51:53Z ccornish $

if (exist('mode', 'var') & MU_lookup_mode_num_by_name(mode) >= 5)
  str = ['Asserting error message ids (', expected_msg_id,') and ', ...
        '(', actual_msg_id, ') are equal ...'];
  disp(str);
end
  
  
if (isequal(expected_msg_id, actual_msg_id))
  % Passed test
else
  % Failed test
  [S] = dbstack;
  if (length(S) > 1)
    funcname = S(2).name;
    linenum = S(2).line;
  else
    funcname = '';
    linenum = [];
  end
  msg = mfilename;
  msg = [msg, ': Expected error (', expected_msg_id, ') ', ...
         'not equal to actual error (', actual_msg_id, ').'];

  if (exist('message', 'var') && ~isempty(message))
    msg = [msg, ': ', message]
  end
  
  MU_fail_line(funcname, linenum, msg);

end
    
return
