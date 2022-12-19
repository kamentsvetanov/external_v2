function MU_assert_isequalwithequalnans(expected_values, actual_values, message, mode)
% MU_assert_isequalwithequalnans -- Assert that expected and actual values are equal with equal NaNs.
%
%****f* lib.assert/MU_assert_isequalwithequalnans
%
% NAME
%   MU_assert_isequalwithequalnans -- Assert that expected and actual values are equal with equal NaNs.
%
% SYNPOSIS
%   MU_assert_isequalwithequalnans(expected_values, actual_values, [message])
%
% INPUTS
%   * expected_value -- vector or array of expected values (number).
%   * actual_value   --  vector or array of actual values (number).
%   * message        -- (optional) supplemental message (string).
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function checks that expected and actual values are equal, treating
%   NaNs as equals.  If not, it calls MU_fail to throw 
%   MUNIT:AssertionFailedError.
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

%   $Id: MU_assert_isequalwithequalnans.m 111 2005-08-03 00:51:53Z ccornish $

if (exist('mode', 'var') & MU_lookup_mode_num_by_name(mode) >= 5)
  str = ['Asserting that ', inputname(1), ' equals (with equal nans) ', inputname(2), ' ...'];
  disp(str);
end
  
if (isequalwithequalnans(expected_values, actual_values))
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
  msg = [msg, ': Expected value of (', inputname(1), ') ', ...
         'not equal to actual value of (', inputname(2), ').'];

  if (exist('message', 'var') && ~isempty(message))
    msg = [msg, ': ', message]
  end
  
  MU_fail_line(funcname, linenum, msg);

end
    
return
    
