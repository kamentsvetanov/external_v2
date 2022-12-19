function MU_assert_istrue(actual_value, message, mode)
% MU_assert_istrue -- Assert that actual value is Boolean true.
%
%****f* lib.assert/MU_assert_istrue
%
% NAME
%   MU_assert_istrue -- Assert that actual value is Boolean true.
%
% SYNPOSIS
%   MU_assert_istrue(actual_value, [message])
%
% INPUTS
%   * actual_value   -- actual values (object)
%   * message        -- (optional) supplemental message (character string).
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function checks actual value evaluates to Boolena true.
%   If not, it calls MU_fail to throw MUNIT:AssertionFailedError.
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
%   $Revision: 103 $
%

%   $Id: MU_assert_istrue.m 103 2005-07-19 01:11:06Z ccornish $

if (exist('mode', 'var') & MU_lookup_mode_num_by_name(mode) >= 5)
  str = ['Asserting that ', inputname(1), ' is true ...'];
  disp(str);
end
  
if ~(~actual_value)
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
  msg = [msg, ': Actual value of (', inputname(1), ') is not true.'];

  if (exist('message', 'var') && ~isempty(message))
    msg = [msg, ': ', message]
  end
  
  MU_fail_line(funcname, linenum, msg);

end
    
return
    
