function MU_assert_isempty(actual_value, message, mode)
% MU_assert_isempty -- Assert that actual value is empty.
%
%****f* lib.assert/MU_assert_isempty
%
% NAME
%   MU_assert_isempty -- Assert that actual value is empty.
%
% SYNPOSIS
%   MU_assert_isempty(actual_value, [message])
%
% INPUTS
%   * actual_value   -- actual values (object)
%   * message        -- (optional) supplemental message (character string).
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function checks actual value is empty.
%   If not empty, it calls MU_fail to throw MUNIT:AssertionFailedError.
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
%***

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Apr-27
%
% COPYRIGHT
%   (c) 2004, 2005 Charles R. Cornish
%
% CREDITS
%
%
% REVISION
%   $Revision: 111 $
%

%   $Id: MU_assert_isempty.m 111 2005-08-03 00:51:53Z ccornish $

  if (exist('mode', 'var') & MU_lookup_mode_num_by_name(mode) >= 5)
  str = ['Asserting that ', inputname(1), ' is empty ...'];
  disp(str);
end

if (isempty(actual_value))
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
  msg = [msg, ': Actual value of (', inputname(1), ') is not empty.'];

  if (exist('message', 'var') && ~isempty(message))
    msg = [msg, ': ', message]
  end
  
  MU_fail_line(funcname, linenum, msg);

end
    
return
    
