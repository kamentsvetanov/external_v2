function MU_assert_expression(expression, message, mode)
% MU_assert_expression -- Assert that expression is true.
%
%****f* lib.assert/MU_assert_expression
%
% NAME
%   MU_assert_expression -- Assert that expression is true.
%
% SYNPOSIS
%   MU_assert_expression(expression, [message])
%
% INPUTS
%   * expression     -- expression to evaluate (string).
%   * message        -- (optional) supplemental message (string).
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function evaluates the expression in the caller's workspace and
%   evaluates whether it is true or not.
%   If not true, it calls MU_fail to throw MUNIT:AssertionFailedError.
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
%   2005-07-19
%
% COPYRIGHT
%   (c) 2005 Charles R. Cornish
%
% CREDITS
%
%
% REVISION
%   $Revision: 103 $
%

%   $Id: MU_assert_expression.m 103 2005-07-19 01:11:06Z ccornish $

if (exist('mode', 'var') & MU_lookup_mode_num_by_name(mode) >= 5)
  str = ['Asserting expression (', expression, ') is true ...'];
  disp(str);
end
  
tf = evalin('caller', expression);  
  
if (tf)
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
  msg = [msg, ': Expression (', expression, ') is not true.'];

  if (exist('message', 'var') && ~isempty(message))
    msg = [msg, ': ', message]
  end
  
  MU_fail_line(funcname, linenum, msg);

end
    
return
    
